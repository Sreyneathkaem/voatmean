-- Seed Secondary and High School data for Voatmean
DO $$
DECLARE
  v_school_id UUID := 'eab574d5-10d3-48c0-ab47-e61442335a13';
  v_sub_math UUID;
  v_sub_khmer UUID;
  v_sub_phys UUID;
  v_sub_chem UUID;
  v_sub_bio UUID;
  v_sub_eng UUID;
  v_sub_hist UUID;
  v_sub_geo UUID;
  v_sub_civ UUID;
  v_sub_ict UUID;

  v_tch_samnang UUID;
  v_tch_bopha UUID;
  v_tch_piseth UUID;
  v_tch_sreymom UUID;
  v_tch_vannak UUID;
  v_tch_sreyneath UUID;

  v_cls_10a UUID;
  v_cls_10b UUID;
  v_cls_11a UUID;
  v_cls_11b UUID;
  v_cls_12a UUID;
  v_cls_12b UUID;

  v_slot_10a UUID;
  v_slot_10b UUID;
  v_slot_11a UUID;
  v_slot_11b UUID;
  v_slot_12a UUID;
  v_slot_12b UUID;
  v_stu_id UUID;
  i INT;
BEGIN
  -- 1. Secondary & High School Subjects
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Mathematics') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Khmer Literature') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Physics') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Chemistry') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Biology') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'English') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'History') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Geography') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'Moral & Civics') ON CONFLICT DO NOTHING;
  INSERT INTO subjects (school_id, subject_name) VALUES
    (v_school_id, 'ICT') ON CONFLICT DO NOTHING;

  SELECT subject_id INTO v_sub_math FROM subjects WHERE subject_name = 'Mathematics' LIMIT 1;
  SELECT subject_id INTO v_sub_khmer FROM subjects WHERE subject_name = 'Khmer Literature' LIMIT 1;
  SELECT subject_id INTO v_sub_phys FROM subjects WHERE subject_name = 'Physics' LIMIT 1;
  SELECT subject_id INTO v_sub_chem FROM subjects WHERE subject_name = 'Chemistry' LIMIT 1;
  SELECT subject_id INTO v_sub_bio FROM subjects WHERE subject_name = 'Biology' LIMIT 1;
  SELECT subject_id INTO v_sub_eng FROM subjects WHERE subject_name = 'English' LIMIT 1;
  SELECT subject_id INTO v_sub_hist FROM subjects WHERE subject_name = 'History' LIMIT 1;
  SELECT subject_id INTO v_sub_geo FROM subjects WHERE subject_name = 'Geography' LIMIT 1;

  -- 2. Ensure Teachers Exist with Cambodian Teacher names
  INSERT INTO users (full_name, email, role)
  VALUES ('លោកគ្រូ សុខ សំណាង', 'sok.samnang@voatmean.edu.kh', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_samnang;

  INSERT INTO users (full_name, email, role)
  VALUES ('អ្នកគ្រូ កែវ បុប្ផា', 'keo.bopha@voatmean.edu.kh', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_bopha;

  INSERT INTO users (full_name, email, role)
  VALUES ('លោកគ្រូ ហេង ពិសិដ្ឋ', 'heng.piseth@voatmean.edu.kh', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_piseth;

  INSERT INTO users (full_name, email, role)
  VALUES ('អ្នកគ្រូ ចាន់ ស្រីមុំ', 'chan.sreymom@voatmean.edu.kh', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_sreymom;

  INSERT INTO users (full_name, email, role)
  VALUES ('លោកគ្រូ ជា វណ្ណៈ', 'chea.vannak@voatmean.edu.kh', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_vannak;

  INSERT INTO users (full_name, email, role)
  VALUES ('កែម ស្រីនីត (Kaem Sreyneath)', 'k.sreyneath24@gmail.com', 'teacher')
  ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
  RETURNING user_id INTO v_tch_sreyneath;

  -- 3. Homeroom Classes
  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 10A', '10', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '10'
  RETURNING class_id INTO v_cls_10a;

  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 10B', '10', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '10'
  RETURNING class_id INTO v_cls_10b;

  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 11A', '11', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '11'
  RETURNING class_id INTO v_cls_11a;

  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 11B', '11', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '11'
  RETURNING class_id INTO v_cls_11b;

  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 12A', '12', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '12'
  RETURNING class_id INTO v_cls_12a;

  INSERT INTO homeroom_classes (school_id, class_name, grade_level, academic_year_id)
  VALUES (v_school_id, 'Grade 12B', '12', '2026-2027')
  ON CONFLICT (school_id, class_name, academic_year_id) DO UPDATE SET grade_level = '12'
  RETURNING class_id INTO v_cls_12b;

  -- 4. Timetable Slots
  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_10a, v_sub_math, v_tch_samnang, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_samnang, subject_id = v_sub_math
  RETURNING slot_id INTO v_slot_10a;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_10b, v_sub_phys, v_tch_bopha, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_bopha, subject_id = v_sub_phys
  RETURNING slot_id INTO v_slot_10b;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_11a, v_sub_khmer, v_tch_piseth, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_piseth, subject_id = v_sub_khmer
  RETURNING slot_id INTO v_slot_11a;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_11b, v_sub_chem, v_tch_sreymom, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_sreymom, subject_id = v_sub_chem
  RETURNING slot_id INTO v_slot_11b;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_12a, v_sub_bio, v_tch_vannak, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_vannak, subject_id = v_sub_bio
  RETURNING slot_id INTO v_slot_12a;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  VALUES (v_cls_12b, v_sub_eng, v_tch_sreyneath, 1, 1)
  ON CONFLICT (class_id, day_of_week, period) DO UPDATE SET teacher_id = v_tch_sreyneath, subject_id = v_sub_eng
  RETURNING slot_id INTO v_slot_12b;

  -- 5. Enrol 35 real students per class
  FOR i IN 1..35 LOOP
    -- Student for 10A
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១០ ក)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2010-01-01', '012' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_10a, v_stu_id) ON CONFLICT DO NOTHING;

    -- Add today's slot attendance for 10A (32 present, 2 late, 1 absent)
    IF i <= 32 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10a, v_stu_id, CURRENT_DATE, 'present')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'present';
    ELSIF i <= 34 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10a, v_stu_id, CURRENT_DATE, 'late')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'late';
    ELSE
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10a, v_stu_id, CURRENT_DATE, 'absent')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'absent';
    END IF;

    -- Student for 10B
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១០ ខ)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2010-02-01', '015' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_10b, v_stu_id) ON CONFLICT DO NOTHING;

    -- Add today's slot attendance for 10B (30 present, 3 late, 2 absent)
    IF i <= 30 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10b, v_stu_id, CURRENT_DATE, 'present')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'present';
    ELSIF i <= 33 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10b, v_stu_id, CURRENT_DATE, 'late')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'late';
    ELSE
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_10b, v_stu_id, CURRENT_DATE, 'absent')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'absent';
    END IF;

    -- Student for 11A (Pending - no attendance today)
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១១ ក)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2009-03-01', '016' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_11a, v_stu_id) ON CONFLICT DO NOTHING;

    -- Student for 11B (Submitted)
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១១ ខ)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2009-04-01', '017' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_11b, v_stu_id) ON CONFLICT DO NOTHING;
    IF i <= 33 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_11b, v_stu_id, CURRENT_DATE, 'present')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'present';
    ELSE
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_11b, v_stu_id, CURRENT_DATE, 'permission')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'permission';
    END IF;

    -- Student for 12A (Pending)
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១២ ក)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2008-05-01', '018' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_12a, v_stu_id) ON CONFLICT DO NOTHING;

    -- Student for 12B (Submitted)
    INSERT INTO students (roll_number, full_name, gender, date_of_birth, phone_number, academic_year_id)
    VALUES (i::text, 'សិស្សទី ' || i || ' (ថ្នាក់ ១២ ខ)', CASE WHEN i % 2 = 0 THEN 'Female' ELSE 'Male' END, '2008-06-01', '019' || LPAD(i::text, 6, '0'), '2026-2027')
    RETURNING student_id INTO v_stu_id;
    INSERT INTO class_students (class_id, student_id) VALUES (v_cls_12b, v_stu_id) ON CONFLICT DO NOTHING;
    IF i <= 31 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_12b, v_stu_id, CURRENT_DATE, 'present')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'present';
    ELSIF i <= 34 THEN
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_12b, v_stu_id, CURRENT_DATE, 'permission')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'permission';
    ELSE
      INSERT INTO slot_attendance_records (slot_id, student_id, date, status)
      VALUES (v_slot_12b, v_stu_id, CURRENT_DATE, 'absent')
      ON CONFLICT (slot_id, student_id, date) DO UPDATE SET status = 'absent';
    END IF;
  END LOOP;
END $$;
