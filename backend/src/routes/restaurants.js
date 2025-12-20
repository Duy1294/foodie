const express = require('express');
const { body, validationResult } = require('express-validator');
const Restaurant = require('../models/Restaurant');
const MenuItem = require('../models/MenuItem');
const { protect, authorize } = require('../middleware/auth');

const router = express.Router();

// @route   GET /api/v1/restaurants
// @desc    Get all restaurants
// @access  Public
router.get('/', async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      minRating,
      maxDeliveryFee,
      latitude,
      longitude,
    } = req.query;

    const query = { isActive: true };

    // Search by name
    if (search) {
      query.name = { $regex: search, $options: 'i' };
    }

    // Filter by rating
    if (minRating) {
      query.ratingAverage = { $gte: parseFloat(minRating) };
    }

    // Filter by delivery fee
    if (maxDeliveryFee) {
      query.deliveryFee = { $lte: parseFloat(maxDeliveryFee) };
    }

    const restaurants = await Restaurant.find(query)
      .limit(limit * 1)
      .skip((page - 1) * limit)
      .sort({ ratingAverage: -1, createdAt: -1 })
      .lean(); // Use lean() for better performance

    const total = await Restaurant.countDocuments(query);

    // Transform _id to id
    const transformedRestaurants = restaurants.map(r => ({
      ...r,
      id: r._id.toString(),
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

// ==================== RESTAURANT OWNER ROUTES ====================
// IMPORTANT: These routes must be defined BEFORE /:id route to avoid route conflicts

// @route   GET /api/v1/restaurants/my-restaurant
// @desc    Get restaurant owned by current user
// @access  Private (Restaurant Owner)
router.get('/my-restaurant', protect, authorize('restaurant_owner'), async (req, res) => {
  try {
    const restaurant = await Restaurant.findOne({ ownerId: req.user.id }).lean();

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    const transformedRestaurant = {
      ...restaurant,
      id: restaurant._id.toString(),
      _id: undefined,
      __v: undefined,
    };

    res.json({
      success: true,
      data: transformedRestaurant,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/restaurants/:id
// @desc    Get single restaurant
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id).lean();

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    // Transform _id to id
    const transformedRestaurant = {
      ...restaurant,
      id: restaurant._id.toString(),
      _id: undefined,
      __v: undefined,
    };

    res.json({
      success: true,
      data: transformedRestaurant,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/restaurants/:id/menu
// @desc    Get restaurant menu
// @access  Public
router.get('/:id/menu', async (req, res) => {
  try {
    const menuItems = await MenuItem.find({
      restaurantId: req.params.id,
      isAvailable: true,
    })
      .sort({ isPopular: -1, displayOrder: 1, createdAt: 1 })
      .lean();

    // Transform _id to id
    const transformedMenuItems = menuItems.map(item => ({
      ...item,
      id: item._id.toString(),
      restaurantId: item.restaurantId.toString(),
      categoryId: item.categoryId ? item.categoryId.toString() : null,
      _id: undefined,
      __v: undefined,
    }));

    res.json({
      success: true,
      count: transformedMenuItems.length,
      data: transformedMenuItems,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/restaurants
// @desc    Create restaurant (Owner only)
// @access  Private
router.post('/', protect, async (req, res) => {
  try {
    // Only restaurant owners can create restaurants
    if (req.user.role !== 'restaurant_owner' && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only restaurant owners can create restaurants',
      });
    }

    const restaurant = await Restaurant.create({
      ...req.body,
      ownerId: req.user.id,
    });

    res.status(201).json({
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

// Middleware to check if user owns the restaurant
const checkRestaurantOwner = async (req, res, next) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    
    if (!restaurant) {
      return res.status(404).json({
        success: false,
        message: 'Restaurant not found',
      });
    }

    // Admin can access any restaurant
    if (req.user.role === 'admin') {
      req.restaurant = restaurant;
      return next();
    }

    // Check if user is the owner
    if (restaurant.ownerId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to access this restaurant',
      });
    }

    req.restaurant = restaurant;
    next();
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

// @route   GET /api/v1/restaurants/:id/menu/manage
// @desc    Get all menu items for restaurant owner (including unavailable)
// @access  Private (Restaurant Owner)
router.get('/:id/menu/manage', protect, checkRestaurantOwner, async (req, res) => {
  try {
    const menuItems = await MenuItem.find({
      restaurantId: req.params.id,
    })
      .sort({ displayOrder: 1, createdAt: -1 })
      .lean();

    const transformedMenuItems = menuItems.map(item => ({
      ...item,
      id: item._id.toString(),
      restaurantId: item.restaurantId.toString(),
      categoryId: item.categoryId ? item.categoryId.toString() : null,
      _id: undefined,
      __v: undefined,
    }));

    res.json({
      success: true,
      count: transformedMenuItems.length,
      data: transformedMenuItems,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/restaurants/:id/menu
// @desc    Add menu item (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.post('/:id/menu', protect, checkRestaurantOwner, [
  body('name').notEmpty().withMessage('Name is required'),
  body('price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const menuItem = await MenuItem.create({
      ...req.body,
      restaurantId: req.params.id,
    });

    res.status(201).json({
      success: true,
      data: menuItem,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/restaurants/:id/menu/:menuItemId
// @desc    Update menu item (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.put('/:id/menu/:menuItemId', protect, checkRestaurantOwner, [
  body('name').optional().notEmpty().withMessage('Name cannot be empty'),
  body('price').optional().isFloat({ min: 0 }).withMessage('Price must be a positive number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const menuItem = await MenuItem.findOneAndUpdate(
      { _id: req.params.menuItemId, restaurantId: req.params.id },
      req.body,
      { new: true, runValidators: true }
    );

    if (!menuItem) {
      return res.status(404).json({
        success: false,
        message: 'Menu item not found',
      });
    }

    res.json({
      success: true,
      data: menuItem,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/restaurants/:id/menu/:menuItemId
// @desc    Delete menu item (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.delete('/:id/menu/:menuItemId', protect, checkRestaurantOwner, async (req, res) => {
  try {
    const menuItem = await MenuItem.findOneAndDelete({
      _id: req.params.menuItemId,
      restaurantId: req.params.id,
    });

    if (!menuItem) {
      return res.status(404).json({
        success: false,
        message: 'Menu item not found',
      });
    }

    res.json({
      success: true,
      message: 'Menu item deleted successfully',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/restaurants/:id
// @desc    Update restaurant info (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.put('/:id', protect, checkRestaurantOwner, [
  body('name').optional().notEmpty().withMessage('Name cannot be empty'),
  body('address').optional().notEmpty().withMessage('Address cannot be empty'),
  body('deliveryFee').optional().isFloat({ min: 0 }).withMessage('Delivery fee must be a positive number'),
  body('minimumOrder').optional().isFloat({ min: 0 }).withMessage('Minimum order must be a positive number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const restaurant = await Restaurant.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

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

// @route   PUT /api/v1/restaurants/:id/delivery
// @desc    Update delivery settings (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.put('/:id/delivery', protect, checkRestaurantOwner, [
  body('deliveryFee').optional().isFloat({ min: 0 }).withMessage('Delivery fee must be a positive number'),
  body('minimumOrder').optional().isFloat({ min: 0 }).withMessage('Minimum order must be a positive number'),
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        errors: errors.array(),
      });
    }

    const { deliveryFee, minimumOrder } = req.body;
    const updateData = {};
    if (deliveryFee !== undefined) updateData.deliveryFee = deliveryFee;
    if (minimumOrder !== undefined) updateData.minimumOrder = minimumOrder;

    const restaurant = await Restaurant.findByIdAndUpdate(
      req.params.id,
      updateData,
      { new: true, runValidators: true }
    );

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

// @route   PUT /api/v1/restaurants/:id/hours
// @desc    Update opening hours (Restaurant Owner only)
// @access  Private (Restaurant Owner)
router.put('/:id/hours', protect, checkRestaurantOwner, async (req, res) => {
  try {
    const { openingHours } = req.body;

    if (!openingHours || typeof openingHours !== 'object') {
      return res.status(400).json({
        success: false,
        message: 'Opening hours must be an object',
      });
    }

    const restaurant = await Restaurant.findByIdAndUpdate(
      req.params.id,
      { openingHours },
      { new: true, runValidators: true }
    );

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

module.exports = router;

