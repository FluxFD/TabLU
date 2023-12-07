const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const Criteria = require('../models/criteria.model');
const { someFunction, Event } = require('../models/event.model');
  
  // API for adding new criteria
  router.post('/criteria', async (req, res) => {
    try {
      const { criterianame, percentage, eventId } = req.body;
      const newCriteria = new Criteria({ 
        criterianame, 
        percentage, 
        eventId
      });
  
      const associatedEvent = await Event.findById(eventId);
      if (!associatedEvent) {
        return res.status(404).json({ error: 'Event not found' });
      }
  
      const savedCriteria = await newCriteria.save();
  
      // Update event with the new criteria
      if (!Array.isArray(associatedEvent.criteria)) {
        associatedEvent.criteria = [];
      }

      console.log('Before pushing criteria:', associatedEvent.criteria);
      associatedEvent.criteria.push(savedCriteria);
      console.log('After pushing criteria:', associatedEvent.criteria);
      await associatedEvent.save();
  
      res.status(201).json({ message: 'Criteria added successfully', savedCriteria });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message || 'Internal Server Error' });
    }
  });
  
  
  router.get('/criteria', async (req, res) => {
    try {
      const criteria = await Criteria.find();
      res.json(criteria);
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });
  
  // API for deleting criteria
  /*router.delete('/criteria/:id', async (req, res) => {
    try {
      const { id } = req.params;
      await Criteria.findByIdAndDelete(id);
      res.json({ message: 'Criteria deleted successfully' });
    } catch (error) {
      res.status(500).json({ error: 'Internal Server Error' });
    }
  });*/

  

  module.exports = router;