const { query } = require("../config/db");
const { AuditLog } = require("../config/mongo");

// GET /api/timetable/mine
// A teacher's full weekly schedule can be reconstructed from
// timetable_slots alone (BE-04 acceptance criteria). admin/admin_teacher
// hitting this endpoint just get their own teaching slots, if any —
// use GET /:classId to build out a class's timetable instead.
const getMyTimetable = async (req, res, next) => {
  try {
    const { rows } = await query(
      `SELECT ts.slot_id, ts.day_of_week, ts.period, ts.term_id,
              hc.class_id, hc.class_name, hc.grade_level,
              sub.subject_id, sub.subject_name
       FROM timetable_slots ts
       JOIN homeroom_classes hc ON hc.class_id = ts.class_id
       JOIN subjects sub        ON sub.subject_id = ts.subject_id
       WHERE ts.teacher_id = $1
       ORDER BY ts.day_of_week, ts.period`,
      [req.user.user_id],
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

// GET /api/timetable/:classId
// Admin-facing: the full weekly grid for one homeroom class, so an
// admin can see gaps and build the timetable out slot by slot.
const getClassTimetable = async (req, res, next) => {
  try {
    const { classId } = req.params;

    const cls = await query(
      `SELECT class_id, class_name, grade_level FROM homeroom_classes WHERE class_id = $1`,
      [classId],
    );
    if (!cls.rows.length) {
      return res.status(404).json({ error: "Class not found" });
    }

    const { rows } = await query(
      `SELECT ts.slot_id, ts.day_of_week, ts.period, ts.term_id,
              sub.subject_id, sub.subject_name,
              u.user_id AS teacher_id, u.full_name AS teacher_name
       FROM timetable_slots ts
       JOIN subjects sub ON sub.subject_id = ts.subject_id
       JOIN users u      ON u.user_id = ts.teacher_id
       WHERE ts.class_id = $1
       ORDER BY ts.day_of_week, ts.period`,
      [classId],
    );

    res.json({ class: cls.rows[0], slots: rows });
  } catch (err) {
    next(err);
  }
};

// POST /api/timetable  (admin only)
// Body: { class_id, subject_id, teacher_id, day_of_week, period, term_id? }
// DB-level UNIQUE constraints on (class_id, day_of_week, period) and
// (teacher_id, day_of_week, period) do the double-booking enforcement;
// a conflict here surfaces as a generic 409 via the shared error handler.
const createTimetableSlot = async (req, res, next) => {
  try {
    const { class_id, subject_id, teacher_id, day_of_week, period, term_id } =
      req.body;

    if (!class_id || !subject_id || !teacher_id || !day_of_week || !period) {
      return res.status(400).json({
        error:
          "class_id, subject_id, teacher_id, day_of_week and period are required",
      });
    }

    const { rows } = await query(
      `INSERT INTO timetable_slots (class_id, subject_id, teacher_id, day_of_week, period, term_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [class_id, subject_id, teacher_id, day_of_week, period, term_id || null],
    );

    AuditLog.create({
      event_type: "timetable_slot_created",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: {
        slot_id: rows[0].slot_id,
        class_id,
        subject_id,
        teacher_id,
      },
    }).catch(() => {});

    res.status(201).json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /api/timetable/:slotId  (admin only)
// Body: any subset of { subject_id, teacher_id, day_of_week, period, term_id }
// Routed through authorizeSlot for consistency with the attendance/scores
// endpoints that will reuse it later — today it's a no-op for admins since
// authorizeSlot bypasses on role, but it keeps this route honest if a
// teacher-facing use ever gets added on top of it.
const updateTimetableSlot = async (req, res, next) => {
  try {
    const { slotId } = req.params;
    const { subject_id, teacher_id, day_of_week, period, term_id } = req.body;

    const { rows } = await query(
      `UPDATE timetable_slots
       SET subject_id  = COALESCE($1, subject_id),
           teacher_id  = COALESCE($2, teacher_id),
           day_of_week = COALESCE($3, day_of_week),
           period      = COALESCE($4, period),
           term_id     = COALESCE($5, term_id)
       WHERE slot_id = $6
       RETURNING *`,
      [
        subject_id || null,
        teacher_id || null,
        day_of_week || null,
        period || null,
        term_id || null,
        slotId,
      ],
    );

    if (!rows.length) return res.status(404).json({ error: "Slot not found" });

    AuditLog.create({
      event_type: "timetable_slot_updated",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: rows[0].slot_id },
    }).catch(() => {});

    res.json(rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /api/timetable/:slotId  (admin only)
const deleteTimetableSlot = async (req, res, next) => {
  try {
    const { slotId } = req.params;
    const result = await query(
      `DELETE FROM timetable_slots WHERE slot_id = $1`,
      [slotId],
    );
    if (result.rowCount === 0) {
      return res.status(404).json({ error: "Slot not found" });
    }

    AuditLog.create({
      event_type: "timetable_slot_deleted",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: slotId },
    }).catch(() => {});

    res.json({ removed: true });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getMyTimetable,
  getClassTimetable,
  createTimetableSlot,
  updateTimetableSlot,
  deleteTimetableSlot,
};
