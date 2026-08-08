const { query, getClient } = require("../config/db");
const { AuditLog } = require("../config/mongo");

const getOrCreateSession = async (client, courseId, date, createdBy) => {
  const existing = await client.query(
    `SELECT session_id FROM course_sessions WHERE course_id = $1 AND session_date = $2`,
    [courseId, date],
  );

  if (existing.rows[0]) return existing.rows[0].session_id;

  const created = await client.query(
    `INSERT INTO course_sessions (course_id, session_name, session_date, notes)
     VALUES ($1, $2, $3, $4)
     RETURNING session_id`,
    [courseId, `Session ${date}`, date, `Attendance sheet for ${date}`],
  );

  return created.rows[0].session_id;
};

const createSession = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { session_name, session_date, notes } = req.body;

    if (!session_date) {
      return res.status(400).json({ error: "session_date is required" });
    }

    const { rows } = await query(
      `INSERT INTO course_sessions (course_id, session_name, session_date, notes)
       VALUES ($1, $2, $3, $4)
       RETURNING session_id, session_name, session_date, notes, created_at`,
      [
        classId,
        session_name || `Session ${session_date}`,
        session_date,
        notes || null,
      ],
    );

    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

const verifySessionAccess = async (req, sessionId) => {
  const { rows } = await query(
    `SELECT cs.session_id, cs.course_id, cs.session_date, c.teacher_id
     FROM course_sessions cs
     JOIN courses c ON c.course_id = cs.course_id
     WHERE cs.session_id = $1`,
    [sessionId],
  );

  if (!rows.length) return null;
  const session = rows[0];

  if (req.user.role === "admin" || req.user.role === "admin_teacher") {
    return session;
  }

  if (session.teacher_id !== req.user.user_id) {
    return null;
  }

  return session;
};

const getSessionAttendance = async (req, res, next) => {
  try {
    const { sessionId } = req.params;
    const session = await verifySessionAccess(req, sessionId);
    if (!session) {
      return res
        .status(403)
        .json({ error: "You can only access your own session" });
    }

    const { rows } = await query(
      `SELECT
         s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth,
         sar.record_id, sar.status, sar.remark AS reason, sar.is_reviewed AS is_admin_remark,
         u.full_name AS remarked_by_name
       FROM students s
       LEFT JOIN session_attendance_records sar
              ON sar.session_id = $1 AND sar.student_id = s.student_id
             AND sar.remarked_by IS NOT NULL
       LEFT JOIN users u ON u.user_id = sar.remarked_by
       WHERE s.course_id = $2
          OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = $2))
       ORDER BY s.roll_number`,
      [sessionId, session.course_id],
    );

    res.json(rows);
  } catch (err) {
    next(err);
  }
};

const saveSessionAttendance = async (req, res, next) => {
  const client = await getClient();
  try {
    const { sessionId } = req.params;
    const { records } = req.body;
    const session = await verifySessionAccess(req, sessionId);

    if (!session) {
      return res
        .status(403)
        .json({ error: "You can only update your own session" });
    }

    if (!Array.isArray(records) || records.length === 0) {
      return res.status(400).json({ error: "records[] are required" });
    }

    await client.query("BEGIN");
    const saved = [];

    for (const rec of records) {
      const { rows } = await client.query(
        `INSERT INTO session_attendance_records
           (session_id, student_id, course_id, major_id, status, remark, remarked_by, is_reviewed)
         VALUES ($1, $2, $3, (SELECT major_id FROM students WHERE student_id = $2), $4, $5, $6, $7)
         ON CONFLICT (session_id, student_id)
         DO UPDATE SET
           status          = EXCLUDED.status,
           remark          = EXCLUDED.remark,
           remarked_by     = EXCLUDED.remarked_by,
           is_reviewed     = EXCLUDED.is_reviewed,
           updated_at      = NOW()
         RETURNING *`,
        [
          sessionId,
          rec.student_id,
          session.course_id,
          rec.status,
          rec.reason || null,
          req.user.user_id,
          req.user.role === "admin" || req.user.role === "admin_teacher",
        ],
      );

      await client.query(
        `INSERT INTO attendance_records
           (session_id, student_id, course_id, major_id, date, status, remark, remarked_by, is_reviewed)
         VALUES ($1, $2, $3, (SELECT major_id FROM students WHERE student_id = $2), $4, $5, $6, $7, $8)
         ON CONFLICT (session_id, student_id)
         DO UPDATE SET
           status          = EXCLUDED.status,
           remark          = EXCLUDED.remark,
           remarked_by     = EXCLUDED.remarked_by,
           is_reviewed     = EXCLUDED.is_reviewed,
           updated_at      = NOW()`,
        [
          sessionId,
          rec.student_id,
          session.course_id,
          session.session_date,
          rec.status,
          rec.reason || null,
          req.user.user_id,
          req.user.role === "admin" || req.user.role === "admin_teacher",
        ],
      );

      saved.push(rows[0]);
    }

    await client.query("COMMIT");

    AuditLog.create({
      event_type: "session_attendance_marked",
      performed_by: {
        user_id: req.user.user_id,
        name: req.user.full_name || req.user.email || "Unknown",
        role: req.user.role,
      },
      metadata: {
        session_id: sessionId,
        course_id: session.course_id,
        records_saved: saved.length,
      },
    }).catch(() => {});

    res.json({ saved: saved.length, records: saved });
  } catch (err) {
    await client.query("ROLLBACK");
    next(err);
  } finally {
    client.release();
  }
};

const getAttendanceByDate = async (req, res, next) => {
  try {
    const { classId, date } = req.params;
    const { rows } = await query(
      `SELECT
         s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth,
         sar.record_id, sar.status, sar.remark AS reason, sar.is_reviewed AS is_admin_remark,
         u.full_name AS remarked_by_name,
         cs.session_id
       FROM students s
       LEFT JOIN course_sessions cs
              ON cs.course_id = $1 AND cs.session_date = $2
       LEFT JOIN session_attendance_records sar
              ON sar.session_id = cs.session_id AND sar.student_id = s.student_id
             AND sar.remarked_by IS NOT NULL
       LEFT JOIN users u ON u.user_id = sar.remarked_by
       WHERE s.course_id = $1
          OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = $1))
       ORDER BY s.roll_number`,
      [classId, date],
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// POST /api/attendance
// Body: { class_id, date, records: [{ student_id, status, reason }] }
const saveAttendance = async (req, res, next) => {
  const client = await getClient();
  try {
    const { class_id, date, records } = req.body;
    if (!class_id || !date || !Array.isArray(records) || records.length === 0) {
      return res
        .status(400)
        .json({ error: "class_id, date, and records[] are required" });
    }
    // Teachers can only mark their own course
    if (req.user.role === "teacher") {
      const { rows } = await query(
        "SELECT course_id FROM courses WHERE course_id = $1 AND teacher_id = $2",
        [class_id, req.user.user_id],
      );
      if (rows.length === 0) {
        return res
          .status(403)
          .json({ error: "You can only mark attendance for your own class" });
      }
    }

    await client.query("BEGIN");
    const sessionId = await getOrCreateSession(
      client,
      class_id,
      date,
      req.user.user_id,
    );
    const saved = [];
    for (const rec of records) {
      const { rows } = await client.query(
        `INSERT INTO session_attendance_records
           (session_id, student_id, course_id, major_id, status, remark, remarked_by, is_reviewed)
         VALUES ($1, $2, $3, (SELECT major_id FROM students WHERE student_id = $2), $4, $5, $6, $7)
         ON CONFLICT (session_id, student_id)
         DO UPDATE SET
           status          = EXCLUDED.status,
           remark          = EXCLUDED.remark,
           remarked_by     = EXCLUDED.remarked_by,
           is_reviewed     = EXCLUDED.is_reviewed,
           updated_at      = NOW()
         RETURNING *`,
        [
          sessionId,
          rec.student_id,
          class_id,
          rec.status,
          rec.reason || null,
          req.user.user_id,
          req.user.role === "admin" || req.user.role === "admin_teacher",
        ],
      );

      await client.query(
        `INSERT INTO attendance_records
           (session_id, student_id, course_id, major_id, date, status, remark, remarked_by, is_reviewed)
         VALUES ($1, $2, $3, (SELECT major_id FROM students WHERE student_id = $2), $4, $5, $6, $7, $8)
         ON CONFLICT (session_id, student_id)
         DO UPDATE SET
           status          = EXCLUDED.status,
           remark          = EXCLUDED.remark,
           remarked_by     = EXCLUDED.remarked_by,
           is_reviewed     = EXCLUDED.is_reviewed,
           updated_at      = NOW()`,
        [
          sessionId,
          rec.student_id,
          class_id,
          date,
          rec.status,
          rec.reason || null,
          req.user.user_id,
          req.user.role === "admin" || req.user.role === "admin_teacher",
        ],
      );

      saved.push(rows[0]);
    }
    await client.query("COMMIT");

    // Audit log
    AuditLog.insertMany(
      records.map((r) => ({
        event_type: "attendance_mark",
        performed_by: { user_id: req.user.user_id, role: req.user.role },
        target: { student_id: r.student_id, class_id, date },
        change: { to_status: r.status, reason: r.reason },
      })),
    ).catch(() => {});

    res.json({ saved: saved.length, records: saved });
  } catch (err) {
    await client.query("ROLLBACK");
    next(err);
  } finally {
    client.release();
  }
};

// PUT /api/attendance/:recordId/remark  (admin only)
const remarkAttendance = async (req, res, next) => {
  try {
    const { recordId } = req.params;
    const { status, reason } = req.body;
    const old = await query(
      "SELECT * FROM attendance_records WHERE record_id = $1",
      [recordId],
    );
    if (!old.rows.length)
      return res.status(404).json({ error: "Record not found" });

    const { rows } = await query(
      `UPDATE attendance_records
       SET status = $1, remark = $2, remarked_by = $3, is_reviewed = TRUE, updated_at = NOW()
       WHERE record_id = $4
       RETURNING record_id, session_id, student_id, course_id AS class_id, date,
                 status, remark AS reason, is_reviewed AS is_admin_remark, remarked_by`,
      [status, reason, req.user.user_id, recordId],
    );

    AuditLog.create({
      event_type: "attendance_remark",
      performed_by: { user_id: req.user.user_id, role: "admin" },
      target: { student_id: rows[0].student_id, date: rows[0].date },
      change: { from_status: old.rows[0].status, to_status: status, reason },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// GET /api/attendance/:classId/history?from=&to=
const getHistory = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { from, to } = req.query;
    const { rows } = await query(
      `SELECT ar.record_id, ar.session_id, ar.student_id,
              ar.course_id AS class_id, ar.date, ar.status,
              ar.remark AS reason, ar.is_reviewed AS is_admin_remark,
              ar.remarked_by, ar.created_at, ar.updated_at,
              s.full_name, s.roll_number
       FROM attendance_records ar
       JOIN students s ON s.student_id = ar.student_id
       WHERE ar.course_id = $1
         AND ar.date BETWEEN $2 AND $3
         AND ar.remarked_by IS NOT NULL
       ORDER BY ar.date DESC, s.roll_number`,
      [
        classId,
        from || "2000-01-01",
        to || new Date().toISOString().split("T")[0],
      ],
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

const listSessions = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { rows } = await query(
      `SELECT
         cs.session_id,
         cs.session_name,
         cs.session_date,
         cs.notes,
         cs.created_at,
         COALESCE(sa.marked_count, 0) AS marked_count,
         COALESCE(st.total_students, 0) AS total_students,
         CASE
           WHEN COALESCE(sa.marked_count, 0) > 0
                AND COALESCE(st.total_students, 0) > 0
                AND COALESCE(sa.marked_count, 0) >= COALESCE(st.total_students, 0)
             THEN TRUE
           ELSE FALSE
         END AS is_done
       FROM course_sessions cs
       LEFT JOIN (
         SELECT session_id, COUNT(*) AS marked_count
         FROM session_attendance_records
         WHERE remarked_by IS NOT NULL
         GROUP BY session_id
       ) sa ON sa.session_id = cs.session_id
       LEFT JOIN (
         SELECT c.course_id, COUNT(s.student_id) AS total_students
         FROM courses c
         LEFT JOIN students s ON s.course_id = c.course_id
                              OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = c.course_id))
         GROUP BY c.course_id
       ) st ON st.course_id = cs.course_id
       WHERE cs.course_id = $1
       ORDER BY cs.session_date DESC, cs.created_at DESC`,
      [classId],
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  createSession,
  getSessionAttendance,
  saveSessionAttendance,
  getAttendanceByDate,
  saveAttendance,
  remarkAttendance,
  getHistory,
  listSessions,
};
