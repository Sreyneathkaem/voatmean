const express = require("express");
const r = express.Router();
const {
  authenticate,
  authorize,
  authorizeSlot,
} = require("../middleware/auth.middleware");
const {
  getMyTimetable,
  getClassTimetable,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
} = require("../controllers/timetable.controller");

r.use(authenticate);

// Any authenticated teacher/admin_teacher/admin can fetch their OWN
// weekly schedule — no role gate needed, the query is already scoped
// to req.user.user_id.
r.get("/mine", getMyTimetable);

// Everything below is admin-facing timetable management.
r.use(authorize("admin", "admin_teacher"));

r.get("/:classId", getClassTimetable);
r.post("/", createTimetableSlot);
r.put("/:slotId", authorizeSlot, updateTimetableSlot);
r.delete("/:slotId", authorizeSlot, deleteTimetableSlot);

module.exports = r;

