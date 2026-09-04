const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

// Today there's a single school row (schools table exists purely so a
// second school can be added later without a structural rewrite — FR-18).
// Callers can still pass an explicit school_id once that day comes.
const getDefaultSchoolId = async () => {
  const { rows } = await query(
    `SELECT school_id FROM schools ORDER BY created_at LIMIT 1`,
  );
  return rows[0]?.school_id || null;
};

// GET /api/admin/homeroom-classes
const getHomeroomClasses = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT hc.class_id, hc.class_name, hc.grade_level, hc.academic_year_id,
              hc.school_id, hc.created_at,
              COUNT(cs.student_id) AS student_count
       FROM homeroom_classes hc
       LEFT JOIN class_students cs ON cs.class_id = hc.class_id
       GROUP BY hc.class_id
       ORDER BY hc.academic_year_id DESC, hc.class_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/homeroom-classes/:classId
const getHomeroomClass = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT * FROM homeroom_classes WHERE class_id = $1`,
      [req.params.classId],
    );
    if (!rows.length) return res.status(404).json({ error: "Class not found" });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/homeroom-classes
// Body: { class_name, grade_level?, academic_year_id, school_id? }
const createHomeroomClass = async (req, res, next) => {
  try {
    const { class_name, grade_level, academic_year_id, school_id } = req.body;
    if (!class_name || !academic_year_id) {
      return res
        .status(400)
        .json({ error: "class_name and academic_year_id are required" });
    }

    const resolvedSchoolId = school_id || (await getDefaultSchoolId());
    if (!resolvedSchoolId) {
      return res
        .status(400)
        .json({ error: "No school exists yet — create one first" });
    }

    const { rows } = await query(
      `INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [resolvedSchoolId, class_name, grade_level || null, academic_year_id],
    );

    AuditLog.create({
      event_type: "homeroom_class_created",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { class_id: rows[0].class_id, class_name: rows[0].class_name },
    }).catch(() => {});

    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /api/admin/homeroom-classes/:classId
// Body: any subset of { class_name, grade_level, academic_year_id }.
// Intended use: renaming placeholder "UNASSIGNED — replace me" rows into
// real homerooms once an admin has the actual class list.
const updateHomeroomClass = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { class_name, grade_level, academic_year_id } = req.body;

    const { rows } = await query(
      `UPDATE homeroom_classes
       SET class_name       = COALESCE($1, class_name),
           grade_level      = COALESCE($2, grade_level),
           academic_year_id = COALESCE($3, academic_year_id)
       WHERE class_id = $4
       RETURNING *`,
      [class_name || null, grade_level || null, academic_year_id || null, classId],
    );
    if (!rows.length) return res.status(404).json({ error: "Class not found" });

    AuditLog.create({
      event_type: "homeroom_class_updated",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { class_id: rows[0].class_id, class_name: rows[0].class_name },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/homeroom-classes/:classId/students
const getHomeroomClassStudents = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth, cs.joined_at
       FROM class_students cs
       JOIN students s ON s.student_id = cs.student_id
       WHERE cs.class_id = $1
       ORDER BY s.roll_number`,
      [req.params.classId],
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/homeroom-classes/:classId/students
// Body: { student_id }
const addStudentToHomeroomClass = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { student_id } = req.body;
    if (!student_id) {
      return res.status(400).json({ error: "student_id is required" });
    }

    const { rows } = await query(
      `INSERT INTO class_students (class_id, student_id)
       VALUES ($1, $2)
       ON CONFLICT (class_id, student_id) DO NOTHING
       RETURNING *`,
      [classId, student_id],
    );
    if (!rows.length) {
      return res.status(409).json({ error: "Student already in this class" });
    }

    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /api/admin/homeroom-classes/:classId/students/:studentId
const removeStudentFromHomeroomClass = async (req, res, next) => {
  try {
    const { classId, studentId } = req.params;
    const result = await query(
      `DELETE FROM class_students WHERE class_id = $1 AND student_id = $2`,
      [classId, studentId],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Student not in this class" });
    }
    res.json({ removed: true });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getHomeroomClasses,
  getHomeroomClass,
  createHomeroomClass,
  updateHomeroomClass,
  getHomeroomClassStudents,
  addStudentToHomeroomClass,
  removeStudentFromHomeroomClass,
};