const express = require("express");
const r = express.Router();
const {
  authenticate,
  authorize,
  authorizeClass,
} = require("../middleware/auth.middleware");
const {
  getStudentsByClass,
  addStudent,
  updateStudent,
} = require("../controllers/student.controller");
r.get("/:classId", authenticate, authorizeClass, getStudentsByClass);
r.post("/:classId", authenticate, authorizeClass, addStudent);
r.put("/:studentId", authenticate, updateStudent);
module.exports = r;
