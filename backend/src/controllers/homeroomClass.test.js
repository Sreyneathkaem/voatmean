const {
  getHomeroomClasses,
  getHomeroomClass,
  createHomeroomClass,
  updateHomeroomClass,
  getHomeroomClassStudents,
  addStudentToHomeroomClass,
  removeStudentFromHomeroomClass,
} = require("./homeroomClass.controller");
const db = require("../config/db");

// Mock dependencies
jest.mock("../config/db", () => ({
  query: jest.fn(),
}));
jest.mock("../config/mongo", () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
  },
}));

describe("Homeroom Class Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = { params: {}, body: {}, user: { user_id: "admin-1", role: "admin" } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getHomeroomClasses", () => {
    it("should return a list of classes", async () => {
      const mockClasses = [{ class_id: "c1", class_name: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: mockClasses });

      await getHomeroomClasses(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockClasses);
    });

    it("forwards error to next()", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getHomeroomClasses(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getHomeroomClass", () => {
    it("returns class when found", async () => {
      req.params.classId = "c1";
      const cls = { class_id: "c1", class_name: "Grade 10A" };
      db.query.mockResolvedValueOnce({ rows: [cls] });

      await getHomeroomClass(req, res, next);

      expect(res.json).toHaveBeenCalledWith(cls);
    });

    it("returns 404 when class not found", async () => {
      req.params.classId = "nonexistent";
      db.query.mockResolvedValueOnce({ rows: [] });

      await getHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("forwards error to next()", async () => {
      req.params.classId = "c1";
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getHomeroomClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("createHomeroomClass", () => {
    it("should return 400 if class_name is missing", async () => {
      req.body = { academic_year_id: "2026-2027" };
      await createHomeroomClass(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should return 400 if school does not exist", async () => {
      req.body = { class_name: "10A" };
      db.query.mockResolvedValueOnce({ rows: [] }); // getDefaultSchoolId -> null

      await createHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "No school exists yet — create one first" });
    });

    it("should create class with teacher and subject slots", async () => {
      req.body = {
        class_name: "10A",
        academic_year_id: "2026-2027",
        school_id: "school-1",
        homeroom_teacher_id: "teacher-1",
        subject_id: "sub-1",
        hours_per_week: 2,
      };

      db.query
        .mockResolvedValueOnce({ rows: [{ class_id: "c1", class_name: "10A" }] }) // insert class
        .mockResolvedValue({ rows: [] }); // insert timetable slots

      await createHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ class_name: "10A" }));
    });

    it("should fallback to first subject when subject_id is not passed", async () => {
      req.body = {
        class_name: "10B",
        school_id: "school-1",
        homeroom_teacher_id: "teacher-1",
      };

      db.query
        .mockResolvedValueOnce({ rows: [{ class_id: "c2", class_name: "10B" }] }) // insert class
        .mockResolvedValueOnce({ rows: [{ subject_id: "sub-default" }] }) // select subject
        .mockResolvedValue({ rows: [] }); // timetable inserts

      await createHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
    });

    it("forwards error to next() on insert failure", async () => {
      req.body = { class_name: "10C", school_id: "s1" };
      const err = new Error("DB error");
      db.query.mockRejectedValueOnce(err);

      await createHomeroomClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("updateHomeroomClass", () => {
    it("returns 404 when class not found", async () => {
      req.params.classId = "c-unknown";
      req.body = { class_name: "Grade 11A" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await updateHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("updates class successfully", async () => {
      req.params.classId = "c1";
      req.body = { class_name: "Grade 10B", grade_level: "10" };
      const updated = { class_id: "c1", class_name: "Grade 10B", grade_level: "10" };
      db.query.mockResolvedValueOnce({ rows: [updated] });

      await updateHomeroomClass(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
    });

    it("forwards error to next()", async () => {
      req.params.classId = "c1";
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await updateHomeroomClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getHomeroomClassStudents", () => {
    it("returns students in class", async () => {
      req.params.classId = "c1";
      const students = [{ student_id: "s1", full_name: "Piseth" }];
      db.query.mockResolvedValueOnce({ rows: students });

      await getHomeroomClassStudents(req, res, next);

      expect(res.json).toHaveBeenCalledWith(students);
    });

    it("forwards error to next()", async () => {
      req.params.classId = "c1";
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getHomeroomClassStudents(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("addStudentToHomeroomClass", () => {
    it("returns 400 if student_ids and student_id are missing", async () => {
      req.params.classId = "c1";
      req.body = {};

      await addStudentToHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should enroll multiple students", async () => {
      req.params.classId = "class-1";
      req.body = { student_ids: ["s1", "s2"] };

      db.query.mockResolvedValue({ rows: [{ class_id: "class-1" }] });

      await addStudentToHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ newly_enrolled_count: 2 }));
    });

    it("should handle single student_id", async () => {
      req.params.classId = "class-1";
      req.body = { student_id: "s1" };
      db.query.mockResolvedValueOnce({ rows: [{ class_id: "class-1" }] });

      await addStudentToHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ newly_enrolled_count: 1 }));
    });

    it("forwards error to next()", async () => {
      req.params.classId = "class-1";
      req.body = { student_id: "s1" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await addStudentToHomeroomClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("removeStudentFromHomeroomClass", () => {
    it("returns 404 if student not in class", async () => {
      req.params = { classId: "c1", studentId: "s1" };
      db.query.mockResolvedValueOnce({ rowCount: 0 });

      await removeStudentFromHomeroomClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("removes student successfully", async () => {
      req.params = { classId: "c1", studentId: "s1" };
      db.query.mockResolvedValueOnce({ rowCount: 1 });

      await removeStudentFromHomeroomClass(req, res, next);

      expect(res.json).toHaveBeenCalledWith({ removed: true });
    });

    it("forwards error to next()", async () => {
      req.params = { classId: "c1", studentId: "s1" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await removeStudentFromHomeroomClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
