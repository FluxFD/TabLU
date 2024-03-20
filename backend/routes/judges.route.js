const express = require('express');
const User = require('../models/user.model');
const Judge = require('../models/judges.model'); // Import the Judge model
const router = express.Router();
const mongoose = require('mongoose');


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

router.post('/update-confirmation', async (req, res) => {
  try {
    const { userId, isConfirm, eventId} = req.body;
    console.log(userId, isConfirm);

    // Validate input
    if (!userId) {
      return res.status(400).json({ message: 'Invalid request' });
    }
    
    // Update judge confirmation status
    const updatedJudge = await Judge.findOneAndUpdate({ userId: userId, eventId: eventId }, { isConfirm }, { new: isConfirm });
    if (!updatedJudge) {
      return res.status(404).json({ message: 'Judge not found' });
    }
    
    res.status(200).json({ message: 'Judge confirmation status updated successfully', judge: updatedJudge });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.delete('/reject-request/:userId/:eventId', async (req, res) => {
  try {
    const userId = req.params.userId;
    const eventId = req.params.eventId;
    console.log(userId, " ", eventId);
    // Delete judge entry with the specified userId and eventId
    await Judge.findOneAndDelete({ userId: userId, eventId: eventId });

    res.status(200).json({ message: 'Judge request for event ' + eventId + ' rejected and entry deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});


router.delete('/delete-judge/:judgeId', async (req, res) => {
  const judgeId = req.params.judgeId;
  try {
    const deletedJudge = await Judge.findOneAndDelete({ _id: judgeId });
  
    if (deletedJudge) {
      console.log('Judge deleted successfully:', deletedJudge);
      // Return a success response or perform additional actions if needed
      res.status(200).json({ message: 'Judge deleted successfully' });
    } else {
      console.log('Judge not found');
      // Return a not found response or handle accordingly
      res.status(404).json({ message: 'Judge not found' });
    }
  } catch (error) {
    console.error('Error deleting judge:', error);
    // Return an internal server error response or handle accordingly
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.get('/judges/:eventId/confirmed', async (req, res) => {
  try {
    const { eventId } = req.params;
    const isConfirm = true; // Assuming you want to fetch only those judges who have confirmed
    // Find judges by eventId and isConfirm status
    const judges = await Judge.find({ 
      eventId: eventId, 
      isConfirm: isConfirm,
    }).populate('userId');
    res.status(200).json(judges);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.get('/get-all-judges-events', async (req, res) => {
  try {
    const userId = req.query.userId;

    // Assuming you want to find judges based on the userId
    const events = await Judge.find({ userId: userId, isConfirm: true }).populate('eventId');

    console.log("events", events);
    // Send the response with the list of judges
    res.status(200).json({ events: events});
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});





module.exports = router;
