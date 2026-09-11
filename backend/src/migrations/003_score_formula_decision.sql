-- ═══════════════════════════════════════════════════════════════
-- Voatmean — 003: Section 9 Decision — Weighted Blend Score Formula
--
-- Locks in the Section 9 open decision from the requirements doc:
--   • Final monthly score = a WEIGHTED BLEND of attendance-derived
--     score and teacher-entered subject score (not attendance-only,
--     not teacher-only).
--   • Weighting is CONFIGURABLE PER SUBJECT, not fixed system-wide.
--     score_formula_config already supports this via its nullable
--     subject_id column — this migration flips the system-wide
--     default row to weighted_blend and adds the unique index that
--     lets the API upsert one override row per subject.
--
-- Also adds subject_scores.max_score: the exact 0–100 vs 0–10 scale
-- for teacher-entered scores was NOT decided yet, so rather than
-- hardcode one, each score row carries its own scale. Existing and
-- new rows default to 100.00 (most common convention) until this is
-- revisited — application code MUST normalize
-- (teacher_score / max_score) before blending, never assume a fixed
-- denominator.
--
-- Run: node src/migrations/run.js
-- ═══════════════════════════════════════════════════════════════

-- ── subject_scores.max_score ───────────────────────
ALTER TABLE subject_scores
  ADD COLUMN IF NOT EXISTS max_score DECIMAL(5,2) NOT NULL DEFAULT 100.00;

COMMENT ON COLUMN subject_scores.max_score IS
  'Scale the teacher_score is entered on for THIS row (e.g. 100.00 or 10.00). Always normalize teacher_score/max_score before blending with the attendance score.';

-- ── score_formula_config: allow one override row per subject ──
-- Partial unique index (not a full UNIQUE constraint) so multiple
-- NULL subject_id rows are still technically allowed at the DB
-- level, but every real subject can have at most one override row.
-- This is what lets the upsert API use ON CONFLICT safely.
CREATE UNIQUE INDEX IF NOT EXISTS idx_score_formula_config_subject
  ON score_formula_config (subject_id)
  WHERE subject_id IS NOT NULL;

-- ── score_formula_config: flip default to weighted_blend ──────
-- The single system-wide row (subject_id IS NULL) now acts as the
-- FALLBACK for any subject that hasn't been given its own override.
-- 70/30 (subject/attendance) mirrors the example weighting given in
-- Section 9 of the requirements doc. Adjust anytime via
-- PUT /api/admin/score-formula/default or per-subject via
-- PUT /api/admin/score-formula/:subjectId — no migration needed for
-- future weight changes.
UPDATE score_formula_config
SET mode                 = 'weighted_blend',
    attendance_weight    = 0.30,
    teacher_score_weight = 0.70,
    updated_at           = NOW()
WHERE subject_id IS NULL;

-- Safety net: create the default row if 002's seed was somehow skipped.
INSERT INTO score_formula_config (subject_id, mode, attendance_weight, teacher_score_weight)
SELECT NULL, 'weighted_blend', 0.30, 0.70
WHERE NOT EXISTS (SELECT 1 FROM score_formula_config WHERE subject_id IS NULL);

SELECT '003_score_formula_decision.sql applied. Default is now a 70/30 (subject/attendance) blend, overridable per subject.' AS message;
