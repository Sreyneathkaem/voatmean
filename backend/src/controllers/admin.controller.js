const { query } = require("../config/db");

// GET /api/admin/dashboard
const getDashboard = async (req, res, next) => {
  try {
    let { rows } = await query(
      `WITH latest_session AS (
         SELECT session_id, course_id, session_name, session_date
         FROM (
           SELECT
             session_id,
             course_id,
             session_name,
             session_date,
             ROW_NUMBER() OVER (
               PARTITION BY course_id
               ORDER BY
                 CASE WHEN session_date = CURRENT_DATE THEN 0 ELSE 1 END,
                 ABS(session_date - CURRENT_DATE) ASC,
                 session_date DESC
             ) as rank
           FROM course_sessions
         ) ranked
         WHERE rank = 1
       ),
       stats AS (
         SELECT
           c.course_id AS class_id,
           COUNT(DISTINCT s.student_id) AS total_students,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'present') AS present_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')  AS absent_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')    AS late_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') AS permission_count
         FROM courses c
         LEFT JOIN students s ON s.course_id = c.course_id
                              OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = c.course_id))
         LEFT JOIN attendance_records ar ON ar.student_id = s.student_id AND ar.course_id = c.course_id
         GROUP BY c.course_id
       ),
       active_session_stats AS (
         SELECT
           ls.course_id,
           ls.session_name AS active_session_name,
           ls.session_date AS active_session_date,
           COUNT(sar.record_id) AS marked_today
         FROM latest_session ls
         LEFT JOIN session_attendance_records sar ON sar.session_id = ls.session_id
         GROUP BY ls.course_id, ls.session_name, ls.session_date
       )
       SELECT
         c.course_id AS class_id,
         c.course_name AS class_name,
         u.full_name AS teacher_name,
         COALESCE(st.total_students, 0) AS total_students,
         COALESCE(st.present_count, 0) AS present_count,
         COALESCE(st.absent_count, 0) AS absent_count,
         COALESCE(st.late_count, 0) AS late_count,
         COALESCE(st.permission_count, 0) AS permission_count,
         COALESCE(ass.active_session_name, '') AS active_session_name,
         COALESCE(ass.active_session_date::text, '') AS active_session_date,
         COALESCE(ass.marked_today, 0) AS marked_today,
         ROUND(
           COALESCE(st.present_count, 0) * 100.0 / NULLIF(COALESCE(st.total_students, 0), 0), 1
         ) AS attendance_rate
       FROM courses c
       LEFT JOIN users u ON u.user_id = c.teacher_id
       LEFT JOIN stats st ON st.class_id = c.course_id
       LEFT JOIN active_session_stats ass ON ass.course_id = c.course_id
       ORDER BY c.course_name`
    );

    const courseIds = rows.map((r) => `'${r.class_id}'`).join(",");
    if (courseIds) {
      const majorRes = await query(
        `SELECT cm.course_id, string_agg(DISTINCT m.major_name, ', ') AS major_names
         FROM course_majors cm
         JOIN majors m ON m.major_id = cm.major_id
         WHERE cm.course_id IN (${courseIds})
         GROUP BY cm.course_id`,
      );
      const majorMap = new Map(majorRes.rows.map((r) => [r.course_id, r.major_names]));
      rows = rows.map((r) => ({ ...r, major_names: majorMap.get(r.class_id) || "" }));
    }

    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/dashboard/export-scores
const getDashboardExport = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT
         sas.student_id,
         sas.roll_number,
         sas.full_name,
         c.course_name,
         sas.present_count,
         sas.absent_count,
         sas.late_count,
         sas.permission_count,
         sas.computed_score,
         sas.score_percentage
       FROM student_attendance_scores sas
       JOIN courses c ON c.course_id = sas.course_id
       ORDER BY c.course_name, sas.roll_number`
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/teachers
const getTeachers = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT u.user_id, u.full_name, u.email,
              COUNT(DISTINCT c.course_id) AS course_count,
              string_agg(DISTINCT c.course_name, ', ') AS course_names,
              string_agg(DISTINCT t.term_name, ', ') AS term_names
       FROM users u
       LEFT JOIN courses c ON c.teacher_id = u.user_id
       LEFT JOIN terms t   ON t.term_id = c.term_id
       WHERE u.role = 'teacher' OR u.role = 'admin_teacher'
       GROUP BY u.user_id, u.full_name, u.email
       ORDER BY u.full_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/academic-years
const getAcademicYears = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT year_id, is_active FROM academic_years ORDER BY year_id DESC`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/majors
const getMajors = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT major_id, major_name FROM majors ORDER BY major_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/students-by-major
// Returns each major with the list of students belonging to it.
const getStudentsByMajor = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT m.major_id, m.major_name,
              s.student_id, s.full_name, s.roll_number, s.gender
       FROM majors m
       LEFT JOIN students s ON s.major_id = m.major_id
       ORDER BY m.major_name, s.roll_number`,
    );

    const byMajor = new Map();
    for (const row of rows) {
      if (!byMajor.has(row.major_id)) {
        byMajor.set(row.major_id, {
          major_id: row.major_id,
          major_name: row.major_name,
          students: [],
        });
      }
      if (row.student_id) {
        byMajor.get(row.major_id).students.push({
          student_id: row.student_id,
          full_name: row.full_name,
          roll_number: row.roll_number,
          gender: row.gender,
        });
      }
    }
    res.json(Array.from(byMajor.values()));
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/terms
const getTerms = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT t.term_id, t.term_name, t.academic_year_id,
              t.start_date, t.end_date,
              COUNT(DISTINCT c.course_id)  AS course_count,
              COUNT(DISTINCT c.teacher_id) AS teacher_count
       FROM terms t
       LEFT JOIN courses c ON c.term_id = t.term_id
       GROUP BY t.term_id
       ORDER BY t.academic_year_id DESC, t.term_name`,
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/terms
const createTerm = async (req, res, next) => {
  try {
    const { academic_year_id, term_name, start_date, end_date } = req.body;
    if (!academic_year_id || !term_name || !start_date || !end_date) {
      return res.status(400).json({
        error: "academic_year_id, term_name, start_date and end_date are required",
      });
    }
    const { rows } = await query(
      `INSERT INTO terms (academic_year_id, term_name, start_date, end_date)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (academic_year_id, term_name) DO UPDATE SET
         start_date = EXCLUDED.start_date,
         end_date   = EXCLUDED.end_date
       RETURNING *`,
      [academic_year_id, term_name, start_date, end_date],
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/teachers
const createTeacher = async (req, res, next) => {
  try {
    const { full_name, email, gender, class_id } = req.body;
    if (!full_name || !email || !class_id) {
      return res
        .status(400)
        .json({ error: "full_name, email and class_id are required" });
    }
    // Upsert user
    const userRes = await query(
      `INSERT INTO users (full_name, email, role)
       VALUES ($1, $2, 'teacher')
       ON CONFLICT (email) DO UPDATE SET
         full_name = EXCLUDED.full_name,
         role = 'teacher'
       RETURNING *`,
      [full_name, email],
    );
    const teacher = userRes.rows[0];
    // Assign to course
    await query("UPDATE courses SET teacher_id = $1 WHERE course_id = $2", [
      teacher.user_id,
      class_id,
    ]);
    res.status(201).json({ teacher, class_id });
  } catch (err) {
    next(err);
  }
};

// GET /api/admin/classes
const getClasses = async (req, res, next) => {
  try {
    const { rows } = await query(
      `WITH active_sess AS (
         SELECT session_id, course_id, session_name, session_date
         FROM (
           SELECT
             session_id,
             course_id,
             session_name,
             session_date,
             ROW_NUMBER() OVER (
               PARTITION BY course_id
               ORDER BY
                 CASE WHEN session_date = CURRENT_DATE THEN 0 ELSE 1 END,
                 ABS(session_date - CURRENT_DATE) ASC,
                 session_date DESC
             ) as rank
           FROM course_sessions
         ) ranked
         WHERE rank = 1
       ),
       stats AS (
         SELECT c.course_id AS class_id,
           COUNT(DISTINCT s.student_id) AS student_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'present')    AS present_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')     AS absent_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')       AS late_count,
           COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') AS permission_count,
           COUNT(DISTINCT CASE WHEN ar.session_id = a.session_id THEN ar.record_id END) AS marked_today
         FROM courses c
         LEFT JOIN students s ON s.course_id = c.course_id
                              OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = c.course_id))
         LEFT JOIN active_sess a ON a.course_id = c.course_id
         LEFT JOIN attendance_records ar ON ar.student_id = s.student_id AND ar.course_id = c.course_id
         GROUP BY c.course_id
       ),
       major_info AS (
         SELECT cm.course_id,
           json_agg(DISTINCT cm.major_id) FILTER (WHERE cm.major_id IS NOT NULL) AS major_ids,
           string_agg(DISTINCT m.major_name, ', ') FILTER (WHERE m.major_name IS NOT NULL) AS major_names
         FROM course_majors cm
         JOIN majors m ON m.major_id = cm.major_id
         GROUP BY cm.course_id
       )
       SELECT c.course_id AS class_id, c.course_name AS class_name,
         c.academic_year, c.teacher_id, c.term_id, c.major_id,
         c.total_sessions_planned, c.created_at,
         u.full_name AS teacher_name,
         t.term_name, m.major_name,
         COALESCE(s.student_count, 0) AS student_count,
         COALESCE(s.marked_today, 0) AS marked_today,
         COALESCE(s.present_count, 0) AS present_count,
         COALESCE(s.absent_count, 0) AS absent_count,
         COALESCE(s.late_count, 0) AS late_count,
         COALESCE(s.permission_count, 0) AS permission_count,
         COALESCE(mj.major_ids, '[]'::json) AS major_ids,
         COALESCE(mj.major_names, '') AS major_names
       FROM courses c
       LEFT JOIN users u ON u.user_id = c.teacher_id
       LEFT JOIN terms t ON t.term_id = c.term_id
       LEFT JOIN majors m ON m.major_id = c.major_id
       LEFT JOIN stats s ON s.class_id = c.course_id
       LEFT JOIN major_info mj ON mj.course_id = c.course_id
       ORDER BY c.course_name`
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// POST /api/admin/classes  (add course)
const createClass = async (req, res, next) => {
  try {
    const {
      class_name,
      term_id,
      major_id,
      total_sessions_planned,
      teacher_id,
      teacher_name,
      teacher_email,
      major_ids = [],
    } = req.body;

    if (!class_name) {
      return res.status(400).json({ error: "class_name is required" });
    }

    // Generate next course_id (find highest numeric ID and increment)
    const maxIdResult = await query(
      `SELECT course_id FROM courses 
       WHERE course_id ~ '^[0-9]+$' 
       ORDER BY CAST(course_id AS INTEGER) DESC 
       LIMIT 1`,
    );

    let nextId = "001";
    if (maxIdResult.rows.length > 0) {
      const maxId = parseInt(maxIdResult.rows[0].course_id);
      nextId = String(maxId + 1).padStart(3, "0");
    }

    // Derive academic_year from the chosen term (fallback to active default)
    let academicYear = "2025-2026";
    if (term_id) {
      const termRes = await query(
        `SELECT academic_year_id FROM terms WHERE term_id = $1`,
        [term_id],
      );
      if (termRes.rows[0]?.academic_year_id) {
        academicYear = termRes.rows[0].academic_year_id;
      }
    }

    // Normalise major_ids: accept single major_id, array of major_ids, or empty
    let primaryMajorId = major_id || null;
    const allMajorIds = Array.isArray(major_ids)
      ? [...new Set(major_ids.filter(Boolean))]
      : primaryMajorId
        ? [primaryMajorId]
        : [];

    // Create the course (store first selected major as legacy major_id for ordering / grouping)
    const classResult = await query(
      `INSERT INTO courses
         (course_id, course_name, academic_year, term_id, major_id, total_sessions_planned)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING course_id AS class_id, course_name AS class_name, academic_year,
                 term_id, major_id, total_sessions_planned, teacher_id`,
      [
        nextId,
        class_name,
        academicYear,
        term_id || null,
        primaryMajorId,
        Number(total_sessions_planned) || 0,
      ],
    );
    const newClass = classResult.rows[0];

    // Default score rules so scoring works immediately
    await query(
      `INSERT INTO score_rules (course_id) VALUES ($1)
       ON CONFLICT (course_id) DO NOTHING`,
      [newClass.class_id],
    );

    // Create course-major links
    if (allMajorIds.length > 0) {
      const cmValues = allMajorIds.map((mid) => `('${newClass.class_id}', '${mid}')`).join(", ");
      await query(`INSERT INTO course_majors (course_id, major_id) VALUES ${cmValues} ON CONFLICT DO NOTHING`);
    }

    // Auto-generate the planned sessions (weekly) so admins don't add them
    // one by one. Sessions start from the term's start_date, else today.
    const planned = Number(total_sessions_planned) || 0;
    if (planned > 0) {
      let startDate = new Date();
      if (term_id) {
        const termDate = await query(
          `SELECT start_date FROM terms WHERE term_id = $1`,
          [term_id],
        );
        if (termDate.rows[0]?.start_date) {
          startDate = new Date(termDate.rows[0].start_date);
        }
      }
      for (let i = 0; i < planned; i += 1) {
        const d = new Date(startDate);
        d.setDate(d.getDate() + i * 7);
        const ds = d.toISOString().split("T")[0];
        await query(
          `INSERT INTO course_sessions (course_id, major_id, session_name, session_date)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (course_id, session_date) DO NOTHING`,
          [newClass.class_id, primaryMajorId, `Session ${i + 1}`, ds],
        );
      }
    }

    // Resolve teacher: use existing teacher_id, or create/find by email
    let resolvedTeacherId = teacher_id || null;
    if (!resolvedTeacherId && teacher_email && teacher_name) {
      const teacherResult = await query(
        `INSERT INTO users (full_name, email, role)
         VALUES ($1, $2, 'teacher')
         ON CONFLICT (email) DO UPDATE 
         SET full_name = EXCLUDED.full_name
         RETURNING user_id`,
        [teacher_name, teacher_email],
      );
      resolvedTeacherId = teacherResult.rows[0].user_id;
    }

    if (resolvedTeacherId) {
      await query(`UPDATE courses SET teacher_id = $1 WHERE course_id = $2`, [
        resolvedTeacherId,
        newClass.class_id,
      ]);
      newClass.teacher_id = resolvedTeacherId;
    }

    res.status(201).json(newClass);
  } catch (err) {
    next(err);
  }
};

// PUT /api/admin/classes/:class_id/teacher
const assignTeacher = async (req, res, next) => {
  try {
    const { class_id } = req.params;
    const { teacher_id } = req.body;

    if (teacher_id) {
      await query(
        `UPDATE users
         SET role = 'teacher'
         WHERE user_id = $1 AND role IN ('admin', 'admin_teacher', 'teacher')`,
        [teacher_id],
      );
    }

    // If teacher_id is null or empty, unassign the teacher
    const { rows } = await query(
      `UPDATE courses SET teacher_id = $1 WHERE course_id = $2
       RETURNING course_id AS class_id, course_name AS class_name, academic_year, teacher_id`,
      [teacher_id || null, class_id],
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: "Class not found" });
    }

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getDashboard,
  getTeachers,
  createTeacher,
  getClasses,
  createClass,
  assignTeacher,
  getAcademicYears,
  getMajors,
  getStudentsByMajor,
  getTerms,
  createTerm,
  getDashboardExport,
};
