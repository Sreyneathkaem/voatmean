require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const cookieParser = require('cookie-parser');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const { pool } = require('./config/db');
const { connectMongo } = require('./config/mongo');
const { connectRedis } = require('./config/redis');
const { runMigrations } = require('./migrations/run');
const { JWT_SECRET } = require('./utils/token');

const authRoutes       = require('./routes/auth.routes');
const adminRoutes      = require('./routes/admin.routes');
const classRoutes      = require('./routes/class.routes');
const studentRoutes    = require('./routes/student.routes');
const attendanceRoutes = require('./routes/attendance.routes');
const scoreRoutes      = require('./routes/score.routes');

const { errorHandler } = require('./middleware/error.middleware');

const app  = express();
const PORT = process.env.PORT || 5000;

// ── Middleware ────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:5173',
  credentials: true,
}));
app.use(express.json());
app.use(cookieParser());
app.use(morgan('dev'));

// Stricter limit on the Google auth endpoint (abuse defense).
app.use('/api/auth/google', rateLimit({ windowMs: 15 * 60 * 1000, max: 30, standardHeaders: true, legacyHeaders: false }));
app.use('/api', rateLimit({ windowMs: 15 * 60 * 1000, max: 500, standardHeaders: true, legacyHeaders: false }));

// ── Health Check ──────────────────────────────────────────────────────
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', postgres: 'up', timestamp: new Date() });
  } catch (err) {
    res.status(503).json({ status: 'error', message: err.message });
  }
});

// ── Routes ─────────────────────────────────────────────────────────────
app.use('/api/auth',       authRoutes);
app.use('/api/admin',      adminRoutes);
app.use('/api/classes',    classRoutes);
app.use('/api/students',   studentRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/scores',     scoreRoutes);

// ── Error Handler ──────────────────────────────────────────────────────
app.use(errorHandler);

// ── Start ──────────────────────────────────────────────────────────────
const start = async () => {
  await connectMongo();
  await connectRedis();
  await runMigrations();
  if (!JWT_SECRET) {
    console.error('❌ JWT_SECRET is missing — refusing to start without a signing secret.');
    process.exit(1);
  }
  app.listen(PORT, () => {
    console.log(`\n🚀 EduAttend API → http://localhost:${PORT}`);
    console.log(`📋 Health check → http://localhost:${PORT}/health\n`);
  });
};

start().catch(err => { console.error(err); process.exit(1); });

module.exports = app;
