const { securityLogger } = require("../config/logger");
const { OAuth2Client } = require("google-auth-library");
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

// Turn a verified Google user into a logged-in session:
//  • mint a unique session id (jti)
//  • store the session in Redis (revocable, expiring)
//  • set ONE HttpOnly session cookie (the JWT is never exposed to JS)
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

// POST /api/auth/google — Body: { credential } (Google ID token)
const googleLogin = async (req, res, next) => {
  try {
    const credential = req.body.credential || req.body.idToken;
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
    if (user.email !== normalizedEmailValue) {
      await query(`UPDATE users SET email = $2 WHERE user_id = $1`, [user.user_id, normalizedEmailValue]);
    }

    const me = await startSession(res, user, picture);

    AuditLog.create({
      event_type: "login",
      performed_by: { user_id: user.user_id, name: user.full_name, role: user.role },
    }).catch(() => {});

    securityLogger.info({
      event: "login", who: user.email, what: "/api/auth/google",
      outcome: "success", ip: req.ip, timestamp: new Date().toISOString(),
    });

    res.json({ user: me });
  } catch (err) {
    next(err);
  }
};

// POST /api/auth/logout — clears the session cookie completely AND deletes
// the session from Redis. After this, even a captured token is worthless
// because the server-side session no longer exists.
const logout = async (req, res, next) => {
  try {
    const token = req.cookies[SESSION_COOKIE];
    let jti = null;
    if (token) {
      try {
        jti = verifyToken(token).jti;
      } catch {
        /* expired/invalid token — still clear the cookie below */
      }
    }

    if (jti) await deleteSession(jti);

    // Expire the cookie immediately so the browser drops it.
    res.clearCookie(SESSION_COOKIE, clearSessionCookie);

    securityLogger.info({
      event: "logout", who: req.user?.user_id || jti || "unknown",
      what: "/api/auth/logout", outcome: "success", ip: req.ip,
      timestamp: new Date().toISOString(),
    });

    res.json({ message: "Logged out" });
  } catch (err) {
    next(err);
  }
};

// GET /api/auth/me — returns the current user from the session cookie.
const getMe = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT u.user_id, u.email, u.full_name, u.role
       FROM users u WHERE u.user_id = $1`,
      [req.user.user_id]
    );
    if (!rows.length) return res.status(404).json({ error: "User not found" });
    const u = rows[0];
    res.json({ user_id: u.user_id, name: u.full_name, email: u.email, role: u.role });
  } catch (err) {
    next(err);
  }
};

module.exports = { googleLogin, logout, getMe };
