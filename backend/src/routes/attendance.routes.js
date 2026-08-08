const express = require("express");
const r = express.Router();
const {
  authenticate,
  authorize,
  authorizeClass,
} = require("../middleware/auth.middleware");
const {
  createSession,
  getSessionAttendance,
  saveSessionAttendance,
  getAttendanceByDate,
  saveAttendance,
  remarkAttendance,
  getHistory,
  listSessions,
} = require("../controllers/attendance.controller");

r.get("/sessions/:classId", authenticate, authorizeClass, listSessions);
r.post(
  "/sessions/:classId",
  authenticate,
  authorize("admin", "admin_teacher"),
  createSession,
);
r.get("/session/:sessionId", authenticate, getSessionAttendance);
r.post("/session/:sessionId", authenticate, saveSessionAttendance);
r.get("/:classId/history", authenticate, authorizeClass, getHistory);
r.get("/:classId/:date", authenticate, authorizeClass, getAttendanceByDate);
r.post("/", authenticate, saveAttendance);
r.put(
  "/:recordId/remark",
  authenticate,
  authorize("admin", "admin_teacher"),
  remarkAttendance,
);
module.exports = r;
