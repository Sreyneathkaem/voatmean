const { createClient } = require("redis");

const redisUrl = process.env.REDIS_URL || "redis://localhost:6379";

const client = createClient({ url: redisUrl });

client.on("error", (err) => {
  console.error("❌ Redis error:", err.message);
});

client.on("connect", () => console.log("✅ Redis connected"));
client.on("reconnectError", () => {});

let connected = false;

const connectRedis = async () => {
  if (connected) return client;
  try {
    await client.connect();
    connected = true;
  } catch (err) {
    console.warn(
      "⚠️  Redis unavailable — session revocation/refresh disabled. " +
        "Tokens still validate by signature, but logout will not invalidate them server-side."
    );
  }
  return client;
};

// ── Session store (Redis) ───────────────────────────────────────────────
// A "session" is one logged-in browser, keyed by the JWT `jti` (JWT ID).
// Storing it in Redis lets us:
//   • revoke a token instantly on logout (delete the key)
//   • detect refresh-token reuse (key already gone) → possible theft
//   • expire idle sessions automatically via TTL
const SESSION_PREFIX = "sess:";
const sessionKey = (jti) => `${SESSION_PREFIX}${jti}`;

const SESSION_TTL_SECONDS = Number(process.env.SESSION_TTL_SECONDS || 12 * 60 * 60); // 12h (matches JWT_EXPIRES_IN)

const createSession = async (jti, data) => {
  if (!connected) return;
  await client.set(sessionKey(jti), JSON.stringify(data), {
    EX: SESSION_TTL_SECONDS,
  });
};

const getSession = async (jti) => {
  if (!connected || !jti) return null;
  const raw = await client.get(sessionKey(jti));
  if (!raw) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
};

const deleteSession = async (jti) => {
  if (!connected || !jti) return false;
  const removed = await client.del(sessionKey(jti));
  return removed > 0;
};

// Extend the session lifetime (sliding window on refresh).
const touchSession = async (jti) => {
  if (!connected || !jti) return;
  await client.expire(sessionKey(jti), SESSION_TTL_SECONDS);
};

module.exports = {
  client,
  connectRedis,
  createSession,
  getSession,
  deleteSession,
  touchSession,
  SESSION_TTL_SECONDS,
};
