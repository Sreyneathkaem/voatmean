const express = require("express");
const r = express.Router();
const { authenticate, authorize } = require("../middleware/auth.middleware");
const {
  getSubjects,
  createSubject,
  updateSubject,
} = require("../controllers/subject.controller");

r.use(authenticate, authorize("admin", "admin_teacher"));

r.get("/", getSubjects);
r.post("/", createSubject);
r.put("/:subjectId", updateSubject);

module.exports = r;