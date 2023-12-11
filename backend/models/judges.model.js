const mongoose = require('mongoose');

const judgeSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'user', required: true },
  // Other judge-specific fields
});

const Judge = mongoose.model('Judge', judgeSchema);

module.exports = Judge;
