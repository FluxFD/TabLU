// upload.model.js
const Contestant = require('../models/contestant.model');
const mongoose = require('mongoose');

const uploadSchema = new mongoose.Schema({
  filename: String,
  path: String,
  originalname: String,
  mimetype: String,
  size: Number,
  contestantId:  { type: mongoose.Schema.Types.ObjectId, ref: 'Contestant' }
});

const Upload = mongoose.model('Upload', uploadSchema);

module.exports = Upload;
