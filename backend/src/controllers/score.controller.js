const { query } = require('../config/db');

// GET /api/scores/:classId/:month  (month = YYYY-MM)
const getMonthlyScores = async (req, res, next) => {
  try {
    const { classId, month } = req.params;
    const monthStart = `${month}-01`;

    const { rows: ruleRows } = await query(
      `SELECT base_score, absent_deduction, late_deduction
       FROM score_rules
       WHERE course_id = $1`,
      [classId],
    );

    if (!ruleRows.length) {
      return res.status(404).json({ error: 'Score rules not found' });
    }

    const rule = ruleRows[0];

    const { rows } = await query(
      `SELECT
         s.student_id, s.roll_number, s.full_name,
         COALESCE(ac.total_absences, 0) AS absences,
         COALESCE(ac.total_lates, 0)    AS lates,
         sr.base_score,
         sr.absent_deduction,
         sr.late_deduction,
         CASE
           WHEN COALESCE(ac.total_marked_sessions, 0) = 0 THEN 0
           ELSE GREATEST(
             0,
             sr.base_score
             - (COALESCE(ac.total_absences, 0) * sr.absent_deduction)
             - (COALESCE(ac.total_lates, 0) * sr.late_deduction)
           )
         END AS final_score
       FROM students s
       JOIN score_rules sr ON sr.course_id = $1
       LEFT JOIN (
         SELECT sar.student_id,
           COUNT(*) FILTER (WHERE sar.status = 'absent') AS total_absences,
           COUNT(*) FILTER (WHERE sar.status = 'late')   AS total_lates,
           COUNT(*) AS total_marked_sessions
         FROM session_attendance_records sar
         JOIN course_sessions cs ON cs.session_id = sar.session_id
         WHERE cs.course_id = $1
           AND DATE_TRUNC('month', cs.session_date) = DATE_TRUNC('month', $2::date)
         GROUP BY sar.student_id
       ) ac ON ac.student_id = s.student_id
       WHERE s.course_id = $1
          OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = $1))
       ORDER BY final_score DESC, s.roll_number`,
      [classId, monthStart],
    );
    res.json(rows.map((r, i) => ({ ...r, rank: i + 1 })));
  } catch (err) { next(err); }
};

// GET /api/scores/:classId/rules
const getScoreRules = async (req, res, next) => {
  try {
    const { rows } = await query(
      'SELECT * FROM score_rules WHERE course_id = $1',
      [req.params.classId]
    );
    if (!rows.length) return res.status(404).json({ error: 'Score rules not found' });
    res.json(rows[0]);
  } catch (err) { next(err); }
};

// PUT /api/scores/:classId/rules
const updateScoreRules = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { base_score, absent_deduction, late_deduction } = req.body;
    const { rows } = await query(
      `INSERT INTO score_rules (course_id, base_score, absent_deduction, late_deduction)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (course_id) DO UPDATE SET
         base_score = EXCLUDED.base_score,
         absent_deduction = EXCLUDED.absent_deduction,
         late_deduction = EXCLUDED.late_deduction,
         updated_at = NOW()
       RETURNING *`,
      [classId, base_score, absent_deduction, late_deduction]
    );
    res.json(rows[0]);
  } catch (err) { next(err); }
};

module.exports = { getMonthlyScores, getScoreRules, updateScoreRules };
