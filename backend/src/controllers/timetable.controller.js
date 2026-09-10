const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

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
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

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
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

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
    next(err);
  }
};

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

    AuditLog.create({
      event_type: "timetable_slot_deleted",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: slotId },
    }).catch(() => {});

    res.json({ message: "Slot deleted successfully", deleted_slot: rows[0] });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getSlotsByClass,
  getSlotsByTeacher,
  createSlot,
  deleteSlot
};
