const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const dotenv = require('dotenv');
const connectDB = require('./config/database');

// Load environment variables
dotenv.config();

// Import routes
const authRoutes = require('./routes/auth');
const restaurantRoutes = require('./routes/restaurants');
const orderRoutes = require('./routes/orders');
const userRoutes = require('./routes/users');
const addressRoutes = require('./routes/addresses');
const adminRoutes = require('./routes/admin');
const shipperRoutes = require('./routes/shippers');
const notificationRoutes = require('./routes/notifications');

// Initialize app
const app = express();

// Connect to database
connectDB();

// Middleware
app.use(helmet()); // Security headers

// CORS configuration - Allow all localhost origins in development
const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);
    
    // In development, allow all localhost origins
    if (process.env.NODE_ENV === 'development') {
      if (origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
        return callback(null, true);
      }
    }
    
    // In production, use CORS_ORIGIN from env
    const allowedOrigins = process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : [];
    if (allowedOrigins.includes(origin)) {
      return callback(null, true);
    }
    
    callback(new Error('Not allowed by CORS'));
  },
  credentials: true,
};

app.use(cors(corsOptions));
app.use(morgan('dev')); // Logging

// Request logging middleware for debugging
app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.path} - Origin: ${req.headers.origin || 'none'}`);
  next();
});

app.use(express.json()); // Parse JSON
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    message: 'Foodie API is running',
    timestamp: new Date().toISOString(),
  });
});

// API Routes
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/restaurants', restaurantRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/addresses', addressRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/shippers', shipperRoutes);
app.use('/api/v1/notifications', notificationRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
});

// Start server
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0'; // Listen on all interfaces for emulator access
app.listen(PORT, HOST, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📱 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🌐 API URL: http://localhost:${PORT}/api/v1`);
  console.log(`📲 Android Emulator: http://10.0.2.2:${PORT}/api/v1`);
});

module.exports = app;

