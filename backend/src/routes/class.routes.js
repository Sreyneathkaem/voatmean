const express = require('express');
const r = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { getMyClass } = require('../controllers/class.controller');
r.get('/mine', authenticate, getMyClass);
module.exports = r;
