process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));
jest.mock("../config/mongo", () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
  },
}));
jest.mock("../config/redis", () => ({
  createSession: jest.fn().mockResolvedValue("OK"),
  getSession: jest.fn().mockResolvedValue({}),
  deleteSession: jest.fn().mockResolvedValue(1),
}));
jest.mock("../config/logger", () => ({
  securityLogger: { warn: jest.fn(), info: jest.fn(), error: jest.fn() },
}));
jest.mock("bcryptjs", () => ({
  compare: jest.fn(),
  genSalt: jest.fn().mockResolvedValue("salt"),
  hash: jest.fn().mockResolvedValue("hashed_password"),
}));
jest.mock("../utils/token", () => ({
  SESSION_COOKIE: "voatmean_session",
  sessionCookieOptions: {},
  clearSessionCookie: {},
  newJti: jest.fn().mockReturnValue("mock-jti-123"),
  signSessionToken: jest.fn().mockReturnValue("mock-signed-token"),
  verifyToken: jest.fn().mockReturnValue({ jti: "jti-123", user_id: "u-123" }),
}));

const { googleLogin, login, register, logout, getMe } = require("./auth.controller");
const db = require("../config/db");
const bcrypt = require("bcryptjs");
const { deleteSession } = require("../config/redis");
const { verifyToken } = require("../utils/token");

describe("Auth Controller", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      body: {},
      params: {},
      cookies: {},
      ip: "127.0.0.1",
      user: { user_id: "u-123", role: "teacher" },
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      cookie: jest.fn(),
      clearCookie: jest.fn(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("login", () => {
    it("returns 400 if email or password is missing", async () => {
      req.body = { email: "user@school.edu" };

      await login(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Email and password are required" });
    });

    it("returns 401 if user account is not found", async () => {
      req.body = { email: "notfound@school.edu", password: "password123" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await login(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Invalid email or password" });
    });

    it("returns 401 if account is not activated (no password_hash)", async () => {
      req.body = { email: "inactive@school.edu", password: "password123" };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u1", email: "inactive@school.edu", password_hash: null }],
      });

      await login(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({
        error: "Account not activated. Please set your password first.",
      });
    });

    it("returns 401 if password does not match", async () => {
      req.body = { email: "user@school.edu", password: "wrongpassword" };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u1", email: "user@school.edu", password_hash: "hashed" }],
      });
      bcrypt.compare.mockResolvedValueOnce(false);

      await login(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Invalid email or password" });
    });

    it("logs in successfully when password matches", async () => {
      req.body = { email: "user@school.edu", password: "correctpassword" };
      const userObj = {
        user_id: "u1",
        email: "user@school.edu",
        full_name: "Test User",
        role: "teacher",
        password_hash: "hashed",
      };
      db.query.mockResolvedValueOnce({ rows: [userObj] });
      bcrypt.compare.mockResolvedValueOnce(true);

      await login(req, res, next);

      expect(res.cookie).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith({
        user: {
          user_id: "u1",
          name: "Test User",
          email: "user@school.edu",
          role: "teacher",
          avatar: null,
        },
      });
    });

    it("forwards error to next() on failure", async () => {
      req.body = { email: "user@school.edu", password: "password" };
      const err = new Error("Database Failure");
      db.query.mockRejectedValueOnce(err);

      await login(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("register", () => {
    it("returns 400 if email or password is missing", async () => {
      req.body = { email: "user@school.edu" };

      await register(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Email and password are required" });
    });

    it("returns 403 if email is not in system whitelist", async () => {
      req.body = { email: "unauthorized@school.edu", password: "password123" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await register(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({
        error: "Your email is not in the system. Please contact Admin.",
      });
    });

    it("returns 400 if account is already active", async () => {
      req.body = { email: "active@school.edu", password: "password123" };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u1", password_hash: "existing_hash" }],
      });

      await register(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({
        error: "Account already active. Use Forgot Password if needed.",
      });
    });

    it("registers user successfully by hashing password and updating user record", async () => {
      req.body = { email: "whitelisted@school.edu", password: "newpassword123" };
      db.query.mockResolvedValueOnce({
        rows: [{ user_id: "u2", password_hash: null }],
      });
      db.query.mockResolvedValueOnce({ rowCount: 1 }); // UPDATE query

      await register(req, res, next);

      expect(bcrypt.hash).toHaveBeenCalledWith("newpassword123", "salt");
      expect(db.query).toHaveBeenLastCalledWith(
        expect.stringContaining("UPDATE users SET password_hash"),
        ["hashed_password", "u2"],
      );
      expect(res.json).toHaveBeenCalledWith({
        message: "Account activated successfully! You can now log in.",
      });
    });

    it("forwards error to next() on failure", async () => {
      req.body = { email: "user@school.edu", password: "password" };
      const err = new Error("DB Exception");
      db.query.mockRejectedValueOnce(err);

      await register(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("logout", () => {
    it("deletes session and clears cookie", async () => {
      req.cookies = { voatmean_session: "valid.jwt.token" };
      verifyToken.mockReturnValueOnce({ jti: "jti-123" });

      await logout(req, res, next);

      expect(deleteSession).toHaveBeenCalledWith("jti-123");
      expect(res.clearCookie).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith({ message: "Logged out" });
    });

    it("forwards error to next() if logout fails", async () => {
      req.cookies = { voatmean_session: "valid.jwt.token" };
      verifyToken.mockReturnValueOnce({ jti: "jti-123" });
      const redisErr = new Error("Redis disconnect");
      deleteSession.mockRejectedValueOnce(redisErr);

      await logout(req, res, next);

      expect(next).toHaveBeenCalledWith(redisErr);
    });
  });

  describe("getMe", () => {
    it("returns user record when user exists", async () => {
      req.user = { user_id: "u-123" };
      const user = { user_id: "u-123", email: "teacher@school.edu", full_name: "Teacher", role: "teacher" };
      db.query.mockResolvedValueOnce({ rows: [user] });

      await getMe(req, res, next);

      expect(res.json).toHaveBeenCalledWith(user);
    });

    it("returns 404 when user is not found", async () => {
      req.user = { user_id: "nonexistent" };
      db.query.mockResolvedValueOnce({ rows: [] });

      await getMe(req, res, next);

      expect(res.status).toHaveBeenCalledWith(404);
      expect(res.json).toHaveBeenCalledWith({ error: "User not found" });
    });

    it("forwards error to next() on failure", async () => {
      req.user = { user_id: "u-123" };
      const err = new Error("DB Error");
      db.query.mockRejectedValueOnce(err);

      await getMe(req, res, next);

      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("googleLogin", () => {
    it("returns 400 when idToken is missing", async () => {
      req.body = {};

      await googleLogin(req, res, next);

      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "Google credential is required" });
    });
  });
});
