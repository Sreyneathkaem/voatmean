const { updateDefaultConfig, upsertSubjectConfig, getEffectiveConfig } = require('./scoreFormula.controller');
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

describe('Score Formula Controller', () => {
  let req, res, next;

  beforeEach(() => {
    req = { params: {}, body: {}, user: { user_id: 'admin-1', role: 'admin' } };
    res = {
      json: jest.fn().mockReturnThis(),
      status: jest.fn().mockReturnThis()
    };
    next = jest.fn();
  });

  describe('updateDefaultConfig', () => {
    it('should update fallback configuration', async () => {
      req.body = {
        mode: 'weighted_blend',
        attendance_weight: 0.3,
        teacher_score_weight: 0.7
      };
      db.query.mockResolvedValue({ rows: [{ config_id: 'conf-1' }] });

      await updateDefaultConfig(req, res, next);

      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ config_id: 'conf-1' }));
    });

    it('should return 400 if weights dont sum to 1.00', async () => {
      req.body = {
        mode: 'weighted_blend',
        attendance_weight: 0.5,
        teacher_score_weight: 0.6
      };

      await updateDefaultConfig(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({ error: expect.stringContaining('1.00') }));
    });
  });

  describe('getEffectiveConfig', () => {
    it('should return effective config for a subject', async () => {
      req.params.subjectId = 'sub-1';
      const mockConfig = { mode: 'attendance_only', attendance_weight: 1.0 };
      db.query.mockResolvedValue({ rows: [mockConfig] });

      await getEffectiveConfig(req, res, next);

      expect(res.json).toHaveBeenCalledWith(mockConfig);
    });
  });
});
