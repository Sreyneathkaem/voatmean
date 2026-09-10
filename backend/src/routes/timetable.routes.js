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
