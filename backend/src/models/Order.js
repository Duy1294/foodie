const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  menuItemId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'MenuItem',
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
    min: 1,
  },
  unitPrice: {
    type: Number,
    required: true,
  },
  subtotal: {
    type: Number,
    required: true,
  },
  specialInstructions: {
    type: String,
  },
});

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    unique: true,
    required: false, // Will be auto-generated in pre-save hook
  },
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: true,
  },
  driverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'ready', 'picked_up', 'on_the_way', 'delivered', 'cancelled'],
    default: 'pending',
  },
  subtotal: {
    type: Number,
    required: true,
  },
  deliveryFee: {
    type: Number,
    default: 0,
  },
  discountAmount: {
    type: Number,
    default: 0,
  },
  totalAmount: {
    type: Number,
    required: true,
  },
  paymentMethod: {
    type: String,
    enum: ['cash', 'card', 'wallet', 'momo', 'zalopay'],
    required: true,
  },
  paymentStatus: {
    type: String,
    enum: ['pending', 'paid', 'failed', 'refunded'],
    default: 'pending',
  },
  deliveryAddress: {
    type: String,
    required: true,
  },
  deliveryLatitude: {
    type: Number,
  },
  deliveryLongitude: {
    type: Number,
  },
  customerNote: {
    type: String,
  },
  items: [orderItemSchema],
  deliveredAt: {
    type: Date,
  },
}, {
  timestamps: true,
});

// Transform _id to id in JSON output
orderSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id.toString();
    ret.orderNumber = ret.orderNumber;
    ret.customerId = ret.customerId.toString();
    ret.restaurantId = ret.restaurantId.toString();
    if (ret.driverId) {
      ret.driverId = ret.driverId.toString();
    }
    if (ret.items && Array.isArray(ret.items)) {
      ret.items = ret.items.map(item => {
        if (item._id) {
          item.id = item._id.toString();
          delete item._id;
        }
        if (item.menuItemId) {
          item.menuItemId = item.menuItemId.toString();
        }
        return item;
      });
    }
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

// Generate order number before saving
orderSchema.pre('save', async function(next) {
  if (!this.isNew || this.orderNumber) {
    return next();
  }
  
  try {
    // Generate unique order number
    const timestamp = Date.now();
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    this.orderNumber = `ORD${timestamp}${random}`;
    next();
  } catch (error) {
    next(error);
  }
});

module.exports = mongoose.model('Order', orderSchema);

