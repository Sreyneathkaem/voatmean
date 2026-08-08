// auth.routes.js
const express = require("express");
const r = express.Router();
const { googleLogin, logout, getMe } = require("../controllers/auth.controller");
const { authenticate } = require("../middleware/auth.middleware");

r.post("/google", googleLogin);    // Google OAuth → HttpOnly session cookie
r.post("/logout", logout);         // clears cookie + revokes Redis session
r.get("/me", authenticate, getMe); // who am I, from the session cookie

module.exports = r;
