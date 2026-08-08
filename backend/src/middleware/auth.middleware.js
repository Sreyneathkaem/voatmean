const { verifyToken, SESSION_COOKIE } = require("../utils/token");
const { getSession } = require("../config/redis");
const { query } = require("../config/db");
const { securityLogger } = require("../config/logger");

// Read the session token from the HttpOnly cookie (never from the URL/body).
// The frontend cannot touch this cookie via JS, so an XSS bug can't exfiltrate it.
const authenticate = async (req, res, next) => {
  try {
    const token = req.cookies[SESSION_COOKIE];
    if (!token) {
      securityLogger.warn({
        event: "authn_denied", who: "unknown", what: req.originalUrl,
        outcome: "denied", reason: "no_token", ip: req.ip,
        timestamp: new Date().toISOString(),
      });
      return res.status(401).json({ error: "Not authenticated", code: "NO_TOKEN" });
    }

    let decoded;
    try {
      decoded = verifyToken(token);
    } catch (err) {
      if (err.name === "TokenExpiredError") {
        return res.status(401).json({ error: "Session expired", code: "TOKEN_EXPIRED" });
      }
      securityLogger.warn({
        event: "authn_denied", who: "unknown", what: req.originalUrl,
        outcome: "denied", reason: "invalid_token", ip: req.ip,
        timestamp: new Date().toISOString(),
      });
      return res.status(401).json({ error: "Invalid token", code: "INVALID_TOKEN" });
    }

    // Signature is valid — but is the session still alive server-side?
    // This is what makes logout / instant-revocation actually work: a
    // captured token is useless once its Redis session is gone.
    const session = await getSession(decoded.jti);
    if (!session) {
      res.clearCookie(SESSION_COOKIE, { path: "/" });
      securityLogger.warn({
        event: "authn_denied", who: decoded.user_id, what: req.originalUrl,
        outcome: "denied", reason: "session_revoked", ip: req.ip,
        timestamp: new Date().toISOString(),
      });
      return res.status(401).json({ error: "Session ended. Please log in again.", code: "SESSION_REVOKED" });
    }

    req.user = {
      user_id: decoded.user_id,
      email: decoded.email,
      role: decoded.role,
      jti: decoded.jti,
    };
    next();
  } catch (err) {
    next(err);
  }
};

const authorize =
  (...roles) =>
  (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      securityLogger.warn({
        event: "authz_denied", who: req.user.user_id, what: req.originalUrl,
        outcome: "denied", role: req.user.role, required: roles.join(" or "),
        ip: req.ip, timestamp: new Date().toISOString(),
      });
      return res
        .status(403)
        .json({ error: `Access denied. Required: ${roles.join(" or ")}` });
    }
    next();
  };

const authorizeClass = async (req, res, next) => {
  try {
    if (req.user.role === "admin") return next();

    const classId = req.params.classId || req.body.class_id;

    const { rows } = await query(
      "SELECT course_id FROM courses WHERE course_id = $1 AND teacher_id = $2",
      [classId, req.user.user_id]
    );

    if (rows.length === 0) {
      securityLogger.warn({
        event: "authz_denied", who: req.user.user_id, what: req.originalUrl,
        outcome: "denied", reason: "not_class_owner", class_id: classId,
        ip: req.ip, timestamp: new Date().toISOString(),
      });
      return res
        .status(403)
        .json({ error: "You can only access your own class" });
    }

    next();
  } catch (err) {
    return next(err);
  }
};

module.exports = { authenticate, authorize, authorizeClass };
