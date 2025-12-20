const express = require('express');
const Notification = require('../models/Notification');
const { protect } = require('../middleware/auth');

const router = express.Router();

// All routes require authentication
router.use(protect);

// @route   GET /api/v1/notifications
// @desc    Get user's notifications
// @access  Private
router.get('/', async (req, res) => {
  try {
    const { isRead, limit = 50, page = 1 } = req.query;
    
    // Build query
    const query = { userId: req.user.id };
    if (isRead !== undefined) {
      query.isRead = isRead === 'true';
    }

    // Pagination
    const skip = (parseInt(page) - 1) * parseInt(limit);

    const notifications = await Notification.find(query)
      .populate('orderId', 'orderNumber status')
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip)
      .lean();

    // Transform notifications
    const transformedNotifications = notifications.map(notif => {
      const notifObj = { ...notif };
      
      // Ensure id is string
      if (notifObj._id) {
        notifObj.id = notifObj._id.toString();
      }
      delete notifObj._id;
      delete notifObj.__v;
      
      // Transform orderId if populated
      if (notifObj.orderId) {
        if (typeof notifObj.orderId === 'object') {
          notifObj.orderId = notifObj.orderId._id ? notifObj.orderId._id.toString() : 
                            (notifObj.orderId.id ? notifObj.orderId.id.toString() : null);
        } else {
          notifObj.orderId = notifObj.orderId.toString();
        }
      }
      
      // Transform dates
      if (notifObj.createdAt) {
        notifObj.createdAt = notifObj.createdAt instanceof Date 
          ? notifObj.createdAt.toISOString() 
          : notifObj.createdAt;
      }
      if (notifObj.updatedAt) {
        notifObj.updatedAt = notifObj.updatedAt instanceof Date 
          ? notifObj.updatedAt.toISOString() 
          : notifObj.updatedAt;
      }
      if (notifObj.readAt) {
        notifObj.readAt = notifObj.readAt instanceof Date 
          ? notifObj.readAt.toISOString() 
          : notifObj.readAt;
      }
      
      return notifObj;
    });

    // Get total count for pagination
    const total = await Notification.countDocuments(query);

    res.json({
      success: true,
      count: transformedNotifications.length,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      data: transformedNotifications,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   GET /api/v1/notifications/unread-count
// @desc    Get count of unread notifications
// @access  Private
router.get('/unread-count', async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      userId: req.user.id,
      isRead: false,
    });

    res.json({
      success: true,
      count,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/notifications/:id/read
// @desc    Mark notification as read
// @access  Private
router.put('/:id/read', async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    // Check if notification belongs to user
    if (notification.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized',
      });
    }

    notification.isRead = true;
    notification.readAt = new Date();
    await notification.save();

    const notifObj = notification.toObject();
    if (notifObj.orderId) {
      notifObj.orderId = notifObj.orderId.toString();
    }

    res.json({
      success: true,
      data: notifObj,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   PUT /api/v1/notifications/read-all
// @desc    Mark all notifications as read
// @access  Private
router.put('/read-all', async (req, res) => {
  try {
    const result = await Notification.updateMany(
      {
        userId: req.user.id,
        isRead: false,
      },
      {
        $set: {
          isRead: true,
          readAt: new Date(),
        },
      }
    );

    res.json({
      success: true,
      count: result.modifiedCount,
      message: `Marked ${result.modifiedCount} notifications as read`,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/notifications/:id
// @desc    Delete notification
// @access  Private
router.delete('/:id', async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    // Check if notification belongs to user
    if (notification.userId.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized',
      });
    }

    await notification.deleteOne();

    res.json({
      success: true,
      message: 'Notification deleted',
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
});

// @route   DELETE /api/v1/notifications
// @desc    Delete all notifications
// @access  Private
router.delete('/', async (req, res) => {
  try {
    const result = await Notification.deleteMany({
      userId: req.user.id,
    });

    res.json({
      success: true,
      count: result.deletedCount,
      message: `Deleted ${result.deletedCount} notifications`,
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

