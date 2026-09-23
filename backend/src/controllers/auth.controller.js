const { securityLogger } = require("../config/logger");
const { OAuth2Client } = require("google-auth-library");
const bcrypt = require("bcryptjs");
const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");
const { createSession, getSession, deleteSession } = require("../config/redis");
const {
  newJti,
  signSessionToken,
  verifyToken,
  SESSION_COOKIE,
  sessionCookieOptions,
  clearSessionCookie,
} = require("../utils/token");

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

const normalizeEmail = (value) => (value || "").trim().toLowerCase();

// Turn a verified user into a logged-in session:
const startSession = async (res, user, picture) => {
  const jti = newJti();
  const payload = { user_id: user.user_id, email: user.email, role: user.role };

  await createSession(jti, {
    user_id: user.user_id,
    email: user.email,
    name: user.full_name,
    role: user.role,
    avatar: picture || null,
    createdAt: new Date().toISOString(),
  });

  const token = signSessionToken(payload, jti);
  res.cookie(SESSION_COOKIE, token, sessionCookieOptions);

  return { user_id: user.user_id, name: user.full_name, email: user.email, role: user.role, avatar: picture };
};

// POST /api/auth/google — Body: { idToken }
const googleLogin = async (req, res, next) => {
  try {
    const credential = req.body.idToken;
    if (!credential)
      return res.status(400).json({ error: "Google credential is required" });

    const ticket = await client.verifyIdToken({
      idToken: credential,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    const payload = ticket.getPayload();
    const { email, name, picture } = payload;
    const normalizedEmailValue = normalizeEmail(email);

    const { rows } = await query(
      `SELECT u.user_id, u.email, u.full_name, u.role
       FROM users u
       WHERE LOWER(u.email) = LOWER($1)`,
      [normalizedEmailValue]
    );

    if (rows.length === 0) {
      securityLogger.warn({
        event: "login", who: normalizedEmailValue, what: "/api/auth/google",
        outcome: "failure", reason: "account_not_found", ip: req.ip,
        timestamp: new Date().toISOString(),
      });
      return res.status(403).json({
        error: "Account not found. Ask your administrator to add your email.",
      });
    }

    const user = rows[0];
    const me = await startSession(res, user, picture);

    AuditLog.create({
      event_type: "login",
      performed_by: { user_id: user.user_id, name: user.full_name, role: user.role },
    }).catch(() => {});

    res.json({ user: me });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/login — Body: { email, password }
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const normalizedEmailValue = normalizeEmail(email);

    const { rows } = await query(
      `SELECT u.user_id, u.email, u.full_name, u.role, u.password_hash
       FROM users u
       WHERE LOWER(u.email) = LOWER($1)`,
      [normalizedEmailValue]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const user = rows[0];

    if (!user.password_hash) {
      return res.status(401).json({ error: "Account not activated. Please set your password first." });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid email or password" });
    }

    const me = await startSession(res, user, null);
    res.json({ user: me });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/register — Set password for an existing whitelisted email
const register = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ error: "Email and password are required" });
    }

    const normalizedEmailValue = normalizeEmail(email);

    // 1. Check if the user is in the whitelisted users table
    const { rows } = await query(
      `SELECT user_id, password_hash FROM users WHERE LOWER(email) = LOWER($1)`,
      [normalizedEmailValue]
    );

    if (rows.length === 0) {
      return res.status(403).json({ error: "Your email is not in the system. Please contact Admin." });
    }

    const user = rows[0];

    // 2. Prevent overwriting if already registered (optional, or allow reset)
    if (user.password_hash) {
      return res.status(400).json({ error: "Account already active. Use Forgot Password if needed." });
    }

    // 3. Hash the new password and update the user record
    const salt = await bcrypt.genSalt(10);
    const hash = await bcrypt.hash(password, salt);

    await query(
      `UPDATE users SET password_hash = $1 WHERE user_id = $2`,
      [hash, user.user_id]
    );

    securityLogger.info({
      event: "registration", who: normalizedEmailValue, what: "/api/auth/register",
      outcome: "success", ip: req.ip, timestamp: new Date().toISOString(),
    });

    res.json({ message: "Account activated successfully! You can now log in." });
  } catch (err) {
    next(err);
  }
};

const logout = async (req, res, next) => {
  try {
    const token = req.cookies[SESSION_COOKIE];
    let jti = null;
    if (token) {
      try {
        jti = verifyToken(token).jti;
      } catch { /* ignore */ }
    }
    if (jti) await deleteSession(jti);
    res.clearCookie(SESSION_COOKIE, clearSessionCookie);
    res.json({ message: "Logged out" });
  } catch (err) {
    next(err);
  }
};

const getMe = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT u.user_id, u.email, u.full_name, u.role FROM users u WHERE u.user_id = $1`,
      [req.user.user_id]
    );
    if (!rows.length) return res.status(404).json({ error: "User not found" });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

module.exports = { googleLogin, login, register, logout, getMe };
