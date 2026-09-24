process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));

const {
  getDashboard,
  getDashboardExport,
  getTeachers,
  getAcademicYears,
  getMajors,
  getStudentsByMajor,
  getTerms,
  createTerm,
  createTeacher,
  getClasses,
  createClass,
  assignTeacher,
} = require("./admin.controller");

const db = require("../config/db");

describe("Admin Controller", () => {
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

  describe("getDashboard", () => {
    it("returns dashboard stats with major names mapped", async () => {
      const mockClasses = [{ class_id: "c1", class_name: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: mockClasses }); // courses query
      db.query.mockResolvedValueOnce({ rows: [{ course_id: "c1", major_names: "Science" }] }); // major query

      await getDashboard(req, res, next);

      expect(res.json).toHaveBeenCalledWith([
        expect.objectContaining({ class_id: "c1", major_names: "Science" }),
      ]);
    });

    it("forwards error to next() on failure", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getDashboard(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getDashboardExport", () => {
    it("returns exported score data", async () => {
      const mockExport = [{ student_id: "s1", computed_score: 95 }];
      db.query.mockResolvedValueOnce({ rows: mockExport });

      await getDashboardExport(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockExport);
    });
  });

  describe("getTeachers", () => {
    it("returns teachers list", async () => {
      const teachers = [{ user_id: "u1", full_name: "Teacher Sok", course_count: 2 }];
      db.query.mockResolvedValueOnce({ rows: teachers });

      await getTeachers(req, res, next);

      expect(res.json).toHaveBeenCalledWith(teachers);
    });
  });

  describe("getAcademicYears", () => {
    it("returns academic years list", async () => {
      const years = [{ year_id: "2026-2027", is_active: true }];
      db.query.mockResolvedValueOnce({ rows: years });

      await getAcademicYears(req, res, next);

      expect(res.json).toHaveBeenCalledWith(years);
    });
  });

  describe("getMajors", () => {
    it("returns list of majors", async () => {
      const majors = [{ major_id: "m1", major_name: "Science" }];
      db.query.mockResolvedValueOnce({ rows: majors });

      await getMajors(req, res, next);

      expect(res.json).toHaveBeenCalledWith(majors);
    });
  });

  describe("getStudentsByMajor", () => {
    it("groups students by major_id", async () => {
      db.query.mockResolvedValueOnce({
        rows: [
          { major_id: "m1", major_name: "Science", student_id: "s1", full_name: "Sok Dara" },
        ],
      });

      await getStudentsByMajor(req, res, next);

      expect(res.json).toHaveBeenCalledWith([
        {
          major_id: "m1",
          major_name: "Science",
          students: expect.arrayContaining([
            expect.objectContaining({ student_id: "s1", full_name: "Sok Dara" }),
          ]),
        },
      ]);
    });
  });

  describe("getTerms", () => {
    it("returns list of terms", async () => {
      const terms = [{ term_id: "t1", term_name: "Semester 1" }];
      db.query.mockResolvedValueOnce({ rows: terms });

      await getTerms(req, res, next);

      expect(res.json).toHaveBeenCalledWith(terms);
    });
  });

  describe("createTerm", () => {
    it("returns 400 if required fields are missing", async () => {
      req.body = { term_name: "Semester 1" };

      await createTerm(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: "academic_year_id, term_name, start_date and end_date are required",
      });
    });

    it("creates a new term successfully", async () => {
      req.body = {
        academic_year_id: "2026-2027",
        term_name: "Semester 1",
        start_date: "2026-09-01",
        end_date: "2027-01-31",
      };
      const created = { term_id: "t1", ...req.body };
      db.query.mockResolvedValueOnce({ rows: [created] });

      await createTerm(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(created);
    });
  });

  describe("createTeacher", () => {
    it("returns 400 when required fields are missing", async () => {
      req.body = { full_name: "Teacher Sok" };

      await createTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: "full_name and email are required",
      });
    });

    it("creates teacher user and assigns to course", async () => {
      req.body = {
        full_name: "Teacher Sok",
        email: "sok@school.edu",
        class_id: "c1",
      };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u1", full_name: "Teacher Sok", email: "sok@school.edu" }],
      });
      db.query.mockResolvedValueOnce({ rowCount: 1 }); // course update

      await createTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        teacher: expect.objectContaining({ user_id: "u1" }),
        class_id: "c1",
      });
    });
  });

  describe("getClasses", () => {
    it("returns list of classes with stats", async () => {
      const classes = [{ class_id: "c1", class_name: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: classes });

      await getClasses(req, res, next);

      expect(res.json).toHaveBeenCalledWith(classes);
    });
  });

  describe("createClass", () => {
    it("returns 400 when class_name is missing", async () => {
      req.body = {};

      await createClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "class_name is required" });
    });

    it("creates a new course and auto-generates sessions", async () => {
      req.body = {
        class_name: "Grade 10A",
        term_id: "t1",
        total_sessions_planned: 2,
        teacher_name: "Sok",
        teacher_email: "sok@school.edu",
      };

      // 1. maxId query
      db.query.mockResolvedValueOnce({ rows: [{ course_id: "005" }] });
      // 2. term academic_year query
      db.query.mockResolvedValueOnce({ rows: [{ academic_year_id: "2026-2027" }] });
      // 3. INSERT courses query
      db.query.mockResolvedValueOnce({
        rows: [{ class_id: "006", class_name: "Grade 10A", academic_year: "2026-2027" }],
      });
      // 4. INSERT score_rules query
      db.query.mockResolvedValueOnce({});
      // 5. term start_date query
      db.query.mockResolvedValueOnce({ rows: [{ start_date: "2026-09-01" }] });
      // 6. session 1 INSERT
      db.query.mockResolvedValueOnce({});
      // 7. session 2 INSERT
      db.query.mockResolvedValueOnce({});
      // 8. user teacher INSERT
      db.query.mockResolvedValueOnce({ rows: [{ user_id: "u-sok" }] });
      // 9. course teacher_id UPDATE
      db.query.mockResolvedValueOnce({});

      await createClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ class_id: "006", teacher_id: "u-sok" }),
      );
    });
  });

  describe("assignTeacher", () => {
    it("returns 404 when class is not found", async () => {
      req.params = { class_id: "c-missing" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      db.query.mockResolvedValueOnce({ rows: [] }); // course update

      await assignTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Class not found" });
    });

    it("assigns teacher to class successfully", async () => {
      req.params = { class_id: "c1" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      const updated = { class_id: "c1", class_name: "Grade 10A", teacher_id: "u1" };
      db.query.mockResolvedValueOnce({ rows: [updated] });

      await assignTeacher(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
    });
  });
});
