require('dotenv').config();
const express = require('express');
const router = express.Router();
const { someFunction, findEventByAccessCode, Event } = require('../models/event.model');
const Contestant = require('../models/contestant.model');
const Criteria = require('../models/criteria.model'); 
const httpStatus = require('http-status-codes');
const mongoose = require('mongoose');
const passport = require('../passport-config').passport; 
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET || 'defaultSecretKey';
const JwtStrategy = require('passport-jwt').Strategy;
const ExtractJwt = require('passport-jwt').ExtractJwt;
const User = require('../models/user.model');


//module.exports = verifyToken;

/*passport.serializeUser((user, done) => {
  done(null, user.id);
});

passport.deserializeUser((id, done) => {
  User.findById(id, (err, user) => {
    done(err, user);
  });
});
*/
// Define JWT strategy for Passport
console.log('JWT Secret:', process.env.JWT_SECRET);
/*
passport.use(new JwtStrategy({
  jwtFromRequest: ExtractJwt.fromHeader('authorization'), // Change this line
  secretOrKey: process.env.JWT_SECRET || 'your_hardcoded_secret',
}, async (jwtPayload, done) => {
  try {
    console.log('JwtStrategy - JWT Payload:', jwtPayload);
    const user = await User.findById(jwtPayload.userId);

    if (user) {
      console.log('User found:', user);
      return done(null, user);
    } else {
      console.log('User not found');
      return done(null, false);
    }
  } catch (error) {
    console.error('Error finding user by ID:', error);
    return done(error, false);
  }
}));*/

const verifyToken = (req, res, next) => {
  console.log('Verifying token...');
  const token = req.headers.authorization;
  console.log('Request Headers:', req.headers);
  console.log('Token:', token);

  if (!token) {
    return res.status(401).json({ message: 'Unauthorized: Missing token' });
  }

  const tokenWithoutPrefix = token.replace('Bearer ', '');

jwt.verify(tokenWithoutPrefix, secretKey, async (err, decoded) => {
  if (err) {
    console.error('Error verifying token:', err);
    return res.status(401).json({ message: 'Unauthorized: Invalid token' });
  }

  // Token is valid
  console.log('Decoded Token:', decoded);

  // Fetch the user object from the database based on the userId
  const user = await User.findById(decoded.userId);

  if (user) {
    // Attach the user object to the request
    req.user = user;
    req.userId = decoded.userId;
    next();
  } else {
    console.log('User not found');
    return res.status(401).json({ message: 'Unauthorized: Invalid user' });
  }
});

};

router.get('/protected-route', verifyToken, (req, res) => {
  console.log('Inside protected route');
  console.log('User ID from verifyToken middleware:', req.user._id);

  // Ensure that req.headers.authorization exists
  if (!req.headers.authorization) {
    console.log('No Authorization header found in the request');
    return res.status(401).json({ message: 'Unauthorized: Missing token' });
  }

  // Your existing logic for the protected route...
  res.json({ message: 'You are authenticated!' });
});


// the findEventByAccessCode located here

function generateRandomAccessCode(length) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  let accessCode = '';
  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * charset.length);
    accessCode += charset[randomIndex];
  }
  return accessCode;
}

router.post('/events', verifyToken, async (req, res) => {
  console.log('Request Headers:', req.headers);


  try {
    console.log('Entered /events route');

    // Ensure that required fields are present in the request
    const { eventName, eventCategory, eventVenue, eventOrganizer, eventDate, eventTime } = req.body;

    console.log('Received Data:', { eventName, eventCategory, eventVenue, eventOrganizer, eventDate, eventTime });

    if (!eventName || !eventCategory || !eventVenue || !eventOrganizer || !eventDate || !eventTime) {
      return res.status(httpStatus.BAD_REQUEST).json({ error: 'Incomplete data. Please provide all required fields.' });
    }

    // Verify user authentication
    console.log('User ID from verifyToken middleware:', req.userId);

    if (!req.user || !req.user._id) {
      console.log('Unauthorized: User ID not available');
      return res.status(httpStatus.UNAUTHORIZED).json({ error: 'Unauthorized: User ID not available' });
    }

    // Generate an access code
    const accessCode = generateRandomAccessCode(8);

    // Ensure that req.user and req.user._id are defined before accessing their properties
    const userId = req.user._id;

    // Create a new event
    const event = new Event({
      event_name: eventName,
      event_category: eventCategory,
      event_venue: eventVenue,
      event_organizer: eventOrganizer,
      event_date: eventDate,
      event_time: eventTime,
      access_code: accessCode,
      user: userId,
    });

    console.log('New Event Object:', event);

    try {
      console.log('About to save event');

      // Insert this logging statement
      console.log('Before save - Event:', event);

      // Save the event to the database
      await event.save();

      console.log('Event saved successfully.');
      return res.status(httpStatus.CREATED).send(event);
    } catch (saveError) {
      console.error('Error saving event:', saveError);
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).json({ error: 'Failed to create event', details: saveError.message });
    }
  } catch (err) {
    console.error('Error creating event:', err);
    return res.status(httpStatus.INTERNAL_SERVER_ERROR).json({ error: 'Failed to create event', details: err.message });
  }
});

router.get('/events', async (req, res) => {
  try {
   
    const userId = req.user._id;
    const events = await Event.find({ user: userId }).populate('contestants').populate('criteria').exec();

    // Ensure that the user field is populated in the events
    const populatedEvents = await Promise.all(
      events.map(async (event) => {
        // Populate the 'user' field for each event
        await event.populate('user').execPopulate();
        return event;
      })
    );

    return res.status(httpStatus.OK).send(populatedEvents);
  } catch (err) {
    console.error(err);
    return res.status(httpStatus.INTERNAL_SERVER_ERROR).send(err.message);
  }
});

router.get('/events/:eventId', async (req, res) => {
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
      eventId: fetchedEvent._id || mongoose.Types.ObjectId(),
      accessCode: fetchedEvent.access_code,
      eventName: fetchedEvent.event_name ?? 'Default Event Name',
      eventCategory: fetchedEvent.event_category ?? 'Default Event Category',
      eventVenue: fetchedEvent.event_venue ?? 'Default Event Venue',
      eventOrganizer: fetchedEvent.event_organizer ?? 'Default Event Organizer',
      eventTime: fetchedEvent.event_time ?? 'Default Event Time',
      eventDate: fetchedEvent.event_date ?? 'Default Event Date',
      contestant: fetchedEvent.contestants,
      criteria: fetchedEvent.criteria,
    };

    return res.status(httpStatus.OK).json(modifiedResponse);
  } catch (err) {
    console.error('Error in /events/:eventId:', err);
    return res.status(httpStatus.INTERNAL_SERVER_ERROR).json({ error: 'Internal Server Error', details: err.message });
  }
  
});

router.get('/events/:eventId/contestants', async (req, res) => {
  try {
    const eventId = req.params.eventId;
    const event = await Event.findById(eventId)
    .populate('contestants')
    .populate('criteria');
  

    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }

    const contestants = event.contestants || [];

    res.status(200).json(contestants);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/events/:eventId/criteria', async (req, res) => {
  const eventId = req.params.eventId;

  try {
    const event = await Event.findById(eventId)
  .populate('contestants')
  .populate('criteria');


    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }

    const criteria = event.criteria || [];

    res.status(200).json(criteria);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/latest-event-id', async (req, res) => {
  try {
    // Retrieve the latest event by sorting based on creation date
    const latestEvent = await Event.findOne().sort({ _id: -1 });

    if (latestEvent) {
      // Log the latest event details for debugging
      console.log('Latest Event:', latestEvent);

      // Return the latest event ID in the response
      res.json({ eventData: { eventId: String(latestEvent._id) } });

    } else {
      // Log a message if no events are found (for debugging)
      console.log('No events found.');

      // Return null if no events are found
      res.json({ eventId: null });
    }
  } catch (err) {
    // Log the error for debugging
    console.error('Error in /latest-event-id:', err);

    // Return a meaningful error response
    res.status(500).json({ error: 'Failed to retrieve latest event ID', details: err.message });
  }
});


router.get('/pageant-events', async (req, res) => {
  try {
    const pageantEvents = await Event.find({ event_category: "Pageants" });

    console.log('Pageant Events:', pageantEvents);

    res.status(200).json(pageantEvents);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});


router.get('/talent-events', async (req, res) => {
  try {
    const talentShowEvents = await Event.find({ event_category: "Talent Shows" });

    console.log('Talent Shows:', talentShowEvents);

    res.status(200).json(talentShowEvents);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});





router.get('debate-events', async (req, res) => {
  try {
    const debateEvents = await Event.find({ event_category: "Debates" });

    console.log('Debates:', debateEvents);

    res.status(200).json(debateEvents);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});





router.get('/artcontest-events', async (req, res) => {
  try {
    const artcontestEvents = await Event.find({ event_category: "Art Contests" })

    console.log('Art Contests:', artcontestEvents);

    res.status(200).json(artcontestEvents);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Internal server error', error: error.message });
  }
});

router.delete('/events/:eventId', async (req, res) => {
  const eventId = req.params.eventId;
  console.log('Received DELETE request for eventId:', eventId);
  try {
    const deletedEvent = await Event.findByIdAndDelete(eventId);

    if (!deletedEvent) {
      console.log('Event not found');
      return res.status(404).json({ error: 'Event not found' });
    }

    console.log('Event deleted:', deletedEvent);
    res.status(200).json({ message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Error deleting event:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

router.get('/events/:accessCode', async (req, res) => {
  try {
    const accessCode = req.params.accessCode;
    console.log('Access Code Received:', accessCode);

    if (!accessCode || accessCode.trim() === '') {
      console.error('Invalid or missing access code');
      return res.status(400).json({ error: 'Invalid or missing access code' });
    }

    // Use the static method to find the event by access code
    const event = await Event.findEventByAccessCode(accessCode);

    if (!event) {
      console.error('Event not found');
      return res.status(404).json({ error: 'Event not found' });
    }

    return res.json([event]);
  } catch (error) {
    console.error('Error fetching event:', error);
    console.error(error.stack);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

module.exports = 
router, 
verifyToken;
