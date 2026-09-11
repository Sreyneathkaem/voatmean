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

r.use(authenticate, authorize("admin", "admin_teacher"));

r.get("/", getAllConfigs);
r.get("/default", getDefaultConfig);
r.put("/default", updateDefaultConfig);
r.get("/:subjectId", getEffectiveConfig);
r.put("/:subjectId", upsertSubjectConfig);
r.delete("/:subjectId", deleteSubjectConfig);

module.exports = r;
