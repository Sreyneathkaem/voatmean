-- ═══════════════════════════════════════════════════════════════
-- Voatmean — 004: Attendance Deduction & Scoring Customization
--
-- Enables teachers and administrators to configure:
--   • Attendance deductions per status (absent, permission, late)
--   • Weighted blend between attendance score and teacher monthly subject score
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE score_formula_config
  ADD COLUMN IF NOT EXISTS permission_deduction DECIMAL(5,2) NOT NULL DEFAULT 30.00,
  ADD COLUMN IF NOT EXISTS late_deduction DECIMAL(5,2) NOT NULL DEFAULT 50.00,
  ADD COLUMN IF NOT EXISTS absent_deduction DECIMAL(5,2) NOT NULL DEFAULT 100.00;

COMMENT ON COLUMN score_formula_config.permission_deduction IS
  'Percentage deducted from attendance score for excused absence (permission). Default 30.00 (70% credit).';

COMMENT ON COLUMN score_formula_config.late_deduction IS
  'Percentage deducted from attendance score for late arrival. Default 50.00 (50% credit).';

COMMENT ON COLUMN score_formula_config.absent_deduction IS
  'Percentage deducted from attendance score for unexcused absence. Default 100.00 (0% credit).';

SELECT '004_attendance_deduction_formula.sql applied. Configurable attendance deductions enabled.' AS message;
