const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    type: {
      type: String,
      required: true,
      enum: [
        'order_placed', // Customer: Đơn hàng đã được đặt
        'order_confirmed', // Customer: Đơn hàng đã được xác nhận
        'order_preparing', // Customer: Nhà hàng đang chuẩn bị
        'order_ready', // Customer: Đơn hàng sẵn sàng
        'order_on_the_way', // Customer: Đơn hàng đang được giao
        'order_delivered', // Customer: Đơn hàng đã được giao
        'order_cancelled', // Customer: Đơn hàng đã bị hủy
        'new_order', // Restaurant: Có đơn hàng mới
        'order_accepted_by_driver', // Restaurant: Shipper đã nhận đơn
        'driver_assigned', // Restaurant: Shipper đã được gán
        'order_available', // Shipper: Có đơn hàng mới cần giao
        'order_ready_for_pickup', // Shipper: Đơn hàng sẵn sàng để lấy
        'promotion', // Tất cả: Khuyến mãi
        'system', // Tất cả: Thông báo hệ thống
      ],
    },
    title: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    data: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
      default: {},
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Order',
      default: null,
    },
    isRead: {
      type: Boolean,
      default: false,
      index: true,
    },
    readAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true,
  }
);

// Transform to remove _id and add id
notificationSchema.set('toJSON', {
  transform: function (doc, ret) {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  },
});

// Indexes for performance
notificationSchema.index({ userId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('Notification', notificationSchema);

