const express = require('express');
const Order = require('../models/Order');
const { protect } = require('../middleware/auth');
const { notifyOrderStatusChange, notifyNewOrderAvailable } = require('../utils/notificationHelper');

const router = express.Router();

// All routes require authentication
router.use(protect);

// @route   GET /api/v1/orders
// @desc    Get user orders
// @access  Private
router.get('/', async (req, res) => {
  try {
    let query = {};

    // Customers see their own orders
    if (req.user.role === 'customer') {
      query.customerId = req.user.id;
    }
    // Restaurant owners see orders for their restaurants
    else if (req.user.role === 'restaurant_owner') {
      const Restaurant = require('../models/Restaurant');
      const mongoose = require('mongoose');
      
      // Find restaurants by ownerId (handle both string and ObjectId)
      const ownerId = mongoose.Types.ObjectId.isValid(req.user.id) 
        ? new mongoose.Types.ObjectId(req.user.id) 
        : req.user.id;
      
      const restaurants = await Restaurant.find({ ownerId });
      
      if (restaurants.length === 0) {
        // Restaurant owner has no restaurants, return empty array
        return res.json({
          success: true,
          count: 0,
          data: [],
        });
      }
      
      query.restaurantId = { $in: restaurants.map(r => r._id) };
      
      console.log('🔍 Restaurant owner orders filter:', {
        userId: req.user.id,
        restaurantIds: restaurants.map(r => r._id.toString()),
        query: query.restaurantId,
      });
    }
    // Drivers see their assigned orders
    else if (req.user.role === 'driver') {
      query.driverId = req.user.id;
    }

    const orders = await Order.find(query)
      .populate('restaurantId', 'name address')
      .populate('customerId', 'fullName phone')
      .populate('items.menuItemId', 'id name price description imageUrl restaurantId categoryId createdAt')
      .sort({ createdAt: -1 });

    // Transform orders to have menuItem field in items
    const transformedOrders = orders.map(order => {
      const orderObj = order.toObject();
      
      // ALWAYS ensure id is set from _id (Mongoose toObject may not include id)
      if (orderObj._id) {
        orderObj.id = orderObj._id.toString();
      } else if (!orderObj.id) {
        orderObj.id = '';
      } else if (typeof orderObj.id === 'object') {
        orderObj.id = orderObj.id._id ? orderObj.id._id.toString() : orderObj.id.toString();
      } else {
        orderObj.id = orderObj.id.toString();
      }
      
      // Ensure orderNumber is always a string
      if (!orderObj.orderNumber || orderObj.orderNumber === null || orderObj.orderNumber === undefined) {
        orderObj.orderNumber = '';
      } else {
        orderObj.orderNumber = orderObj.orderNumber.toString();
      }
      
      // Ensure status exists
      if (!orderObj.status || orderObj.status === null || orderObj.status === undefined) {
        orderObj.status = 'pending';
      }
      
      // Ensure paymentMethod exists
      if (!orderObj.paymentMethod || orderObj.paymentMethod === null || orderObj.paymentMethod === undefined) {
        orderObj.paymentMethod = 'cash';
      }
      
      // Ensure numeric fields exist
      if (orderObj.subtotal === null || orderObj.subtotal === undefined) {
        orderObj.subtotal = 0;
      }
      if (orderObj.totalAmount === null || orderObj.totalAmount === undefined) {
        orderObj.totalAmount = (orderObj.subtotal || 0) + (orderObj.deliveryFee || 0) - (orderObj.discountAmount || 0);
      }
      if (orderObj.deliveryFee === null || orderObj.deliveryFee === undefined) {
        orderObj.deliveryFee = 0;
      }
      if (orderObj.discountAmount === null || orderObj.discountAmount === undefined) {
        orderObj.discountAmount = 0;
      }
      
      // Ensure items is an array
      if (!orderObj.items || !Array.isArray(orderObj.items)) {
        orderObj.items = [];
      }
      
      // Ensure deliveryLatitude and deliveryLongitude
      if (orderObj.deliveryLatitude === null || orderObj.deliveryLatitude === undefined) {
        orderObj.deliveryLatitude = null;
      }
      if (orderObj.deliveryLongitude === null || orderObj.deliveryLongitude === undefined) {
        orderObj.deliveryLongitude = null;
      }
      
      if (orderObj.customerId) {
        if (typeof orderObj.customerId === 'object') {
          orderObj.customerId = orderObj.customerId._id ? orderObj.customerId._id.toString() : 
                               (orderObj.customerId.id ? orderObj.customerId.id.toString() : '');
        } else {
          orderObj.customerId = orderObj.customerId.toString();
        }
      } else {
        orderObj.customerId = '';
      }
      
      if (orderObj.restaurantId) {
        if (typeof orderObj.restaurantId === 'object') {
          orderObj.restaurantId = orderObj.restaurantId._id ? orderObj.restaurantId._id.toString() : 
                                 (orderObj.restaurantId.id ? orderObj.restaurantId.id.toString() : '');
        } else {
          orderObj.restaurantId = orderObj.restaurantId.toString();
        }
      } else {
        orderObj.restaurantId = '';
      }
      
      if (orderObj.driverId) {
        if (typeof orderObj.driverId === 'object') {
          orderObj.driverId = orderObj.driverId._id ? orderObj.driverId._id.toString() : 
                            (orderObj.driverId.id ? orderObj.driverId.id.toString() : null);
        } else {
          orderObj.driverId = orderObj.driverId.toString();
        }
      } else {
        orderObj.driverId = null;
      }
      
      if (!orderObj.deliveryAddress) {
        orderObj.deliveryAddress = '';
      } else {
        orderObj.deliveryAddress = orderObj.deliveryAddress.toString();
      }
      
      if (orderObj.items && Array.isArray(orderObj.items)) {
        orderObj.items = orderObj.items.map((item, index) => {
          try {
            // Ensure id is always a string
            if (!item.id && item._id) {
              item.id = item._id.toString();
            } else if (!item.id) {
              item.id = `item_${index}_${Date.now()}`;
            } else if (typeof item.id === 'object') {
              item.id = item.id._id ? item.id._id.toString() : item.id.toString();
            } else {
              item.id = item.id.toString();
            }
            
            // Ensure menuItemId is always a string
            if (!item.menuItemId || item.menuItemId === null) {
              item.menuItemId = '';
              item.menuItem = null;
            } else if (typeof item.menuItemId === 'object') {
              // If populated, extract the menuItem and keep menuItemId as string
              const menuItemObj = item.menuItemId.toObject ? item.menuItemId.toObject() : item.menuItemId;
              
              // Ensure menuItem has id from _id
              if (menuItemObj._id && !menuItemObj.id) {
                menuItemObj.id = menuItemObj._id.toString();
              }
              delete menuItemObj._id;
              delete menuItemObj.__v;
              
              // Ensure required fields
              if (!menuItemObj.restaurantId) {
                menuItemObj.restaurantId = '';
              } else if (typeof menuItemObj.restaurantId === 'object') {
                menuItemObj.restaurantId = menuItemObj.restaurantId._id 
                  ? menuItemObj.restaurantId._id.toString() 
                  : menuItemObj.restaurantId.toString();
              }
              
              if (!menuItemObj.name) {
                menuItemObj.name = '';
              }
              
              if (menuItemObj.price === null || menuItemObj.price === undefined) {
                menuItemObj.price = 0;
              }
              
              if (!menuItemObj.createdAt) {
                menuItemObj.createdAt = new Date().toISOString();
              } else if (menuItemObj.createdAt instanceof Date) {
                menuItemObj.createdAt = menuItemObj.createdAt.toISOString();
              }
              
              item.menuItem = menuItemObj;
              item.menuItemId = menuItemObj.id || menuItemObj._id?.toString() || '';
            } else {
              item.menuItemId = item.menuItemId.toString();
            }
            
            // Ensure numeric fields
            if (item.quantity === null || item.quantity === undefined) {
              item.quantity = 1;
            }
            if (item.unitPrice === null || item.unitPrice === undefined) {
              item.unitPrice = 0;
            }
            if (item.subtotal === null || item.subtotal === undefined) {
              item.subtotal = 0;
            }
            
            // Remove _id from item if exists (we already have id)
            delete item._id;
            
            return item;
          } catch (error) {
            console.error(`Error transforming item ${index}:`, error, item);
            // Return a safe default item
            return {
              id: `item_${index}_${Date.now()}`,
              menuItemId: '',
              quantity: item.quantity || 1,
              unitPrice: item.unitPrice || 0,
              subtotal: item.subtotal || 0,
              specialInstructions: item.specialInstructions || null,
            };
          }
        });
      }
      
      // Remove _id and __v from response (we already have id)
      delete orderObj._id;
      delete orderObj.__v;
      
      return orderObj;
    });

    // Log first order for debugging
    if (transformedOrders.length > 0) {
      const sample = transformedOrders[0];
      console.log('📋 Sample transformed order keys:', Object.keys(sample));
      console.log('📋 Sample order id:', sample.id);
      console.log('📋 Sample order orderNumber:', sample.orderNumber);
      console.log('📋 Sample order customerId:', sample.customerId);
      console.log('📋 Sample order restaurantId:', sample.restaurantId);
      console.log('📋 Sample order deliveryAddress:', sample.deliveryAddress);
      console.log('📋 Sample order items count:', sample.items?.length || 0);
      if (sample.items && sample.items.length > 0) {
        console.log('📋 Sample first item:', {
          id: sample.items[0].id,
          menuItemId: sample.items[0].menuItemId,
          hasMenuItem: !!sample.items[0].menuItem,
        });
      }
    }
    
    res.json({
      success: true,
      count: transformedOrders.length,
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

// ==================== DRIVER-SPECIFIC ROUTES ====================
// IMPORTANT: These routes must be defined BEFORE /:id route to avoid route conflicts

// @route   GET /api/v1/orders/available
// @desc    Get available orders for drivers (orders without driver assigned)
// @access  Private (Driver)
router.get('/available', async (req, res) => {
  try {
    // Only drivers can see available orders
    if (req.user.role !== 'driver') {
      return res.status(403).json({
        success: false,
        message: 'Only drivers can view available orders',
      });
    }

    // Find orders that:
    // 1. Don't have a driver assigned (driverId is null)
    // 2. Status is confirmed (restaurant has confirmed but not started preparing yet)
    // Shipper must accept order BEFORE restaurant starts preparing
    const query = {
      driverId: null,
      status: 'confirmed', // Only show confirmed orders (not preparing or ready yet)
    };

    const orders = await Order.find(query)
      .populate('restaurantId', 'name address phone')
      .populate('customerId', 'fullName phone')
      .populate('items.menuItemId', 'id name price description imageUrl restaurantId categoryId createdAt')
      .sort({ createdAt: -1 });

    // Transform orders (same logic as GET /)
    const transformedOrders = orders.map(order => {
      const orderObj = order.toObject();
    
    // ALWAYS ensure id is set from _id (Mongoose toObject may not include id)
    if (orderObj._id) {
      orderObj.id = orderObj._id.toString();
    } else if (!orderObj.id) {
      orderObj.id = '';
    } else if (typeof orderObj.id === 'object') {
      orderObj.id = orderObj.id._id ? orderObj.id._id.toString() : orderObj.id.toString();
    } else {
      orderObj.id = orderObj.id.toString();
    }
    
    // Ensure orderNumber is always a string
    if (!orderObj.orderNumber || orderObj.orderNumber === null || orderObj.orderNumber === undefined) {
      orderObj.orderNumber = '';
    } else {
      orderObj.orderNumber = orderObj.orderNumber.toString();
    }
    
    // Ensure status exists
    if (!orderObj.status || orderObj.status === null || orderObj.status === undefined) {
      orderObj.status = 'pending';
    }
    
    // Ensure paymentMethod exists
    if (!orderObj.paymentMethod || orderObj.paymentMethod === null || orderObj.paymentMethod === undefined) {
      orderObj.paymentMethod = 'cash';
    }
    
    // Ensure numeric fields exist
    if (orderObj.subtotal === null || orderObj.subtotal === undefined) {
      orderObj.subtotal = 0;
    }
    if (orderObj.totalAmount === null || orderObj.totalAmount === undefined) {
      orderObj.totalAmount = (orderObj.subtotal || 0) + (orderObj.deliveryFee || 0) - (orderObj.discountAmount || 0);
    }
    if (orderObj.deliveryFee === null || orderObj.deliveryFee === undefined) {
      orderObj.deliveryFee = 0;
    }
    if (orderObj.discountAmount === null || orderObj.discountAmount === undefined) {
      orderObj.discountAmount = 0;
    }
    
    // Ensure deliveryLatitude and deliveryLongitude
    if (orderObj.deliveryLatitude === null || orderObj.deliveryLatitude === undefined) {
      orderObj.deliveryLatitude = null;
    }
    if (orderObj.deliveryLongitude === null || orderObj.deliveryLongitude === undefined) {
      orderObj.deliveryLongitude = null;
    }
    
    // Ensure items is an array
    if (!orderObj.items || !Array.isArray(orderObj.items)) {
      orderObj.items = [];
    }
    
    if (orderObj.customerId) {
      if (typeof orderObj.customerId === 'object') {
        orderObj.customerId = orderObj.customerId._id ? orderObj.customerId._id.toString() : 
                             (orderObj.customerId.id ? orderObj.customerId.id.toString() : '');
      } else {
        orderObj.customerId = orderObj.customerId.toString();
      }
    } else {
      orderObj.customerId = '';
    }
    
    if (orderObj.restaurantId) {
      if (typeof orderObj.restaurantId === 'object') {
        orderObj.restaurantId = orderObj.restaurantId._id ? orderObj.restaurantId._id.toString() : 
                               (orderObj.restaurantId.id ? orderObj.restaurantId.id.toString() : '');
      } else {
        orderObj.restaurantId = orderObj.restaurantId.toString();
      }
    } else {
      orderObj.restaurantId = '';
    }
    
    if (orderObj.driverId) {
      if (typeof orderObj.driverId === 'object') {
        orderObj.driverId = orderObj.driverId._id ? orderObj.driverId._id.toString() : 
                           (orderObj.driverId.id ? orderObj.driverId.id.toString() : null);
      } else {
        orderObj.driverId = orderObj.driverId.toString();
      }
    } else {
      orderObj.driverId = null;
    }
    
    if (!orderObj.deliveryAddress) {
      orderObj.deliveryAddress = '';
    } else {
      orderObj.deliveryAddress = orderObj.deliveryAddress.toString();
    }
    
    if (orderObj.items && Array.isArray(orderObj.items)) {
      orderObj.items = orderObj.items.map((item, index) => {
        try {
          // Ensure id is always a string
          if (!item.id && item._id) {
            item.id = item._id.toString();
          } else if (!item.id) {
            item.id = `item_${index}_${Date.now()}`;
          } else if (typeof item.id === 'object') {
            item.id = item.id._id ? item.id._id.toString() : item.id.toString();
          } else {
            item.id = item.id.toString();
          }
          
          // Ensure menuItemId is always a string
          if (!item.menuItemId || item.menuItemId === null) {
            item.menuItemId = '';
          } else if (typeof item.menuItemId === 'object') {
            // If populated, extract the menuItem and keep menuItemId as string
            const menuItemObj = item.menuItemId.toObject ? item.menuItemId.toObject() : item.menuItemId;
            
            // Ensure menuItem has id from _id
            if (menuItemObj._id && !menuItemObj.id) {
              menuItemObj.id = menuItemObj._id.toString();
            }
            delete menuItemObj._id;
            delete menuItemObj.__v;
            
            // Ensure required fields
            if (!menuItemObj.restaurantId) {
              menuItemObj.restaurantId = '';
            } else if (typeof menuItemObj.restaurantId === 'object') {
              menuItemObj.restaurantId = menuItemObj.restaurantId._id 
                ? menuItemObj.restaurantId._id.toString() 
                : menuItemObj.restaurantId.toString();
            }
            
            if (!menuItemObj.name) {
              menuItemObj.name = '';
            }
            
            if (menuItemObj.price === null || menuItemObj.price === undefined) {
              menuItemObj.price = 0;
            }
            
            if (!menuItemObj.createdAt) {
              menuItemObj.createdAt = new Date().toISOString();
            } else if (menuItemObj.createdAt instanceof Date) {
              menuItemObj.createdAt = menuItemObj.createdAt.toISOString();
            }
            
            item.menuItem = menuItemObj;
            item.menuItemId = menuItemObj.id || menuItemObj._id?.toString() || '';
          } else {
            item.menuItemId = item.menuItemId.toString();
          }
          
          // Ensure numeric fields
          if (item.quantity === null || item.quantity === undefined) {
            item.quantity = 1;
          }
          if (item.unitPrice === null || item.unitPrice === undefined) {
            item.unitPrice = 0;
          }
          if (item.subtotal === null || item.subtotal === undefined) {
            item.subtotal = 0;
          }
          
          // Remove _id from item if exists (we already have id)
          delete item._id;
          
          return item;
        } catch (error) {
          console.error(`Error transforming item ${index}:`, error, item);
          return {
            id: `item_${index}_${Date.now()}`,
            menuItemId: '',
            quantity: item.quantity || 1,
            unitPrice: item.unitPrice || 0,
            subtotal: item.subtotal || 0,
            specialInstructions: item.specialInstructions || null,
          };
        }
      });
    }
    
      delete orderObj._id;
      delete orderObj.__v;
      return orderObj;
    });

    res.json({
      success: true,
      count: transformedOrders.length,
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

// @route   GET /api/v1/orders/:id
// @desc    Get single order
// @access  Private
router.get('/:id', async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('restaurantId')
      .populate('customerId')
      .populate('driverId')
      .populate('items.menuItemId', 'id name price description imageUrl restaurantId categoryId createdAt');

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Transform items to have menuItem field instead of menuItemId when populated
    const orderObj = order.toObject();
    
    // ALWAYS ensure id is set from _id (Mongoose toObject may not include id)
    if (orderObj._id) {
      orderObj.id = orderObj._id.toString();
    } else if (!orderObj.id) {
      orderObj.id = '';
    } else if (typeof orderObj.id === 'object') {
      orderObj.id = orderObj.id._id ? orderObj.id._id.toString() : orderObj.id.toString();
    } else {
      orderObj.id = orderObj.id.toString();
    }
    
    // Ensure orderNumber is always a string
    if (!orderObj.orderNumber || orderObj.orderNumber === null || orderObj.orderNumber === undefined) {
      orderObj.orderNumber = '';
    } else {
      orderObj.orderNumber = orderObj.orderNumber.toString();
    }
    
    // Ensure status exists
    if (!orderObj.status || orderObj.status === null || orderObj.status === undefined) {
      orderObj.status = 'pending';
    }
    
    // Ensure paymentMethod exists
    if (!orderObj.paymentMethod || orderObj.paymentMethod === null || orderObj.paymentMethod === undefined) {
      orderObj.paymentMethod = 'cash';
    }
    
    // Ensure numeric fields exist
    if (orderObj.subtotal === null || orderObj.subtotal === undefined) {
      orderObj.subtotal = 0;
    }
    if (orderObj.totalAmount === null || orderObj.totalAmount === undefined) {
      orderObj.totalAmount = (orderObj.subtotal || 0) + (orderObj.deliveryFee || 0) - (orderObj.discountAmount || 0);
    }
    if (orderObj.deliveryFee === null || orderObj.deliveryFee === undefined) {
      orderObj.deliveryFee = 0;
    }
    if (orderObj.discountAmount === null || orderObj.discountAmount === undefined) {
      orderObj.discountAmount = 0;
    }
    
    // Ensure deliveryLatitude and deliveryLongitude
    if (orderObj.deliveryLatitude === null || orderObj.deliveryLatitude === undefined) {
      orderObj.deliveryLatitude = null;
    }
    if (orderObj.deliveryLongitude === null || orderObj.deliveryLongitude === undefined) {
      orderObj.deliveryLongitude = null;
    }
    
    // Ensure items is an array
    if (!orderObj.items || !Array.isArray(orderObj.items)) {
      orderObj.items = [];
    }
    
    if (orderObj.customerId) {
      if (typeof orderObj.customerId === 'object') {
        orderObj.customerId = orderObj.customerId._id ? orderObj.customerId._id.toString() : 
                             (orderObj.customerId.id ? orderObj.customerId.id.toString() : '');
      } else {
        orderObj.customerId = orderObj.customerId.toString();
      }
    } else {
      orderObj.customerId = '';
    }
    
    if (orderObj.restaurantId) {
      if (typeof orderObj.restaurantId === 'object') {
        orderObj.restaurantId = orderObj.restaurantId._id ? orderObj.restaurantId._id.toString() : 
                               (orderObj.restaurantId.id ? orderObj.restaurantId.id.toString() : '');
      } else {
        orderObj.restaurantId = orderObj.restaurantId.toString();
      }
    } else {
      orderObj.restaurantId = '';
    }
    
    if (orderObj.driverId) {
      if (typeof orderObj.driverId === 'object') {
        orderObj.driverId = orderObj.driverId._id ? orderObj.driverId._id.toString() : 
                           (orderObj.driverId.id ? orderObj.driverId.id.toString() : null);
      } else {
        orderObj.driverId = orderObj.driverId.toString();
      }
    } else {
      orderObj.driverId = null;
    }
    
    if (!orderObj.deliveryAddress) {
      orderObj.deliveryAddress = '';
    } else {
      orderObj.deliveryAddress = orderObj.deliveryAddress.toString();
    }
    
    if (orderObj.items && Array.isArray(orderObj.items)) {
      orderObj.items = orderObj.items.map((item, index) => {
        try {
          // Ensure id is always a string
          if (!item.id && item._id) {
            item.id = item._id.toString();
          } else if (!item.id) {
            item.id = `item_${index}_${Date.now()}`;
          } else if (typeof item.id === 'object') {
            item.id = item.id._id ? item.id._id.toString() : item.id.toString();
          } else {
            item.id = item.id.toString();
          }
          
          // Ensure menuItemId is always a string
          if (!item.menuItemId || item.menuItemId === null) {
            item.menuItemId = '';
          } else if (typeof item.menuItemId === 'object') {
            // If populated, extract the menuItem and keep menuItemId as string
            const menuItemObj = item.menuItemId.toObject ? item.menuItemId.toObject() : item.menuItemId;
            
            // Ensure menuItem has id from _id
            if (menuItemObj._id && !menuItemObj.id) {
              menuItemObj.id = menuItemObj._id.toString();
            }
            delete menuItemObj._id;
            delete menuItemObj.__v;
            
            // Ensure required fields
            if (!menuItemObj.restaurantId) {
              menuItemObj.restaurantId = '';
            } else if (typeof menuItemObj.restaurantId === 'object') {
              menuItemObj.restaurantId = menuItemObj.restaurantId._id 
                ? menuItemObj.restaurantId._id.toString() 
                : menuItemObj.restaurantId.toString();
            }
            
            if (!menuItemObj.name) {
              menuItemObj.name = '';
            }
            
            if (menuItemObj.price === null || menuItemObj.price === undefined) {
              menuItemObj.price = 0;
            }
            
            if (!menuItemObj.createdAt) {
              menuItemObj.createdAt = new Date().toISOString();
            } else if (menuItemObj.createdAt instanceof Date) {
              menuItemObj.createdAt = menuItemObj.createdAt.toISOString();
            }
            
            item.menuItem = menuItemObj;
            item.menuItemId = menuItemObj.id || menuItemObj._id?.toString() || '';
          } else {
            item.menuItemId = item.menuItemId.toString();
          }
          
          // Ensure numeric fields
          if (item.quantity === null || item.quantity === undefined) {
            item.quantity = 1;
          }
          if (item.unitPrice === null || item.unitPrice === undefined) {
            item.unitPrice = 0;
          }
          if (item.subtotal === null || item.subtotal === undefined) {
            item.subtotal = 0;
          }
          
          // Remove _id from item if exists (we already have id)
          delete item._id;
          
          return item;
        } catch (error) {
          console.error(`Error transforming item ${index}:`, error, item);
          return {
            id: `item_${index}_${Date.now()}`,
            menuItemId: '',
            quantity: item.quantity || 1,
            unitPrice: item.unitPrice || 0,
            subtotal: item.subtotal || 0,
            specialInstructions: item.specialInstructions || null,
          };
        }
      });
    }
    
    // Remove _id and __v from response (we already have id)
    delete orderObj._id;
    delete orderObj.__v;
    
    // Check authorization
    let isAuthorized = false;
    
    if (orderObj.customerId === req.user.id) {
      isAuthorized = true;
    } else if (req.user.role === 'restaurant_owner') {
      // Check if order belongs to user's restaurant
      const Restaurant = require('../models/Restaurant');
      const restaurant = await Restaurant.findOne({ ownerId: req.user.id });
      if (restaurant && orderObj.restaurantId === restaurant._id.toString()) {
        isAuthorized = true;
      }
    } else if (req.user.role === 'driver' && orderObj.driverId && orderObj.driverId === req.user.id) {
      isAuthorized = true;
    } else if (req.user.role === 'admin') {
      isAuthorized = true;
    }

    if (!isAuthorized) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to view this order',
      });
    }

    // Notify restaurant owner about new order
    await notifyOrderStatusChange(order, null, 'pending', req.user.id);

    res.json({
      success: true,
      data: orderObj,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   POST /api/v1/orders
// @desc    Create new order
// @access  Private (Customer only)
router.post('/', async (req, res) => {
  try {
    if (req.user.role !== 'customer') {
      return res.status(403).json({
        success: false,
        message: 'Only customers can create orders',
      });
    }

    // Validate ObjectIds
    const mongoose = require('mongoose');
    if (!mongoose.Types.ObjectId.isValid(req.body.restaurantId)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid restaurant ID',
      });
    }

    // Validate menu item IDs
    if (req.body.items && Array.isArray(req.body.items)) {
      for (const item of req.body.items) {
        if (!mongoose.Types.ObjectId.isValid(item.menuItemId)) {
          return res.status(400).json({
            success: false,
            message: `Invalid menu item ID: ${item.menuItemId}`,
          });
        }
      }
    }

    // Create order (orderNumber will be auto-generated by pre-save hook)
    const order = await Order.create({
      ...req.body,
      customerId: req.user.id,
      // orderNumber will be generated automatically
    });

    const populatedOrder = await Order.findById(order._id)
      .populate('restaurantId', 'name address phone deliveryFee minimumOrder')
      .populate('items.menuItemId', 'id name price description imageUrl restaurantId categoryId createdAt');

    // Transform items to have menuItem field
    const orderObj = populatedOrder.toObject();
    
    // Ensure all required fields are present
    if (!orderObj.id && orderObj._id) {
      orderObj.id = orderObj._id.toString();
    } else if (orderObj.id && typeof orderObj.id === 'object') {
      orderObj.id = orderObj.id._id ? orderObj.id._id.toString() : orderObj.id.toString();
    } else if (orderObj.id) {
      orderObj.id = orderObj.id.toString();
    }
    
    if (!orderObj.orderNumber) {
      orderObj.orderNumber = '';
    } else {
      orderObj.orderNumber = orderObj.orderNumber.toString();
    }
    
    if (orderObj.customerId) {
      if (typeof orderObj.customerId === 'object') {
        orderObj.customerId = orderObj.customerId._id ? orderObj.customerId._id.toString() : 
                             (orderObj.customerId.id ? orderObj.customerId.id.toString() : '');
      } else {
        orderObj.customerId = orderObj.customerId.toString();
      }
    } else {
      orderObj.customerId = '';
    }
    
    if (orderObj.restaurantId) {
      if (typeof orderObj.restaurantId === 'object') {
        orderObj.restaurantId = orderObj.restaurantId._id ? orderObj.restaurantId._id.toString() : 
                               (orderObj.restaurantId.id ? orderObj.restaurantId.id.toString() : '');
      } else {
        orderObj.restaurantId = orderObj.restaurantId.toString();
      }
    } else {
      orderObj.restaurantId = '';
    }
    
    if (orderObj.driverId) {
      if (typeof orderObj.driverId === 'object') {
        orderObj.driverId = orderObj.driverId._id ? orderObj.driverId._id.toString() : 
                           (orderObj.driverId.id ? orderObj.driverId.id.toString() : null);
      } else {
        orderObj.driverId = orderObj.driverId.toString();
      }
    } else {
      orderObj.driverId = null;
    }
    
    if (!orderObj.deliveryAddress) {
      orderObj.deliveryAddress = '';
    } else {
      orderObj.deliveryAddress = orderObj.deliveryAddress.toString();
    }
    
    if (orderObj.items && Array.isArray(orderObj.items)) {
      orderObj.items = orderObj.items.map((item, index) => {
        try {
          // Ensure id is always a string
          if (!item.id && item._id) {
            item.id = item._id.toString();
          } else if (!item.id) {
            item.id = `item_${index}_${Date.now()}`;
          } else if (typeof item.id === 'object') {
            item.id = item.id._id ? item.id._id.toString() : item.id.toString();
          } else {
            item.id = item.id.toString();
          }
          
          // Ensure menuItemId is always a string
          if (!item.menuItemId || item.menuItemId === null) {
            item.menuItemId = '';
          } else if (typeof item.menuItemId === 'object') {
            // If populated, extract the menuItem and keep menuItemId as string
            const menuItemObj = item.menuItemId.toObject ? item.menuItemId.toObject() : item.menuItemId;
            
            // Ensure menuItem has id from _id
            if (menuItemObj._id && !menuItemObj.id) {
              menuItemObj.id = menuItemObj._id.toString();
            }
            delete menuItemObj._id;
            delete menuItemObj.__v;
            
            // Ensure required fields
            if (!menuItemObj.restaurantId) {
              menuItemObj.restaurantId = '';
            } else if (typeof menuItemObj.restaurantId === 'object') {
              menuItemObj.restaurantId = menuItemObj.restaurantId._id 
                ? menuItemObj.restaurantId._id.toString() 
                : menuItemObj.restaurantId.toString();
            }
            
            if (!menuItemObj.name) {
              menuItemObj.name = '';
            }
            
            if (menuItemObj.price === null || menuItemObj.price === undefined) {
              menuItemObj.price = 0;
            }
            
            if (!menuItemObj.createdAt) {
              menuItemObj.createdAt = new Date().toISOString();
            } else if (menuItemObj.createdAt instanceof Date) {
              menuItemObj.createdAt = menuItemObj.createdAt.toISOString();
            }
            
            item.menuItem = menuItemObj;
            item.menuItemId = menuItemObj.id || menuItemObj._id?.toString() || '';
          } else {
            item.menuItemId = item.menuItemId.toString();
          }
          
          // Ensure numeric fields
          if (item.quantity === null || item.quantity === undefined) {
            item.quantity = 1;
          }
          if (item.unitPrice === null || item.unitPrice === undefined) {
            item.unitPrice = 0;
          }
          if (item.subtotal === null || item.subtotal === undefined) {
            item.subtotal = 0;
          }
          
          // Remove _id from item if exists (we already have id)
          delete item._id;
          
          return item;
        } catch (error) {
          console.error(`Error transforming item ${index}:`, error, item);
          return {
            id: `item_${index}_${Date.now()}`,
            menuItemId: '',
            quantity: item.quantity || 1,
            unitPrice: item.unitPrice || 0,
            subtotal: item.subtotal || 0,
            specialInstructions: item.specialInstructions || null,
          };
        }
      });
    }
    
    // Remove _id and __v from response (we already have id)
    delete orderObj._id;
    delete orderObj.__v;
    
    // Log for debugging
    console.log('📋 Created order:', {
      id: orderObj.id,
      orderNumber: orderObj.orderNumber,
      customerId: orderObj.customerId,
      restaurantId: orderObj.restaurantId,
      itemsCount: orderObj.items?.length || 0,
    });

    res.status(201).json({
      success: true,
      data: orderObj,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: error.message || 'Server error',
    });
  }
});

// @route   POST /api/v1/orders/:id/accept
// @desc    Driver accepts an order
// @access  Private (Driver)
router.post('/:id/accept', async (req, res) => {
  try {
    // Only drivers can accept orders
    if (req.user.role !== 'driver') {
      return res.status(403).json({
        success: false,
        message: 'Only drivers can accept orders',
      });
    }

    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Check if order already has a driver
    if (order.driverId) {
      return res.status(400).json({
        success: false,
        message: 'Order already has a driver assigned',
      });
    }

    // Check if order status allows driver to accept
    // Driver can only accept orders that are confirmed (restaurant has confirmed but not started preparing)
    if (order.status !== 'confirmed') {
      return res.status(400).json({
        success: false,
        message: `Cannot accept order with status: ${order.status}. Order must be confirmed. Restaurant will start preparing after you accept.`,
      });
    }

    // Assign driver to order
    order.driverId = req.user.id;
    // Keep status as 'confirmed' - restaurant will change to 'preparing' after driver accepts

    await order.save();

    // Populate and transform order
    await order.populate('restaurantId', 'name address');
    await order.populate('customerId', 'fullName phone');
    await order.populate('items.menuItemId', 'id name price description imageUrl restaurantId categoryId createdAt');

    const orderObj = order.toObject();
    orderObj.id = orderObj._id.toString();
    orderObj.driverId = orderObj.driverId.toString();
    
    // Transform items (same logic as other endpoints)
    if (orderObj.items && Array.isArray(orderObj.items)) {
      orderObj.items = orderObj.items.map((item, index) => {
        if (!item.id && item._id) {
          item.id = item._id.toString();
        }
        if (item.menuItemId && typeof item.menuItemId === 'object') {
          const menuItem = item.menuItemId;
          item.menuItem = {
            id: menuItem._id ? menuItem._id.toString() : (menuItem.id ? menuItem.id.toString() : ''),
            name: menuItem.name || 'Món đã xóa',
            price: menuItem.price || 0,
            description: menuItem.description || '',
            imageUrl: menuItem.imageUrl || null,
            restaurantId: menuItem.restaurantId ? (typeof menuItem.restaurantId === 'object' ? menuItem.restaurantId._id.toString() : menuItem.restaurantId.toString()) : '',
            categoryId: menuItem.categoryId ? (typeof menuItem.categoryId === 'object' ? menuItem.categoryId._id.toString() : menuItem.categoryId.toString()) : null,
            createdAt: menuItem.createdAt ? (menuItem.createdAt instanceof Date ? menuItem.createdAt.toISOString() : menuItem.createdAt) : null,
          };
          item.menuItemId = item.menuItem.id;
        }
        delete item._id;
        delete item.__v;
        return item;
      });
    }
    
    delete orderObj._id;
    delete orderObj.__v;

    // Notify restaurant owner and customer that driver has accepted
    await notifyOrderStatusChange(order, 'confirmed', 'confirmed', req.user.id);

    res.json({
      success: true,
      message: 'Order accepted successfully',
      data: orderObj,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/orders/:id/status
// @desc    Update order status
// @access  Private
router.put('/:id/status', async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    // Authorization checks based on role
    let canUpdate = false;
    
    if (req.user.role === 'restaurant_owner') {
      // Restaurant can update: confirmed, preparing, ready
      // Also check if order belongs to their restaurant
      const Restaurant = require('../models/Restaurant');
      const mongoose = require('mongoose');
      
      // Find restaurant by ownerId (handle both string and ObjectId)
      const ownerId = mongoose.Types.ObjectId.isValid(req.user.id) 
        ? new mongoose.Types.ObjectId(req.user.id) 
        : req.user.id;
      const restaurant = await Restaurant.findOne({ ownerId });
      
      if (!restaurant) {
        console.log('❌ Restaurant owner has no restaurant. User ID:', req.user.id);
        canUpdate = false;
      } else {
        // Ensure order.restaurantId is compared correctly (handle both ObjectId and string)
        const orderRestaurantId = order.restaurantId.toString();
        const restaurantId = restaurant._id.toString();
        
        console.log('🔍 Authorization check:', {
          userId: req.user.id,
          orderRestaurantId,
          restaurantId,
          match: orderRestaurantId === restaurantId,
          status,
          currentStatus: order.status,
        });
        
        if (orderRestaurantId === restaurantId) {
          // Restaurant can only update to preparing/ready if driver has accepted the order
          if (status === 'confirmed') {
            canUpdate = true; // Can confirm orders
          } else if (status === 'preparing' || status === 'ready') {
            // Can only start preparing/ready if driver has accepted
            canUpdate = order.driverId != null && order.driverId.toString() !== '';
          }
        } else {
          console.log('❌ Order does not belong to restaurant owner');
        }
      }
    } else if (req.user.role === 'driver') {
      // Driver can update: picked_up, on_the_way, delivered
      // Also check if order is assigned to them
      if (order.driverId && order.driverId.toString() === req.user.id) {
        canUpdate = ['picked_up', 'on_the_way', 'delivered'].includes(status);
      }
    } else if (req.user.role === 'customer') {
      // Customer can only cancel pending orders
      if (order.customerId.toString() === req.user.id && status === 'cancelled' && order.status === 'pending') {
        canUpdate = true;
      }
    } else if (req.user.role === 'admin') {
      // Admin can update any status
      canUpdate = true;
    }

    if (!canUpdate) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to update order status',
      });
    }

    // Validate status transitions
    // Note: preparing and ready can only happen if driverId is set
    const validTransitions = {
      'pending': ['confirmed', 'cancelled'],
      'confirmed': ['preparing', 'cancelled'], // preparing only if driverId exists
      'preparing': ['ready', 'cancelled'], // ready only if driverId exists
      'ready': ['on_the_way', 'cancelled'], // Shipper picks up and starts delivery directly
      'picked_up': ['on_the_way'], // Keep for backward compatibility
      'on_the_way': ['delivered'],
      'delivered': [], // Final state
      'cancelled': [], // Final state
    };

    // Additional validation: preparing and ready require driverId
    if ((status === 'preparing' || status === 'ready') && !order.driverId) {
      return res.status(400).json({
        success: false,
        message: `Cannot set status to ${status} without a driver assigned. Driver must accept the order first.`,
      });
    }

    const currentStatus = order.status;
    if (validTransitions[currentStatus] && !validTransitions[currentStatus].includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status transition from ${currentStatus} to ${status}`,
      });
    }

    const oldStatus = order.status;
    order.status = status;
    if (status === 'delivered') {
      order.deliveredAt = new Date();
    }

    await order.save();

    // Notify all relevant parties about status change
    await notifyOrderStatusChange(order, oldStatus, status, req.user.id);

    res.json({
      success: true,
      data: order,
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

