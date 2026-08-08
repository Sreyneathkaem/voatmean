const { Pool } = require('pg');

const rawConn = process.env.DATABASE_URL;
if (!rawConn || typeof rawConn !== 'string') {
  console.error('❌ Invalid or missing DATABASE_URL. Ensure DATABASE_URL is a string like: postgresql://user:password@host:port/dbname');
  // Exit early so the error is explicit instead of a cryptic SASL message
  process.exit(1);
}

const pool = new Pool({
  connectionString: rawConn,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on('connect', () => {
  console.log('✅ PostgreSQL connected');
});

pool.on('error', (err) => {
  console.error('❌ PostgreSQL error:', err.message);
});

const query = (text, params) => pool.query(text, params);

const getClient = () => pool.connect();

module.exports = { query, getClient, pool };
