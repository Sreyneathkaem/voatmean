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
    let { classId, subjectId, month } = req.params;
    const monthStart = `${month}-01`;

    // 1. Fetch the Effective Formula
    const { rows: formulaRows } = await query(
      `SELECT * FROM score_formula_config WHERE subject_id::text = $1
       UNION ALL
       SELECT * FROM score_formula_config WHERE subject_id IS NULL
         AND NOT EXISTS (SELECT 1 FROM score_formula_config WHERE subject_id::text = $1)
       LIMIT 1`,
      [subjectId]
    );

    if (!formulaRows.length) {
      return res.status(404).json({ error: "Score formula not found" });
    }
    const formula = formulaRows[0];

    // Deduction rates (e.g. 30% deduction -> 0.70 credit; 0% deduction -> 1.00 credit)
    const permDeduction = formula.permission_deduction != null ? Number(formula.permission_deduction) : 30.0;
    const lateDeduction = formula.late_deduction != null ? Number(formula.late_deduction) : 50.0;
    const absentDeduction = formula.absent_deduction != null ? Number(formula.absent_deduction) : 100.0;

    const presentCredit = 1.0;
    const lateCredit = Math.max(0, (100.0 - lateDeduction) / 100.0);
    const permCredit = Math.max(0, (100.0 - permDeduction) / 100.0);
    const absentCredit = Math.max(0, (100.0 - absentDeduction) / 100.0);

    // 2. Fetch Students and calculate Blended Scores
    const { rows } = await query(
      `WITH att_stats AS (
        SELECT
          student_id,
          COUNT(*) as total_slots,
          COUNT(*) FILTER (WHERE status = 'present') as present_count,
          COUNT(*) FILTER (WHERE status = 'late') as late_count,
          COUNT(*) FILTER (WHERE status = 'permission') as permission_count,
          COUNT(*) FILTER (WHERE status = 'absent') as absent_count
        FROM slot_attendance_records sar
        JOIN timetable_slots ts ON ts.slot_id = sar.slot_id
        WHERE ts.subject_id::text = $1
          AND sar.date >= $2::date
          AND sar.date < ($2::date + interval '1 month')
        GROUP BY student_id
      )
      SELECT
        s.student_id, s.full_name, s.roll_number,
        COALESCE(ss.teacher_score, 0) as teacher_score,
        COALESCE(ss.max_score, 100) as max_score,
        COALESCE(stats.total_slots, 0) as total_attendance_slots,
        COALESCE(stats.present_count, 0) as present_count,
        COALESCE(stats.late_count, 0) as late_count,
        COALESCE(stats.permission_count, 0) as permission_count,
        COALESCE(stats.absent_count, 0) as absent_count,
        CASE
          WHEN COALESCE(stats.total_slots, 0) = 0 THEN 0
          ELSE (
            (stats.present_count::numeric * $4::numeric) +
            (stats.late_count::numeric * $5::numeric) +
            (stats.permission_count::numeric * $6::numeric) +
            (stats.absent_count::numeric * $7::numeric)
          ) / stats.total_slots::numeric
        END as attendance_rate
      FROM students s
      JOIN class_students cs ON cs.student_id = s.student_id
      LEFT JOIN att_stats stats ON stats.student_id = s.student_id
      LEFT JOIN subject_scores ss ON ss.student_id = s.student_id
           AND ss.subject_id::text = $1 AND ss.month = $2::date
      WHERE cs.class_id::text = $3
      ORDER BY s.roll_number`,
      [subjectId, monthStart, classId, presentCredit, lateCredit, permCredit, absentCredit]
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
        formula_applied: formula.mode,
        formula_config: {
          attendance_weight: Number(formula.attendance_weight),
          teacher_score_weight: Number(formula.teacher_score_weight),
          permission_deduction: permDeduction,
          late_deduction: lateDeduction,
          absent_deduction: absentDeduction,
        }
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
