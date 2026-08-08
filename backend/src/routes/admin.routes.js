const express = require("express");
const r = express.Router();
const { authenticate, authorize } = require("../middleware/auth.middleware");
const {
  getDashboard,
  getDashboardExport,
  getTeachers,
  createTeacher,
  getClasses,
  createClass,
  assignTeacher,
  getAcademicYears,
  getMajors,
  getStudentsByMajor,
  getTerms,
  createTerm,
} = require("../controllers/admin.controller");

r.use(authenticate, authorize("admin", "admin_teacher"));
r.get("/dashboard", getDashboard);
r.get("/dashboard/export-scores", getDashboardExport);
r.get("/teachers", getTeachers);
r.post("/teachers", createTeacher);
r.get("/classes", getClasses);
r.post("/classes", createClass);
r.put("/classes/:class_id/teacher", assignTeacher);
r.get("/academic-years", getAcademicYears);
r.get("/majors", getMajors);
r.get("/students-by-major", getStudentsByMajor);
r.get("/terms", getTerms);
r.post("/terms", createTerm);
module.exports = r;
