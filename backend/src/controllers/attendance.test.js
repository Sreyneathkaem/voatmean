process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
  getClient: jest.fn(),
}));
jest.mock("../config/mongo", () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
    insertMany: jest.fn().mockResolvedValue({}),
  },
}));

const {
  createSession,
  getSessionAttendance,
  saveSessionAttendance,
  getAttendanceByDate,
  saveAttendance,
  remarkAttendance,
  getHistory,
  listSessions,
} = require("./attendance.controller");

const db = require("../config/db");
const { AuditLog } = require("../config/mongo");

describe("Attendance Controller", () => {
  let req, res, next, mockClient;

  beforeEach(() => {
    req = {
      params: {},
      body: {},
      query: {},
      user: { user_id: "u-teacher", role: "teacher", full_name: "Teacher Sok" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();

    mockClient = {
      query: jest.fn(),
      release: jest.fn(),
    };
    db.getClient.mockResolvedValue(mockClient);

    jest.clearAllMocks();
  });

  describe("createSession", () => {
    it("returns 400 if session_date is missing", async () => {
      req.params = { classId: "c1" };
      req.body = {};

      await createSession(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "session_date is required" });
    });

    it("creates a course session successfully", async () => {
      req.params = { classId: "c1" };
      req.body = { session_date: "2026-09-01", session_name: "Morning Session" };

      const created = { session_id: "sess-1", session_name: "Morning Session", session_date: "2026-09-01" };
      db.query.mockResolvedValueOnce({ rows: [created] });

      await createSession(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(created);
    });

    it("forwards error to next() on failure", async () => {
      req.params = { classId: "c1" };
      req.body = { session_date: "2026-09-01" };
      const err = new Error("DB Failure");
      db.query.mockRejectedValueOnce(err);

      await createSession(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getSessionAttendance", () => {
    it("returns 403 if session does not exist or user lacks access", async () => {
      req.params = { sessionId: "s-invalid" };
      db.query.mockResolvedValueOnce({ rows: [] }); // session verify query

      await getSessionAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({ error: "You can only access your own session" });
    });

    it("returns student attendance roster for authorized session", async () => {
      req.params = { sessionId: "s1" };
      db.query.mockResolvedValueOnce({
        rows: [{ session_id: "s1", course_id: "c1", teacher_id: "u-teacher" }],
      });
      const students = [{ student_id: "std1", full_name: "Student A", status: "present" }];
      db.query.mockResolvedValueOnce({ rows: students });

      await getSessionAttendance(req, res, next);

      expect(res.json).toHaveBeenCalledWith(students);
    });
  });

  describe("saveAttendance", () => {
    it("returns 400 when class_id, date, or records[] are missing", async () => {
      req.body = { class_id: "c1", date: "2026-09-01", records: [] };

      await saveAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "class_id, date, and records[] are required" });
    });

    it("returns 403 if teacher does not teach the class", async () => {
      req.body = {
        class_id: "c1",
        date: "2026-09-01",
        records: [{ student_id: "s1", status: "present" }],
      };
      db.query.mockResolvedValueOnce({ rows: [] }); // teacher check

      await saveAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        error: "You can only mark attendance for your own class",
      });
    });

    it("saves attendance successfully inside transaction", async () => {
      req.body = {
        class_id: "c1",
        date: "2026-09-01",
        records: [{ student_id: "s1", status: "present" }],
      };

      // Teacher ownership query
      db.query.mockResolvedValueOnce({ rows: [{ course_id: "c1" }] });

      // Transaction queries inside mockClient:
      // 1. BEGIN
      mockClient.query.mockResolvedValueOnce({});
      // 2. getOrCreateSession check
      mockClient.query.mockResolvedValueOnce({ rows: [{ session_id: "sess-1" }] });
      // 3. session_attendance_records INSERT
      mockClient.query.mockResolvedValueOnce({ rows: [{ record_id: "r1", student_id: "s1", status: "present" }] });
      // 4. attendance_records INSERT
      mockClient.query.mockResolvedValueOnce({});
      // 5. COMMIT
      mockClient.query.mockResolvedValueOnce({});

      await saveAttendance(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith("BEGIN");
      expect(mockClient.query).toHaveBeenCalledWith("COMMIT");
      expect(mockClient.release).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ saved: 1 }),
      );
    });

    it("rolls back transaction on error", async () => {
      req.body = {
        class_id: "c1",
        date: "2026-09-01",
        records: [{ student_id: "s1", status: "present" }],
      };
      db.query.mockResolvedValueOnce({ rows: [{ course_id: "c1" }] });

      mockClient.query.mockResolvedValueOnce({}); // BEGIN
      const err = new Error("DB Error in transaction");
      mockClient.query.mockRejectedValueOnce(err); // Session query fails

      await saveAttendance(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith("ROLLBACK");
      expect(mockClient.release).toHaveBeenCalled();
      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("remarkAttendance", () => {
    it("returns 404 when record is not found", async () => {
      req.params = { recordId: "nonexistent" };
      req.body = { status: "excused", reason: "Medical" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await remarkAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Record not found" });
    });

    it("remarks attendance record and logs audit event", async () => {
      req.params = { recordId: "rec-1" };
      req.body = { status: "present", reason: "Teacher Correction" };
      req.user = { user_id: "admin-1", role: "admin" };

      db.query.mockResolvedValueOnce({ rows: [{ record_id: "rec-1", status: "absent" }] }); // old
      const updated = { record_id: "rec-1", student_id: "s1", date: "2026-09-01", status: "present" };
      db.query.mockResolvedValueOnce({ rows: [updated] }); // update

      await remarkAttendance(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
      expect(AuditLog.create).toHaveBeenCalledWith(
        expect.objectContaining({ event_type: "attendance_remark" }),
      );
    });
  });

  describe("getAttendanceByDate", () => {
    it("returns attendance records for a class on a specific date", async () => {
      req.params = { classId: "c1", date: "2026-09-01" };
      const records = [{ student_id: "s1", status: "present" }];
      db.query.mockResolvedValueOnce({ rows: records });

      await getAttendanceByDate(req, res, next);

      expect(res.json).toHaveBeenCalledWith(records);
    });
  });

  describe("getHistory", () => {
    it("returns attendance history records", async () => {
      req.params = { classId: "c1" };
      req.query = { from: "2026-09-01", to: "2026-09-30" };
      const history = [{ record_id: "r1", date: "2026-09-01", status: "present" }];
      db.query.mockResolvedValueOnce({ rows: history });

      await getHistory(req, res, next);

      expect(res.json).toHaveBeenCalledWith(history);
    });
  });

  describe("listSessions", () => {
    it("returns list of course sessions with done state", async () => {
      req.params = { classId: "c1" };
      const sessions = [{ session_id: "sess-1", session_name: "Session 1", is_done: true }];
      db.query.mockResolvedValueOnce({ rows: sessions });

      await listSessions(req, res, next);

      expect(res.json).toHaveBeenCalledWith(sessions);
    });
  });
});
