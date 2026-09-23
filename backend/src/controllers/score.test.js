const { getMonthlyGrades, upsertSubjectScore } = require('./score.controller');
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
    db.query.mockReset(); // clear call history AND any queued mockResolvedValueOnce values
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

  describe('upsertSubjectScore', () => {
    it('returns 400 when required fields are missing', async () => {
      req.body = { student_id: 'std1' }; // missing subject_id, class_id, month, teacher_score

      await upsertSubjectScore(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: 'Missing required fields' });
      expect(db.query).not.toHaveBeenCalled();
    });

    it('upserts the score and defaults max_score to 100 when omitted', async () => {
      req.body = {
        student_id: 'std1',
        subject_id: 's1',
        class_id: 'c1',
        month: '2026-09',
        teacher_score: 88,
        // max_score omitted on purpose
      };

      const upserted = {
        student_id: 'std1', subject_id: 's1', class_id: 'c1',
        month: '2026-09-01', teacher_score: 88, max_score: 100.0,
      };
      db.query.mockResolvedValueOnce({ rows: [upserted] });

      await upsertSubjectScore(req, res, next);

      expect(db.query).toHaveBeenCalledWith(
        expect.stringContaining('INSERT INTO subject_scores'),
        ['std1', 's1', 'c1', '2026-09-01', 88, 100.00, 't1'],
      );
      expect(res.json).toHaveBeenCalledWith(upserted);
    });

    it('forwards db errors to next()', async () => {
      req.body = {
        student_id: 'std1', subject_id: 's1', class_id: 'c1',
        month: '2026-09', teacher_score: 88,
      };
      const dbError = new Error('constraint violation');
      db.query.mockRejectedValueOnce(dbError);

      await upsertSubjectScore(req, res, next);

      expect(next).toHaveBeenCalledWith(dbError);
    });
  });

  describe('getMonthlyGrades — additional branches', () => {
    it('returns 404 when no formula config exists for the subject', async () => {
      req.params = { classId: 'c1', subjectId: 'missing-subject', month: '2026-09' };
      db.query.mockResolvedValueOnce({ rows: [] }); // no formula found

      await getMonthlyGrades(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: 'Score formula not found' });
      expect(db.query).toHaveBeenCalledTimes(1); // never reaches the student query
    });

    it('handles a student with zero attendance slots and zero teacher score', async () => {
      req.params = { classId: 'c1', subjectId: 's1', month: '2026-09' };

      db.query.mockResolvedValueOnce({
        rows: [{ attendance_weight: 0.3, teacher_score_weight: 0.7, mode: 'weighted_blend' }],
      });
      db.query.mockResolvedValueOnce({
        rows: [{
          student_id: 'std2',
          full_name: 'No Data Student',
          total_attendance_slots: 0,
          attendance_rate: 0,
          teacher_score: 0,
          max_score: 100,
        }],
      });

      await getMonthlyGrades(req, res, next);

      // (0 * 0.3) + (0 * 0.7) = 0
      expect(res.json).toHaveBeenCalledWith(expect.arrayContaining([
        expect.objectContaining({ final_score: 0, attendance_score: 0 }),
      ]));
    });

    it('forwards db errors to next()', async () => {
      req.params = { classId: 'c1', subjectId: 's1', month: '2026-09' };
      const dbError = new Error('connection lost');
      db.query.mockRejectedValueOnce(dbError);

      await getMonthlyGrades(req, res, next);

      expect(next).toHaveBeenCalledWith(dbError);
      expect(res.json).not.toHaveBeenCalled();
    });
  });
});