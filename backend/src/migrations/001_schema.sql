-- ═══════════════════════════════════════════════════
-- EduAttend — Full Schema + Demo Seed Data (v3)
-- Renames: classes -> courses, class_id -> course_id,
-- class_name -> course_name (everywhere, incl. FKs/views)
-- Adds: major-based courses (Cyber Security, Software Engineering,
-- AI Engineering, Data Science, Computer Science, Business Analytics),
-- more teachers/admins, more terms, variable session counts per course.
-- Run: node src/migrations/run.js
-- ═══════════════════════════════════════════════════

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ── users ──────────────────────────────────────────
-- role: 'admin'          -> Academic Year / Term / Course / Teacher admin console
--       'teacher'        -> Dashboard / Course / Score screens
-- Only two actor roles are supported: 'admin' and 'teacher'
CREATE TABLE IF NOT EXISTS users (
  user_id    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  email      VARCHAR(255) NOT NULL UNIQUE,
  full_name  VARCHAR(255) NOT NULL,
  role       VARCHAR(20)  NOT NULL CHECK (role IN ('admin','teacher')),
  created_at TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- ── academic_years ─────────────────────────────────
-- Defined before majors/terms because both reference year_id.
CREATE TABLE IF NOT EXISTS academic_years (
  year_id    VARCHAR(9)  PRIMARY KEY,          -- e.g. '2025-2026'
  is_active  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP   NOT NULL DEFAULT NOW()
);

-- ── majors ─────────────────────────────────────────
-- Subject/track a course + teacher belong to (e.g. "Young Learners",
-- "DevOps"). Selected by the admin when assigning a teacher to a
-- course inside a term.
-- Majors now include an associated academic year (optional). A
-- course and a student can be linked to multiple majors via
-- join tables created later.
CREATE TABLE IF NOT EXISTS majors (
  major_id    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  major_name  VARCHAR(100) NOT NULL,
  academic_year_id VARCHAR(9) REFERENCES academic_years(year_id) ON DELETE SET NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
  UNIQUE (major_name)
);

-- ── terms ──────────────────────────────────────────
-- Admin flow: select academic year -> create term (with start/end
-- dates = "Time") -> add courses to the term -> assign a teacher +
-- major to each course.
CREATE TABLE IF NOT EXISTS terms (
  term_id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  academic_year_id VARCHAR(9)  NOT NULL REFERENCES academic_years(year_id) ON DELETE CASCADE,
  term_name        VARCHAR(50) NOT NULL,       -- e.g. 'Term 1'
  start_date       DATE        NOT NULL,
  end_date         DATE        NOT NULL,
  created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (academic_year_id, term_name),
  CHECK (end_date >= start_date)
);

-- ── courses (a.k.a. "classes" in older builds) ─────
CREATE TABLE IF NOT EXISTS courses (
  course_id     VARCHAR(20)  PRIMARY KEY,
  teacher_id    UUID         REFERENCES users(user_id) ON DELETE SET NULL,
  course_name   VARCHAR(100) NOT NULL,
  academic_year VARCHAR(9)   NOT NULL DEFAULT '2025-2026',
  term_id       UUID         REFERENCES terms(term_id) ON DELETE SET NULL,
  major_id      UUID         REFERENCES majors(major_id) ON DELETE SET NULL,
  -- Planned number of sessions for the term. Drives the Score card:
  -- "total Sessions 15, present 13, absent 2, late 3 ..."
  total_sessions_planned INT NOT NULL DEFAULT 0,
  created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- One-time migration helper: if an older 'classes' table still exists
-- (pre-rename), pull its rows into 'courses'. Safe to leave in place;
-- it no-ops once 'classes' is gone.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'classes'
  ) THEN
    INSERT INTO courses (course_id, teacher_id, course_name, academic_year,
                          term_id, major_id, total_sessions_planned, created_at)
    SELECT class_id, teacher_id, class_name, academic_year,
           term_id, major_id, total_sessions_planned, created_at
    FROM classes
    ON CONFLICT (course_id) DO UPDATE SET
      teacher_id    = EXCLUDED.teacher_id,
      course_name   = EXCLUDED.course_name,
      academic_year = EXCLUDED.academic_year,
      term_id       = EXCLUDED.term_id,
      major_id      = EXCLUDED.major_id,
      total_sessions_planned = EXCLUDED.total_sessions_planned;
  END IF;
END $$;

-- course_majors junction table (allows one course to have multiple majors)
CREATE TABLE IF NOT EXISTS course_majors (
  course_id VARCHAR(20) REFERENCES courses(course_id) ON DELETE CASCADE,
  major_id  UUID      REFERENCES majors(major_id) ON DELETE CASCADE,
  PRIMARY KEY (course_id, major_id)
);

-- Backfill existing courses into course_majors
INSERT INTO course_majors (course_id, major_id)
SELECT course_id, major_id FROM courses WHERE major_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- Make courses.major_id nullable since we now use course_majors
ALTER TABLE courses ALTER COLUMN major_id DROP NOT NULL;

-- ── students ───────────────────────────────────────
-- Students keep a course enrollment (for backwards compatibility with
-- existing backend/frontend). Each student has one major, plus academic
-- year and term data.
CREATE TABLE IF NOT EXISTS students (
  student_id    UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     VARCHAR(20)  NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
  roll_number   VARCHAR(20)  NOT NULL,
  full_name     VARCHAR(255) NOT NULL,
  gender        VARCHAR(10)  NOT NULL CHECK (gender IN ('Male','Female','Other')),
  date_of_birth DATE         NOT NULL,
  phone_number  VARCHAR(20),
  major_id      UUID         REFERENCES majors(major_id) ON DELETE SET NULL,
  academic_year_id VARCHAR(9) REFERENCES academic_years(year_id) ON DELETE SET NULL,
  term_id       UUID         REFERENCES terms(term_id) ON DELETE SET NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT NOW(),
  UNIQUE (course_id, roll_number)
);

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'students' AND column_name = 'class_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'students' AND column_name = 'course_id'
  ) THEN
    ALTER TABLE students ADD COLUMN course_id VARCHAR(20);
    UPDATE students SET course_id = class_id WHERE course_id IS NULL;
  END IF;
END $$;

-- ── course sessions ────────────────────────────────
CREATE TABLE IF NOT EXISTS course_sessions (
  session_id    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id     VARCHAR(20) NOT NULL REFERENCES courses(course_id) ON DELETE CASCADE,
  major_id      UUID        REFERENCES majors(major_id) ON DELETE SET NULL,
  session_name  VARCHAR(100) NOT NULL DEFAULT 'Session',
  session_date  DATE        NOT NULL,
  notes         TEXT,
  created_at    TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (course_id, session_date)
);

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'course_sessions' AND column_name = 'class_id'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'course_sessions' AND column_name = 'course_id'
  ) THEN
    ALTER TABLE course_sessions ADD COLUMN course_id VARCHAR(20);
    UPDATE course_sessions SET course_id = class_id WHERE course_id IS NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'course_sessions' AND column_name = 'major_id'
  ) THEN
    ALTER TABLE course_sessions ADD COLUMN major_id UUID REFERENCES majors(major_id) ON DELETE SET NULL;
  END IF;

  UPDATE course_sessions cs
  SET major_id = c.major_id
  FROM courses c
  WHERE cs.course_id = c.course_id
    AND cs.major_id IS NULL;
END $$;

-- Per-session attendance. Status: present / late / absent / permission.
-- 'remark' stores teacher notes. Admin can only review (is_reviewed) —
-- teachers do the actual remarking.
CREATE TABLE IF NOT EXISTS session_attendance_records (
  record_id        UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id       UUID        NOT NULL REFERENCES course_sessions(session_id) ON DELETE CASCADE,
  student_id       UUID        NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
  course_id        VARCHAR(20) REFERENCES courses(course_id) ON DELETE CASCADE,
  major_id         UUID        REFERENCES majors(major_id) ON DELETE SET NULL,
  status           VARCHAR(10) NOT NULL CHECK (status IN ('present','late','absent','permission')),
  remark           TEXT,
  remarked_by      UUID        REFERENCES users(user_id) ON DELETE SET NULL,
  is_reviewed      BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMP   NOT NULL DEFAULT NOW(),
  UNIQUE (session_id, student_id)
);

DO $$
BEGIN
  ALTER TABLE session_attendance_records DROP CONSTRAINT IF EXISTS session_attendance_records_status_check;
  ALTER TABLE session_attendance_records ADD CONSTRAINT session_attendance_records_status_check
    CHECK (status IN ('present','late','absent','permission'));
END $$;

-- ── attendance_records ─────────────────────────────
-- Flat, session-based mirror of session_attendance_records used for
-- fast per-student / per-course score & dashboard queries.
CREATE TABLE IF NOT EXISTS attendance_records (
  record_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id      UUID        REFERENCES course_sessions(session_id) ON DELETE CASCADE,
  student_id      UUID        NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
  course_id       VARCHAR(20) REFERENCES courses(course_id) ON DELETE CASCADE,
  major_id        UUID        REFERENCES majors(major_id) ON DELETE SET NULL,
  date            DATE,
  status          VARCHAR(10) NOT NULL CHECK (status IN ('present','late','absent','permission')),
  remark          TEXT,
  remarked_by     UUID        REFERENCES users(user_id) ON DELETE SET NULL,
  is_reviewed     BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMP   NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMP   NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'course_id'
  ) THEN
    ALTER TABLE attendance_records ADD COLUMN course_id VARCHAR(20);
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'class_id'
  ) THEN
    UPDATE attendance_records SET course_id = class_id WHERE course_id IS NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'date'
  ) THEN
    ALTER TABLE attendance_records ADD COLUMN date DATE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'session_id'
  ) THEN
    ALTER TABLE attendance_records ADD COLUMN session_id UUID REFERENCES course_sessions(session_id) ON DELETE CASCADE;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'major_id'
  ) THEN
    ALTER TABLE attendance_records ADD COLUMN major_id UUID REFERENCES majors(major_id) ON DELETE SET NULL;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'attendance_records' AND column_name = 'session_id'
  ) THEN
    UPDATE attendance_records ar
    SET course_id = cs.course_id,
        major_id = cs.major_id,
        date = cs.session_date,
        session_id = cs.session_id
    FROM course_sessions cs
    WHERE ar.course_id = cs.course_id
      AND ar.date = cs.session_date
      AND ar.session_id IS NULL;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'attendance_records_session_student_key'
  ) THEN
    ALTER TABLE attendance_records
      ADD CONSTRAINT attendance_records_session_student_key UNIQUE (session_id, student_id);
  END IF;

  ALTER TABLE attendance_records DROP CONSTRAINT IF EXISTS attendance_records_status_check;
  ALTER TABLE attendance_records ADD CONSTRAINT attendance_records_status_check
    CHECK (status IN ('present','late','absent','permission'));
END $$;

-- ── score_rules ────────────────────────────────────
-- Editable per course. Score = base_score - absent*absent_deduction
-- - late*late_deduction - permission*permission_deduction (floored at 0).
CREATE TABLE IF NOT EXISTS score_rules (
  rule_id              UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id            VARCHAR(20)  NOT NULL UNIQUE REFERENCES courses(course_id) ON DELETE CASCADE,
  base_score           DECIMAL(5,2) NOT NULL DEFAULT 10.00,
  absent_deduction     DECIMAL(5,2) NOT NULL DEFAULT 2.00,
  late_deduction       DECIMAL(5,2) NOT NULL DEFAULT 0.50,
  permission_deduction DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  updated_at           TIMESTAMP    NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'score_rules' AND column_name = 'course_id'
  ) THEN
    ALTER TABLE score_rules ADD COLUMN course_id VARCHAR(20);
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'score_rules' AND column_name = 'class_id'
  ) THEN
    UPDATE score_rules SET course_id = class_id WHERE course_id IS NULL;
  END IF;
END $$;

-- ── Indexes ────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_att_student_date  ON attendance_records (student_id, date);
CREATE INDEX IF NOT EXISTS idx_att_course_date    ON attendance_records (course_id, date);
CREATE INDEX IF NOT EXISTS idx_students_course    ON students (course_id);
CREATE INDEX IF NOT EXISTS idx_courses_teacher    ON courses (teacher_id);
CREATE INDEX IF NOT EXISTS idx_courses_term       ON courses (term_id);
CREATE INDEX IF NOT EXISTS idx_courses_major      ON courses (major_id);
CREATE INDEX IF NOT EXISTS idx_terms_year         ON terms (academic_year_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_students_course_roll ON students (course_id, roll_number);
CREATE UNIQUE INDEX IF NOT EXISTS idx_score_rules_course   ON score_rules (course_id);

-- ════════════════════════════════════════════════════
-- VIEWS — power the Teacher Score card and the Admin
-- Dashboard bar chart / CSV export directly from SQL.
-- ════════════════════════════════════════════════════

-- Teacher: per-student attendance + editable score, per course.
CREATE OR REPLACE VIEW student_attendance_scores AS
SELECT
  st.student_id,
  c.course_id,
  st.roll_number,
  st.full_name,
  c.total_sessions_planned,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'present')    AS present_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')     AS absent_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')       AS late_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') AS permission_count,
  sr.base_score,
  sr.absent_deduction,
  sr.late_deduction,
  sr.permission_deduction,
  GREATEST(
    sr.base_score
      - COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')     * sr.absent_deduction
      - COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')       * sr.late_deduction
      - COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') * sr.permission_deduction,
    0
  ) AS computed_score,
  ROUND(
    (GREATEST(
      sr.base_score
        - COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')     * sr.absent_deduction
        - COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')       * sr.late_deduction
        - COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') * sr.permission_deduction,
      0
    ) / NULLIF(sr.base_score, 0)) * 100, 2
  ) AS score_percentage
FROM students st
CROSS JOIN courses c
LEFT JOIN course_majors cm ON cm.course_id = c.course_id AND cm.major_id = st.major_id
LEFT JOIN attendance_records ar ON ar.student_id = st.student_id AND ar.course_id = c.course_id
LEFT JOIN score_rules sr        ON sr.course_id = c.course_id
WHERE st.course_id = c.course_id OR (st.course_id IS NULL AND cm.major_id IS NOT NULL)
GROUP BY st.student_id, c.course_id, st.roll_number, st.full_name,
         c.total_sessions_planned, sr.base_score, sr.absent_deduction,
         sr.late_deduction, sr.permission_deduction;

-- Admin: attendance totals per course, for the comparison bar chart
-- and CSV export (SELECT * FROM admin_course_attendance_summary).
CREATE OR REPLACE VIEW admin_course_attendance_summary AS
SELECT
  c.course_id,
  c.course_name,
  ay.year_id                    AS academic_year,
  t.term_name,
  string_agg(DISTINCT m.major_name, ', ') AS majors,
  u.full_name                   AS teacher_name,
  c.total_sessions_planned,
  COUNT(DISTINCT s.student_id)  AS student_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'present')    AS present_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'absent')     AS absent_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'late')       AS late_count,
  COUNT(ar.record_id) FILTER (WHERE ar.status = 'permission') AS permission_count
FROM courses c
LEFT JOIN terms t           ON t.term_id = c.term_id
LEFT JOIN academic_years ay ON ay.year_id = t.academic_year_id
LEFT JOIN course_majors cm  ON cm.course_id = c.course_id
LEFT JOIN majors m          ON m.major_id = cm.major_id OR m.major_id = c.major_id
LEFT JOIN users u           ON u.user_id = c.teacher_id
LEFT JOIN students s        ON s.course_id = c.course_id OR (s.course_id IS NULL AND s.major_id = cm.major_id)
LEFT JOIN attendance_records ar ON ar.course_id = c.course_id AND ar.student_id = s.student_id
GROUP BY c.course_id, c.course_name, ay.year_id, t.term_name, u.full_name, c.total_sessions_planned;

-- course_majors was moved earlier in schema

-- ════════════════════════════════════════════════════
-- SEED DEMO DATA
-- IMPORTANT: Replace these emails with YOUR team's actual
-- Google account emails so you can log in!
-- ════════════════════════════════════════════════════

-- Majors
INSERT INTO majors (major_name, academic_year_id) VALUES
  ('Cyber Security', NULL),
  ('Software Engineering', NULL),
  ('AI Engineering', NULL),
  ('Data Science', NULL),
  ('Computer Science', NULL),
  ('Business Analytics', NULL)
ON CONFLICT (major_name) DO NOTHING;

-- Academic years
INSERT INTO academic_years (year_id, is_active) VALUES
  ('2024-2025', FALSE),
  ('2025-2026', TRUE),
  ('2026-2027', FALSE)
ON CONFLICT (year_id) DO NOTHING;

-- Terms (Time = start_date/end_date, selected under an academic year)
INSERT INTO terms (academic_year_id, term_name, start_date, end_date) VALUES
  ('2025-2026', 'Term 1', '2025-09-01', '2025-12-19'),
  ('2025-2026', 'Term 2', '2026-01-05', '2026-04-17'),
  ('2025-2026', 'Term 3', '2026-04-27', '2026-08-14'),
  ('2026-2027', 'Term 1', '2026-09-07', '2026-12-18')
ON CONFLICT (academic_year_id, term_name) DO NOTHING;

-- Admin users (replace with your Google email)
INSERT INTO users (email, full_name, role) VALUES
  ('sk6024010075@camtech.edu.kh', 'Ms. Neath',   'admin'),
  ('ds6024010093@camtech.edu.kh', 'Ms. Rika',    'admin'),
  ('rv6024010101@camtech.edu.kh', 'Ms. Rangsey', 'admin'),
  ('ys6024010107@camtech.edu.kh', 'Ms. Neang',   'admin'),
  ('hd6024010112@camtech.edu.kh', 'Mr. Hong Dara', 'admin')
ON CONFLICT (email) DO NOTHING;

-- Teachers (replace with real Google emails)
INSERT INTO users (email, full_name, role) VALUES
  ('sreyneathk24@gmail.com',   'Ms. Sreyneath',  'teacher'),
  ('darikasophea2@gmail.com',  'Ms. Darika',     'teacher'),
  ('virakrangsey@gmail.com',   'Ms. RangseyV',   'teacher'),
  ('neangsrey137@gmail.com',   'Ms. Sreyneang',  'teacher'),
  ('sovannmakara2@gmail.com',  'Mr. Makara',     'teacher'),
  ('chanthyrith2@gmail.com',   'Mr. Chanthy',    'teacher')
ON CONFLICT (email) DO NOTHING;

-- ── Courses ────────────────────────────────────────
-- Academic courses seeded with majors such as Cyber Security, Software
-- Engineering, AI Engineering, Data Science, Computer Science, and Business Analytics.
INSERT INTO courses (course_id, course_name) VALUES
  ('001', 'Cyber Security Fundamentals'),
  ('002', 'Cyber Security Practical'),
  ('003', 'Cyber Security Lab'),
  ('004', 'Cyber Security Capstone'),
  ('005', 'Software Engineering Fundamentals'),
  ('006', 'Software Engineering Project'),
  ('007', 'AI Engineering Fundamentals'),
  ('008', 'AI Engineering Project'),
  ('009', 'Data Science Fundamentals'),
  ('010', 'Data Science Analytics'),
  ('011', 'Computer Science Theory'),
  ('012', 'Computer Science Systems'),
  ('013', 'Business Analytics Fundamentals'),
  ('014', 'Business Analytics Insights'),
  ('015', 'Business Analytics Project'),
  ('016', 'AI Engineering Capstone'),
  ('017', 'Data Science Capstone'),
  ('018', 'Cyber Security Advanced'),
  ('019', 'Software Engineering Advanced'),
  ('020', 'Computer Science Capstone'),
  ('021', 'Business Analytics Advanced'),
  ('022', 'Data Science Lab'),
  ('023', 'Blockchain Technology')
ON CONFLICT (course_id) DO NOTHING;

-- Assign teachers to courses (dropdown-style admin assignment)
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'sk6024010075@camtech.edu.kh')      WHERE course_id = '001';
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'ds6024010093@camtech.edu.kh')      WHERE course_id = '006';
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'rv6024010101@camtech.edu.kh')      WHERE course_id = '010';
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'ys6024010107@camtech.edu.kh')      WHERE course_id = '007';
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'sreyneathk24@gmail.com')          WHERE course_id IN ('002','017','023');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'darikasophea2@gmail.com')         WHERE course_id IN ('003','018');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'virakrangsey@gmail.com')          WHERE course_id IN ('004','019');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'neangsrey137@gmail.com')          WHERE course_id IN ('005','020');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'sovannmakara2@gmail.com')         WHERE course_id IN ('021');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'chanthyrith2@gmail.com')          WHERE course_id IN ('022');
UPDATE courses SET teacher_id = (SELECT user_id FROM users WHERE email = 'hd6024010112@camtech.edu.kh')     WHERE course_id IN ('008','009','011','012','013','014','015','016');

-- Wire courses into terms, majors, and planned session counts
-- (drives the Score card denominator).
UPDATE courses c
SET term_id = (SELECT term_id FROM terms WHERE academic_year_id = '2025-2026' AND term_name = 'Term 2'),
    major_id = (SELECT major_id FROM majors WHERE major_name = 'Cyber Security'),
    total_sessions_planned = 15
WHERE c.course_id IN ('001','002','003','004');

UPDATE courses c
SET term_id = (SELECT term_id FROM terms WHERE academic_year_id = '2025-2026' AND term_name = 'Term 2'),
    major_id = (SELECT major_id FROM majors WHERE major_name = 'Software Engineering'),
    total_sessions_planned = 15
WHERE c.course_id IN ('005','006','007','008','009','010','011','012','013','014','015','016','023');

UPDATE courses c
SET term_id = (SELECT term_id FROM terms WHERE academic_year_id = '2025-2026' AND term_name = 'Term 2'),
    major_id = (SELECT major_id FROM majors WHERE major_name = 'Data Science'),
    total_sessions_planned = 12
WHERE c.course_id IN ('017','018');

UPDATE courses c
SET term_id = (SELECT term_id FROM terms WHERE academic_year_id = '2025-2026' AND term_name = 'Term 3'),
    major_id = (SELECT major_id FROM majors WHERE major_name = 'AI Engineering'),
    total_sessions_planned = 18
WHERE c.course_id IN ('019','020');

UPDATE courses c
SET term_id = (SELECT term_id FROM terms WHERE academic_year_id = '2025-2026' AND term_name = 'Term 3'),
    major_id = (SELECT major_id FROM majors WHERE major_name = 'Computer Science'),
    total_sessions_planned = 15
WHERE c.course_id IN ('021','022');

-- Associate Blockchain Technology with Software Engineering, Data Science, and AI Engineering in course_majors
INSERT INTO course_majors (course_id, major_id)
SELECT '023', major_id FROM majors WHERE major_name IN ('Software Engineering', 'Data Science', 'AI Engineering')
ON CONFLICT DO NOTHING;

-- Score rules for every course
INSERT INTO score_rules (course_id, base_score, absent_deduction, late_deduction, permission_deduction)
SELECT course_id, 10, 2, 0.5, 0.25 FROM courses
ON CONFLICT (course_id) DO NOTHING;

-- Students — a base 10-student roster cloned into every course, plus
-- a few extra students on the newer IT/SWE/DevOps courses so those
-- rosters don't look identical to the English classes.
DO $$
DECLARE
  cid TEXT;
  course_ids TEXT[] := ARRAY['001','002','003','004','005','006','007','008',
                              '009','010','011','012','013','014','015','016',
                              '017','018','019','020','021','022'];
BEGIN
  FOREACH cid IN ARRAY course_ids LOOP
    INSERT INTO students (course_id, roll_number, full_name, gender, date_of_birth) VALUES
      (cid,'001','Emma Johnson',   'Female','2009-03-15'),
      (cid,'002','Liam Smith',     'Male',  '2009-07-22'),
      (cid,'003','Olivia Brown',   'Female','2009-01-08'),
      (cid,'004','Noah Davis',     'Male',  '2009-11-30'),
      (cid,'005','Ava Wilson',     'Female','2009-05-19'),
      (cid,'006','Sophia Taylor',  'Female','2008-06-28'),
      (cid,'007','Mason Anderson', 'Male',  '2008-12-03'),
      (cid,'008','Isabella Thomas','Female','2008-04-17'),
      (cid,'009','William Garcia', 'Male',  '2009-09-04'),
      (cid,'010','Ethan Martinez', 'Male',  '2009-09-04')
    ON CONFLICT (course_id, roll_number) DO NOTHING;
  END LOOP;

  -- Extra students for the IT / Software Engineering / DevOps courses
  FOREACH cid IN ARRAY ARRAY['017','018','019','020','021','022'] LOOP
    INSERT INTO students (course_id, roll_number, full_name, gender, date_of_birth) VALUES
      (cid,'011','Sokha Chan',     'Male',  '2003-02-14'),
      (cid,'012','Dara Pich',      'Female','2003-08-09'),
      (cid,'013','Vichet Sok',     'Male',  '2002-12-25'),
      (cid,'014','Sreymom Heng',   'Female','2003-05-30')
    ON CONFLICT (course_id, roll_number) DO NOTHING;
  END LOOP;
END $$;

-- ════════════════════════════════════════════════════
-- Dedicated mock students per MAJOR (not tied to a course roster).
-- These power the "students in each major" view on the admin panel.
-- students.course_id is made nullable so a student can belong to a
-- major without being enrolled in a specific course.
-- ════════════════════════════════════════════════════
ALTER TABLE students ALTER COLUMN course_id DROP NOT NULL;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM students WHERE course_id IS NULL) THEN
    INSERT INTO students (course_id, roll_number, full_name, gender, date_of_birth, major_id)
    SELECT NULL, v.roll, v.name, v.gender, v.dob::date, m.major_id
    FROM (VALUES
      -- Cyber Security
      ('CS01','Rithy Sok',        'Male',  '2003-02-11','Cyber Security'),
      ('CS02','Sophal Meas',      'Female','2003-06-24','Cyber Security'),
      ('CS03','Dara Kong',        'Male',  '2002-11-05','Cyber Security'),
      ('CS04','Chanlina Pen',     'Female','2003-09-18','Cyber Security'),
      ('CS05','Visal Chhun',      'Male',  '2003-01-30','Cyber Security'),
      -- Software Engineering
      ('SE01','Piseth Nou',       'Male',  '2003-03-14','Software Engineering'),
      ('SE02','Sreyleak Voan',   'Female','2003-07-22','Software Engineering'),
      ('SE03','Kimhak Ly',        'Male',  '2002-12-02','Software Engineering'),
      ('SE04','Bopha Rin',        'Female','2003-05-09','Software Engineering'),
      ('SE05','Vibol Chea',       'Male',  '2003-08-27','Software Engineering'),
      ('SE06','Nita Sam',         'Female','2003-04-15','Software Engineering'),
      -- AI Engineering
      ('AI01','Rattana Yim',      'Male',  '2003-02-19','AI Engineering'),
      ('AI02','Chenda Hor',       'Female','2003-06-01','AI Engineering'),
      ('AI03','Sokleap Tep',      'Male',  '2002-10-28','AI Engineering'),
      ('AI04','Maly Doung',       'Female','2003-11-11','AI Engineering'),
      ('AI05','Panha Chan',       'Male',  '2003-03-03','AI Engineering'),
      -- Data Science
      ('DS01','Vichea Korn',      'Male',  '2003-01-17','Data Science'),
      ('DS02','Sokha Prak',       'Female','2003-05-25','Data Science'),
      ('DS03','Raksmey Oul',      'Male',  '2002-09-30','Data Science'),
      ('DS04','Kanha Sen',        'Female','2003-07-08','Data Science'),
      ('DS05','Chhaya Meng',      'Male',  '2003-12-19','Data Science'),
      -- Computer Science
      ('CO01','Sovann Rith',      'Male',  '2003-02-06','Computer Science'),
      ('CO02','Davin Chum',       'Female','2003-06-13','Computer Science'),
      ('CO03','Makara Uch',       'Male',  '2002-11-21','Computer Science'),
      ('CO04','Sreypov Lim',      'Female','2003-08-04','Computer Science'),
      ('CO05','Bunna Ke',         'Male',  '2003-04-29','Computer Science'),
      -- Business Analytics
      ('BA01','Chesda Roeun',     'Male',  '2003-03-22','Business Analytics'),
      ('BA02','Leakhena Sar',     'Female','2003-07-30','Business Analytics'),
      ('BA03','Sopheak Vann',     'Male',  '2002-12-15','Business Analytics'),
      ('BA04','Chariya Pov',      'Female','2003-05-02','Business Analytics'),
      ('BA05','Ratanak Chhem',    'Male',  '2003-09-09','Business Analytics')
    ) AS v(roll,name,gender,dob,major)
    JOIN majors m ON m.major_name = v.major;
  END IF;
END $$;

-- ════════════════════════════════════════════════════
-- Generate weekly sessions per course (count = total_sessions_planned,
-- starting from that course's assigned term start_date) with per-
-- student attendance across present/late/absent statuses, so both the Teacher
-- Score card and the Admin Dashboard bar chart / CSV export have
-- real, varied data to show for every course.
-- ════════════════════════════════════════════════════
DO $$
DECLARE
  crs RECORD;
  stu RECORD;
  sess_date DATE;
  this_session_id UUID;
  i INT;
  seed INT;
  status_val VARCHAR(10);
  reason_val TEXT;
BEGIN
  FOR crs IN
    SELECT c.course_id, c.total_sessions_planned, c.major_id, COALESCE(t.start_date, DATE '2026-01-05') AS start_date
    FROM courses c
    LEFT JOIN terms t ON t.term_id = c.term_id
  LOOP
    FOR i IN 1..GREATEST(crs.total_sessions_planned, 1) LOOP
      sess_date := crs.start_date + ((i - 1) * 7);

      INSERT INTO course_sessions (course_id, major_id, session_name, session_date)
      VALUES (crs.course_id, crs.major_id, 'Session ' || i, sess_date)
      ON CONFLICT (course_id, session_date) DO NOTHING;

      SELECT session_id INTO this_session_id
      FROM course_sessions
      WHERE course_id = crs.course_id AND session_date = sess_date;

      FOR stu IN SELECT student_id, roll_number FROM students WHERE course_id = crs.course_id LOOP
        -- Vary the pattern per course so not every course looks identical.
        seed := (i + stu.roll_number::INT + ('x' || substr(crs.course_id, 1, 2))::bit(8)::INT) % 10;
        status_val := CASE
          WHEN seed BETWEEN 0 AND 5 THEN 'present'
          WHEN seed IN (6, 7)       THEN 'late'
          WHEN seed = 8             THEN 'absent'
          ELSE                      'permission'
        END;
        reason_val := CASE status_val
          WHEN 'absent' THEN 'No reason given'
          WHEN 'permission' THEN 'Approved leave'
          ELSE NULL
        END;

        INSERT INTO session_attendance_records (session_id, student_id, course_id, major_id, status, remark)
        VALUES (this_session_id, stu.student_id, crs.course_id, crs.major_id, status_val, reason_val)
        ON CONFLICT (session_id, student_id) DO NOTHING;

        INSERT INTO attendance_records (session_id, student_id, course_id, major_id, date, status, remark)
        VALUES (this_session_id, stu.student_id, crs.course_id, crs.major_id, sess_date, status_val, reason_val)
        ON CONFLICT (session_id, student_id) DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;

SELECT 'Setup complete! Remember to update emails in users table.' AS message;