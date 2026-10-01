process.env.JWT_SECRET = "test-jwt-secret-key-for-testing-only-32-bytes-long";

const express = require("express");

jest.mock("../config/db", () => ({
  query: jest.fn(),
  getClient: jest.fn(),
}));

jest.mock("../config/mongo", () => ({
  AuditLog: {
    create: jest.fn().mockResolvedValue({}),
  },
}));

describe("Route definitions", () => {
  it("should mount all routes successfully", () => {
    const app = express();
    app.use(express.json());

    const adminRoutes = require("./admin.routes");
    const attendanceRoutes = require("./attendance.routes");
    const authRoutes = require("./auth.routes");
    const classRoutes = require("./class.routes");
    const homeroomClassRoutes = require("./homeroomClass.routes");
    const scoreRoutes = require("./score.routes");
    const scoreFormulaRoutes = require("./scoreFormula.routes");
    const slotAttendanceRoutes = require("./slotAttendance.routes");
    const studentRoutes = require("./student.routes");
    const subjectRoutes = require("./subject.routes");
    const timetableRoutes = require("./timetable.routes");

    app.use("/api/admin", adminRoutes);
    app.use("/api/attendance", attendanceRoutes);
    app.use("/api/auth", authRoutes);
    app.use("/api/classes", classRoutes);
    app.use("/api/admin/homeroom-classes", homeroomClassRoutes);
    app.use("/api/scores", scoreRoutes);
    app.use("/api/admin/score-formula", scoreFormulaRoutes);
    app.use("/api/attendance/slots", slotAttendanceRoutes);
    app.use("/api/students", studentRoutes);
    app.use("/api/admin/subjects", subjectRoutes);
    app.use("/api/timetable", timetableRoutes);

    expect(adminRoutes).toBeDefined();
    expect(authRoutes).toBeDefined();
    expect(timetableRoutes).toBeDefined();
  });
});
