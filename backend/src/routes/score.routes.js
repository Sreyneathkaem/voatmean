const express = require('express');
const router = express.Router();
const scoreController = require('../controllers/score.controller');
const { authenticate, authorize } = require('../middleware/auth.middleware');

router.use(authenticate);

// Teachers and admins can enter scores
router.post('/subject', authorize('admin', 'teacher', 'admin_teacher'), scoreController.upsertSubjectScore);

// View final grades for a class/subject
router.get('/final/:classId/:subjectId/:month', scoreController.getMonthlyGrades);

module.exports = router;
