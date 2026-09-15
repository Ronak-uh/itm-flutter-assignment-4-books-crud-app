require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bookRoutes = require('./src/routes/bookRoutes');
const { isFirebaseInitialized } = require('./src/config/firebase');

const app = express();
// Default to port 5050 to avoid conflict with macOS AirPlay/AirTunes on port 5000
const PORT = process.env.PORT || 5050;

// Enable Cross-Origin Resource Sharing for all origins and methods
app.use(
  cors({
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  })
);

// Parse incoming JSON payloads
app.use(express.json());

// Request logging middleware for debugging
app.use((req, res, next) => {
  const start = Date.now();
  res.on('finish', () => {
    const duration = Date.now() - start;
    console.log(`[HTTP] ${req.method} ${req.originalUrl} - ${res.statusCode} (${duration}ms)`);
  });
  next();
});

// Root welcome endpoint
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Welcome to Books CRUD REST API',
    firebaseConnected: isFirebaseInitialized(),
    endpoints: {
      health: '/api/health',
      books: '/api/books',
    },
  });
});

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Books API is running',
    timestamp: new Date().toISOString(),
    firebaseConnected: isFirebaseInitialized(),
  });
});

// Mount Books API routes
app.use('/api/books', bookRoutes);

// Catch-all 404 handler for undefined routes
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: `API route not found: ${req.method} ${req.originalUrl}`,
  });
});

// Centralized error handling middleware
app.use((err, req, res, next) => {
  console.error('[Unhandled Server Error]', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

// Start Express server
const server = app.listen(PORT, () => {
  console.log(`\n====================================================`);
  console.log(`🚀 Books CRUD Server listening on port ${PORT}`);
  console.log(`👉 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`👉 Books API:    http://localhost:${PORT}/api/books`);
  console.log(`====================================================\n`);
});

module.exports = { app, server };
