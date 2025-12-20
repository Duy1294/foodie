const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  label: {
    type: String,
    required: [true, 'Please provide address label'],
    trim: true,
  },
  fullAddress: {
    type: String,
    required: [true, 'Please provide full address'],
    trim: true,
  },
  street: {
    type: String,
    trim: true,
  },
  ward: {
    type: String,
    trim: true,
  },
  district: {
    type: String,
    trim: true,
  },
  city: {
    type: String,
    trim: true,
  },
  latitude: {
    type: Number,
  },
  longitude: {
    type: Number,
  },
  phone: {
    type: String,
    trim: true,
  },
  recipientName: {
    type: String,
    trim: true,
  },
  isDefault: {
    type: Boolean,
    default: false,
  },
}, {
  timestamps: true,
});

// Ensure only one default address per user
addressSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await mongoose.model('Address').updateMany(
      { userId: this.userId, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

// Transform _id to id in JSON output
addressSchema.methods.toJSON = function() {
  const obj = this.toObject();
  obj.id = obj._id.toString();
  delete obj._id;
  delete obj.__v;
  return obj;
};

module.exports = mongoose.model('Address', addressSchema);

