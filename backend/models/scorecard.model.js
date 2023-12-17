const mongoose = require('mongoose');

const scoreCardSchema = new mongoose.Schema({
    // judgesId: { type: mongoose.Schema.Types.ObjectId, ref: 'Judge', required: true },
    eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
    criteria: { 
        criteriaId : {type: mongoose.Schema.Types.ObjectId, ref: 'Criteria', required: true} ,
        criteriascore: { type: Number, required: true },
    },
    contestantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contestant', required: true },
    // criteriascore: { type: Number, required: true },
    // Other score card fields
  });
  
  const ScoreCard = mongoose.model('ScoreCard', scoreCardSchema);

  module.exports = ScoreCard;