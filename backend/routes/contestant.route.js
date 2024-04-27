// contestant.route.js
const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const { someFunction, Event } = require("../models/event.model");
const Contestant = require("../models/contestant.model");
const Upload = require("../models/upload.model");
const multer = require("multer");
const User = require("../models/user.model");
const admin = require("firebase-admin");
const serviceAccount = require("./firebase-config");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "project-chat-d6cb6.appspot.com",
});

const bucket = admin.storage().bucket();

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
const path = require("path");

const storage = multer.memoryStorage();

var uploads = multer({
  storage: storage,
  fileFilter: function (req, file, callback) {
    console.log("Uploaded file:", file);
    if (
      file.mimetype == "image/png" ||
      file.mimetype == "image/jpg" ||
      file.mimetype == "image/jpeg" ||
      file.mimetype == "application/octet-stream"
    ) {
      callback(null, true);
    } else {
      console.log("Only jpg and png are supported");
      callback(null, false);
    }
  },
  /*limits:{
    fileSize: 1024 * 1024 *2
  }*/
});

// Middleware for "/upload" path
router.post("/uploads", uploads.single("profilePic"), (req, res) => {
  console.log("Uploaded file:", req.file);

  const filePath = req.file.path;

  const fileName = req.file.filename;

  res.json({ filePath, fileName });
});

router.post(
  "/upload-profilePic",
  uploads.single("profilePic"),
  async (req, res) => {
    try {
      // Extract user ID from the request body
      const userId = req.body.userId;
      const fileName = req.file.originalname;

      const fileUpload = bucket.file(fileName);
      const blobStream = fileUpload.createWriteStream({
        metadata: {
          contentType: req.file.mimetype,
        },
      });

      blobStream.on("error", (error) => {
        console.error(error);
        res
          .status(500)
          .json({ error: "Error uploading file to Firebase Storage" });
      });

      blobStream.on("finish", async () => {
        // File uploaded successfully.

        // Construct the Firebase Storage URL
        const fileUrl = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${fileName}?alt=media`;
        // Save the file URL to the user's profile in the database
        console.log(userId);
        await User.findOneAndUpdate(
          { _id: userId },
          { $set: { profilePic: fileUrl } },
          { new: true, upsert: true }
        );

        res.json({ success: true });
      });
      blobStream.end(req.file.buffer); // Send the file buffer to Firebase Storage
    } catch (error) {
      console.error("Error uploading profile picture:", error);
      res.status(500).json({ error: "Internal Server Error" });
    }
  }
);

router.get("/uploads/:contestantId", async (req, res) => {
  try {
    const contestantId = req.params.contestantId;
    console.log(contestantId);
    // Find the document in the uploads collection based on contestantId
    const upload = await Upload.findOne({ contestantId });

    if (!upload) {
      return res.status(404).json({ error: "Image not found" });
    }
    const filePaths = upload.path;
    // const filePath = filePaths.match(/[^\/\\]+$/)[0];
    const fileName = upload.filename;

    res.json({ filePaths, fileName });
  } catch (error) {
    console.error("Error fetching image path:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

let processedTokens = new Set();

router.post("/contestants", uploads.single("profilePic"), async (req, res) => {
  try {
    const {
      name,
      course,
      department,
      eventId,
      contestantId,
      contestantNumber,
    } = req.body;


    console.log("Name:", name);
    console.log("Course:", course);
    console.log("Department:", department);
    console.log("Event ID:", eventId);
    console.log("Contestant ID:", contestantId);
    console.log("Contestant Number:", contestantNumber);
    // Ensure that eventId is a valid ObjectId
    if (!mongoose.Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ error: "Invalid eventId" });
    }

    // Check if contestantId is provided and valid
    if (contestantId && !mongoose.Types.ObjectId.isValid(contestantId)) {
      return res.status(400).json({ error: "Invalid contestantId" });
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
        existingContestant.contestantNumber = contestantNumber; // Add contestNumber here

        // Change the image on the uploads
        let existingUpload = await Upload.findOne({
          contestantId: existingContestant._id,
        });

        if (existingUpload) {
          // Remove the existing file
          const fileToDelete = bucket.file(existingUpload.filename);
          await fileToDelete.delete();
        }

        // Upload the new file to Firebase Storage
        const fileUpload = bucket.file(req.file.originalname);
        const blobStream = fileUpload.createWriteStream({
          metadata: {
            contentType: req.file.mimetype,
          },
        });

        blobStream.on("error", (error) => {
          console.error(error);
          res
            .status(500)
            .json({ error: "Error uploading file to Firebase Storage" });
        });

        blobStream.on("finish", async () => {
          // File uploaded successfully.
          // Save the upload information to your database
          if (existingUpload) {
            // If existing upload record is found, update its information
            existingUpload.filename = req.file.originalname;
            existingUpload.path = `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${req.file.originalname}?alt=media`;
            existingUpload.originalname = req.file.originalname;
            existingUpload.mimetype = req.file.mimetype;
            existingUpload.size = req.file.size;

            // Save the updated upload information
            await existingUpload.save();
          } else {
            // If no existing upload record is found, create a new one
            existingUpload = new Upload({
              filename: req.file.originalname,
              path: `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${req.file.originalname}?alt=media`,
              originalname: req.file.originalname,
              mimetype: req.file.mimetype,
              size: req.file.size,
              contestantId: existingContestant._id,
            });

            // Save the new upload information
            await existingUpload.save();
          }

          // Update the contestant's profilePic
          existingContestant.profilePic = existingUpload._id;

          // Save the updated contestant information
          const updatedContestant = await existingContestant.save();
          return res.status(200).json(updatedContestant);
        });

        blobStream.end(req.file.buffer);
        return res.status(200); // Send the file buffer to Firebase Storage
      } else {
        // Update existing contestant
        existingContestant.name = name;
        existingContestant.course = course;
        existingContestant.department = department;
        existingContestant.contestantNumber = contestantNumber; // Add contestNumber here

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
      contestantNumber,
    });

    // Save the contestant to get the _id
    const savedContestant = await contestant.save();

    // Handle profilePic upload
    let savedUpload;

    if (req.file) {
      // Upload the file to Firebase Storage
      const fileUpload = bucket.file(req.file.originalname);
      const blobStream = fileUpload.createWriteStream({
        metadata: {
          contentType: req.file.mimetype,
        },
      });

      blobStream.on("error", (error) => {
        console.error(error);
        res
          .status(500)
          .json({ error: "Error uploading file to Firebase Storage" });
      });

      blobStream.on("finish", async () => {
        // File uploaded successfully.
        // Save the upload information to your database
        const upload = new Upload({
          filename: req.file.originalname,
          path: `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${req.file.originalname}?alt=media`,
          originalname: req.file.originalname,
          mimetype: req.file.mimetype,
          size: req.file.size,
          contestantId: savedContestant._id, // Use savedContestant._id here
        });

        savedUpload = await upload.save();

        // Update contestant's profilePic
        savedContestant.profilePic = savedUpload._id;
        await savedContestant.save();

        // Update event with the new contestant
        const event = await Event.findById(eventId);
        if (event) {
          event.contestants.push(savedContestant);
          await event.save();
        } else {
          return res.status(404).json({ error: "Event not found" });
        }

        // Send a success response with the created or updated contestant data
        res.status(201).json(savedContestant);
      });

      blobStream.end(req.file.buffer); // Send the file buffer to Firebase Storage
    } else {
      // Update event with the new contestant (no file upload)
      const event = await Event.findById(eventId);
      if (event) {
        event.contestants.push(savedContestant);
        await event.save();
      } else {
        return res.status(404).json({ error: "Event not found" });
      }

      // Send a success response with the created or updated contestant data
      res.status(201).json(savedContestant);
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

router.put(
  "/contestants/:id",
  uploads.single("profilePic"),
  async (req, res) => {
    const { name, course, department, eventId } = req.body;

    try {
      let profilePicPath;

      // Check if a file was uploaded
      if (req.file && req.file.path) {
        profilePicPath = req.file.path;
      }

      const contestantId = req.params.id;

      // Check if the provided id is not "null" or an invalid ObjectId
      if (
        contestantId === "null" ||
        !mongoose.Types.ObjectId.isValid(contestantId)
      ) {
        return res.status(400).json({ error: "Invalid contestant ID" });
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
        return res.status(404).json({ error: "Contestant not found" });
      }

      res.status(200).json(updatedContestant);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: err.message });
    }
  }
);

router.get("/get-contestants/:eventId", async (req, res) => {
  try {
    const { eventId } = req.params;
    const contestants = await Contestant.find({ eventId })
      .populate("profilePic")
      .exec();

    // Trim the path to get only the file name
    const trimmedContestants = contestants.map((contestant) => {
      return {
        ...contestant.toObject(),
        profilePic: contestant.profilePic ? contestant.profilePic.path : null,
      };
    });

    res.json(trimmedContestants);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

router.delete("/delete-contestant/:contestandId", async (req, res) => {
  const contestantId = req.params.contestandId;
  console.log(contestantId);

  try {
    // Check if the provided id is not "null" or an invalid ObjectId
    if (
      contestantId === "null" ||
      !mongoose.Types.ObjectId.isValid(contestantId)
    ) {
      return res.status(400).json({ error: "Invalid contestant ID" });
    }

    // Find the contestant by ID
    const contestant = await Contestant.findById(contestantId);

    if (!contestant) {
      return res.status(404).json({ error: "Contestant not found" });
    }

    // Delete associated profile picture
    if (contestant.profilePic) {
      await Upload.findByIdAndDelete(contestant.profilePic);
    }

    // Delete the contestant
    await Contestant.findByIdAndDelete(contestantId);

    res.status(200).json({ message: "Contestant deleted successfully" });
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
