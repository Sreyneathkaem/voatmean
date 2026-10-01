const {
  getTimetableSlots,
  getMySlots,
  getTimetableSlot,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
} = require("./timetable.controller");
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

describe("Timetable Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = { query: {}, params: {}, body: {}, user: { user_id: "user-1", role: "teacher" } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("getTimetableSlots", () => {
    it("should return slots with optional filters", async () => {
      const mockSlots = [{ slot_id: "slot-1", subject_name: "Math" }];
      db.query.mockResolvedValue({ rows: mockSlots });
      req.query = {
        classId: "class-1",
        teacherId: "teacher-1",
        subjectId: "subject-1",
        dayOfWeek: "1",
      };

      await getTimetableSlots(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockSlots);
      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("WHERE ts.class_id = $1 AND ts.teacher_id = $2 AND ts.subject_id = $3 AND ts.day_of_week = $4"),
        ["class-1", "teacher-1", "subject-1", "1"],
      );
    });

    it("should handle error in getTimetableSlots", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getTimetableSlots(req, res, next);
      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getMySlots", () => {
    it("returns slots for the authenticated teacher", async () => {
      const slots = [{ slot_id: "slot-1", class_name: "Grade 10A" }];
      db.query.mockResolvedValueOnce({ rows: slots });

      await getMySlots(req, res, next);

      expect(res.json).toHaveBeenCalledWith(slots);
      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining("WHERE ts.teacher_id = $1"),
        ["user-1"],
      );
    });

    it("returns all slots for admin when teacher has 0 assigned slots", async () => {
      req.user = { user_id: "admin-1", role: "admin" };
      const allSlots = [{ slot_id: "slot-all", class_name: "Grade 10B" }];
      db.query
        .mockResolvedValueOnce({ rows: [] }) // personal slots
        .mockResolvedValueOnce({ rows: allSlots }); // fallback all slots

      await getMySlots(req, res, next);

      expect(res.json).toHaveBeenCalledWith(allSlots);
    });

    it("forwards error to next() on failure", async () => {
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getMySlots(req, res, next);
      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("getTimetableSlot", () => {
    it("returns 400 for invalid UUID slotId", async () => {
      req.params.slotId = "invalid-uuid";

      await getTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Invalid slot ID format" });
    });

    it("returns 404 when slot is not found", async () => {
      req.params.slotId = "a0000000-0000-0000-0000-000000000001";
      db.query.mockResolvedValueOnce({ rows: [] });

      await getTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "Slot not found" });
    });

    it("returns slot when found", async () => {
      const slot = { slot_id: "a0000000-0000-0000-0000-000000000001", subject_name: "Khmer" };
      req.params.slotId = slot.slot_id;
      db.query.mockResolvedValueOnce({ rows: [slot] });

      await getTimetableSlot(req, res, next);

      expect(res.json).toHaveBeenCalledWith(slot);
    });

    it("forwards error to next()", async () => {
      req.params.slotId = "a0000000-0000-0000-0000-000000000001";
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getTimetableSlot(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("createTimetableSlot", () => {
    it("should return 400 if required fields are missing", async () => {
      req.body = { class_id: "c1" };
      await createTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should return 400 if day_of_week is invalid", async () => {
      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 8,
        period: 1,
      };
      await createTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should return 400 if period is invalid", async () => {
      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 1,
        period: 0,
      };
      await createTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should create a slot if no conflicts exist", async () => {
      db.query
        .mockResolvedValueOnce({ rows: [{ slot_id: "new-slot" }] })
        .mockResolvedValueOnce({ rows: [{ slot_id: "new-slot", class_id: "c1" }] });

      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 1,
        period: 1,
      };

      await createTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ slot_id: "new-slot" }));
    });

    it("should return 409 if a unique constraint violation occurs", async () => {
      const error = new Error("Unique constraint");
      error.code = "23505";
      error.constraint = "timetable_slots_teacher_id_day_of_week_period_key";
      db.query.mockRejectedValue(error);

      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 1,
        period: 1,
      };

      await createTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(409);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        error: expect.stringContaining("teacher"),
      }));
    });

    it("should return 400 if foreign key violation occurs", async () => {
      const error = new Error("Foreign key violation");
      error.code = "23503";
      db.query.mockRejectedValue(error);

      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 1,
        period: 1,
      };

      await createTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        error: expect.stringContaining("does not exist"),
      }));
    });

    it("forwards generic error to next()", async () => {
      const error = new Error("Generic failure");
      db.query.mockRejectedValue(error);

      req.body = {
        class_id: "c1",
        subject_id: "s1",
        teacher_id: "t1",
        day_of_week: 1,
        period: 1,
      };

      await createTimetableSlot(req, res, next);

      expect(next).toHaveBeenCalledWith(error);
    });
  });

  describe("updateTimetableSlot", () => {
    it("should return 400 if day_of_week is invalid", async () => {
      req.params.slotId = "slot-1";
      req.body = { day_of_week: 0 };
      await updateTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should return 400 if period is invalid", async () => {
      req.params.slotId = "slot-1";
      req.body = { period: -1 };
      await updateTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("should return 404 when slot to update is not found", async () => {
      req.params.slotId = "slot-1";
      req.body = { day_of_week: 2 };
      db.query.mockResolvedValueOnce({ rows: [] });

      await updateTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("should update a slot and return re-fetched result", async () => {
      req.params.slotId = "slot-1";
      req.body = { day_of_week: 2 };

      db.query
        .mockResolvedValueOnce({ rows: [{ slot_id: "slot-1" }] })
        .mockResolvedValueOnce({ rows: [{ slot_id: "slot-1", day_of_week: 2 }] });

      await updateTimetableSlot(req, res, next);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ day_of_week: 2 }));
    });

    it("should return 409 on update unique conflict", async () => {
      req.params.slotId = "slot-1";
      req.body = { day_of_week: 2 };
      const err = new Error("Unique constraint");
      err.code = "23505";
      err.constraint = "timetable_slots_class_id_day_of_week_period_key";
      db.query.mockRejectedValueOnce(err);

      await updateTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(409);
    });

    it("should return 400 on update fk error", async () => {
      req.params.slotId = "slot-1";
      req.body = { teacher_id: "bad-id" };
      const err = new Error("FK violation");
      err.code = "23503";
      db.query.mockRejectedValueOnce(err);

      await updateTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
    });

    it("forwards generic error to next()", async () => {
      req.params.slotId = "slot-1";
      req.body = { day_of_week: 2 };
      const err = new Error("Generic failure");
      db.query.mockRejectedValueOnce(err);

      await updateTimetableSlot(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("deleteTimetableSlot", () => {
    it("should return 404 when slot to delete is not found", async () => {
      req.params.slotId = "slot-1";
      db.query.mockResolvedValueOnce({ rows: [] });

      await deleteTimetableSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(404);
    });

    it("should delete a slot successfully", async () => {
      req.params.slotId = "slot-1";
      db.query.mockResolvedValueOnce({ rows: [{ slot_id: "slot-1" }] });

      await deleteTimetableSlot(req, res, next);

      expect(res.json).toHaveBeenCalledWith({ deleted: true });
    });

    it("forwards error to next() on delete failure", async () => {
      req.params.slotId = "slot-1";
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await deleteTimetableSlot(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
