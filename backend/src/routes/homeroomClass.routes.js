const express = require("express");
const r = express.Router();
const { authenticate, authorize } = require("../middleware/auth.middleware");
const {
  getHomeroomClasses,
  getHomeroomClass,
  createHomeroomClass,
  updateHomeroomClass,
  getHomeroomClassStudents,
  addStudentToHomeroomClass,
  removeStudentFromHomeroomClass,
} = require("../controllers/homeroomClass.controller");

r.use(authenticate, authorize("admin", "admin_teacher"));

r.get("/", getHomeroomClasses);
r.post("/", createHomeroomClass);
r.get("/:classId", getHomeroomClass);
r.put("/:classId", updateHomeroomClass);
r.get("/:classId/students", getHomeroomClassStudents);
r.post("/:classId/students", addStudentToHomeroomClass);
r.delete("/:classId/students/:studentId", removeStudentFromHomeroomClass);

module.exports = r;