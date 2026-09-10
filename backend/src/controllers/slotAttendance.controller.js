const { query, getClient } = require("../config/db");
const { AuditLog } = require("../config/mongo");

/**
 * GET /api/attendance/slots/:slotId/roster
 * Gets the list of students enrolled in the class assigned to this slot.
 */
const getSlotRoster = async (req, res, next) => {
  try {
    const { slotId } = req.params;
    const { rows } = await query(
      `SELECT s.student_id, s.roll_number, s.full_name, s.gender, s.date_of_birth
       FROM timetable_slots ts
       JOIN homeroom_classes hc ON hc.class_id = ts.class_id
       JOIN class_students cs ON cs.class_id = hc.class_id
       JOIN students s ON s.student_id = cs.student_id
       WHERE ts.slot_id = $1
       ORDER BY s.roll_number`,
      [slotId]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

/**
 * GET /api/attendance/slots/:slotId/:date
 * Gets existing attendance records for a slot on a specific date.
 */
const getSlotAttendance = async (req, res, next) => {
  try {
    const { slotId, date } = req.params;
    const { rows } = await query(
      `SELECT sar.*, s.full_name, s.roll_number, u.full_name as remarked_by_name
       FROM slot_attendance_records sar
       JOIN students s ON s.student_id = sar.student_id
       LEFT JOIN users u ON u.user_id = sar.remarked_by
       WHERE sar.slot_id = $1 AND sar.date = $2
       ORDER BY s.roll_number`,
      [slotId, date]
    );
    res.json(rows);
  } catch (err) {
    next(err);
  }
};

/**
 * POST /api/attendance/slots/:slotId/:date
 * Body: { records: [{ student_id, status, reason }] }
 * Status must be: 'present', 'late', 'absent', or 'permission'
 */
const saveSlotAttendance = async (req, res, next) => {
  const client = await getClient();
  try {
    const { slotId, date } = req.params;
    const { records } = req.body;

    if (!Array.isArray(records) || records.length === 0) {
      return res.status(400).json({ error: "records[] array is required" });
    }

    await client.query("BEGIN");
    const saved = [];

    for (const rec of records) {
      const { rows } = await client.query(
        `INSERT INTO slot_attendance_records
           (slot_id, student_id, date, status, reason, remarked_by, is_admin_remark)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT (slot_id, student_id, date)
         DO UPDATE SET
           status          = EXCLUDED.status,
           reason          = EXCLUDED.reason,
           remarked_by     = EXCLUDED.remarked_by,
           is_admin_remark = EXCLUDED.is_admin_remark,
           updated_at      = NOW()
         RETURNING *`,
        [
          slotId,
          rec.student_id,
          date,
          rec.status,
          rec.reason || null,
          req.user.user_id,
          req.user.role === "admin" || req.user.role === "admin_teacher"
        ]
      );
      saved.push(rows[0]);
    }

    await client.query("COMMIT");

    // Bulk Audit Log
    AuditLog.create({
      event_type: "slot_attendance_marked",
      performed_by: { user_id: req.user.user_id, role: req.user.role },
      target: { slot_id: slotId, date },
      metadata: { record_count: saved.length }
    }).catch(() => {});

    res.json({ message: "Attendance saved successfully", count: saved.length, records: saved });
  } catch (err) {
    await client.query("ROLLBACK");
    next(err);
  } finally {
    client.release();
  }
};

module.exports = {
  getSlotRoster,
  getSlotAttendance,
  saveSlotAttendance
};
