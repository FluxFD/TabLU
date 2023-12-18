//contestant.model.js
const mongoose = require('mongoose');

const contestantSchema = new mongoose.Schema({
  name: String,
  course: String,
  department: String,
  profilePic: { type: mongoose.Schema.Types.ObjectId, ref: 'Upload' },
  eventId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  totalScore: Number, // Assuming you want to use Number for criteria score
  // criterianame: {
  //   type: String,
  //   ref: 'Criteria',
  // },
  // criteriaId: {
  //   type: mongoose.Schema.Types.ObjectId,
  //   ref: 'Criteria',
  // },
});





const Contestant = mongoose.model('Contestant', contestantSchema);

module.exports = Contestant;
