const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Please provide an email'],
    unique: true,
    lowercase: true,
    trim: true,
    match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
  },
  phone: {
    type: String,
    trim: true,
  },
  password: {
    type: String,
    required: function() {
      // Password is required only if firebaseUid is not provided
      return !this.firebaseUid;
    },
    minlength: 6,
    select: false, // Don't return password by default
  },
  fullName: {
    type: String,
    required: [true, 'Please provide your full name'],
    trim: true,
  },
  avatarUrl: {
    type: String,
  },
  role: {
    type: String,
    enum: ['customer', 'restaurant_owner', 'driver', 'admin'],
    default: 'customer',
  },
  isVerified: {
    type: Boolean,
    default: false,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  resetPasswordToken: {
    type: String,
  },
  resetPasswordExpire: {
    type: Date,
  },
  // Firebase integration
  firebaseUid: {
    type: String,
    unique: true,
    sparse: true, // Allow null values but enforce uniqueness when present
  },
  // Shipper-specific fields
  vehicleInfo: {
    vehicleType: {
      type: String,
      enum: ['motorcycle', 'bicycle', 'car'],
    },
    licensePlate: {
      type: String,
      trim: true,
    },
    vehicleBrand: {
      type: String,
      trim: true,
    },
    vehicleModel: {
      type: String,
      trim: true,
    },
  },
  currentLocation: {
    latitude: {
      type: Number,
    },
    longitude: {
      type: Number,
    },
    lastUpdated: {
      type: Date,
    },
  },
  isOnline: {
    type: Boolean,
    default: false,
  },
  shipperSettings: {
    notificationEnabled: {
      type: Boolean,
      default: true,
    },
    workingHours: {
      type: Map,
      of: {
        start: String,
        end: String,
      },
      default: {},
    },
    deliveryAreas: {
      type: [String],
      default: [],
    },
  },
}, {
  timestamps: true,
});

// Hash password before saving (skip if Firebase user without password)
userSchema.pre('save', async function(next) {
  // Skip password hashing for Firebase users
  if (this.firebaseUid && !this.password) {
    return next();
  }
  
  if (!this.isModified('password')) {
    return next();
  }
  
  // Only hash if password exists and is being modified
  if (this.password) {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
  }
  next();
});

// Compare password method
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Remove password from JSON output and transform _id to id
userSchema.methods.toJSON = function() {
  const obj = this.toObject();
  delete obj.password;
  obj.id = obj._id.toString();
  delete obj._id;
  delete obj.__v;
  return obj;
};

module.exports = mongoose.model('User', userSchema);

