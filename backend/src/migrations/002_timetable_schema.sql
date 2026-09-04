-- ═══════════════════════════════════════════════════════════════
-- Voatmean — 002: Timetable Model
--
-- Introduces the Class × Subject × Timetable model from Section 4.4
-- of the requirements doc, replacing the EduAttend-era assumption
-- that a "course" is both a homeroom AND a subject at once.
--
-- New concepts, kept deliberately separate:
--   homeroom_classes    — fixed homeroom (e.g. "Grade 10A"), no subject
--   subjects            — school-wide catalog (Math, Khmer, Physics...)
--   timetable_slots      — Class + Subject + Teacher + Day/Period
--   attendance_records   — one row per student, per SLOT, per date
--   subject_scores        — teacher-entered monthly score per student/subject
--
-- NOTE: the homeroom table is named `homeroom_classes`, NOT `classes`.
-- `001_schema.sql` contains a one-time legacy-upgrade shim that looks
-- for a table literally named `classes` and tries to migrate it into
-- `courses` using old EduAttend-era columns (teacher_id, term_id,
-- major_id, ...). If this table were named `classes`, that shim
-- would misfire against it and fail with something like
-- `column "teacher_id" does not exist`. Do not rename this table
-- back to `classes` for any reason — see git history for the
-- original incident.
--
-- This migration is ADDITIVE ONLY. It does not drop or rewrite the
-- existing courses/course_sessions/session_attendance_records tables,
-- since those still power the legacy React admin screens during the
-- transition. Cut those over and drop them in a later migration once
-- the Flutter app is live end-to-end.
--
-- IMPORTANT — manual step required before this is usable:
-- Your current `courses` rows conflate subject + major (e.g.
-- "Cyber Security Fundamentals"). There is no reliable automatic way
-- to derive real homeroom classes (Grade 10A, Grade 11B, etc.) from
-- that data. The backfill block at the bottom seeds one homeroom
-- class per academic year as a PLACEHOLDER so FK constraints don't
-- block development — an admin must create the real classes via the
-- admin UI/API once it exists, then re-point timetable_slots.
--
-- Run: node src/migrations/run.js
-- ═══════════════════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── schools ────────────────────────────────────────
-- Single row today (school_id is FK'd from homeroom_classes so a
-- second school can be added later without a structural rewrite —
-- FR-18).
CREATE TABLE IF NOT EXISTS schools (
  school_id   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  school_name VARCHAR(255) NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT NOW()
);

INSERT INTO schools (school_name)
SELECT 'Voatmean School'
WHERE NOT EXISTS (SELECT 1 FROM schools);

-- ── homeroom_classes (fixed homeroom, independent of subject) ────
-- Replaces the old idea that "courses" are the homeroom. A class
-- spans secondary and high-school grade levels within one school
-- (FR-06). grade_level is free text ("10", "11A-Secondary", etc.)
-- since the exact grade taxonomy isn't finalized yet.
--
-- Named `homeroom_classes` (not `classes`) — see header note above.
CREATE TABLE IF NOT EXISTS homeroom_classes (
  class_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id        UUID        NOT NULL REFERENCES schools(school_id) ON DELETE CASCADE,
  class_name       VARCHAR(100) NOT NULL,          -- e.g. "Grade 10A"
  grade_level      VARCHAR(50),                     -- e.g. "10", "Secondary-2"
  academic_year_id VARCHAR(9)  REFERENCES academic_years(year_id) ON DELETE SET NULL,
  created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, class_name, academic_year_id)
);

-- ── class_students ─────────────────────────────────
-- A student's fixed homeroom membership. Kept as its own join table
-- (rather than a column on students) so a student can be re-assigned
-- across academic years without losing history.
CREATE TABLE IF NOT EXISTS class_students (
  class_id   UUID NOT NULL REFERENCES homeroom_classes(class_id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(student_id)       ON DELETE CASCADE,
  joined_at  TIMESTAMP NOT NULL DEFAULT NOW(),
  PRIMARY KEY (class_id, student_id)
);

-- ── subjects ───────────────────────────────────────
-- School-wide catalog (FR-04). Independent of any one class.
CREATE TABLE IF NOT EXISTS subjects (
  subject_id   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id    UUID         NOT NULL REFERENCES schools(school_id) ON DELETE CASCADE,
  subject_name VARCHAR(100) NOT NULL,
  created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
  UNIQUE (school_id, subject_name)
);

-- ── timetable_slots ────────────────────────────────
-- A specific Class + Subject + Teacher + Day/Period combination
-- (FR-05). day_of_week: 1=Monday .. 7=Sunday. period is an integer
-- ordinal within the day (1st period, 2nd period, ...).
-- Two uniqueness rules enforced at the DB level:
--   1. A class can't have two subjects in the same day/period.
--   2. A teacher can't be double-booked in the same day/period.
CREATE TABLE IF NOT EXISTS timetable_slots (
  slot_id     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id    UUID        NOT NULL REFERENCES homeroom_classes(class_id) ON DELETE CASCADE,
  subject_id  UUID        NOT NULL REFERENCES subjects(subject_id)       ON DELETE RESTRICT,
  teacher_id  UUID        NOT NULL REFERENCES users(user_id)             ON DELETE RESTRICT,
  term_id     UUID        REFERENCES terms(term_id) ON DELETE SET NULL,
  day_of_week SMALLINT    NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
  period      SMALLINT    NOT NULL CHECK (period > 0),
  created_at  TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (class_id, day_of_week, period),
  UNIQUE (teacher_id, day_of_week, period)
);

CREATE INDEX IF NOT EXISTS idx_slots_class   ON timetable_slots (class_id);
CREATE INDEX IF NOT EXISTS idx_slots_teacher ON timetable_slots (teacher_id);
CREATE INDEX IF NOT EXISTS idx_slots_subject ON timetable_slots (subject_id);

-- ── slot_attendance_records ────────────────────────
-- Per-slot attendance (FR-07): one row per student, per timetable
-- slot, per date — not per day. Named distinctly from the legacy
-- attendance_records table so both can coexist during the cutover.
CREATE TABLE IF NOT EXISTS slot_attendance_records (
  record_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  slot_id         UUID        NOT NULL REFERENCES timetable_slots(slot_id) ON DELETE CASCADE,
  student_id      UUID        NOT NULL REFERENCES students(student_id)    ON DELETE CASCADE,
  date            DATE        NOT NULL,
  status          VARCHAR(10) NOT NULL CHECK (status IN ('present','late','absent','permission')),
  reason          TEXT,
  remarked_by     UUID        REFERENCES users(user_id) ON DELETE SET NULL,
  is_admin_remark BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (slot_id, student_id, date)
);

CREATE INDEX IF NOT EXISTS idx_slot_att_student_date ON slot_attendance_records (student_id, date);
CREATE INDEX IF NOT EXISTS idx_slot_att_slot_date     ON slot_attendance_records (slot_id, date);

-- ── subject_scores ─────────────────────────────────
-- Teacher-entered monthly score per student per subject (FR-10).
-- final_score is intentionally left NULL/computed-later: the
-- attendance-vs-teacher-score blend formula is still an open
-- decision (Section 9) and must not be hardcoded here. Once that's
-- resolved, either add a generated column or compute it in the
-- application layer — don't bake an assumption into the schema.
CREATE TABLE IF NOT EXISTS subject_scores (
  score_id        UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id      UUID         NOT NULL REFERENCES students(student_id)       ON DELETE CASCADE,
  subject_id      UUID         NOT NULL REFERENCES subjects(subject_id)       ON DELETE CASCADE,
  class_id        UUID         NOT NULL REFERENCES homeroom_classes(class_id) ON DELETE CASCADE,
  month           DATE         NOT NULL,   -- store as first-of-month, e.g. 2026-09-01
  teacher_score   DECIMAL(5,2),            -- raw teacher-entered subject score
  entered_by      UUID         REFERENCES users(user_id) ON DELETE SET NULL,
  created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
  UNIQUE (student_id, subject_id, month)
);

CREATE INDEX IF NOT EXISTS idx_subject_scores_student ON subject_scores (student_id, month);
CREATE INDEX IF NOT EXISTS idx_subject_scores_subject ON subject_scores (subject_id, month);

-- ── score_formula_config ───────────────────────────
-- Holds whatever gets decided for Section 9. mode is left as a
-- string enum rather than assumed; the app reads this row to decide
-- how to compute FR-11's final score. is_per_subject lets a future
-- decision be "fixed system-wide" (FALSE, subject_id NULL) or
-- "configurable per subject" (TRUE, one row per subject).
CREATE TABLE IF NOT EXISTS score_formula_config (
  config_id           UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id          UUID         REFERENCES subjects(subject_id) ON DELETE CASCADE,
  mode                VARCHAR(20)  NOT NULL DEFAULT 'attendance_only'
                       CHECK (mode IN ('attendance_only','teacher_score_only','weighted_blend')),
  attendance_weight   DECIMAL(4,2) NOT NULL DEFAULT 1.00,
  teacher_score_weight DECIMAL(4,2) NOT NULL DEFAULT 0.00,
  updated_at          TIMESTAMP    NOT NULL DEFAULT NOW(),
  CHECK (attendance_weight + teacher_score_weight = 1.00)
);

-- Seed one system-wide default row (subject_id NULL) so FR-11 has
-- somewhere to read from even before Section 9 is formally closed.
-- UPDATE this row (or add per-subject rows) once the decision lands.
INSERT INTO score_formula_config (subject_id, mode, attendance_weight, teacher_score_weight)
SELECT NULL, 'attendance_only', 1.00, 0.00
WHERE NOT EXISTS (SELECT 1 FROM score_formula_config WHERE subject_id IS NULL);

-- ── Backfill: placeholder classes so development isn't blocked ────
-- Creates ONE placeholder class per existing academic year so admins
-- have something to attach timetable_slots to immediately. This is
-- NOT real homeroom data — replace via the admin UI once it exists.
DO $$
DECLARE
  default_school_id UUID;
  yr RECORD;
BEGIN
  SELECT school_id INTO default_school_id FROM schools LIMIT 1;

  FOR yr IN SELECT year_id FROM academic_years LOOP
    INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
    SELECT default_school_id, 'UNASSIGNED — replace me', 'TBD', yr.year_id
    WHERE NOT EXISTS (
      SELECT 1 FROM homeroom_classes
      WHERE academic_year_id = yr.year_id AND class_name = 'UNASSIGNED — replace me'
    );
  END LOOP;
END $$;

SELECT '002_timetable_schema.sql applied. Replace placeholder classes and confirm score_formula_config before building FR-11.' AS message;