//../models/judges.model.js
const mongoose = require('mongoose');

const judgeSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  isConfirm: { type: Boolean, default: false },// Added isConfirm with default value false
  scoreSubmitted: {type: Boolean, default: false}
  // Other judge-specific fields
});


const Judge = mongoose.model('Judge', judgeSchema);

module.exports = Judge;
