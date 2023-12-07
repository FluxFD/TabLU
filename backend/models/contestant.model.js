const mongoose = require('mongoose');

const contestantSchema = new mongoose.Schema({
  name: String,
  course: String,
  department: String,
  profilePic: String,
 /* eventId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Event',
  },
  criteriascore: Number, // Assuming you want to use Number for criteria score
  criterianame: {
    type: String,
    ref: 'Criteria',
  },
  criteriaId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Criteria',
  },*/
});

const scoreCardSchema = new mongoose.Schema({
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  criteriaId: { type: mongoose.Schema.Types.ObjectId, ref: 'Criteria', required: true },
  contestantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contestant', required: true },
  criteriascore: { type: Number, required: true },
  // Other score card fields
});

const ScoreCard = mongoose.model('ScoreCard', scoreCardSchema);

const Contestant = mongoose.model('Contestant', contestantSchema);

module.exports = Contestant, ScoreCard;
