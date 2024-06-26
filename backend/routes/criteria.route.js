const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const Criteria = require("../models/criteria.model");
const Scorecard = require("../models/scorecard.model");
const { someFunction, Event } = require("../models/event.model");
const ScoreCard = require("../models/scorecard.model");
const e = require("express");

// API for adding new criteria
router.post("/criteria", async (req, res) => {
  try {
    const { criterianame, percentage, eventId, criteriaId, subCriteriaList, baseScore, isSpecialAwards } =
      req.body;

    // console.log("Criteria ID:", subCriteriaList);

    // Check if a criteria with the same name already exists
    if (criteriaId) {
      const existingCriteria = await Criteria.findOne({ _id: criteriaId });

      const associatedScoreCards = await ScoreCard.find({
        eventId: eventId,
        "criteria.criteriaId": criteriaId,
      });

      if (associatedScoreCards.length > 0) {
        return res
          .status(304)
          .json({
            error: "Cannot modify criteria, scores are already submitted.",
          });
      }

      existingCriteria.criterianame = criterianame;
      existingCriteria.percentage = percentage;
      existingCriteria.subCriteriaList = subCriteriaList;
      existingCriteria.baseScore = baseScore;
      existingCriteria.isSpecialAwards = isSpecialAwards;
      await existingCriteria.save();
      return res.status(200).json({ message: "Criteria edited successfully" });
    }

    const associatedEvent = await Event.findById(eventId);

    if (!associatedEvent) {
      return res.status(404).json({ error: "Event not found" });
    }

    // Check if the total percentage is already 100
    const totalPercentage = associatedEvent.criteria.reduce(
      (total, criteria) => {
        return total + parseFloat(criteria.percentage);
      },
      0
    );

    const newPercentage = parseFloat(percentage);

    if (totalPercentage + newPercentage > 100) {
      return res.status(400).json({ error: "Total percentage exceeds 100%" });
    }

    const newCriteria = new Criteria({
      criterianame,
      percentage,
      eventId,
      subCriteriaList,
      baseScore,
      isSpecialAwards,
    });

    const savedCriteria = await newCriteria.save();

    // Update event with the new criteria
    if (!Array.isArray(associatedEvent.criteria)) {
      associatedEvent.criteria = [];
    }

    console.log("Before pushing criteria:", associatedEvent.criteria);
    associatedEvent.criteria.push(savedCriteria);
    console.log("After pushing criteria:", associatedEvent.criteria);
    await associatedEvent.save();

    res
      .status(201)
      .json({ message: "Criteria added successfully", savedCriteria });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.message || "Internal Server Error" });
  }
});

router.get("/criteria/:eventId", async (req, res) => {
  const eventId = req.params.eventId;

  try {
    const filteredCriterias = await Criteria.find({ eventId });
    res.json(filteredCriterias);
  } catch (error) {
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// router.get('/criteria', async (req, res) => {
//   try {
//     const criteria = await Criteria.find();
//     res.json(criteria);
//   } catch (error) {
//     res.status(500).json({ error: 'Internal Server Error' });
//   }
// });

// API for deleting criteria
router.delete("/criteria", async (req, res) => {
  try {
    
    const eventId = req.query.eventId;
    const criteriaId = req.query.criteriaId;
    const associatedScoreCards = await ScoreCard.find({ eventId: eventId });
    // console.log(eventId, criteriaName);
    if (associatedScoreCards.length > 0) {
      return res
        .status(304)
        .json({
          error: "Cannot modify criteria; scores are already submitted.",
        });
    }
   

    // Find the criteria to delete
    const criteriaToDelete = await Criteria.findByIdAndDelete(criteriaId);

    if (!criteriaToDelete) {
      return res.status(404).json({ error: "Criteria not found" });
    }

    // Delete the criteria from the database
    res.json({ message: "Criteria deleted successfully" });
  } catch (error) {
    console.error("Error deleting criteria:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

module.exports = router;
