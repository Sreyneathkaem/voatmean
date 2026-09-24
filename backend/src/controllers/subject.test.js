process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));
jest.mock("../config/mongo", () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
  },
}));

const { getSubjects, createSubject, updateSubject } = require("./subject.controller");
const db = require("../config/db");
const { AuditLog } = require("../config/mongo");

describe("Subject Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      params: {},
      body: {},
      user: { user_id: "admin-1", role: "admin" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getSubjects", () => {
    it("returns array of subjects ordered by name", async () => {
      const mockSubjects = [
        { subject_id: "s1", subject_name: "Khmer" },
        { subject_id: "s2", subject_name: "Mathematics" },
      ];
      db.query.mockResolvedValueOnce({ rows: mockSubjects });

      await getSubjects(req, res, next);

      expect(db.query).toHaveBeenCalledWith(expect.stringContaining("SELECT subject_id, subject_name"));
      expect(res.json).toHaveBeenCalledWith(mockSubjects);
    });

    it("forwards error to next() on failure", async () => {
      const err = new Error("DB Failure");
      db.query.mockRejectedValueOnce(err);

      await getSubjects(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("createSubject", () => {
    it("returns 400 when subject_name is missing", async () => {
      req.body = {};

      await createSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "subject_name is required" });
    });

    it("returns 400 when no school exists and school_id is omitted", async () => {
      req.body = { subject_name: "Physics" };
      db.query.mockResolvedValueOnce({ rows: [] }); // getDefaultSchoolId returns null

      await createSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "No school exists yet — create one first" });
    });

    it("creates subject successfully with resolved school_id", async () => {
      req.body = { subject_name: "Physics" };
      db.query.mockResolvedValueOnce({ rows: [{ school_id: "school-1" }] }); // getDefaultSchoolId
      db.query.mockResolvedValueOnce({
        rows: [{ subject_id: "s3", subject_name: "Physics", school_id: "school-1" }],
      });

      await createSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        subject_id: "s3",
        subject_name: "Physics",
        school_id: "school-1",
      });
      expect(AuditLog.create).toHaveBeenCalledWith(
        expect.objectContaining({ event_type: "subject_created" }),
      );
    });

    it("returns 409 when subject already exists", async () => {
      req.body = { subject_name: "Mathematics", school_id: "school-1" };
      db.query.mockResolvedValueOnce({ rows: [] }); // ON CONFLICT DO NOTHING returns empty

      await createSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(409);
      expect(res.json).toHaveBeenCalledWith({ error: "Subject already exists" });
    });

    it("forwards error to next() on failure", async () => {
      req.body = { subject_name: "Biology", school_id: "school-1" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await createSubject(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("updateSubject", () => {
    it("returns 400 when subject_name is missing", async () => {
      req.params = { subjectId: "s1" };
      req.body = {};

      await updateSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "subject_name is required" });
    });

    it("returns 404 when subject is not found", async () => {
      req.params = { subjectId: "nonexistent" };
      req.body = { subject_name: "Advanced Chemistry" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await updateSubject(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Subject not found" });
    });

    it("updates subject successfully and logs audit event", async () => {
      req.params = { subjectId: "s1" };
      req.body = { subject_name: "Advanced Chemistry" };
      const updated = { subject_id: "s1", subject_name: "Advanced Chemistry" };
      db.query.mockResolvedValueOnce({ rows: [updated] });

      await updateSubject(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
      expect(AuditLog.create).toHaveBeenCalledWith(
        expect.objectContaining({ event_type: "subject_updated" }),
      );
    });

    it("forwards error to next() on failure", async () => {
      req.params = { subjectId: "s1" };
      req.body = { subject_name: "Advanced Chemistry" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await updateSubject(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
