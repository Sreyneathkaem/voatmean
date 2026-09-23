// backend/src/controllers/scoreFormula.controller.test.js
//
// Mocks ../config/db and ../config/mongo so these run without a live
// Postgres/Mongo connection. validateWeights() isn't exported, so it's
// exercised indirectly through updateDefaultConfig / upsertSubjectConfig,
// which is what actually matters for coverage of those endpoints.

jest.mock('../config/db', () => ({
  query: jest.fn(),
}));
jest.mock('../config/mongo', () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
  },
}));

const { query } = require('../config/db');
const { AuditLog } = require('../config/mongo');
const {
  getAllConfigs,
  getDefaultConfig,
  getEffectiveConfig,
  updateDefaultConfig,
  upsertSubjectConfig,
  deleteSubjectConfig,
} = require('./scoreFormula.controller');

const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json = jest.fn().mockReturnValue(res);
  return res;
};

const mockReq = (overrides = {}) => ({
  params: {},
  body: {},
  user: { user_id: 'admin1', role: 'admin' },
  ...overrides,
});

beforeEach(() => {
  query.mockReset();
  AuditLog.create.mockClear();
});

describe('getAllConfigs', () => {
  it('returns all config rows', async () => {
    const req = mockReq();
    const res = mockRes();
    const next = jest.fn();
    const rows = [
      { config_id: 1, subject_id: null, mode: 'weighted_blend' },
      { config_id: 2, subject_id: 's1', subject_name: 'Math', mode: 'teacher_score_only' },
    ];
    query.mockResolvedValueOnce({ rows });

    await getAllConfigs(req, res, next);

    expect(res.json).toHaveBeenCalledWith(rows);
    expect(next).not.toHaveBeenCalled();
  });

  it('forwards db errors to next()', async () => {
    const req = mockReq();
    const res = mockRes();
    const next = jest.fn();
    const dbError = new Error('timeout');
    query.mockRejectedValueOnce(dbError);

    await getAllConfigs(req, res, next);

    expect(next).toHaveBeenCalledWith(dbError);
  });
});

describe('getDefaultConfig', () => {
  it('returns the system-wide default row', async () => {
    const req = mockReq();
    const res = mockRes();
    const next = jest.fn();
    const row = { config_id: 1, subject_id: null, mode: 'weighted_blend' };
    query.mockResolvedValueOnce({ rows: [row] });

    await getDefaultConfig(req, res, next);

    expect(res.json).toHaveBeenCalledWith(row);
  });

  it('returns 404 when the default row is missing', async () => {
    const req = mockReq();
    const res = mockRes();
    const next = jest.fn();
    query.mockResolvedValueOnce({ rows: [] });

    await getDefaultConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('default row is missing') }),
    );
  });
});

describe('getEffectiveConfig', () => {
  it('returns the subject override when one exists', async () => {
    const req = mockReq({ params: { subjectId: 's1' } });
    const res = mockRes();
    const next = jest.fn();
    const row = { config_id: 2, subject_id: 's1', mode: 'teacher_score_only' };
    query.mockResolvedValueOnce({ rows: [row] });

    await getEffectiveConfig(req, res, next);

    expect(query).toHaveBeenCalledWith(expect.any(String), ['s1']);
    expect(res.json).toHaveBeenCalledWith(row);
  });

  it('returns 404 when neither an override nor a default exists', async () => {
    const req = mockReq({ params: { subjectId: 's1' } });
    const res = mockRes();
    const next = jest.fn();
    query.mockResolvedValueOnce({ rows: [] });

    await getEffectiveConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('No config found') }),
    );
  });
});

describe('updateDefaultConfig', () => {
  it('returns 400 for an invalid mode', async () => {
    const req = mockReq({
      body: { mode: 'not_a_real_mode', attendance_weight: 0.3, teacher_score_weight: 0.7 },
    });
    const res = mockRes();
    const next = jest.fn();

    await updateDefaultConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('mode must be one of') }),
    );
    expect(query).not.toHaveBeenCalled();
  });

  it('returns 400 when weights do not sum to 1.00', async () => {
    const req = mockReq({
      body: { mode: 'weighted_blend', attendance_weight: 0.3, teacher_score_weight: 0.6 },
    });
    const res = mockRes();
    const next = jest.fn();

    await updateDefaultConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('must equal 1.00') }),
    );
    expect(query).not.toHaveBeenCalled();
  });

  it('returns 400 when weights are not numbers', async () => {
    const req = mockReq({
      body: { mode: 'weighted_blend', attendance_weight: 'oops', teacher_score_weight: 0.7 },
    });
    const res = mockRes();
    const next = jest.fn();

    await updateDefaultConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('must be numbers') }),
    );
  });

  it('updates the default row, writes an audit log, and returns it', async () => {
    const req = mockReq({
      body: { mode: 'weighted_blend', attendance_weight: 0.3, teacher_score_weight: 0.7 },
    });
    const res = mockRes();
    const next = jest.fn();
    const updated = { config_id: 1, subject_id: null, mode: 'weighted_blend', attendance_weight: 0.3, teacher_score_weight: 0.7 };
    query.mockResolvedValueOnce({ rows: [updated] });

    await updateDefaultConfig(req, res, next);

    expect(res.json).toHaveBeenCalledWith(updated);
    expect(AuditLog.create).toHaveBeenCalledWith(
      expect.objectContaining({ event_type: 'score_formula_default_updated' }),
    );
  });

  it('returns 404 if the default row does not exist to update', async () => {
    const req = mockReq({
      body: { mode: 'weighted_blend', attendance_weight: 0.3, teacher_score_weight: 0.7 },
    });
    const res = mockRes();
    const next = jest.fn();
    query.mockResolvedValueOnce({ rows: [] });

    await updateDefaultConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  it('forwards db errors to next()', async () => {
    const req = mockReq({
      body: { mode: 'weighted_blend', attendance_weight: 0.3, teacher_score_weight: 0.7 },
    });
    const res = mockRes();
    const next = jest.fn();
    const dbError = new Error('db down');
    query.mockRejectedValueOnce(dbError);

    await updateDefaultConfig(req, res, next);

    expect(next).toHaveBeenCalledWith(dbError);
  });
});

describe('upsertSubjectConfig', () => {
  it('returns 400 on invalid weights before touching the db', async () => {
    const req = mockReq({
      params: { subjectId: 's1' },
      body: { mode: 'weighted_blend', attendance_weight: 0.5, teacher_score_weight: 0.4 },
    });
    const res = mockRes();
    const next = jest.fn();

    await upsertSubjectConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(query).not.toHaveBeenCalled();
  });

  it('upserts a subject override and writes an audit log', async () => {
    const req = mockReq({
      params: { subjectId: 's1' },
      body: { mode: 'attendance_only', attendance_weight: 1, teacher_score_weight: 0 },
    });
    const res = mockRes();
    const next = jest.fn();
    const row = { config_id: 3, subject_id: 's1', mode: 'attendance_only' };
    query.mockResolvedValueOnce({ rows: [row] });

    await upsertSubjectConfig(req, res, next);

    expect(res.json).toHaveBeenCalledWith(row);
    expect(AuditLog.create).toHaveBeenCalledWith(
      expect.objectContaining({
        event_type: 'score_formula_subject_override_set',
        target: { subject_id: 's1' },
      }),
    );
  });

  it('forwards db errors to next()', async () => {
    const req = mockReq({
      params: { subjectId: 's1' },
      body: { mode: 'attendance_only', attendance_weight: 1, teacher_score_weight: 0 },
    });
    const res = mockRes();
    const next = jest.fn();
    const dbError = new Error('unique violation');
    query.mockRejectedValueOnce(dbError);

    await upsertSubjectConfig(req, res, next);

    expect(next).toHaveBeenCalledWith(dbError);
  });
});

describe('deleteSubjectConfig', () => {
  it('deletes the override and confirms removal', async () => {
    const req = mockReq({ params: { subjectId: 's1' } });
    const res = mockRes();
    const next = jest.fn();
    query.mockResolvedValueOnce({ rowCount: 1 });

    await deleteSubjectConfig(req, res, next);

    expect(res.json).toHaveBeenCalledWith({ removed: true });
    expect(AuditLog.create).toHaveBeenCalledWith(
      expect.objectContaining({ event_type: 'score_formula_subject_override_removed' }),
    );
  });

  it('returns 404 when no override exists for the subject', async () => {
    const req = mockReq({ params: { subjectId: 's1' } });
    const res = mockRes();
    const next = jest.fn();
    query.mockResolvedValueOnce({ rowCount: 0 });

    await deleteSubjectConfig(req, res, next);

    expect(res.status).toHaveBeenCalledWith(404);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ error: expect.stringContaining('No override exists') }),
    );
  });

  it('forwards db errors to next()', async () => {
    const req = mockReq({ params: { subjectId: 's1' } });
    const res = mockRes();
    const next = jest.fn();
    const dbError = new Error('fk violation');
    query.mockRejectedValueOnce(dbError);

    await deleteSubjectConfig(req, res, next);

    expect(next).toHaveBeenCalledWith(dbError);
  });
});