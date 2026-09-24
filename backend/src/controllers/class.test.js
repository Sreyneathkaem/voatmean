process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));

const { getMyClass } = require("./class.controller");
const db = require("../config/db");

describe("Class Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      user: { user_id: "teacher-123", role: "teacher" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getMyClass", () => {
    it("returns empty array with 200 when teacher has no classes", async () => {
      db.query.mockResolvedValueOnce({ rows: [] });

      await getMyClass(req, res, next);

      expect(res.status).toHaveBeenCalledWith(200);
      expect(res.json).toHaveBeenCalledWith([]);
    });

    it("returns classes for the current teacher", async () => {
      const mockClasses = [
        {
          class_id: "c1",
          class_name: "Grade 10A",
          student_count: "25",
          marked_today: "20",
        },
      ];
      db.query.mockResolvedValueOnce({ rows: mockClasses });

      await getMyClass(req, res, next);

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("WHERE c.teacher_id = $1"),
        ["teacher-123"],
      );
      expect(res.json).toHaveBeenCalledWith(mockClasses);
    });

    it("forwards error to next() on failure", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getMyClass(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
