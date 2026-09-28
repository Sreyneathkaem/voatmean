SET client_encoding = 'UTF8';

DO $$
DECLARE
  v_sreyneath_id UUID;
  v_sreyneang_id UUID;
  v_cls_10a UUID := 'b1c76ca3-3912-4a41-9dcd-33da8c0074e4';
  v_cls_10b UUID := 'ae3e0105-0621-42a4-b413-102bb3959e80';
  v_cls_11a UUID := '0a92cc0f-3732-4927-9fed-1bbadda7c824';
  v_cls_11b UUID := '649fbf63-4527-455b-a447-93ec307c5453';
  v_cls_12a UUID := '8cbf0b3f-162d-4212-bea6-43fed7d693d8';
  v_cls_12b UUID := '429b91d0-cd0a-40c8-89b3-063ccae4eaa1';
BEGIN
  -- 1. Ensure Kaem Sreyneath exists as teacher
  INSERT INTO users (full_name, email, role)
  VALUES ('អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)', 'k.sreyneath24@gmail.com', 'teacher')
  ON CONFLICT (email) DO UPDATE 
    SET full_name = 'អ្នកគ្រូ កែម ស្រីនីត (Kaem Sreyneath)', role = 'teacher'
  RETURNING user_id INTO v_sreyneath_id;

  -- 2. Ensure Yung Sreyneang exists as teacher
  INSERT INTO users (full_name, email, role)
  VALUES ('អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)', 'neangsrey137@gmail.com', 'teacher')
  ON CONFLICT (email) DO UPDATE 
    SET full_name = 'អ្នកគ្រូ យុង ស្រីនាង (Yung Sreyneang)', role = 'teacher'
  RETURNING user_id INTO v_sreyneang_id;

  -- 3. Reassign remarks/logs
  UPDATE slot_attendance_records
  SET remarked_by = v_sreyneath_id
  WHERE remarked_by IS NOT NULL;

  UPDATE attendance_records
  SET remarked_by = v_sreyneath_id
  WHERE remarked_by IS NOT NULL;

  UPDATE session_attendance_records
  SET remarked_by = v_sreyneath_id
  WHERE remarked_by IS NOT NULL;

  UPDATE subject_scores
  SET entered_by = v_sreyneath_id
  WHERE entered_by IS NOT NULL;

  -- 4. Clean timetable_slots to only Kaem Sreyneath and Yung Sreyneang without unique key conflict
  -- Remove existing non-matching slots
  DELETE FROM timetable_slots;

  -- Insert slots for Kaem Sreyneath (English, Khmer Literature, Mathematics)
  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_12b, subject_id, v_sreyneath_id, 1, 1 FROM subjects WHERE subject_name = 'English' LIMIT 1;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_11a, subject_id, v_sreyneath_id, 1, 2 FROM subjects WHERE subject_name = 'Khmer Literature' LIMIT 1;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_10a, subject_id, v_sreyneath_id, 1, 3 FROM subjects WHERE subject_name = 'Mathematics' LIMIT 1;

  -- Insert slots for Yung Sreyneang (Physics, Chemistry, Biology)
  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_10b, subject_id, v_sreyneang_id, 1, 1 FROM subjects WHERE subject_name = 'Physics' LIMIT 1;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_11b, subject_id, v_sreyneang_id, 1, 2 FROM subjects WHERE subject_name = 'Chemistry' LIMIT 1;

  INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period)
  SELECT v_cls_12a, subject_id, v_sreyneang_id, 1, 3 FROM subjects WHERE subject_name = 'Biology' LIMIT 1;

  -- 5. Reassign courses
  UPDATE courses 
  SET teacher_id = CASE WHEN course_id LIKE '%A' THEN v_sreyneath_id ELSE v_sreyneang_id END;

  -- 6. Remove all other teachers from users table
  DELETE FROM users
  WHERE (role = 'teacher' OR role = 'admin_teacher')
    AND user_id NOT IN (v_sreyneath_id, v_sreyneang_id);

END $$;
