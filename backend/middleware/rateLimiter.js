const rateLimit = require('express-rate-limit');

// General API rate limiter
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many requests',
    message: 'You have exceeded the rate limit. Please try again later.',
    retryAfter: '15 minutes',
  },
});

// Stricter limiter for AI endpoints (expensive API calls)
const aiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // 30 AI requests per window per IP
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many AI requests',
    message: 'AI request limit reached. Please try again later.',
    retryAfter: '15 minutes',
  },
});

// Auth endpoint limiter (prevents brute force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10, // 10 auth attempts per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: 'Too many auth attempts',
    message: 'Too many authentication attempts. Please try again later.',
  },
});

module.exports = { apiLimiter, aiLimiter, authLimiter };
