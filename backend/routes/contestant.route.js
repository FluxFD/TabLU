const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const { someFunction, Event } = require('../models/event.model');
const Contestant = require('../models/contestant.model');
const multer = require('multer');

const contestantSchema = new mongoose.Schema({
  name: { type: String, required: true },
  course: { type: String, required: true },
  department: { type: String, required: true },
  profilePic: String,
  eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
  /*criteriascore: { type: Int, required: true },
  criterianame: { type: String, ref: 'Criteria', required: true },
  criteriaId: { type: mongoose.Schema.Types.ObjectId, ref: 'Criteria', required: true }*/

  // other fields
});



//Responsible for saving images to  the database
var storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + '-' + file.originalname);
  },
});

var uploads = multer({
  storage: storage,
  fileFilter: function(req, file, callback) {
    console.log('Uploaded file:', file);
    if (
      file.mimetype == "image/png" ||
      file.mimetype == "image/jpg" ||
      file.mimetype == "image/jpeg"
    
    ) {
      callback(null, true);
    } else {
      console.log('Only jpg and png are supported');
      callback(null, false);
    }
  },
  /*limits:{
    fileSize: 1024 * 1024 *2
  }*/
});

// Middleware for "/upload" path
router.post('/uploads', uploads.single('profilePic'), (req, res) => {
  console.log('Uploaded file:', req.file);

  const filePath = req.file.path;
  const fileName = req.file.filename;

  res.json({ filePath, fileName });
});

router.post('/contestants', uploads.single('profilePic'), async (req, res) => {
  try {
    const { name, course, department, eventId } = req.body;

    // Ensure that eventId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ error: 'Invalid eventId' });
    }

    const profilePicPath = req.file ? req.file.path : undefined;
    
    console.log('Profile Pic Path:', profilePicPath);

    const contestant = new Contestant({
      name,
      course,
      department,
      profilePic: profilePicPath,
      eventId,
    /*criteriaId,
    criterianame,
    criteriascore,*/
    });

    const savedContestant = await contestant.save();
    console.log('Saved Contestant:', savedContestant);

    const event = await Event.findById(eventId);
    if (event) {
      event.contestants.push(savedContestant);
      await event.save();
    } else {
      // Handle the case where the event is not found
      return res.status(404).json({ error: 'Event not found' });
    }

    // Send a success response
    res.status(201).json(savedContestant);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.get('/contestants', (req, res) => {

  Contestant.find({}, (err, contestants) => {
    if (err) {
      res.status(500).json({ error: err.message });
    } else {
      res.status(200).json(contestants);
    }
  });
});

router.put('/contestants/:id', uploads.single('profilePic'), async (req, res) => {
  const { name, course, department, eventId } = req.body;

  try {
    let profilePicPath;

    // Check if a file was uploaded
    if (req.file && req.file.path) {
      profilePicPath = req.file.path;
    }

    const contestantId = req.params.id;

    // Check if the provided id is not "null" or an invalid ObjectId
    if (contestantId === "null" || !mongoose.Types.ObjectId.isValid(contestantId)) {
      return res.status(400).json({ error: 'Invalid contestant ID' });
    }

    const updatedContestant = await Contestant.findByIdAndUpdate(
      contestantId,
      {
        name,
        course,
        department,
        profilePic: profilePicPath,
        eventId,
      /*  criteriaId,
        criterianame,
        criteriascore*/ 
      },
      { new: true }
    );

    if (!updatedContestant) {
      return res.status(404).json({ error: 'Contestant not found' });
    }

    res.status(200).json(updatedContestant);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});




router.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: err.message });
});

module.exports = router;
