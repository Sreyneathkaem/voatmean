const { getSlotRoster, saveSlotAttendance } = require('./slotAttendance.controller');
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
  });

  describe('getSlotRoster', () => {
    it('should return students for a slot', async () => {
      const mockStudents = [{ student_id: 's1', full_name: 'John' }];
      db.query.mockResolvedValue({ rows: mockStudents });
      req.params.slotId = 'slot-1';

      await getSlotRoster(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockStudents);
    });
  });

  describe('saveSlotAttendance', () => {
    it('should save multiple records and commit transaction', async () => {
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
