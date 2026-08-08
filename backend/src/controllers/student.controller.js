const { query } = require("../config/db");

const getStudentsByClass = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT student_id, roll_number, full_name, gender, date_of_birth, phone_number, major_id
       FROM students 
       WHERE course_id = $1 
          OR (course_id IS NULL AND major_id IN (SELECT major_id FROM course_majors WHERE course_id = $1))
       ORDER BY roll_number`,
      [req.params.classId],
    );
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
