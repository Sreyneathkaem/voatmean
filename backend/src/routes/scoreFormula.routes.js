const express = require("express");
const r = express.Router();
const { authenticate, authorize } = require("../middleware/auth.middleware");
const {
  getAllConfigs,
  getDefaultConfig,
  getEffectiveConfig,
  updateDefaultConfig,
  upsertSubjectConfig,
  deleteSubjectConfig,
} = require("../controllers/scoreFormula.controller");

r.use(authenticate);

// Default system config: admin and admin_teacher only
r.get("/", authorize("admin", "admin_teacher"), getAllConfigs);
r.get("/default", authorize("admin", "admin_teacher"), getDefaultConfig);
r.put("/default", authorize("admin", "admin_teacher"), updateDefaultConfig);

// Subject-specific score & attendance formula: accessible by teachers, admin, admin_teacher
r.get("/:subjectId", authorize("admin", "admin_teacher", "teacher"), getEffectiveConfig);
r.put("/:subjectId", authorize("admin", "admin_teacher", "teacher"), upsertSubjectConfig);
r.delete("/:subjectId", authorize("admin", "admin_teacher"), deleteSubjectConfig);

module.exports = r;
