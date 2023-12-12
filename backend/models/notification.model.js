const mongoose = require('mongoose');

// Define the possible values for the 'type' field
const notificationTypes = ['normal', 'confirmation'];

const notificationSchema = new mongoose.Schema({
  body: { type: String, required: true },
  date: { type: Date, default: Date.now },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true },
  receiver: { type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true },
  type: { type: String, enum: notificationTypes, default: 'normal' }, // Add the 'type' field with enum and default
  // Other notification-specific fields can be added here
});

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
