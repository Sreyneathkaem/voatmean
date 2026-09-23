// auth.routes.js
const express = require("express");
const r = express.Router();
const { googleLogin, login, register, logout, getMe } = require("../controllers/auth.controller");
const { authenticate } = require("../middleware/auth.middleware");

r.post("/google", googleLogin);    // Google OAuth
r.post("/login", login);           // Email/Password login
r.post("/register", register);     // Set password for whitelisted email
r.post("/logout", logout);
r.get("/me", authenticate, getMe);

module.exports = r;
