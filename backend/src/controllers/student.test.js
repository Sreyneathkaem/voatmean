process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));

const { getStudentsByClass, addStudent, updateStudent } = require("./student.controller");
const db = require("../config/db");

describe("Student Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      params: {},
      body: {},
      user: { user_id: "teacher-1", role: "teacher" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getStudentsByClass", () => {
    it("returns array of students for a given classId", async () => {
      req.params = { classId: "class-1" };
      const students = [
        { student_id: "st1", roll_number: "1", full_name: "Sok Dara" },
        { student_id: "st2", roll_number: "2", full_name: "Chan Bopha" },
      ];
      db.query.mockResolvedValueOnce({ rows: students });

      await getStudentsByClass(req, res, next);

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("WHERE course_id = $1"),
        ["class-1"],
      );
      expect(res.json).toHaveBeenCalledWith(students);
    });

    it("forwards error to next() on failure", async () => {
      req.params = { classId: "class-1" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getStudentsByClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("addStudent", () => {
    it("creates a new student and infers majorId from class if not passed", async () => {
      req.params = { classId: "class-1" };
      req.body = {
        roll_number: "3",
        full_name: "Keo Voleak",
        gender: "F",
        date_of_birth: "2008-05-12",
        phone_number: "012345678",
      };

      db.query.mockResolvedValueOnce({ rows: [{ major_id: "major-science" }] }); // course major lookup
      db.query.mockResolvedValueOnce({
        rows: [{ student_id: "st3", ...req.body, major_id: "major-science", course_id: "class-1" }],
      });

      await addStudent(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ student_id: "st3", full_name: "Keo Voleak" }),
      );
    });

    it("uses major_id provided in body if present", async () => {
      req.params = { classId: "class-1" };
      req.body = {
        roll_number: "4",
        full_name: "Meng Heng",
        gender: "M",
        date_of_birth: "2008-01-01",
        phone_number: "098765432",
        major_id: "custom-major",
      };

      db.query.mockResolvedValueOnce({
        rows: [{ student_id: "st4", ...req.body, course_id: "class-1" }],
      });

      await addStudent(req, res, next);

      expect(db.query).toHaveBeenCalledTimes(1); // Didn't need course query for major
      expect(res.status).toHaveBeenCalledWith(201);
    });

    it("forwards error to next() on failure", async () => {
      req.params = { classId: "class-1" };
      req.body = { roll_number: "5" };
      const err = new Error("DB Constraint Fail");
      db.query.mockRejectedValueOnce(err);

      await addStudent(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("updateStudent", () => {
    it("updates student details and returns updated record", async () => {
      req.params = { studentId: "st1" };
      req.body = {
        roll_number: "10",
        full_name: "Sok Dara Updated",
        gender: "M",
        date_of_birth: "2008-02-14",
        phone_number: "011223344",
      };

      const updated = { student_id: "st1", ...req.body };
      db.query.mockResolvedValueOnce({ rows: [updated] });

      await updateStudent(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
    });

    it("returns 404 when student is not found", async () => {
      req.params = { studentId: "nonexistent" };
      req.body = {
        roll_number: "10",
        full_name: "Ghost",
        gender: "M",
        date_of_birth: "2000-01-01",
        phone_number: "000",
      };

      db.query.mockResolvedValueOnce({ rows: [] });

      await updateStudent(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Student not found" });
    });

    it("forwards error to next() on failure", async () => {
      req.params = { studentId: "st1" };
      req.body = { roll_number: "1" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await updateStudent(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
