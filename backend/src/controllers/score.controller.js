const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

/**
 * POST /api/scores/subject
 * Body: { student_id, subject_id, class_id, month, teacher_score, max_score? }
 * month format: YYYY-MM
 */
const upsertSubjectScore = async (req, res, next) => {
  try {
    const { student_id, subject_id, class_id, month, teacher_score, max_score } = req.body;
    const monthStart = `${month}-01`;

    if (!student_id || !subject_id || !class_id || !month || teacher_score === undefined) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const { rows } = await query(
      `INSERT INTO subject_scores (student_id, subject_id, class_id, month, teacher_score, max_score, entered_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       ON CONFLICT (student_id, subject_id, month)
       DO UPDATE SET
         teacher_score = EXCLUDED.teacher_score,
         max_score     = EXCLUDED.max_score,
         entered_by    = EXCLUDED.entered_by,
         updated_at    = NOW()
       RETURNING *`,
      [student_id, subject_id, class_id, monthStart, teacher_score, max_score || 100.00, req.user.user_id]
    );

    AuditLog.create({
      event_type: "subject_score_entered",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { student_id, subject_id, month: monthStart },
      change: { teacher_score }
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/scores/final/:classId/:subjectId/:month
 * Returns blended scores for all students in a class for a specific subject/month.
 */
const getMonthlyGrades = async (req, res, next) => {
  try {
    const { classId, subjectId, month } = req.params;
    const monthStart = `${month}-01`;

    // 1. Fetch the Effective Formula
    const { rows: formulaRows } = await query(
      `SELECT * FROM score_formula_config WHERE subject_id = $1
       UNION ALL
       SELECT * FROM score_formula_config WHERE subject_id IS NULL
         AND NOT EXISTS (SELECT 1 FROM score_formula_config WHERE subject_id = $1)
       LIMIT 1`,
      [subjectId]
    );

    if (!formulaRows.length) {
      return res.status(404).json({ error: "Score formula not found" });
    }
    const formula = formulaRows[0];

    // 2. Fetch Students and calculate Blended Scores
    // Logic:
    // Attendance Score = (Present + 0.5 * Late) / Total Marked
    // Blended = (AttScore * AttWeight) + ((TeacherScore/MaxScore) * TeacherWeight)
    const { rows } = await query(
      `WITH att_stats AS (
        SELECT
          student_id,
          COUNT(*) as total_slots,
          COUNT(*) FILTER (WHERE status = 'present') as present_count,
          COUNT(*) FILTER (WHERE status = 'late') as late_count
        FROM slot_attendance_records sar
        JOIN timetable_slots ts ON ts.slot_id = sar.slot_id
        WHERE ts.subject_id = $1
          AND sar.date >= $2::date
          AND sar.date < ($2::date + interval '1 month')
        GROUP BY student_id
      )
      SELECT
        s.student_id, s.full_name, s.roll_number,
        COALESCE(ss.teacher_score, 0) as teacher_score,
        COALESCE(ss.max_score, 100) as max_score,
        COALESCE(stats.total_slots, 0) as total_attendance_slots,
        CASE
          WHEN COALESCE(stats.total_slots, 0) = 0 THEN 0
          ELSE (stats.present_count + (stats.late_count * 0.5)) / stats.total_slots
        END as attendance_rate
      FROM students s
      JOIN class_students cs ON cs.student_id = s.student_id
      LEFT JOIN att_stats stats ON stats.student_id = s.student_id
      LEFT JOIN subject_scores ss ON ss.student_id = s.student_id
           AND ss.subject_id = $1 AND ss.month = $2::date
      WHERE cs.class_id = $3
      ORDER BY s.roll_number`,
      [subjectId, monthStart, classId]
    );

    const results = rows.map(r => {
      const attScore = r.attendance_rate * 100; // normalize to 0-100
      const teacherNorm = (r.teacher_score / r.max_score) * 100;

      const finalBlended = (attScore * formula.attendance_weight) +
                           (teacherNorm * formula.teacher_score_weight);

      return {
        ...r,
        attendance_score: parseFloat(attScore.toFixed(2)),
        teacher_score_normalized: parseFloat(teacherNorm.toFixed(2)),
        final_score: parseFloat(finalBlended.toFixed(2)),
        formula_applied: formula.mode
      };
    });

    res.json(results);
  } catch (err) {
    next(err);
  }
};

module.exports = {
  upsertSubjectScore,
  getMonthlyGrades
};
