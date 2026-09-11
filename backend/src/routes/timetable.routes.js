<<<<<<< HEAD
const express = require("express");
const r = express.Router();
const {
  authenticate,
  authorize,
  authorizeSlot,
} = require("../middleware/auth.middleware");
const {
  getTimetableSlots,
  getMySlots,
  getTimetableSlot,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
} = require("../controllers/timetable.controller");

r.use(authenticate);

// A teacher's own schedule — any authenticated role, scoped to self.
r.get("/mine", getMySlots);

// Everything else is admin/admin_teacher-managed, except reading a
// single slot: authorizeSlot lets the owning teacher fetch their own
// slot's detail too (admin/admin_teacher bypass as usual).
r.get("/", authorize("admin", "admin_teacher"), getTimetableSlots);
r.post("/", authorize("admin", "admin_teacher"), createTimetableSlot);
r.get("/:slotId", authorizeSlot, getTimetableSlot);
r.put("/:slotId", authorize("admin", "admin_teacher"), updateTimetableSlot);
r.delete("/:slotId", authorize("admin", "admin_teacher"), deleteTimetableSlot);

module.exports = r;
=======
const express = require('express');
const router = express.Router();
const timetableController = require('../controllers/timetable.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

// All timetable management is admin-only for now
router.use(authenticate);

// Admin view/manage
router.get('/class/:classId', authorize('admin', 'admin_teacher'), timetableController.getSlotsByClass);
router.get('/teacher/:teacherId', authorize('admin', 'admin_teacher'), timetableController.getSlotsByTeacher);
router.post('/', authorize('admin', 'admin_teacher'), timetableController.createSlot);
router.delete('/:slotId', authorize('admin', 'admin_teacher'), timetableController.deleteSlot);

module.exports = router;
>>>>>>> main
