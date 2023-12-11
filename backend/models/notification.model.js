const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  body: { type: String, required: true },
  date: { type: Date, default: Date.now },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true },
  // Other notification-specific fields can be added here
});

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
