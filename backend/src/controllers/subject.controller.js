const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

const getDefaultSchoolId = async () => {
  const { rows } = await query(
    `SELECT school_id FROM schools ORDER BY created_at LIMIT 1`,
  );
  return rows[0]?.school_id || null;
};

// GET /api/admin/subjects
const getSubjects = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT subject_id, subject_name, school_id, created_at
       FROM subjects
       ORDER BY subject_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/subjects
// Body: { subject_name, school_id? }
const createSubject = async (req, res, next) => {
  try {
    const { subject_name, school_id } = req.body;
    if (!subject_name) {
      return res.status(400).json({ error: "subject_name is required" });
    }

    const resolvedSchoolId = school_id || (await getDefaultSchoolId());
    if (!resolvedSchoolId) {
      return res
        .status(400)
        .json({ error: "No school exists yet — create one first" });
    }

    const { rows } = await query(
      `INSERT INTO subjects (school_id, subject_name)
       VALUES ($1, $2)
       ON CONFLICT (school_id, subject_name) DO NOTHING
       RETURNING *`,
      [resolvedSchoolId, subject_name],
    );
    if (!rows.length) {
      return res.status(409).json({ error: "Subject already exists" });
    }

    AuditLog.create({
      event_type: "subject_created",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { subject_id: rows[0].subject_id, subject_name: rows[0].subject_name },
    }).catch(() => {});

    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /api/admin/subjects/:subjectId
// Body: { subject_name }
const updateSubject = async (req, res, next) => {
  try {
    const { subjectId } = req.params;
    const { subject_name } = req.body;
    if (!subject_name) {
      return res.status(400).json({ error: "subject_name is required" });
    }

    const { rows } = await query(
      `UPDATE subjects SET subject_name = $1 WHERE subject_id = $2 RETURNING *`,
      [subject_name, subjectId],
    );
    if (!rows.length) return res.status(404).json({ error: "Subject not found" });

    AuditLog.create({
      event_type: "subject_updated",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { subject_id: rows[0].subject_id, subject_name: rows[0].subject_name },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

module.exports = { getSubjects, createSubject, updateSubject };