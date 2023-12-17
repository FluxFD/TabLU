const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const { Event } = require('../models/event.model');
const Contestant = require('../models/contestant.model');
const ScoreCard = require('../models/scorecard.model');
const Criteria = require('../models/criteria.model');

router.post('/scorecards', async (req, res) => {
  try {
    const scoreCardEntries = [];

    // Iterate over each object in the array
    for (const scoreData of req.body) {
      const { eventId, contestantId, criterias } = scoreData;
      console.log(eventId, contestantId, criterias);

      // Validate ObjectId for eventId and contestantId
      if (
        !mongoose.Types.ObjectId.isValid(eventId) ||
        !mongoose.Types.ObjectId.isValid(contestantId)
      ) {
        return res.status(400).json({ error: 'Invalid ObjectId(s) provided' });
      }

      // Check if the event and contestant exist
      const event = await Event.findById(eventId);
      const contestant = await Contestant.findById(contestantId);

      if (!event || !contestant) {
        return res.status(404).json({ error: 'Event or Contestant not found' });
      }
      
      const criteriaEntries = [];
      for (const criteria of criterias) {
        console.log(criteria['criteriaId']);
        // // Ensure that criteria is an object and has a property named 'criteriaId'
        // if (typeof criteria !== 'object' || !criteria.hasOwnProperty('criteriaId')) {
        //   return res.status(400).json({ error: 'Invalid criteria format' });
        // }
      
        // // Validate ObjectId for criteriaId
        // if (!mongoose.Types.ObjectId.isValid(criteria.criteriaId)) {
        //   return res.status(400).json({ error: 'Invalid ObjectId(s) provided for criteria' });
        // }
        // Check if the criteria exists
        const criteriaObj = await Criteria.findById(criteria['criteriaId']);
        if (!criteriaObj) {
          return res.status(404).json({ error: 'Criteria not found' });
        }

        // Create the score card entry
        const scoreCardEntry = new ScoreCard({
          eventId: event._id,
          criteria: {
            criteriaId: criteriaObj._id,
            criteriascore: criteria['scores']
          },
          contestantId: contestant._id,
        });

        // Save the score card entry
        const savedScoreCardEntry = await scoreCardEntry.save();

        // Add the saved entry to the array
        criteriaEntries.push(savedScoreCardEntry);
      }

      // Add the criteria entries to the main array
      scoreCardEntries.push({ eventId: event._id, contestantId: contestant._id, criteriaEntries });
    }

    res.status(201).json({ message: 'Score card entries created successfully', scoreCardEntries });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


  
router.get('/scorecards', async (req, res) => {
  try {
    const contestantId = req.query.contestantId;
    const eventId = req.query.eventId;
      console.log(contestantId, eventId);
    // Validate ObjectId for contestantId and eventId
    if (!mongoose.Types.ObjectId.isValid(contestantId) || !mongoose.Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ error: 'Invalid ObjectId provided for contestantId or eventId' });
    }

    // Fetch the contestant's scores for the specified event from the database
    const contestantScores = await ScoreCard.find({
      contestantId: new mongoose.Types.ObjectId(contestantId),
      eventId:new mongoose.Types.ObjectId(eventId),
    }).populate('criteria.criteriaId', 'criterianame'); // Assuming you want to populate criteria details

    // Check if the contestant scores exist
    if (!contestantScores || contestantScores.length === 0) {
      return res.status(404).json({ error: 'Scorecard not found' });
    }

    // Respond with the contestant's scores
    res.status(200).json({ scores: contestantScores });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});



  module.exports = router;