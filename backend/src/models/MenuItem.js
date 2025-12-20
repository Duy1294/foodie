const mongoose = require('mongoose');

const menuItemSchema = new mongoose.Schema({
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: true,
  },
  categoryId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
  },
  name: {
    type: String,
    required: [true, 'Please provide item name'],
    trim: true,
  },
  description: {
    type: String,
  },
  price: {
    type: Number,
    required: [true, 'Please provide price'],
    min: 0,
  },
  imageUrl: {
    type: String,
  },
  isAvailable: {
    type: Boolean,
    default: true,
  },
  isPopular: {
    type: Boolean,
    default: false,
  },
  displayOrder: {
    type: Number,
    default: 0,
  },
}, {
  timestamps: true,
});

// Transform _id to id in JSON output
menuItemSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id ? ret._id.toString() : ret.id;
    if (ret.restaurantId) {
      ret.restaurantId = ret.restaurantId.toString();
    }
    if (ret.categoryId) {
      ret.categoryId = ret.categoryId.toString();
    }
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

module.exports = mongoose.model('MenuItem', menuItemSchema);

