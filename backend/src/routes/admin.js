const express = require('express');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const Restaurant = require('../models/Restaurant');
const Order = require('../models/Order');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// All admin routes require authentication and admin role
router.use(protect);
router.use(authorize('admin'));

// ==================== USERS MANAGEMENT ====================

// @route   GET /api/v1/admin/users
// @desc    Get all users with filters
// @access  Private/Admin
router.get('/users', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      role,
      isActive,
      search,
    } = req.query;

    const query = {};

    // Filter by role
    if (role) {
      query.role = role;
    }

    // Filter by active status
    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    // Search by name or email
    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const users = await User.find(query)
      .select('-password -resetPasswordToken -resetPasswordExpire')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 })
      .lean();

    const total = await User.countDocuments(query);

    // Transform _id to id
    const transformedUsers = users.map(user => ({
      ...user,
      id: user._id.toString(),
      _id: undefined,
      __v: undefined,
    }));

    res.json({
      success: true,
      count: transformedUsers.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / limit),
      data: transformedUsers,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/admin/users/:id
// @desc    Get single user
// @access  Private/Admin
router.get('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id)
      .select('-password -resetPasswordToken -resetPasswordExpire');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/admin/users/:id
// @desc    Update user (admin only)
// @access  Private/Admin
router.put('/users/:id', async (req, res) => {
  try {
    const { fullName, phone, role, isActive, isVerified } = req.body;

    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Prevent admin from changing their own role or status
    if (user._id.toString() === req.user.id) {
      if (role !== undefined && role !== user.role) {
        return res.status(400).json({
          success: false,
          message: 'Cannot change your own role',
        });
      }
      if (isActive !== undefined && isActive === false) {
        return res.status(400).json({
          success: false,
          message: 'Cannot deactivate your own account',
        });
      }
    }

    if (fullName !== undefined) user.fullName = fullName;
    if (phone !== undefined) user.phone = phone;
    if (role !== undefined) user.role = role;
    if (isActive !== undefined) user.isActive = isActive;
    if (isVerified !== undefined) user.isVerified = isVerified;

    await user.save();

    res.json({
      success: true,
      data: user,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/admin/users/:id
// @desc    Delete user (admin only)
// @access  Private/Admin
router.delete('/users/:id', async (req, res) => {
  try {
    const user = await User.findById(req.params.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Prevent admin from deleting themselves
    if (user._id.toString() === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete your own account',
      });
    }

    await User.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'User deleted successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ==================== RESTAURANTS MANAGEMENT ====================

// @route   GET /api/v1/admin/restaurants
// @desc    Get all restaurants with filters
// @access  Private/Admin
router.get('/restaurants', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      isActive,
      isVerified,
      search,
    } = req.query;

    const query = {};

    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    if (isVerified !== undefined) {
      query.isVerified = isVerified === 'true';
    }

    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { address: { $regex: search, $options: 'i' } },
      ];
    }

    const restaurants = await Restaurant.find(query)
      .populate('ownerId', 'id fullName email phone')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 })
      .lean();

    const total = await Restaurant.countDocuments(query);

    const transformedRestaurants = restaurants.map(restaurant => ({
      ...restaurant,
      id: restaurant._id.toString(),
      _id: undefined,
      __v: undefined,
    }));

    res.json({
      success: true,
      count: transformedRestaurants.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / limit),
      data: transformedRestaurants,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/admin/restaurants/:id
// @desc    Update restaurant (admin only)
// @access  Private/Admin
router.put('/restaurants/:id', async (req, res) => {
  try {
    const { isActive, isVerified } = req.body;

    const restaurant = await Restaurant.findById(req.params.id);

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    if (isActive !== undefined) restaurant.isActive = isActive;
    if (isVerified !== undefined) restaurant.isVerified = isVerified;

    await restaurant.save();

    res.json({
      success: true,
      data: restaurant,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/admin/restaurants/:id
// @desc    Delete restaurant (admin only)
// @access  Private/Admin
router.delete('/restaurants/:id', async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    await Restaurant.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Restaurant deleted successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ==================== ORDERS MANAGEMENT ====================

// @route   GET /api/v1/admin/orders
// @desc    Get all orders with filters
// @access  Private/Admin
router.get('/orders', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      status,
      restaurantId,
      customerId,
      startDate,
      endDate,
    } = req.query;

    const query = {};

    if (status) {
      query.status = status;
    }

    if (restaurantId) {
      query.restaurantId = restaurantId;
    }

    if (customerId) {
      query.customerId = customerId;
    }

    if (startDate || endDate) {
      query.createdAt = {};
      if (startDate) {
        query.createdAt.$gte = new Date(startDate);
      }
      if (endDate) {
        query.createdAt.$lte = new Date(endDate);
      }
    }

    const orders = await Order.find(query)
      .populate('customerId', 'id fullName email phone')
      .populate('restaurantId', 'id name address')
      .populate('driverId', 'id fullName email phone')
      .populate('items.menuItemId', 'id name price')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 })
      .lean();

    const total = await Order.countDocuments(query);

    const transformedOrders = orders.map(order => {
      const orderObj = { ...order };
      orderObj.id = orderObj._id ? orderObj._id.toString() : (orderObj.id ? orderObj.id.toString() : '');
      
      // Ensure customerId, restaurantId, driverId are strings
      if (orderObj.customerId) {
        orderObj.customerId = typeof orderObj.customerId === 'object' 
          ? (orderObj.customerId._id ? orderObj.customerId._id.toString() : (orderObj.customerId.id ? orderObj.customerId.id.toString() : ''))
          : orderObj.customerId.toString();
      } else {
        orderObj.customerId = '';
      }
      
      if (orderObj.restaurantId) {
        orderObj.restaurantId = typeof orderObj.restaurantId === 'object'
          ? (orderObj.restaurantId._id ? orderObj.restaurantId._id.toString() : (orderObj.restaurantId.id ? orderObj.restaurantId.id.toString() : ''))
          : orderObj.restaurantId.toString();
      } else {
        orderObj.restaurantId = '';
      }
      
      if (orderObj.driverId) {
        orderObj.driverId = typeof orderObj.driverId === 'object'
          ? (orderObj.driverId._id ? orderObj.driverId._id.toString() : (orderObj.driverId.id ? orderObj.driverId.id.toString() : ''))
          : orderObj.driverId.toString();
      } else {
        orderObj.driverId = null;
      }
      
      // Ensure orderNumber is string
      orderObj.orderNumber = orderObj.orderNumber ? orderObj.orderNumber.toString() : '';
      
      // Ensure deliveryAddress is string
      orderObj.deliveryAddress = orderObj.deliveryAddress ? orderObj.deliveryAddress.toString() : '';
      
      delete orderObj._id;
      delete orderObj.__v;

      // Transform items
      if (orderObj.items && Array.isArray(orderObj.items)) {
        orderObj.items = orderObj.items.map(item => {
          const itemObj = { ...item };
          itemObj.id = itemObj._id ? itemObj._id.toString() : (itemObj.id ? itemObj.id.toString() : '');
          if (itemObj.menuItemId) {
            itemObj.menuItemId = typeof itemObj.menuItemId === 'object' 
              ? (itemObj.menuItemId._id ? itemObj.menuItemId._id.toString() : (itemObj.menuItemId.id ? itemObj.menuItemId.id.toString() : ''))
              : itemObj.menuItemId.toString();
          } else {
            itemObj.menuItemId = '';
          }
          delete itemObj._id;
          return itemObj;
        });
      } else {
        orderObj.items = [];
      }

      return orderObj;
    });

    res.json({
      success: true,
      count: transformedOrders.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / limit),
      data: transformedOrders,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// ==================== SHIPPERS MANAGEMENT ====================

// @route   GET /api/v1/admin/shippers
// @desc    Get all shippers
// @access  Private/Admin
router.get('/shippers', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      isActive,
      search,
    } = req.query;

    const query = { role: 'driver' };

    if (isActive !== undefined) {
      query.isActive = isActive === 'true';
    }

    if (search) {
      query.$or = [
        { fullName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } },
      ];
    }

    const shippers = await User.find(query)
      .select('-password -resetPasswordToken -resetPasswordExpire')
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ createdAt: -1 })
      .lean();

    const total = await User.countDocuments(query);

    const transformedShippers = shippers.map(shipper => ({
      ...shipper,
      id: shipper._id.toString(),
      _id: undefined,
      __v: undefined,
    }));

    res.json({
      success: true,
      count: transformedShippers.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / limit),
      data: transformedShippers,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/admin/shippers/:id
// @desc    Update shipper (admin only)
// @access  Private/Admin
router.put('/shippers/:id', async (req, res) => {
  try {
    const { fullName, phone, isActive, isVerified } = req.body;

    const shipper = await User.findOne({ _id: req.params.id, role: 'driver' });

    if (!shipper) {
      return res.status(404).json({
        success: false,
        message: 'Shipper not found',
      });
    }

    if (fullName !== undefined) shipper.fullName = fullName;
    if (phone !== undefined) shipper.phone = phone;
    if (isActive !== undefined) shipper.isActive = isActive;
    if (isVerified !== undefined) shipper.isVerified = isVerified;

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

