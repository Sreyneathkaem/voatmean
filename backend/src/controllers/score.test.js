const { getMonthlyGrades } = require('./score.controller');
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

describe('Score Controller (Blended)', () => {
  let req, res, next;

  beforeEach(() => {
    req = { params: {}, body: {}, user: { user_id: 't1', role: 'teacher' } };
    res = { json: jest.fn().mockReturnThis(), status: jest.fn().mockReturnThis() };
    next = jest.fn();
  });

  describe('getMonthlyGrades', () => {
    it('should correctly calculate a 70/30 blended score', async () => {
      req.params = { classId: 'c1', subjectId: 's1', month: '2026-09' };

      // 1. Mock Formula (30% attendance, 70% teacher)
      db.query.mockResolvedValueOnce({
        rows: [{ attendance_weight: 0.3, teacher_score_weight: 0.7, mode: 'weighted_blend' }]
      });

      // 2. Mock Student Data
      // 10 slots: 8 present, 2 late = (8 + 1)/10 = 90% attendance
      // Teacher score: 80/100
      db.query.mockResolvedValueOnce({
        rows: [{
          student_id: 'std1',
          full_name: 'Test Student',
          attendance_rate: 0.9,
          teacher_score: 80,
          max_score: 100
        }]
      });

      await getMonthlyGrades(req, res, next);

      // Math: (90 * 0.3) + (80 * 0.7) = 27 + 56 = 83
      expect(res.json).toHaveBeenCalledWith(expect.arrayContaining([
        expect.objectContaining({ final_score: 83 })
      ]));
    });
  });
});
