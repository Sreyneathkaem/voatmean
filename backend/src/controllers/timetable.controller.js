const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

<<<<<<< HEAD
// timetable_slots has two separate UNIQUE constraints (see
// 002_timetable_schema.sql): a class can't have two subjects in the
// same day/period, and a teacher can't be double-booked in the same
// day/period. Postgres auto-names these constraints after their
// columns — map that name to a message a caller can actually act on.
const DOUBLE_BOOKING_MESSAGES = {
  timetable_slots_class_id_day_of_week_period_key:
    "This class already has a subject scheduled for that day/period.",
  timetable_slots_teacher_id_day_of_week_period_key:
    "This teacher is already booked for that day/period.",
};

const conflictMessageFor = (err) =>
  DOUBLE_BOOKING_MESSAGES[err.constraint] ||
  "This slot conflicts with an existing timetable entry.";

const SLOT_SELECT = `
  SELECT ts.slot_id, ts.class_id, ts.subject_id, ts.teacher_id, ts.term_id,
         ts.day_of_week, ts.period, ts.created_at,
         hc.class_name, sub.subject_name,
         u.full_name AS teacher_name
  FROM timetable_slots ts
  JOIN homeroom_classes hc ON hc.class_id = ts.class_id
  JOIN subjects sub        ON sub.subject_id = ts.subject_id
  JOIN users u              ON u.user_id = ts.teacher_id
`;

// GET /api/timetable
// Optional filters: ?classId=&teacherId=&subjectId=&dayOfWeek=
const getTimetableSlots = async (req, res, next) => {
  try {
    const { classId, teacherId, subjectId, dayOfWeek } = req.query;
    const conditions = [];
    const params = [];

    if (classId) {
      params.push(classId);
      conditions.push(`ts.class_id = $${params.length}`);
    }
    if (teacherId) {
      params.push(teacherId);
      conditions.push(`ts.teacher_id = $${params.length}`);
    }
    if (subjectId) {
      params.push(subjectId);
      conditions.push(`ts.subject_id = $${params.length}`);
    }
    if (dayOfWeek) {
      params.push(dayOfWeek);
      conditions.push(`ts.day_of_week = $${params.length}`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";
    const { rows } = await query(
      `${SLOT_SELECT} ${where} ORDER BY ts.day_of_week, ts.period`,
      params,
=======
/**
 * GET /api/admin/timetable/class/:classId
 */
const getSlotsByClass = async (req, res, next) => {
  try {
    const { classId } = req.params;
    const { rows } = await query(
      `SELECT ts.*, s.subject_name, u.full_name as teacher_name
       FROM timetable_slots ts
       JOIN subjects s ON s.subject_id = ts.subject_id
       JOIN users u ON u.user_id = ts.teacher_id
       WHERE ts.class_id = $1
       ORDER BY ts.day_of_week, ts.period`,
      [classId]
>>>>>>> main
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

<<<<<<< HEAD
// GET /api/timetable/mine
// A teacher's own schedule. Not gated by authorizeSlot (there's no
// single :slotId to check) — just scoped to req.user.user_id directly.
// Admin/admin_teacher hitting this get an empty list unless they're
// also assigned as a teacher on some slot, which is expected.
const getMySlots = async (req, res, next) => {
  try {
    const { rows } = await query(
      `${SLOT_SELECT} WHERE ts.teacher_id = $1 ORDER BY ts.day_of_week, ts.period`,
      [req.user.user_id],
=======
/**
 * GET /api/admin/timetable/teacher/:teacherId
 */
const getSlotsByTeacher = async (req, res, next) => {
  try {
    const { teacherId } = req.params;
    const { rows } = await query(
      `SELECT ts.*, s.subject_name, hc.class_name
       FROM timetable_slots ts
       JOIN subjects s ON s.subject_id = ts.subject_id
       JOIN homeroom_classes hc ON hc.class_id = ts.class_id
       WHERE ts.teacher_id = $1
       ORDER BY ts.day_of_week, ts.period`,
      [teacherId]
>>>>>>> main
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

<<<<<<< HEAD
// GET /api/timetable/:slotId
const getTimetableSlot = async (req, res, next) => {
  try {
    const { rows } = await query(`${SLOT_SELECT} WHERE ts.slot_id = $1`, [
      req.params.slotId,
    ]);
    if (!rows.length) return res.status(404).json({ error: "Slot not found" });
    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// POST /api/timetable
// Body: { class_id, subject_id, teacher_id, term_id?, day_of_week, period }
const createTimetableSlot = async (req, res, next) => {
  try {
    const { class_id, subject_id, teacher_id, term_id, day_of_week, period } =
      req.body;

    if (!class_id || !subject_id || !teacher_id || !day_of_week || !period) {
      return res.status(400).json({
        error:
          "class_id, subject_id, teacher_id, day_of_week, and period are required",
      });
    }
    if (day_of_week < 1 || day_of_week > 7) {
      return res
        .status(400)
        .json({ error: "day_of_week must be between 1 (Mon) and 7 (Sun)" });
    }
    if (period < 1) {
      return res.status(400).json({ error: "period must be greater than 0" });
    }

    const { rows } = await query(
      `INSERT INTO timetable_slots (class_id, subject_id, teacher_id, term_id, day_of_week, period)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING slot_id`,
      [class_id, subject_id, teacher_id, term_id || null, day_of_week, period],
    );

    const { rows: full } = await query(`${SLOT_SELECT} WHERE ts.slot_id = $1`, [
      rows[0].slot_id,
    ]);

    AuditLog.create({
      event_type: "timetable_slot_created",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: {
        slot_id: full[0].slot_id,
        class_id: full[0].class_id,
        subject_id: full[0].subject_id,
        teacher_id: full[0].teacher_id,
      },
    }).catch(() => {});

    res.status(201).json(full[0]);
  } catch (err) {
    if (err.code === "23505") {
      return res.status(409).json({ error: conflictMessageFor(err) });
    }
    if (err.code === "23503") {
      return res
        .status(400)
        .json({ error: "class_id, subject_id, teacher_id, or term_id does not exist" });
    }
=======
/**
 * POST /api/admin/timetable
 * Body: { class_id, subject_id, teacher_id, day_of_week, period, term_id? }
 */
const createSlot = async (req, res, next) => {
  try {
    const { class_id, subject_id, teacher_id, day_of_week, period, term_id } = req.body;

    // 1. Basic validation
    if (!class_id || !subject_id || !teacher_id || !day_of_week || !period) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    // 2. Conflict Check (Class or Teacher already busy at this time)
    const { rows: conflicts } = await query(
      `SELECT 'class' as conflict_type FROM timetable_slots
       WHERE class_id = $1 AND day_of_week = $2 AND period = $3
       UNION ALL
       SELECT 'teacher' as conflict_type FROM timetable_slots
       WHERE teacher_id = $4 AND day_of_week = $2 AND period = $3`,
      [class_id, day_of_week, period, teacher_id]
    );

    if (conflicts.length > 0) {
      const type = conflicts[0].conflict_type;
      return res.status(409).json({
        error: `Schedule conflict: The ${type} is already assigned a subject for this period.`
      });
    }

    // 3. Insert
    const { rows } = await query(
      `INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period, term_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [class_id, subject_id, teacher_id, day_of_week, period, term_id || null]
    );

    const newSlot = rows[0];

    // 4. Audit Log
    AuditLog.create({
      event_type: "timetable_slot_created",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: newSlot.slot_id, class_id: newSlot.class_id, teacher_id: newSlot.teacher_id },
      metadata: { day_of_week, period }
    }).catch(() => {});

    res.status(201).json(newSlot);
  } catch (err) {
>>>>>>> main
    next(err);
  }
};

<<<<<<< HEAD
// PUT /api/timetable/:slotId
// Body: any subset of { class_id, subject_id, teacher_id, term_id, day_of_week, period }
const updateTimetableSlot = async (req, res, next) => {
  try {
    const { slotId } = req.params;
    const { class_id, subject_id, teacher_id, term_id, day_of_week, period } =
      req.body;

    if (day_of_week != null && (day_of_week < 1 || day_of_week > 7)) {
      return res
        .status(400)
        .json({ error: "day_of_week must be between 1 (Mon) and 7 (Sun)" });
    }
    if (period != null && period < 1) {
      return res.status(400).json({ error: "period must be greater than 0" });
    }

    const { rows } = await query(
      `UPDATE timetable_slots
       SET class_id    = COALESCE($1, class_id),
           subject_id  = COALESCE($2, subject_id),
           teacher_id  = COALESCE($3, teacher_id),
           term_id     = COALESCE($4, term_id),
           day_of_week = COALESCE($5, day_of_week),
           period      = COALESCE($6, period)
       WHERE slot_id = $7
       RETURNING slot_id`,
      [
        class_id || null,
        subject_id || null,
        teacher_id || null,
        term_id || null,
        day_of_week || null,
        period || null,
        slotId,
      ],
    );
    if (!rows.length) return res.status(404).json({ error: "Slot not found" });

    const { rows: full } = await query(`${SLOT_SELECT} WHERE ts.slot_id = $1`, [
      slotId,
    ]);

    AuditLog.create({
      event_type: "timetable_slot_updated",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: full[0].slot_id },
    }).catch(() => {});

    res.json(full[0]);
  } catch (err) {
    if (err.code === "23505") {
      return res.status(409).json({ error: conflictMessageFor(err) });
    }
    if (err.code === "23503") {
      return res
        .status(400)
        .json({ error: "class_id, subject_id, teacher_id, or term_id does not exist" });
    }
    next(err);
  }
};

// DELETE /api/timetable/:slotId
// Cascades to slot_attendance_records (ON DELETE CASCADE) — deleting a
// slot deletes its attendance history too. Worth a confirm step on the
// frontend; the API itself doesn't second-guess the caller here.
const deleteTimetableSlot = async (req, res, next) => {
  try {
    const { rows } = await query(
      `DELETE FROM timetable_slots WHERE slot_id = $1 RETURNING slot_id`,
      [req.params.slotId],
    );
    if (!rows.length) return res.status(404).json({ error: "Slot not found" });
=======
/**
 * DELETE /api/admin/timetable/:slotId
 */
const deleteSlot = async (req, res, next) => {
  try {
    const { slotId } = req.params;
    const { rows } = await query(
      "DELETE FROM timetable_slots WHERE slot_id = $1 RETURNING *",
      [slotId]
    );

    if (!rows.length) {
      return res.status(404).json({ error: "Slot not found" });
    }
>>>>>>> main

    AuditLog.create({
      event_type: "timetable_slot_deleted",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
<<<<<<< HEAD
      target: { slot_id: req.params.slotId },
    }).catch(() => {});

    res.json({ deleted: true });
=======
      target: { slot_id: slotId },
    }).catch(() => {});

    res.json({ message: "Slot deleted successfully", deleted_slot: rows[0] });
>>>>>>> main
  } catch (err) {
    next(err);
  }
};

module.exports = {
<<<<<<< HEAD
  getTimetableSlots,
  getMySlots,
  getTimetableSlot,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
};
=======
  getSlotsByClass,
  getSlotsByTeacher,
  createSlot,
  deleteSlot
};
>>>>>>> main
