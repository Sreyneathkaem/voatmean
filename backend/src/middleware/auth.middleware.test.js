process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

jest.mock("../config/db", () => ({
  query: jest.fn(),
}));
jest.mock("../utils/token");
jest.mock("../config/redis");
jest.mock("../config/logger", () => ({
  securityLogger: { warn: jest.fn(), info: jest.fn(), error: jest.fn() },
}));

const { authenticate, authorize, authorizeClass, authorizeSlot } = require("./auth.middleware");
const { verifyToken, SESSION_COOKIE } = require("../utils/token");
const { getSession } = require("../config/redis");
const { query } = require("../config/db");

describe("auth.middleware", () => {
  let req, res, next;

  beforeEach(() => {
    req = {
      cookies: {},
      ip: "127.0.0.1",
      originalUrl: "/test",
      params: {},
      body: {},
      user: null,
    };
    res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
      clearCookie: jest.fn(),
    };
    next = jest.fn();
    jest.clearAllMocks();
  });

  describe("authenticate", () => {
    it("returns 401 NO_TOKEN when no session cookie is provided", async () => {
      await authenticate(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Not authenticated", code: "NO_TOKEN" });
      expect(next).not.toHaveBeenCalled();
    });

    it("returns 401 TOKEN_EXPIRED when verifyToken throws TokenExpiredError", async () => {
      req.cookies[SESSION_COOKIE] = "expired.jwt.token";
      const err = new Error("jwt expired");
      err.name = "TokenExpiredError";
      verifyToken.mockImplementation(() => {
        throw err;
      });

      await authenticate(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Session expired", code: "TOKEN_EXPIRED" });
    });

    it("returns 401 INVALID_TOKEN for invalid token", async () => {
      req.cookies[SESSION_COOKIE] = "bad.jwt.token";
      verifyToken.mockImplementation(() => {
        throw new Error("invalid signature");
      });

      await authenticate(req, res, next);
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Invalid token", code: "INVALID_TOKEN" });
    });

    it("returns 401 SESSION_REVOKED if session is not found in Redis", async () => {
      req.cookies[SESSION_COOKIE] = "valid.jwt.token";
      verifyToken.mockReturnValue({ jti: "jti-1", user_id: "u-1", email: "a@b.com", role: "admin" });
      getSession.mockResolvedValue(null);

      await authenticate(req, res, next);
      expect(res.clearCookie).toHaveBeenCalledWith(SESSION_COOKIE, { path: "/" });
      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith({ error: "Session ended. Please log in again.", code: "SESSION_REVOKED" });
    });

    it("attaches req.user and calls next() on valid token and active Redis session", async () => {
      req.cookies[SESSION_COOKIE] = "valid.jwt.token";
      verifyToken.mockReturnValue({ jti: "jti-1", user_id: "u-1", email: "a@b.com", role: "admin" });
      getSession.mockResolvedValue({ user_id: "u-1" });

      await authenticate(req, res, next);
      expect(req.user).toEqual({ user_id: "u-1", email: "a@b.com", role: "admin", jti: "jti-1" });
      expect(next).toHaveBeenCalledWith();
    });

    it("calls next(err) if an unexpected error occurs", async () => {
      req.cookies[SESSION_COOKIE] = "valid.jwt.token";
      verifyToken.mockReturnValue({ jti: "jti-1" });
      const dbErr = new Error("Redis failure");
      getSession.mockRejectedValue(dbErr);

      await authenticate(req, res, next);
      expect(next).toHaveBeenCalledWith(dbErr);
    });
  });

  describe("authorize", () => {
    it("allows access if user role is included", () => {
      req.user = { role: "admin", user_id: "u1" };
      const middleware = authorize("admin", "teacher");
      middleware(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("returns 403 if user role is not allowed", () => {
      req.user = { role: "student", user_id: "u1" };
      const middleware = authorize("admin", "teacher");
      middleware(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({ error: "Access denied. Required: admin or teacher" });
    });
  });

  describe("authorizeClass", () => {
    it("bypasses check for admin role", async () => {
      req.user = { role: "admin", user_id: "u1" };
      await authorizeClass(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("allows access if teacher owns the class", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.params.classId = "class-1";
      query.mockResolvedValue({ rows: [{ course_id: "class-1" }] });

      await authorizeClass(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("denies access if teacher does not own the class", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.params.classId = "class-1";
      query.mockResolvedValue({ rows: [] });

      await authorizeClass(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({ error: "You can only access your own class" });
    });

    it("calls next(err) on database error", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.params.classId = "class-1";
      const err = new Error("DB Error");
      query.mockRejectedValue(err);

      await authorizeClass(req, res, next);
      expect(next).toHaveBeenCalledWith(err);
    });
  });

  describe("authorizeSlot", () => {
    it("bypasses check for admin role", async () => {
      req.user = { role: "admin", user_id: "u1" };
      await authorizeSlot(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("bypasses check for admin_teacher role", async () => {
      req.user = { role: "admin_teacher", user_id: "u1" };
      await authorizeSlot(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("returns 400 if slot_id is missing", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      await authorizeSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(400);
      expect(res.json).toHaveBeenCalledWith({ error: "slot_id is required" });
    });

    it("allows access if teacher owns the slot", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.params.slotId = "slot-1";
      query.mockResolvedValue({ rows: [{ slot_id: "slot-1" }] });

      await authorizeSlot(req, res, next);
      expect(next).toHaveBeenCalled();
    });

    it("denies access if teacher does not own the slot", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.body.slot_id = "slot-1";
      query.mockResolvedValue({ rows: [] });

      await authorizeSlot(req, res, next);
      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith({ error: "You can only access your own timetable slot" });
    });

    it("calls next(err) on error", async () => {
      req.user = { role: "teacher", user_id: "u1" };
      req.params.slotId = "slot-1";
      const err = new Error("DB Error");
      query.mockRejectedValue(err);

      await authorizeSlot(req, res, next);
      expect(next).toHaveBeenCalledWith(err);
    });
  });
});
