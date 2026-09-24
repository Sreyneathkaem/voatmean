-- ═══════════════════════════════════════════════════════════════
-- Voatmean — Demo Seed Script for October 2nd Presentation
-- ═══════════════════════════════════════════════════════════════

-- 1. Ensure Default School
INSERT INTO schools (school_name)
SELECT 'Voatmean School'
WHERE NOT EXISTS (SELECT 1 FROM schools);

-- 2. Academic Year & Term
INSERT INTO academic_years (year_id, is_active)
VALUES ('2026-2027', TRUE)
ON CONFLICT (year_id) DO NOTHING;

INSERT INTO terms (academic_year_id, term_name, start_date, end_date)
VALUES ('2026-2027', 'Semester 1', '2026-09-01', '2027-01-31')
ON CONFLICT (academic_year_id, term_name) DO NOTHING;

-- 3. Teachers & Admin Users
INSERT INTO users (full_name, email, role)
VALUES
  ('Admin Principal', 'admin@voatmean.edu.kh', 'admin'),
  ('លោកគ្រូ សុខ សំណាង', 'sok.samnang@voatmean.edu.kh', 'teacher'),
  ('អ្នកគ្រូ កែវ បុប្ផា', 'keo.bopha@voatmean.edu.kh', 'teacher'),
  ('Kaem Sreyneath', 'sreyneathk24@gmail.com', 'admin')
ON CONFLICT (email) DO NOTHING;

-- 4. Subjects
INSERT INTO subjects (school_id, subject_name)
SELECT s.school_id, v.subject_name
FROM schools s
CROSS JOIN (VALUES
  ('Mathematics'),
  ('Khmer Literature'),
  ('Physics'),
  ('English')
) AS v(subject_name)
ON CONFLICT (school_id, subject_name) DO NOTHING;

-- 5. Homeroom Classes
INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
SELECT s.school_id, v.class_name, v.grade_level, '2026-2027'
FROM schools s
CROSS JOIN (VALUES
  ('Grade 10A', '10'),
  ('Grade 11B', '11')
) AS v(class_name, grade_level)
ON CONFLICT (school_id, class_name, academic_year_id) DO NOTHING;

-- 6. Courses (Legacy/Compatibility Course Roster)
INSERT INTO courses (course_id, course_name, academic_year, teacher_id, term_id)
SELECT
  'c1',
  'Grade 10A Mathematics',
  '2026-2027',
  (SELECT user_id FROM users WHERE email = 'sok.samnang@voatmean.edu.kh' LIMIT 1),
  (SELECT term_id FROM terms WHERE academic_year_id = '2026-2027' AND term_name = 'Semester 1' LIMIT 1)
ON CONFLICT (course_id) DO NOTHING;

-- 7. Students
INSERT INTO students (course_id, roll_number, full_name, gender, date_of_birth, phone_number)
VALUES
  ('c1', '1', 'ចាន់ ស្រីមុំ (Chan Sreymom)', 'Female', '2009-03-15', '012111222'),
  ('c1', '2', 'ហេង ពិសិដ្ឋ (Heng Piseth)', 'Male', '2009-07-22', '012555666'),
  ('c1', '3', 'សុខ សំណាង (Sok Samnang)', 'Male', '2009-01-10', '012345678'),
  ('c1', '4', 'កែវ បុប្ផា (Keo Bopha)', 'Female', '2009-11-05', '098765432'),
  ('c1', '5', 'ជា វណ្ណៈ (Chea Vannak)', 'Male', '2009-08-18', '011223344')
ON CONFLICT (course_id, roll_number) DO NOTHING;

-- 8. Timetable Slots
INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
SELECT
  hc.class_id,
  sub.subject_id,
  usr.user_id,
  1,
  1
FROM homeroom_classes hc
CROSS JOIN subjects sub
CROSS JOIN users usr
WHERE hc.class_name = 'Grade 10A'
  AND sub.subject_name = 'Mathematics'
  AND usr.email = 'sok.samnang@voatmean.edu.kh'
ON CONFLICT (class_id, day_of_week, period) DO NOTHING;

SELECT 'Demo seed data applied successfully!' AS message;
