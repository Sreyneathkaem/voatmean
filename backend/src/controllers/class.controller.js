const { query } = require("../config/db");

const getMyClass = async (req, res, next) => {
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
       )
       SELECT c.course_id AS class_id, c.course_name AS class_name,
              c.academic_year, c.teacher_id, c.term_id, c.major_id,
              c.total_sessions_planned, c.created_at,
              u.full_name AS teacher_name,
              COUNT(DISTINCT s.student_id) AS student_count,
              COUNT(DISTINCT CASE WHEN ar.session_id = a.session_id THEN ar.student_id END) AS marked_today
       FROM courses c
       LEFT JOIN users u ON u.user_id = c.teacher_id
       LEFT JOIN students s ON s.course_id = c.course_id
                            OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = c.course_id))
       LEFT JOIN active_sess a ON a.course_id = c.course_id
       LEFT JOIN attendance_records ar ON ar.course_id = c.course_id AND ar.student_id = s.student_id
       WHERE c.teacher_id = $1
       GROUP BY c.course_id, u.full_name, a.session_id
       ORDER BY c.course_name`,
      [req.user.user_id],
    );
    if (!rows.length)
      return res.status(200).json([]);
    // Return all classes (array) with attendance status
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

module.exports = { getMyClass };
