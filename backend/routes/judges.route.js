const express = require('express');
const Judge = require('../models/judges.model'); // Import the Judge model
const router = express.Router();

// POST route for adding a judge
router.post('/judges', async (req, res) => {
  const { eventId, userId } = req.body;

  try {
    // Check if the judge already exists for the given event and user
    const existingJudge = await Judge.findOne({ eventId: eventId, userId: userId });

    if (existingJudge) {
      return res.status(400).json({ message: 'Judge already assigned to this event' });
    }

    // If the judge doesn't exist, create a new judge
    const newJudge = new Judge({
      eventId: eventId,
      userId: userId,
      // Add any other judge-specific fields as needed
    });

    // Save the new judge to the database
    await newJudge.save();

    res.status(201).json({ message: 'Judge added successfully', judge: newJudge });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

module.exports = router;
