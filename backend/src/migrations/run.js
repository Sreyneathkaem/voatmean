require('dotenv').config();
const { pool } = require('../config/db');
const fs = require('fs');
const path = require('path');

const splitSqlStatements = (sql) => {
  const statements = [];
  let current = '';
  let inSingleQuote = false;
  let inDoubleQuote = false;
  let dollarQuote = null;

  for (let i = 0; i < sql.length; i += 1) {
    const char = sql[i];
    const next = sql[i + 1];

    if (dollarQuote) {
      if (sql.startsWith(dollarQuote, i)) {
        current += dollarQuote;
        i += dollarQuote.length - 1;
        dollarQuote = null;
      } else {
        current += char;
      }
      continue;
    }

    if (inSingleQuote) {
      current += char;
      if (char === "'" && next === "'") {
        current += next;
        i += 1;
      } else if (char === "'") {
        inSingleQuote = false;
      }
      continue;
    }

    if (inDoubleQuote) {
      current += char;
      if (char === '"') {
        inDoubleQuote = false;
      }
      continue;
    }

    // Line comment (-- ...). Checked BEFORE quote handling below, since
    // comments can legitimately contain apostrophes (don't, isn't, won't,
    // ...) that would otherwise be mistaken for the start of a
    // single-quoted string and desync the rest of the parse.
    if (char === '-' && next === '-') {
      const newlineIndex = sql.indexOf('\n', i);
      const end = newlineIndex === -1 ? sql.length : newlineIndex;
      current += sql.slice(i, end);
      i = end - 1; // for-loop's i += 1 will land us right after
      continue;
    }

    // Block comment (/* ... */), same rationale as above.
    if (char === '/' && next === '*') {
      const endIndex = sql.indexOf('*/', i + 2);
      const end = endIndex === -1 ? sql.length : endIndex + 2;
      current += sql.slice(i, end);
      i = end - 1;
      continue;
    }

    if (char === "'") {
      inSingleQuote = true;
      current += char;
      continue;
    }

    if (char === '"') {
      inDoubleQuote = true;
      current += char;
      continue;
    }

    if (char === '$' && next === '$') {
      dollarQuote = '$$';
      current += '$$';
      i += 1;
      continue;
    }

    if (char === ';') {
      const statement = current.trim();
      if (statement) {
        statements.push(statement);
      }
      current = '';
      continue;
    }

    current += char;
  }

  const tail = current.trim();
  if (tail) {
    statements.push(tail);
  }

  return statements;
};

const runMigrations = async () => {
  console.log('Running migrations...');
  const files = fs
    .readdirSync(__dirname)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  const client = await pool.connect();

  try {
    await client.query('BEGIN');
    for (const file of files) {
      console.log(`  ▸ ${file}`);
      const sql = fs.readFileSync(path.join(__dirname, file), 'utf8');
      const statements = splitSqlStatements(sql);
      for (const statement of statements) {
        if (!statement.trim()) continue;
        await client.query(statement);
      }
    }
    await client.query('COMMIT');
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }

  console.log('✅ Migrations complete!');
  console.log('⚠️  Update the placeholder emails in backend/src/migrations/001_schema.sql if needed.');
};

if (require.main === module) {
  runMigrations()
    .then(() => pool.end())
    .catch((err) => {
      console.error('❌ Migration failed:', err.message);
      process.exit(1);
    });
}

module.exports = { runMigrations };