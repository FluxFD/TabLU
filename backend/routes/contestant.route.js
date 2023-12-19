// contestant.route.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose'); 
const { someFunction, Event } = require('../models/event.model');
const Contestant = require('../models/contestant.model');
const Upload = require('../models/upload.model');
const multer = require('multer');
const fs = require('fs');


// const contestantSchema = new mongoose.Schema({
//   name: { type: String, required: true },
//   course: { type: String, required: true },
//   department: { type: String, required: true },
//   profilePic: String,
//   eventId: { type: mongoose.Schema.Types.ObjectId, ref: 'Event', required: true },
//   /*criteriascore: { type: Int, required: true },
//   criterianame: { type: String, ref: 'Criteria', required: true },
//   criteriaId: { type: mongoose.Schema.Types.ObjectId, ref: 'Criteria', required: true }*/

//   // other fields
// });



//Responsible for saving images to  the database
const path = require('path');

var storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadPath = path.join(__dirname, 'uploads/');
    cb(null, uploadPath);
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
      file.mimetype == "image/jpeg" ||
      file.mimetype == "application/octet-stream"
    
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

router.get('/uploads/:contestantId', async (req, res) => {
  try {

    const contestantId = req.params.contestantId;
    console.log(contestantId);
    // Find the document in the uploads collection based on contestantId
    const upload = await Upload.findOne({ contestantId });

    if (!upload) {
      return res.status(404).json({ error: 'Image not found' });
    }
    const filePaths = upload.path
    const filePath = filePaths.match(/[^\/\\]+$/)[0];
    const fileName = upload.filename;

    res.json({ filePath, fileName });
  } catch (error) {
    console.error('Error fetching image path:', error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


router.post('/contestants', uploads.single('profilePic'), async (req, res) => {
  try {
    const { name, course, department, eventId, contestantId } = req.body;

    // Ensure that eventId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ error: 'Invalid eventId' });
    }

    // Check if contestantId is provided and valid
    if (contestantId && !mongoose.Types.ObjectId.isValid(contestantId)) {
      return res.status(400).json({ error: 'Invalid contestantId' });
    }

    let existingContestant;

    if (contestantId) {
      // Check if contestantId already exists
      existingContestant = await Contestant.findById(contestantId);

      if (existingContestant && req.file) {
        // Update existing contestant
        existingContestant.name = name;
        existingContestant.course = course;
        existingContestant.department = department;
    
        // Change the image on the uploads
        const existingUpload = await Upload.findOne({ contestantId: existingContestant._id });
    
        if (existingUpload) {
            // Remove the existing file
            fs.unlinkSync(existingUpload.path);
    
            // Update information for the new file
            existingUpload.filename = req.file.filename;
            existingUpload.path = req.file.path;
            existingUpload.originalname = req.file.originalname;
            existingUpload.mimetype = req.file.mimetype;
            existingUpload.size = req.file.size;
    
            // Save the updated upload information
            await existingUpload.save();
        }
    
        const updatedContestant = await existingContestant.save();
        return res.status(200).json(updatedContestant);
    } else {
        // Update existing contestant
        existingContestant.name = name;
        existingContestant.course = course;
        existingContestant.department = department;
    
        const updatedContestant = await existingContestant.save();
        return res.status(200).json(updatedContestant);
    }
    }

    // Create a new contestant
    const contestant = new Contestant({
      name,
      course,
      department,
      profilePic: null, // Set to null initially
      eventId,
    });

    // Save the contestant to get the _id
    const savedContestant = await contestant.save();

    // Handle profilePic upload
    let savedUpload;
    if (req.file) {
      const upload = new Upload({
        filename: req.file.filename,
        path: req.file.path,
        originalname: req.file.originalname,
        mimetype: req.file.mimetype,
        size: req.file.size,
        contestantId: savedContestant._id, // Use savedContestant._id here
      });

      savedUpload = await upload.save();

      // Update contestant's profilePic
      savedContestant.profilePic = savedUpload._id;
      await savedContestant.save();
    }

    // Update event with the new contestant
    const event = await Event.findById(eventId);
    if (event) {
      event.contestants.push(savedContestant);
      await event.save();
    } else {
      return res.status(404).json({ error: 'Event not found' });
    }

    // Send a success response with the created or updated contestant data
    res.status(201).json(savedContestant);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
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

router.get('/get-contestants/:eventId', async (req, res) => {
  try {
    const { eventId } = req.params;
    const contestants = await Contestant.find({ eventId }).populate('profilePic').exec();
    
    // Trim the path to get only the file name
    const trimmedContestants = contestants.map(contestant => {
      return {
        ...contestant.toObject(),
        profilePic: contestant.profilePic ? path.basename(contestant.profilePic.path) : null,
      };
    });

    res.json(trimmedContestants);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
  }
});


router.delete('/delete-contestant/:contestandId', async (req, res) => {
  const contestantId = req.params.contestandId;
  console.log(contestantId);

  try {
    // Check if the provided id is not "null" or an invalid ObjectId
    if (contestantId === "null" || !mongoose.Types.ObjectId.isValid(contestantId)) {
      return res.status(400).json({ error: 'Invalid contestant ID' });
    }

    // Find the contestant by ID
    const contestant = await Contestant.findById(contestantId);

    if (!contestant) {
      return res.status(404).json({ error: 'Contestant not found' });
    }

    // Delete associated profile picture
    if (contestant.profilePic) {
      await Upload.findByIdAndDelete(contestant.profilePic);
    }

    // Delete the contestant
    await Contestant.findByIdAndDelete(contestantId);

    res.status(200).json({ message: 'Contestant deleted successfully' });
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
