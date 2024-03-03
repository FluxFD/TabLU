//scorecard.model.js
const mongoose = require('mongoose');

const scoreCardSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
    criteria: { 
        criteriaId : {type: mongoose.Schema.Types.ObjectId, ref: 'Criteria', required: true} ,
        rawScore: {type: Number, required: true},
        criteriascore: { type: Number, required: true },
        subCriteriaList: {type: Array},
    },
    contestantId: { type: mongoose.Schema.Types.ObjectId, ref: 'Contestant', required: true },
    // criteriascore: { type: Number, required: true },
    // Other score card fields
  });
  
  const ScoreCard = mongoose.model('ScoreCard', scoreCardSchema);

  module.exports = ScoreCard;