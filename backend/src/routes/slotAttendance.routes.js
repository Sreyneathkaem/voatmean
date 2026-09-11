const express = require('express');
const router = express.Router();
const slotAttendanceController = require('../controllers/slotAttendance.controller');
const { authenticate, authorizeSlot } = require('../middleware/auth.middleware');

router.use(authenticate);

// Both admins and the assigned teacher can view the roster
router.get('/:slotId/roster', authorizeSlot, slotAttendanceController.getSlotRoster);

// View existing attendance
router.get('/:slotId/:date', authorizeSlot, slotAttendanceController.getSlotAttendance);

// Save/Update attendance
router.post('/:slotId/:date', authorizeSlot, slotAttendanceController.saveSlotAttendance);

module.exports = router;
