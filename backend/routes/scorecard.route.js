const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const Contestant = require('../models/contestant.model');
const Criteria = require('../models/criteria.model');

router.post('/scorecards', async (req, res) => {
    try {
      const { eventId, criteriaId, contestantId, criteriascore } = req.body;
  
      // Validate ObjectId for eventId, criteriaId, and contestantId
      if (
        !mongoose.Types.ObjectId.isValid(eventId) ||
        !mongoose.Types.ObjectId.isValid(criteriaId) ||
        !mongoose.Types.ObjectId.isValid(contestantId)
      ) {
        return res.status(400).json({ error: 'Invalid ObjectId(s) provided' });
      }
  
      // Check if the event, criteria, and contestant exist
      const event = await Event.findById(eventId);
      const criteria = await Criteria.findById(criteriaId);
      const contestant = await Contestant.findById(contestantId);
  
      if (!event || !criteria || !contestant) {
        return res.status(404).json({ error: 'Event, Criteria, or Contestant not found' });
      }
  
      // Create the score card entry
      const scoreCardEntry = new ScoreCard({
        eventId: event._id,
        criteriaId: criteria._id,
        contestantId: contestant._id,
        criteriascore,
      });
  
      // Save the score card entry
      const savedScoreCardEntry = await scoreCardEntry.save();
  
      res.status(201).json({ message: 'Score card entry created successfully', savedScoreCardEntry });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  