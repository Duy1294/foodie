const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication and driver role
router.use(protect);
router.use(authorize('driver'));

// @route   GET /api/v1/shippers/profile
// @desc    Get current shipper profile
// @access  Private (Driver)
router.get('/profile', async (req, res) => {
  try {
    const shipper = await User.findById(req.user.id).lean();

    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    const transformedShipper = {
      ...shipper,
      id: shipper._id.toString(),
      _id: undefined,
      __v: undefined,
    };

    res.json({
      success: true,
      data: transformedShipper,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/shippers/vehicle
// @desc    Update vehicle info
// @access  Private (Driver)
router.put('/vehicle', [
  body('vehicleType').optional().isIn(['motorcycle', 'bicycle', 'car']).withMessage('Invalid vehicle type'),
  body('licensePlate').optional().trim(),
  body('vehicleBrand').optional().trim(),
  body('vehicleModel').optional().trim(),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { vehicleType, licensePlate, vehicleBrand, vehicleModel } = req.body;

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (!shipper.vehicleInfo) {
      shipper.vehicleInfo = {};
    }

    if (vehicleType !== undefined) shipper.vehicleInfo.vehicleType = vehicleType;
    if (licensePlate !== undefined) shipper.vehicleInfo.licensePlate = licensePlate;
    if (vehicleBrand !== undefined) shipper.vehicleInfo.vehicleBrand = vehicleBrand;
    if (vehicleModel !== undefined) shipper.vehicleInfo.vehicleModel = vehicleModel;

    await shipper.save();

    res.json({
      success: true,
      data: shipper,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/shippers/location
// @desc    Update current location
// @access  Private (Driver)
router.post('/location', [
  body('latitude').isFloat().withMessage('Latitude must be a number'),
  body('longitude').isFloat().withMessage('Longitude must be a number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { latitude, longitude } = req.body;

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (!shipper.currentLocation) {
      shipper.currentLocation = {};
    }

    shipper.currentLocation.latitude = latitude;
    shipper.currentLocation.longitude = longitude;
    shipper.currentLocation.lastUpdated = new Date();

    await shipper.save();

    res.json({
      success: true,
      data: {
        latitude: shipper.currentLocation.latitude,
        longitude: shipper.currentLocation.longitude,
        lastUpdated: shipper.currentLocation.lastUpdated,
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

// @route   PUT /api/v1/shippers/online-status
// @desc    Update online status
// @access  Private (Driver)
router.put('/online-status', [
  body('isOnline').isBoolean().withMessage('isOnline must be a boolean'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { isOnline } = req.body;

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    shipper.isOnline = isOnline;
    await shipper.save();

    res.json({
      success: true,
      data: {
        isOnline: shipper.isOnline,
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

// @route   PUT /api/v1/shippers/settings/notifications
// @desc    Update notification settings
// @access  Private (Driver)
router.put('/settings/notifications', [
  body('notificationEnabled').isBoolean().withMessage('notificationEnabled must be a boolean'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { notificationEnabled } = req.body;

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (!shipper.shipperSettings) {
      shipper.shipperSettings = {};
    }

    shipper.shipperSettings.notificationEnabled = notificationEnabled;
    await shipper.save();

    res.json({
      success: true,
      data: shipper,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/shippers/settings/working-hours
// @desc    Update working hours
// @access  Private (Driver)
router.put('/settings/working-hours', async (req, res) => {
  try {
    const { workingHours } = req.body;

    if (!workingHours || typeof workingHours !== 'object') {
      return res.status(400).json({
        success: false,
        message: 'Working hours must be an object',
      });
    }

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (!shipper.shipperSettings) {
      shipper.shipperSettings = {};
    }

    shipper.shipperSettings.workingHours = workingHours;
    await shipper.save();

    res.json({
      success: true,
      data: shipper,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/shippers/settings/delivery-areas
// @desc    Update delivery areas
// @access  Private (Driver)
router.put('/settings/delivery-areas', [
  body('deliveryAreas').isArray().withMessage('Delivery areas must be an array'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { deliveryAreas } = req.body;

    const shipper = await User.findById(req.user.id);
    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (!shipper.shipperSettings) {
      shipper.shipperSettings = {};
    }

    shipper.shipperSettings.deliveryAreas = deliveryAreas;
    await shipper.save();

    res.json({
      success: true,
      data: shipper,
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

