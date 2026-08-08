const mongoose = require('mongoose');

const connectMongo = async () => {
  try {
      await mongoose.connect(process.env.MONGO_URL, { serverSelectionTimeoutMS: 3000 });
      console.log('✅ MongoDB connected');
    } catch (err) {
      console.warn('⚠️  MongoDB skipped (audit logs disabled)');
    }
  };

const auditLogSchema = new mongoose.Schema({
  event_type:   { type: String, required: true },
  timestamp:    { type: Date, default: Date.now },
  performed_by: { user_id: String, name: String, role: String },
  target:       { student_id: String, student_name: String, class_id: String, date: String },
  change:       { from_status: String, to_status: String, reason: String },
}, { collection: 'audit_logs' });

const AuditLog = mongoose.model('AuditLog', auditLogSchema);

module.exports = { connectMongo, AuditLog };
