const { securityLogger } = require('../config/logger');

const errorHandler = (err, req, res, next) => {
  securityLogger.error({
    event: 'unhandled_error',
    who: req.user?.user_id || 'anonymous',
    what: `${req.method} ${req.path}`,
    message: err.message,
    stack: err.stack,
    timestamp: new Date().toISOString()
  });

  if (err.code === '23505') return res.status(409).json({ error: 'Duplicate record already exists' });
  if (err.code === '23503') return res.status(400).json({ error: 'Referenced record does not exist' });

  // Generic to user — no err.message, no stack, ever
  res.status(err.status || 500).json({ error: 'Something went wrong. Please try again.' });
};

module.exports = { errorHandler };