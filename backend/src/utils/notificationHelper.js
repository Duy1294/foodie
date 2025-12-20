const Notification = require('../models/Notification');
const Restaurant = require('../models/Restaurant');

/**
 * Create notification for user
 * @param {String} userId - User ID to receive notification
 * @param {String} type - Notification type
 * @param {String} title - Notification title
 * @param {String} message - Notification message
 * @param {Object} data - Additional data
 * @param {String} orderId - Order ID (optional)
 */
async function createNotification(userId, type, title, message, data = {}, orderId = null) {
  try {
    const notification = await Notification.create({
      userId,
      type,
      title,
      message,
      data,
      orderId,
    });
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    return null;
  }
}

/**
 * Create notifications for order status changes
 */
async function notifyOrderStatusChange(order, oldStatus, newStatus, changedBy) {
  const notifications = [];

  try {
    // Get restaurant info
    const restaurant = await Restaurant.findById(order.restaurantId).populate('ownerId');

    // Notify customer
    if (order.customerId) {
      let customerTitle = '';
      let customerMessage = '';

      switch (newStatus) {
        case 'confirmed':
          customerTitle = 'Đơn hàng đã được xác nhận';
          customerMessage = `Đơn hàng #${order.orderNumber} đã được nhà hàng xác nhận. Nhà hàng sẽ bắt đầu chuẩn bị sau khi có shipper nhận đơn.`;
          break;
        case 'preparing':
          customerTitle = 'Nhà hàng đang chuẩn bị';
          customerMessage = `Đơn hàng #${order.orderNumber} đang được nhà hàng chuẩn bị.`;
          break;
        case 'ready':
          customerTitle = 'Đơn hàng sẵn sàng';
          customerMessage = `Đơn hàng #${order.orderNumber} đã sẵn sàng. Shipper sẽ đến lấy hàng và giao đến bạn.`;
          break;
        case 'on_the_way':
          customerTitle = 'Đơn hàng đang được giao';
          customerMessage = `Đơn hàng #${order.orderNumber} đang được shipper giao đến bạn.`;
          break;
        case 'delivered':
          customerTitle = 'Đơn hàng đã được giao';
          customerMessage = `Đơn hàng #${order.orderNumber} đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!`;
          break;
        case 'cancelled':
          customerTitle = 'Đơn hàng đã bị hủy';
          customerMessage = `Đơn hàng #${order.orderNumber} đã bị hủy.`;
          break;
      }

      if (customerTitle && customerMessage) {
        const notif = await createNotification(
          order.customerId,
          `order_${newStatus}`,
          customerTitle,
          customerMessage,
          { orderNumber: order.orderNumber, status: newStatus },
          order._id
        );
        if (notif) notifications.push(notif);
      }
    }

    // Notify restaurant owner
    if (restaurant && restaurant.ownerId) {
      let restaurantTitle = '';
      let restaurantMessage = '';

      switch (newStatus) {
        case 'pending':
          restaurantTitle = 'Có đơn hàng mới';
          restaurantMessage = `Bạn có đơn hàng mới #${order.orderNumber}. Vui lòng xác nhận đơn hàng.`;
          break;
        case 'confirmed':
          if (order.driverId) {
            restaurantTitle = 'Shipper đã nhận đơn';
            restaurantMessage = `Shipper đã nhận đơn hàng #${order.orderNumber}. Bạn có thể bắt đầu chuẩn bị.`;
          } else {
            restaurantTitle = 'Đang chờ shipper nhận đơn';
            restaurantMessage = `Đơn hàng #${order.orderNumber} đã được xác nhận. Đang chờ shipper nhận đơn.`;
          }
          break;
        case 'preparing':
          restaurantTitle = 'Đang chuẩn bị đơn hàng';
          restaurantMessage = `Đơn hàng #${order.orderNumber} đang được chuẩn bị.`;
          break;
        case 'ready':
          restaurantTitle = 'Đơn hàng sẵn sàng';
          restaurantMessage = `Đơn hàng #${order.orderNumber} đã sẵn sàng. Shipper sẽ đến lấy hàng.`;
          break;
      }

      if (restaurantTitle && restaurantMessage) {
        const notif = await createNotification(
          restaurant.ownerId._id || restaurant.ownerId,
          newStatus === 'pending' ? 'new_order' : 
          (newStatus === 'confirmed' && order.driverId ? 'order_accepted_by_driver' : 'order_update'),
          restaurantTitle,
          restaurantMessage,
          { orderNumber: order.orderNumber, status: newStatus },
          order._id
        );
        if (notif) notifications.push(notif);
      }
    }

    // Notify shipper
    if (order.driverId) {
      let shipperTitle = '';
      let shipperMessage = '';

      switch (newStatus) {
        case 'confirmed':
          if (oldStatus === 'pending') {
            shipperTitle = 'Bạn đã nhận đơn hàng';
            shipperMessage = `Bạn đã nhận đơn hàng #${order.orderNumber}. Nhà hàng sẽ bắt đầu chuẩn bị.`;
          }
          break;
        case 'preparing':
          shipperTitle = 'Nhà hàng đang chuẩn bị';
          shipperMessage = `Nhà hàng đang chuẩn bị đơn hàng #${order.orderNumber}. Vui lòng chờ.`;
          break;
        case 'ready':
          shipperTitle = 'Đơn hàng sẵn sàng để lấy';
          shipperMessage = `Đơn hàng #${order.orderNumber} đã sẵn sàng. Vui lòng đến nhà hàng để lấy hàng.`;
          break;
        case 'on_the_way':
          shipperTitle = 'Bắt đầu giao hàng';
          shipperMessage = `Bạn đã bắt đầu giao đơn hàng #${order.orderNumber}.`;
          break;
        case 'delivered':
          shipperTitle = 'Giao hàng thành công';
          shipperMessage = `Đơn hàng #${order.orderNumber} đã được giao thành công.`;
          break;
      }

      if (shipperTitle && shipperMessage) {
        const notif = await createNotification(
          order.driverId,
          newStatus === 'ready' ? 'order_ready_for_pickup' : `order_${newStatus}`,
          shipperTitle,
          shipperMessage,
          { orderNumber: order.orderNumber, status: newStatus },
          order._id
        );
        if (notif) notifications.push(notif);
      }
    }

    return notifications;
  } catch (error) {
    console.error('Error creating order status notifications:', error);
    return [];
  }
}

/**
 * Notify shippers about new available orders
 */
async function notifyNewOrderAvailable(order) {
  try {
    // This would typically query for online shippers and notify them
    // For now, we'll just log it
    console.log(`📢 New order available: ${order.orderNumber}`);
    // TODO: Query online shippers and create notifications
    return [];
  } catch (error) {
    console.error('Error notifying shippers:', error);
    return [];
  }
}

module.exports = {
  createNotification,
  notifyOrderStatusChange,
  notifyNewOrderAvailable,
};

