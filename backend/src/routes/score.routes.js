// score.routes.js
const express = require('express');
const r = express.Router();
const { authenticate, authorize, authorizeClass } = require('../middleware/auth.middleware');
const { getMonthlyScores, getScoreRules, updateScoreRules } = require('../controllers/score.controller');
r.get('/:classId/rules',  authenticate, getScoreRules);
r.put('/:classId/rules',  authenticate, authorize('teacher'), updateScoreRules);
r.get('/:classId/:month', authenticate, authorizeClass, getMonthlyScores);
module.exports = r;
