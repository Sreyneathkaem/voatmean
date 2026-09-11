const { getTimetableSlots, createTimetableSlot } = require('./timetable.controller');
const db = require('../config/db');

// Mock dependencies
jest.mock('../config/db', () => ({
  query: jest.fn()
}));
jest.mock('../config/mongo', () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({})
  }
}));

describe('Timetable Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = { query: {}, params: {}, body: {}, user: { user_id: 'user-1', role: 'admin' } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis()
    };
    next = jest.fn();
  });

  describe('getTimetableSlots', () => {
    it('should return slots with optional filters', async () => {
      const mockSlots = [{ slot_id: 'slot-1', subject_name: 'Math' }];
      db.query.mockResolvedValue({ rows: mockSlots });
      req.query.classId = 'class-1';

      await getTimetableSlots(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockSlots);
      expect(db.query).toHaveBeenCalledWith(expect.stringContaining('WHERE ts.class_id = $1'), ['class-1']);
    });
  });

  describe('createTimetableSlot', () => {
    it('should create a slot if no conflicts exist', async () => {
      db.query
        .mockResolvedValueOnce({ rows: [{ slot_id: 'new-slot' }] }) // Insert result
        .mockResolvedValueOnce({ rows: [{ slot_id: 'new-slot', class_id: 'c1' }] }); // Re-fetch result

      req.body = {
        class_id: 'c1',
        subject_id: 's1',
        teacher_id: 't1',
        day_of_week: 1,
        period: 1
      };

      await createTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ slot_id: 'new-slot' }));
    });

    it('should return 409 if a unique constraint violation occurs', async () => {
      const error = new Error('Unique constraint');
      error.code = '23505';
      error.constraint = 'timetable_slots_teacher_id_day_of_week_period_key';
      db.query.mockRejectedValue(error);

      req.body = {
        class_id: 'c1',
        subject_id: 's1',
        teacher_id: 't1',
        day_of_week: 1,
        period: 1
      };

      await createTimetableSlot(req, res, next);

      expect(res.status).toHaveBeenCalledWith(409);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        error: expect.stringContaining('teacher')
      }));
    });
  });

  describe('updateTimetableSlot', () => {
    it('should update a slot and return re-fetched result', async () => {
      req.params.slotId = 'slot-1';
      req.body = { day_of_week: 2 };

      db.query
        .mockResolvedValueOnce({ rows: [{ slot_id: 'slot-1' }] }) // update result
        .mockResolvedValueOnce({ rows: [{ slot_id: 'slot-1', day_of_week: 2 }] }); // fetch result

      const { updateTimetableSlot } = require('./timetable.controller');
      await updateTimetableSlot(req, res, next);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ day_of_week: 2 }));
    });
  });

  describe('deleteTimetableSlot', () => {
    it('should delete a slot', async () => {
      req.params.slotId = 'slot-1';
      db.query.mockResolvedValue({ rows: [{ slot_id: 'slot-1' }] });

      const { deleteTimetableSlot } = require('./timetable.controller');
      await deleteTimetableSlot(req, res, next);

      expect(res.json).toHaveBeenCalledWith({ deleted: true });
    });
  });
});
