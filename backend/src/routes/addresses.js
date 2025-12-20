const express = require('express');
const { body, validationResult } = require('express-validator');
const Address = require('../models/Address');
const { protect } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(protect);

// @route   GET /api/v1/addresses
// @desc    Get user addresses
// @access  Private
router.get('/', async (req, res) => {
  try {
    const addresses = await Address.find({ userId: req.user.id })
      .sort({ isDefault: -1, createdAt: -1 });

    res.json({
      success: true,
      count: addresses.length,
      data: addresses,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/addresses/:id
// @desc    Get single address
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const address = await Address.findById(req.params.id);

    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check authorization
    if (address.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this address',
      });
    }

    res.json({
      success: true,
      data: address,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/addresses
// @desc    Create new address
// @access  Private
router.post('/', [
  body('label').notEmpty().withMessage('Label is required'),
  body('fullAddress').notEmpty().withMessage('Full address is required'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const {
      label,
      fullAddress,
      street,
      ward,
      district,
      city,
      latitude,
      longitude,
      phone,
      recipientName,
      isDefault,
    } = req.body;

    // If setting as default, unset other defaults
    if (isDefault) {
      await Address.updateMany(
        { userId: req.user.id },
        { isDefault: false }
      );
    }

    const address = await Address.create({
      userId: req.user.id,
      label,
      fullAddress,
      street,
      ward,
      district,
      city,
      latitude,
      longitude,
      phone: phone || req.user.phone,
      recipientName: recipientName || req.user.fullName,
      isDefault: isDefault || false,
    });

    res.status(201).json({
      success: true,
      data: address,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/addresses/:id
// @desc    Update address
// @access  Private
router.put('/:id', async (req, res) => {
  try {
    const address = await Address.findById(req.params.id);

    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check authorization
    if (address.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update this address',
      });
    }

    const {
      label,
      fullAddress,
      street,
      ward,
      district,
      city,
      latitude,
      longitude,
      phone,
      recipientName,
      isDefault,
    } = req.body;

    // If setting as default, unset other defaults
    if (isDefault && !address.isDefault) {
      await Address.updateMany(
        { userId: req.user.id, _id: { $ne: address._id } },
        { isDefault: false }
      );
    }

    address.label = label || address.label;
    address.fullAddress = fullAddress || address.fullAddress;
    address.street = street !== undefined ? street : address.street;
    address.ward = ward !== undefined ? ward : address.ward;
    address.district = district !== undefined ? district : address.district;
    address.city = city !== undefined ? city : address.city;
    address.latitude = latitude !== undefined ? latitude : address.latitude;
    address.longitude = longitude !== undefined ? longitude : address.longitude;
    address.phone = phone !== undefined ? phone : address.phone;
    address.recipientName = recipientName !== undefined ? recipientName : address.recipientName;
    address.isDefault = isDefault !== undefined ? isDefault : address.isDefault;

    await address.save();

    res.json({
      success: true,
      data: address,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/addresses/:id
// @desc    Delete address
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const address = await Address.findById(req.params.id);

    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Address not found',
      });
    }

    // Check authorization
    if (address.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this address',
      });
    }

    await Address.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Address deleted successfully',
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

