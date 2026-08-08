const crypto = require("crypto");
const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
  throw new Error(
    "JWT_SECRET is not set. Generate one with: node -e \"console.log(require('crypto').randomBytes(48).toString('hex'))\" and put it in .env"
  );
}

// One session cookie (short-to-medium lived). Revocation is handled
// server-side in Redis (see auth.middleware.js), so logout makes the
// token useless even if someone captured it.
const SESSION_TOKEN_TTL = process.env.JWT_EXPIRES_IN || "12h";

// Cookie name. httpOnly → JS cannot read it (no XSS token theft).
const SESSION_COOKIE = "ea_session";

const isProd = process.env.NODE_ENV === "production";

// sameSite: 'lax' is the safe default (works via the Vite dev proxy, which
// makes /api same-origin). For a real cross-origin HTTPS deployment, set
// COOKIE_SAMESITE=none (secure is then forced on).
const sameSite = (process.env.COOKIE_SAMESITE || "lax").toLowerCase();
const secure = sameSite === "none" ? true : isProd;

const sessionCookieOptions = {
  httpOnly: true,
  secure,
  sameSite,
  path: "/",
  maxAge: msFromTtl(SESSION_TOKEN_TTL),
};

// Clearing must use the SAME path/sameSite/secure the cookie was set with.
const clearSessionCookie = {
  path: sessionCookieOptions.path,
  httpOnly: true,
  sameSite: sessionCookieOptions.sameSite,
  secure: sessionCookieOptions.secure,
};

// Unique session id embedded in every token (jti = JWT ID). The live
// session lives in Redis keyed by this jti, so we can revoke it on logout.
const newJti = () => crypto.randomBytes(24).toString("hex");

const signSessionToken = (payload, jti) =>
  jwt.sign({ ...payload, jti }, JWT_SECRET, { expiresIn: SESSION_TOKEN_TTL });

// Verify throws on bad signature / expiry. Caller decides the response.
const verifyToken = (token) => jwt.verify(token, JWT_SECRET);

function msFromTtl(ttl) {
  const match = /^(\d+)\s*(s|m|h|d)$/.exec(ttl.trim());
  if (!match) return 12 * 60 * 60 * 1000;
  const value = Number(match[1]);
  const unit = match[2];
  const mult = { s: 1000, m: 60 * 1000, h: 60 * 60 * 1000, d: 24 * 60 * 60 * 1000 };
  return value * mult[unit];
}

module.exports = {
  JWT_SECRET,
  SESSION_COOKIE,
  sessionCookieOptions,
  clearSessionCookie,
  isProd,
  newJti,
  signSessionToken,
  verifyToken,
};
