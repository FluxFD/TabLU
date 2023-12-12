//notification.route.js
const express = require('express');
const router = express.Router();
const httpStatus = require('http-status-codes');
const mongoose = require('mongoose');
const Notification = require('../models/notification.model');
const { Event } = require('../models/event.model');

// POST route for creating a notification
router.post('/notifications', async (req, res) => {
  try {
    // Extract necessary information from the request body
    const { body, userId, receiver, type } = req.body;

    // Create a new notification document
    const newNotification = new Notification({
      userId: userId,
      body: body,
      receiver: receiver,
      type: type,
    });

    // Save the notification to the database
    const savedNotification = await newNotification.save();

    // Respond with the created notification
    res.status(201).json({
      message: 'Notification created successfully',
      notification: savedNotification,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.get('/get-notifications/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    if (!userId) {
      return res.status(400).json({ error: 'User ID is required' });
    }

    // Fetch notifications where the receiver field matches the provided userId
    const notifications = await Notification.find({ receiver: userId });

    res.status(200).json(notifications);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});



router.get('/notifications/:eventId', async (req, res) => {
  try {
    const eventId = req.params.eventId;
    if (!eventId || typeof eventId !== 'string') {
      return res.status(httpStatus.BAD_REQUEST).json({ error: 'Invalid event ID' });
    }

    let fetchedEvent;

    if (eventId === 'default') {
      fetchedEvent = {
        _id: new mongoose.Types.ObjectId(),
        event_name: 'Default Event Name',
      };
    } else if (mongoose.Types.ObjectId.isValid(eventId)) {
      const objectId = new mongoose.Types.ObjectId(eventId);
      fetchedEvent = await Event.findOne({ _id: objectId }).populate('criteria');

      if (!fetchedEvent || !fetchedEvent._id) {
        return res.status(httpStatus.NOT_FOUND).json({ error: 'Event not found' });
      }
      
    } else if (eventId === '') {
      fetchedEvent = {
        _id: mongoose.Types.ObjectId(),
        event_name: 'Default Event Name',
      };
    } else {
      return res.status(httpStatus.NOT_FOUND).json({ error: 'Invalid event ID' });
    }



    const modifiedResponse = {
      "eventId": fetchedEvent._id || mongoose.Types.ObjectId(),
      "eventName": fetchedEvent.event_name ?? 'Default Event Name',
      "user": fetchedEvent.user ?? 'Default User',
    };
    console.log(modifiedResponse);
    
    return res.status(httpStatus.OK).json(modifiedResponse);
  } catch (err) {
    console.error('Error in /events/:eventId:', err);
    return res.status(httpStatus.INTERNAL_SERVER_ERROR).json({ error: 'Internal Server Error', details: err.message });
  }
  
});

router.delete('/delete-notification/:userId', async (req, res) => {
  try {
    const userId = req.params.userId;

    // Delete notification document with the specified userId
    await Notification.findOneAndDelete({ userId: userId });

    res.status(200).json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error' });
  }
});
  

module.exports = router;
