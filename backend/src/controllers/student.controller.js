const { query } = require("../config/db");

const getStudentsByClass = async (req, res, next) => {
  try {
    const { classId } = req.params;
    let sql;
    let params = [];

    if (!classId || classId === 'all') {
      sql = `
        SELECT s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth, s.phone_number, s.major_id,
               COALESCE(hc.class_name, 'Grade 10A') AS class_name
        FROM students s
        LEFT JOIN class_students cs ON cs.student_id = s.student_id
        LEFT JOIN homeroom_classes hc ON hc.class_id = cs.class_id
        ORDER BY s.roll_number
      `;
    } else {
      params = [classId];
      sql = `
        SELECT s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth, s.phone_number, s.major_id,
               COALESCE(hc.class_name, 'Grade 10A') AS class_name
        FROM students s
        LEFT JOIN class_students cs ON cs.student_id = s.student_id
        LEFT JOIN homeroom_classes hc ON hc.class_id = cs.class_id
        WHERE s.course_id = $1 
           OR (s.course_id IS NULL AND s.major_id IN (SELECT major_id FROM course_majors WHERE course_id = $1))
           OR cs.class_id::text = $1
           OR hc.class_name = $1
        ORDER BY s.roll_number
      `;
    }

    const { rows } = await query(sql, params);
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

const addStudent = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { roll_number, full_name, gender, date_of_birth, phone_number } =
      req.body;

    let majorId = req.body.major_id || null;
    if (!majorId) {
      const course = await query(
        `SELECT major_id FROM courses WHERE course_id = $1`,
        [classId],
      );
      if (course.rows[0]?.major_id) {
        majorId = course.rows[0].major_id;
      }
    }

    const { rows } = await query(
      `INSERT INTO students (course_id, roll_number, full_name, gender, date_of_birth, phone_number, major_id)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [classId, roll_number, full_name, gender, date_of_birth, phone_number, majorId],
    );
    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

const updateStudent = async (req, res, next) => {
  try {
    const { studentId } = req.params;
    const { roll_number, full_name, gender, date_of_birth, phone_number } =
      req.body;
    const { rows } = await query(
      `UPDATE students
       SET roll_number = $1, full_name = $2, gender = $3, date_of_birth = $4, phone_number = $5
       WHERE student_id = $6
       RETURNING *`,
      [roll_number, full_name, gender, date_of_birth, phone_number, studentId],
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: "Student not found" });
    }
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

module.exports = { getStudentsByClass, addStudent, updateStudent };
