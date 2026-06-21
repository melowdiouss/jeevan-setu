require('dotenv').config();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const connectDB = require('./config/db');
const { apiLimiter } = require('./middleware/rateLimiter');

// Import routes
const aiRoutes = require('./routes/ai');
const studentRoutes = require('./routes/students');
const healthRoutes = require('./routes/health');

const app = express();
const PORT = process.env.PORT || 3000;

// ──────────────────────────────────────────────
// Security Middleware
// ──────────────────────────────────────────────

// Helmet: Set security HTTP headers
app.use(helmet());

// CORS: Only allow configured origins
const allowedOrigins = (process.env.ALLOWED_ORIGINS || '').split(',').filter(Boolean);
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin (mobile apps, curl, etc.)
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization'],
    credentials: true,
  })
);

// Body parser with size limits
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));

// Request logging (skip in test env)
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('short'));
}

// Global rate limiter
app.use('/api/', apiLimiter);

// ──────────────────────────────────────────────
// Database Connection (works for both local & Vercel serverless)
// ──────────────────────────────────────────────

let isDbConnected = false;

app.use(async (req, res, next) => {
  if (!isDbConnected) {
    try {
      await connectDB();
      isDbConnected = true;
    } catch (error) {
      console.error('DB connection failed:', error.message);
      return res.status(500).json({ error: 'Database connection failed' });
    }
  }
  next();
});

// ──────────────────────────────────────────────
// Routes
// ──────────────────────────────────────────────

app.use('/api/ai', aiRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/health', healthRoutes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'JeevanSetu Backend API',
    version: '1.0.0',
    status: 'running',
    docs: '/api/health',
  });
});

// ──────────────────────────────────────────────
// Error Handling
// ──────────────────────────────────────────────

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.path} does not exist`,
  });
});

// Global error handler
app.use((err, req, res, _next) => {
  console.error('Unhandled error:', err.message);

  // Don't leak internal errors in production
  const isDev = process.env.NODE_ENV === 'development';

  res.status(err.status || 500).json({
    error: 'Internal Server Error',
    message: isDev ? err.message : 'An unexpected error occurred.',
    ...(isDev && { stack: err.stack }),
  });
});

// ──────────────────────────────────────────────
// Start Server (only in local/non-serverless mode)
// ──────────────────────────────────────────────

if (process.env.NODE_ENV !== 'production' || !process.env.VERCEL) {
  app.listen(PORT, () => {
    console.log(`\n🚀 JeevanSetu Backend running on port ${PORT}`);
    console.log(`   Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`   Health check: http://localhost:${PORT}/api/health`);
    console.log(`   API base:     http://localhost:${PORT}/api\n`);
  });
}

module.exports = app;
