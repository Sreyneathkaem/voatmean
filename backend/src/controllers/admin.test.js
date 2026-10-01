process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));

const {
  getDashboard,
  getDashboardExport,
  getTeachers,
  getAllStudents,
  getAcademicYears,
  getMajors,
  getStudentsByMajor,
  getTerms,
  createTerm,
  createTeacher,
  getClasses,
  createClass,
  assignTeacher,
  bulkImportStudents,
  bulkImportTeachers,
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
    db.query.mockReset();
  });

  describe("getDashboard", () => {
    it("returns dashboard stats with major names mapped", async () => {
      const mockClasses = [{ class_id: "c1", class_name: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: mockClasses });
      db.query.mockResolvedValueOnce({ rows: [{ course_id: "c1", major_names: "Science" }] });

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

  describe("getAllStudents", () => {
    it("returns all students list", async () => {
      const students = [{ student_id: "s1", full_name: "Student A", current_class: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: students });

      await getAllStudents(req, res, next);

      expect(res.json).toHaveBeenCalledWith(students);
    });

    it("forwards error to next() on failure", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getAllStudents(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
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
    it("returns students grouped by major", async () => {
      const dbRows = [
        {
          major_id: "m1",
          major_name: "Computer Science",
          student_id: "s1",
          full_name: "Alice",
          roll_number: "001",
          gender: "F",
        },
      ];
      db.query.mockResolvedValueOnce({ rows: dbRows });

      await getStudentsByMajor(req, res, next);

      expect(res.json).toHaveBeenCalledWith([
        {
          major_id: "m1",
          major_name: "Computer Science",
          students: [
            {
              student_id: "s1",
              full_name: "Alice",
              roll_number: "001",
              gender: "F",
            },
          ],
        },
      ]);
    });
  });

  describe("getTerms", () => {
    it("returns terms list", async () => {
      const terms = [{ term_id: "t1", term_name: "Semester 1" }];
      db.query.mockResolvedValueOnce({ rows: terms });

      await getTerms(req, res, next);

      expect(res.json).toHaveBeenCalledWith(terms);
    });
  });

  describe("createTerm", () => {
    it("returns 400 when required fields are missing", async () => {
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
    it("returns 400 when full_name or email is missing", async () => {
      req.body = { full_name: "Teacher" };

      await createTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "full_name and email are required" });
    });

    it("creates a new teacher successfully", async () => {
      req.body = { full_name: "New Teacher", email: "new@school.edu", class_id: "c1" };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u2", full_name: "New Teacher", email: "new@school.edu", role: "teacher" }],
      });
      db.query.mockResolvedValueOnce({}); // assign class

      await createTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        teacher: expect.objectContaining({ user_id: "u2", email: "new@school.edu" }),
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

    it("creates a new course, links majors, and auto-generates sessions", async () => {
      req.body = {
        class_name: "Grade 10A",
        term_id: "t1",
        major_ids: ["m1", "m2"],
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
      // 5. INSERT course_majors m1
      db.query.mockResolvedValueOnce({});
      // 6. INSERT course_majors m2
      db.query.mockResolvedValueOnce({});
      // 7. term start_date query
      db.query.mockResolvedValueOnce({ rows: [{ start_date: "2026-09-01" }] });
      // 8. session 1 INSERT
      db.query.mockResolvedValueOnce({});
      // 9. session 2 INSERT
      db.query.mockResolvedValueOnce({});
      // 10. user teacher INSERT
      db.query.mockResolvedValueOnce({ rows: [{ user_id: "u-sok" }] });
      // 11. course teacher_id UPDATE
      db.query.mockResolvedValueOnce({});

      await createClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ class_id: "006", teacher_id: "u-sok" }),
      );
    });
  });

  describe("assignTeacher", () => {
    it("returns 404 when class is not found in courses or homeroom_classes", async () => {
      req.params = { class_id: "c-missing" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      db.query.mockResolvedValueOnce({ rows: [] }); // course update
      db.query.mockResolvedValueOnce({ rows: [] }); // homeroom_classes select

      await assignTeacher(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Class not found" });
    });

    it("assigns teacher to regular course successfully", async () => {
      req.params = { class_id: "c1" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      const updated = { class_id: "c1", class_name: "Grade 10A", teacher_id: "u1" };
      db.query.mockResolvedValueOnce({ rows: [updated] });

      await assignTeacher(req, res, next);

      expect(res.json).toHaveBeenCalledWith(updated);
    });

    it("assigns teacher to homeroom class updating existing slot", async () => {
      req.params = { class_id: "hr-1" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      db.query.mockResolvedValueOnce({ rows: [] }); // course update
      db.query.mockResolvedValueOnce({ rows: [{ class_name: "Grade 10A", academic_year_id: "2026-2027" }] }); // homeroom_classes
      db.query.mockResolvedValueOnce({ rows: [{ slot_id: "sl-1" }] }); // timetable_slots check
      db.query.mockResolvedValueOnce({}); // update slot

      await assignTeacher(req, res, next);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ class_id: "hr-1", teacher_id: "u1" }),
      );
    });

    it("assigns teacher to homeroom class inserting new slot if none exists", async () => {
      req.params = { class_id: "hr-2" };
      req.body = { teacher_id: "u1" };
      db.query.mockResolvedValueOnce({}); // user role update
      db.query.mockResolvedValueOnce({ rows: [] }); // course update
      db.query.mockResolvedValueOnce({ rows: [{ class_name: "Grade 10B", academic_year_id: "2026-2027" }] }); // homeroom_classes
      db.query.mockResolvedValueOnce({ rows: [] }); // timetable_slots check
      db.query.mockResolvedValueOnce({ rows: [{ subject_id: "sub-1" }] }); // subject check
      db.query.mockResolvedValueOnce({}); // insert slot

      await assignTeacher(req, res, next);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ class_id: "hr-2", teacher_id: "u1" }),
      );
    });

    it("unassigns teacher from homeroom class by deleting slots when teacher_id is null", async () => {
      req.params = { class_id: "hr-3" };
      req.body = { teacher_id: null };
      db.query.mockResolvedValueOnce({ rows: [] }); // course update
      db.query.mockResolvedValueOnce({ rows: [{ class_name: "Grade 10C", academic_year_id: "2026-2027" }] }); // homeroom_classes
      db.query.mockResolvedValueOnce({}); // delete slots

      await assignTeacher(req, res, next);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({ class_id: "hr-3", teacher_id: null }),
      );
    });
  });

  describe("bulkImportStudents", () => {
    it("returns 400 when students array is empty", async () => {
      req.body = { students: [] };
      await bulkImportStudents(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "No students provided for import" });
    });

    it("imports students with gender parsing, class name formatting, new class creation and update", async () => {
      req.body = {
        students: [
          { full_name: "" }, // missing name error
          { full_name: "Sok Piseth", gender: "ស្រី", class_name: "10B", roll_number: "1", phone: "012345" },
          { full_name: "Dara Chan", gender: "other", class_name: "ថ្នាក់ទី10C", roll_number: "2" },
        ],
      };

      db.query.mockResolvedValueOnce({ rows: [{ school_id: "s1" }] }); // school_id
      db.query.mockResolvedValueOnce({ rows: [{ class_id: "c10b", class_name: "Grade 10B" }] }); // homeroom_classes
      
      // Student 2 (Sok Piseth)
      db.query.mockResolvedValueOnce({ rows: [{ student_id: "stu-existing" }] }); // existing student check
      db.query.mockResolvedValueOnce({}); // update student

      // Student 3 (Dara Chan)
      db.query.mockResolvedValueOnce({ rows: [{ class_id: "c10c" }] }); // new class insert
      db.query.mockResolvedValueOnce({ rows: [] }); // existing student check
      db.query.mockResolvedValueOnce({ rows: [{ student_id: "stu-new" }] }); // insert student
      db.query.mockResolvedValueOnce({}); // insert class_students

      await bulkImportStudents(req, res, next);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          imported_count: 1,
          updated_count: 1,
          errors: [expect.objectContaining({ row: 1, error: "Missing student name" })],
        }),
      );
    });

    it("forwards error to next() on bulk import failure", async () => {
      req.body = { students: [{ full_name: "Sok" }] };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await bulkImportStudents(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("bulkImportTeachers", () => {
    it("returns 400 when teachers array is empty", async () => {
      req.body = { teachers: [] };
      await bulkImportTeachers(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("imports teachers with auto-generated email, subject creation, and class creation", async () => {
      req.body = {
        teachers: [
          { full_name: "" }, // missing name error
          { full_name: "Kaem Sreyneath", email: "invalid-email", subject: "New Subject", classes: "10A, 10B" },
        ],
      };

      db.query.mockResolvedValueOnce({ rows: [{ school_id: "s1" }] }); // school
      db.query.mockResolvedValueOnce({ rows: [] }); // subjects (empty)
      
      // Teacher 2
      db.query.mockResolvedValueOnce({ rows: [{ user_id: "u-tch-1" }] }); // insert user
      db.query.mockResolvedValueOnce({ rows: [{ subject_id: "sub-created" }] }); // insert subject
      // class 10A
      db.query.mockResolvedValueOnce({ rows: [{ class_id: "c10a" }] }); // insert class
      db.query.mockResolvedValueOnce({}); // insert timetable_slot
      // class 10B
      db.query.mockResolvedValueOnce({ rows: [] }); // insert class (conflict)
      db.query.mockResolvedValueOnce({ rows: [{ class_id: "c10b" }] }); // find class
      db.query.mockResolvedValueOnce({}); // insert timetable_slot

      await bulkImportTeachers(req, res, next);

      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: true,
          imported_count: 1,
          errors: [expect.objectContaining({ row: 1, error: "Missing teacher name" })],
        }),
      );
    });

    it("forwards error to next() on failure", async () => {
      req.body = { teachers: [{ full_name: "Sok" }] };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await bulkImportTeachers(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
