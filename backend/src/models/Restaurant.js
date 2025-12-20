const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  name: {
    type: String,
    required: [true, 'Please provide restaurant name'],
    trim: true,
  },
  description: {
    type: String,
  },
  address: {
    type: String,
    required: [true, 'Please provide address'],
  },
  latitude: {
    type: Number,
  },
  longitude: {
    type: Number,
  },
  phone: {
    type: String,
  },
  email: {
    type: String,
  },
  logoUrl: {
    type: String,
  },
  coverImageUrl: {
    type: String,
  },
  openingHours: {
    type: Map,
    of: {
      open: String,
      close: String,
    },
    default: {},
  },
  deliveryFee: {
    type: Number,
    default: 0,
  },
  minimumOrder: {
    type: Number,
    default: 0,
  },
  ratingAverage: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
  },
  ratingCount: {
    type: Number,
    default: 0,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Index for location-based queries
restaurantSchema.index({ latitude: 1, longitude: 1 });

// Transform _id to id in JSON output
restaurantSchema.set('toJSON', {
  transform: function(doc, ret) {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

module.exports = mongoose.model('Restaurant', restaurantSchema);

