SET client_encoding = 'UTF8';

-- Update all corrupted student names with authentic Khmer student names based on their roll number and class
DO $$
DECLARE
  r RECORD;
  khmer_surnames TEXT[] := ARRAY[
    'សុខ', 'កែវ', 'ចាន់', 'ហេង', 'ជា', 'លី', 'ម៉េង', 'ទេព', 'គង់', 'ព្រំ',
    'អ៊ុក', 'ឈិត', 'ស៊ឹម', 'យន់', 'អ៊ឹម', 'រ័ត្ន', 'ស៊ន', 'ប៊ុន', 'នួន', 'វ៉ាន់',
    'សៀក', 'ផន', 'ឡាយ', 'សេង', 'ឃុត', 'ឌៀប', 'ម៉ៅ', 'ឡុង', 'ពេជ្រ', 'យឹម',
    'ប៉ែន', 'ទ្រី', 'សំ', 'សន', 'អៀង'
  ];
  khmer_male_names TEXT[] := ARRAY[
    'ពិសិដ្ឋ', 'វីរៈ', 'បូរ៉ា', 'សុវណ្ណ', 'មុនីន្ទ', 'កុសល', 'ដារ៉ា', 'សម្បត្តិ', 'វិសាល',
    'ភារម្យ', 'ច័ន្ទដារ៉ា', 'សុខហេង', 'វិបុល', 'ឧត្តម', 'វណ្ណឌី', 'រក្សា', 'រដ្ឋា', 'វិចិត្រ'
  ];
  khmer_female_names TEXT[] := ARRAY[
    'មុន្នី', 'សុខា', 'ស្រីពៅ', 'ធីតា', 'វណ្ណា', 'ស្រីនាថ', 'ចិន្តា', 'រស្មី', 'ចរិយា',
    'សោភា', 'មុន្នីរ័ត្ន', 'សុគន្ធា', 'គន្ធា', 'កល្យាណ', 'ពិសី', 'និមល', 'ធារី', 'លីដា'
  ];
  surname TEXT;
  firstname TEXT;
  clean_name TEXT;
  idx INT;
  roll_val INT;
BEGIN
  FOR r IN 
    SELECT s.student_id, s.roll_number, s.gender, hc.class_name
    FROM students s
    LEFT JOIN class_students cs ON cs.student_id = s.student_id
    LEFT JOIN homeroom_classes hc ON hc.class_id = cs.class_id
    WHERE s.full_name LIKE '%?%' OR s.full_name LIKE 'សិស្សទី%'
    ORDER BY s.student_id
  LOOP
    roll_val := COALESCE(NULLIF(regexp_replace(r.roll_number, '\D', '', 'g'), '')::INT, 1);
    idx := ((roll_val - 1) % array_length(khmer_surnames, 1)) + 1;
    surname := khmer_surnames[idx];

    IF r.gender = 'Female' THEN
      idx := ((roll_val - 1) % array_length(khmer_female_names, 1)) + 1;
      firstname := khmer_female_names[idx];
    ELSE
      idx := ((roll_val - 1) % array_length(khmer_male_names, 1)) + 1;
      firstname := khmer_male_names[idx];
    END IF;

    clean_name := surname || ' ' || firstname;

    UPDATE students
    SET full_name = clean_name
    WHERE student_id = r.student_id;
  END LOOP;
END $$;
