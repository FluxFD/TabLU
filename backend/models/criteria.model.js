const mongoose = require('mongoose');

const criteriaSchema = new mongoose.Schema({
  criterianame: String,
  percentage: String,
  subCriteriaList: Array,
  baseScore: String,
  isSpecialAwards: Boolean,
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event' },
});

const Criteria = mongoose.model('Criteria', criteriaSchema);

module.exports = Criteria;
