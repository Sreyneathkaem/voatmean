const { getSlotRoster, getSlotAttendance, saveSlotAttendance } = require('./slotAttendance.controller');
const db = require('../config/db');

// Mock dependencies
jest.mock('../config/db', () => ({
  query: jest.fn(),
  getClient: jest.fn()
}));
jest.mock('../config/mongo', () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({})
  }
}));

describe('Slot Attendance Controller', () => {
  let req, res, next, mockClient;

  beforeEach(() => {
    req = { params: {}, body: {}, user: { user_id: 'user-1', role: 'teacher' } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis()
    };
    next = jest.fn();

    mockClient = {
      query: jest.fn(),
      release: jest.fn()
    };
    db.getClient.mockResolvedValue(mockClient);
    jest.clearAllMocks();
  });

  describe('getSlotRoster', () => {
    it('should return students for a slot', async () => {
      const mockStudents = [{ student_id: 's1', full_name: 'John' }];
      db.query.mockResolvedValueOnce({ rows: mockStudents });
      req.params.slotId = 'slot-1';

      await getSlotRoster(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockStudents);
    });

    it('forwards error to next() on failure', async () => {
      const err = new Error('DB Error');
      db.query.mockRejectedValueOnce(err);
      req.params.slotId = 'slot-1';

      await getSlotRoster(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe('getSlotAttendance', () => {
    it('returns attendance records for a slot and date', async () => {
      const records = [{ record_id: 'r1', status: 'present', full_name: 'Sok' }];
      db.query.mockResolvedValueOnce({ rows: records });
      req.params = { slotId: 'slot-1', date: '2026-09-28' };

      await getSlotAttendance(req, res, next);

      expect(res.json).toHaveBeenCalledWith(records);
    });

    it('forwards error to next() on failure', async () => {
      const err = new Error('DB Error');
      db.query.mockRejectedValueOnce(err);
      req.params = { slotId: 'slot-1', date: '2026-09-28' };

      await getSlotAttendance(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe('saveSlotAttendance', () => {
    it('returns 400 when records array is missing or empty', async () => {
      req.params = { slotId: 'slot-1', date: '2026-09-10' };
      req.body = { records: [] };

      await saveSlotAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'records[] array is required' });
      expect(mockClient.release).toHaveBeenCalled();
    });

    it('returns 400 when any record is missing student_id', async () => {
      req.params = { slotId: 'slot-1', date: '2026-09-10' };
      req.body = { records: [{ status: 'present' }] };

      await saveSlotAttendance(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'student_id is required for every record' });
      expect(mockClient.release).toHaveBeenCalled();
    });

    it('should save multiple records and commit transaction for admin', async () => {
      req.user = { user_id: 'admin-1', role: 'admin' };
      req.params = { slotId: 'slot-1', date: '2026-09-10' };
      req.body.records = [
        { student_id: 's1', status: 'present' },
        { student_id: 's2', status: 'permission', reason: 'Sick' }
      ];

      mockClient.query.mockResolvedValue({ rows: [{ record_id: 'rec' }] });

      await saveSlotAttendance(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith('BEGIN');
      expect(mockClient.query).toHaveBeenCalledWith('COMMIT');
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ count: 2 }));
      expect(mockClient.release).toHaveBeenCalled();
    });

    it('should rollback on error', async () => {
      req.params = { slotId: 'slot-1', date: '2026-09-10' };
      req.body.records = [{ student_id: 's1', status: 'present' }];

      mockClient.query
        .mockResolvedValueOnce({}) // BEGIN
        .mockRejectedValueOnce(new Error('DB Error'));

      await saveSlotAttendance(req, res, next);

      expect(mockClient.query).toHaveBeenCalledWith('ROLLBACK');
      expect(next).toHaveBeenCalledWith(expect.any(Error));
      expect(mockClient.release).toHaveBeenCalled();
    });
  });
});
