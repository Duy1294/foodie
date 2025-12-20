const express = require('express');
const { body, validationResult } = require('express-validator');
const crypto = require('crypto');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { protect } = require('../middleware/auth');

const router = express.Router();

// @route   POST /api/v1/auth/register
// @desc    Register a new user
// @access  Public
router.post('/register', [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }),
  body('fullName').notEmpty().trim(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { email, password, fullName, phone } = req.body;

    // Check if user exists
    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'User already exists',
      });
    }

    // Create user
    const user = await User.create({
      email,
      password,
      fullName,
      phone,
    });

    // Generate token
    const token = generateToken(user._id);

    res.status(201).json({
      success: true,
      token,
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone || null,
        role: user.role,
        avatarUrl: user.avatarUrl || null,
        isVerified: user.isVerified || false,
        isActive: user.isActive !== undefined ? user.isActive : true,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt ? user.updatedAt.toISOString() : null,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/auth/login
// @desc    Login user
// @access  Public
router.post('/login', [
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { email, password } = req.body;

    // Check if user exists and get password
    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Check password
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    // Check if user is active
    if (!user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Account is deactivated',
      });
    }

    // Generate token
    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      user: {
        id: user._id,
        email: user.email,
        fullName: user.fullName,
        phone: user.phone || null,
        role: user.role,
        avatarUrl: user.avatarUrl || null,
        isVerified: user.isVerified || false,
        isActive: user.isActive !== undefined ? user.isActive : true,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt ? user.updatedAt.toISOString() : null,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/auth/me
// @desc    Get current user
// @access  Private
router.get('/me', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    res.json({
      success: true,
      user,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/auth/forgot-password
// @desc    Request password reset
// @access  Public
router.post('/forgot-password', [
  body('email').isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { email } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
      // Don't reveal if user exists or not for security
      return res.json({
        success: true,
        message: 'If that email exists, a password reset link has been sent',
      });
    }

    // Generate reset token (simple random string for now)
    const crypto = require('crypto');
    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetPasswordExpire = Date.now() + 10 * 60 * 1000; // 10 minutes

    user.resetPasswordToken = resetToken;
    user.resetPasswordExpire = new Date(resetPasswordExpire);
    await user.save({ validateBeforeSave: false });

    // TODO: Send email with reset token
    // For development, log the token
    console.log('🔑 Password Reset Token for', email, ':', resetToken);
    console.log('🔗 Reset URL: http://localhost:3000/api/v1/auth/reset-password?token=' + resetToken);
    
    res.json({
      success: true,
      message: 'Password reset email sent (check console for token in development)',
      // In development, return token for testing
      ...(process.env.NODE_ENV === 'development' && { resetToken }),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/auth/reset-password
// @desc    Reset password with token
// @access  Public
router.post('/reset-password', [
  body('token').notEmpty().withMessage('Reset token is required'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { token, password } = req.body;

    const user = await User.findOne({
      resetPasswordToken: token,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired reset token',
      });
    }

    // Set new password
    user.password = password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    res.json({
      success: true,
      message: 'Password reset successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/auth/logout
// @desc    Logout user (client-side token removal, this is just for consistency)
// @access  Private
router.post('/logout', protect, async (req, res) => {
  try {
    // In JWT-based auth, logout is handled client-side by removing the token
    // This endpoint exists for consistency and potential future server-side token blacklisting
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/auth/firebase-link
// @desc    Link Firebase user with backend user (create or find existing)
// @access  Public (Firebase token will be verified separately if needed)
router.post('/firebase-link', [
  body('firebaseUid').notEmpty().withMessage('Firebase UID is required'),
  body('email').optional().isEmail().normalizeEmail(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { firebaseUid, email, fullName, phone } = req.body;

    // Try to find existing user by firebaseUid first
    let user = await User.findOne({ firebaseUid });
    
    if (user) {
      // User already linked with Firebase, update info if provided
      if (email && user.email !== email) {
        // Check if email is already taken by another user
        const emailUser = await User.findOne({ email });
        if (emailUser && emailUser._id.toString() !== user._id.toString()) {
          return res.status(400).json({
            success: false,
            message: 'Email already exists',
          });
        }
        user.email = email;
      }
      if (fullName) user.fullName = fullName;
      if (phone) user.phone = phone;
      await user.save();
    } else if (email) {
      // Try to find by email
      user = await User.findOne({ email });
      
      if (user) {
        // User exists with email, link Firebase UID
        if (user.firebaseUid && user.firebaseUid !== firebaseUid) {
          return res.status(400).json({
            success: false,
            message: 'Email already linked to another Firebase account',
          });
        }
        user.firebaseUid = firebaseUid;
        if (fullName) user.fullName = fullName;
        if (phone) user.phone = phone;
        user.isVerified = true; // Firebase users are considered verified
        await user.save();
      } else {
        // Create new user with Firebase UID
        user = await User.create({
          email,
          password: crypto.randomBytes(32).toString('hex'), // Random password since Firebase handles auth
          fullName: fullName || email.split('@')[0],
          phone,
          firebaseUid,
          isVerified: true, // Firebase users are considered verified
        });
      }
    } else {
      // No email provided, create user with Firebase UID only
      user = await User.create({
        email: `firebase_${firebaseUid}@temp.com`, // Temporary email
        password: crypto.randomBytes(32).toString('hex'),
        fullName: fullName || 'Firebase User',
        phone,
        firebaseUid,
        isVerified: true,
      });
    }

    // Generate token
    const token = generateToken(user._id);

    res.json({
      success: true,
      token,
      data: {
        id: user._id.toString(),
        email: user.email,
        fullName: user.fullName,
        phone: user.phone || null,
        role: user.role,
        avatarUrl: user.avatarUrl || null,
        isVerified: user.isVerified || false,
        isActive: user.isActive !== undefined ? user.isActive : true,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt ? user.updatedAt.toISOString() : null,
      },
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

module.exports = router;

