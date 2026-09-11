const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

const VALID_MODES = ["attendance_only", "teacher_score_only", "weighted_blend"];

// Mirrors the DB CHECK (attendance_weight + teacher_score_weight = 1.00)
// so callers get a clean 400 instead of a raw constraint-violation error.
const validateWeights = (mode, attendance_weight, teacher_score_weight) => {
  if (!VALID_MODES.includes(mode)) {
    return `mode must be one of: ${VALID_MODES.join(", ")}`;
  }
  const aw = Number(attendance_weight);
  const tw = Number(teacher_score_weight);
  if (Number.isNaN(aw) || Number.isNaN(tw)) {
    return "attendance_weight and teacher_score_weight must be numbers";
  }
  if (Math.round((aw + tw) * 100) !== 100) {
    return "attendance_weight + teacher_score_weight must equal 1.00";
  }
  return null;
};

// GET /api/admin/score-formula
// Every row: the system-wide default (subject_id NULL) plus all
// per-subject overrides.
const getAllConfigs = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT sfc.config_id, sfc.subject_id, s.subject_name,
              sfc.mode, sfc.attendance_weight, sfc.teacher_score_weight, sfc.updated_at
       FROM score_formula_config sfc
       LEFT JOIN subjects s ON s.subject_id = sfc.subject_id
       ORDER BY sfc.subject_id NULLS FIRST, s.subject_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/score-formula/default
const getDefaultConfig = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT * FROM score_formula_config WHERE subject_id IS NULL LIMIT 1`,
    );
    if (!rows.length) {
      return res.status(404).json({ error: "System-wide default row is missing — run migrations" });
    }
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/score-formula/:subjectId
// The EFFECTIVE config for a subject: its own override if one
// exists, otherwise the system-wide default.
const getEffectiveConfig = async (req, res, next) => {
  try {
    const { subjectId } = req.params;
    const { rows } = await query(
      `SELECT * FROM score_formula_config WHERE subject_id = $1
       UNION ALL
       SELECT * FROM score_formula_config
       WHERE subject_id IS NULL
         AND NOT EXISTS (SELECT 1 FROM score_formula_config WHERE subject_id = $1)
       LIMIT 1`,
      [subjectId],
    );
    if (!rows.length) {
      return res.status(404).json({ error: "No config found (not even a system-wide default)" });
    }
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /api/admin/score-formula/default
// Updates the system-wide fallback row.
const updateDefaultConfig = async (req, res, next) => {
  try {
    const { mode, attendance_weight, teacher_score_weight } = req.body;
    const error = validateWeights(mode, attendance_weight, teacher_score_weight);
    if (error) return res.status(400).json({ error });

    const { rows } = await query(
      `UPDATE score_formula_config
       SET mode = $1, attendance_weight = $2, teacher_score_weight = $3, updated_at = NOW()
       WHERE subject_id IS NULL
       RETURNING *`,
      [mode, attendance_weight, teacher_score_weight],
    );
    if (!rows.length) {
      return res.status(404).json({ error: "System-wide default row is missing — run migrations" });
    }

    AuditLog.create({
      event_type: "score_formula_default_updated",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      change: { mode, attendance_weight, teacher_score_weight },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /api/admin/score-formula/:subjectId
// Upserts a per-subject override. Relies on the partial unique index
// added in 003_score_formula_decision.sql.
const upsertSubjectConfig = async (req, res, next) => {
  try {
    const { subjectId } = req.params;
    const { mode, attendance_weight, teacher_score_weight } = req.body;
    const error = validateWeights(mode, attendance_weight, teacher_score_weight);
    if (error) return res.status(400).json({ error });

    const { rows } = await query(
      `INSERT INTO score_formula_config (subject_id, mode, attendance_weight, teacher_score_weight)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (subject_id) WHERE subject_id IS NOT NULL DO UPDATE SET
         mode                 = EXCLUDED.mode,
         attendance_weight    = EXCLUDED.attendance_weight,
         teacher_score_weight = EXCLUDED.teacher_score_weight,
         updated_at           = NOW()
       RETURNING *`,
      [subjectId, mode, attendance_weight, teacher_score_weight],
    );

    AuditLog.create({
      event_type: "score_formula_subject_override_set",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { subject_id: subjectId },
      change: { mode, attendance_weight, teacher_score_weight },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /api/admin/score-formula/:subjectId
// Removes a per-subject override — that subject falls back to the
// system-wide default again.
const deleteSubjectConfig = async (req, res, next) => {
  try {
    const { subjectId } = req.params;
    const result = await query(
      `DELETE FROM score_formula_config WHERE subject_id = $1`,
      [subjectId],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "No override exists for this subject" });
    }

    AuditLog.create({
      event_type: "score_formula_subject_override_removed",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { subject_id: subjectId },
    }).catch(() => {});

    res.json({ removed: true });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllConfigs,
  getDefaultConfig,
  getEffectiveConfig,
  updateDefaultConfig,
  upsertSubjectConfig,
  deleteSubjectConfig,
};
