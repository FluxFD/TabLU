//scorecard.route.js
const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const { Event } = require("../models/event.model");
const Contestant = require("../models/contestant.model");
const ScoreCard = require("../models/scorecard.model");
const Criteria = require("../models/criteria.model");
const Judge = require("../models/judges.model");
const User = require("../models/user.model");
const { io } = require("./socket");

router.post("/scorecards", async (req, res) => {
  try {
    const scoreCardEntries = [];
    let judge;
    // Iterate over each object in the array
    for (const scoreData of req.body) {
      const { eventId, contestantId, criterias, userId, subCriteriaList } =
        scoreData;
      // console.log(criterias.length);
      console.log(
        "Event Id:",
        eventId,
        "Contestant Id:",
        contestantId,
        "User Id:",
        userId
      );
      // Validate ObjectId for eventId and contestantId
      if (
        !mongoose.Types.ObjectId.isValid(userId) ||
        !mongoose.Types.ObjectId.isValid(eventId) ||
        !mongoose.Types.ObjectId.isValid(contestantId)
      ) {
        return res.status(400).json({ error: "Invalid ObjectId(s) provided" });
      }

      // Check if the event and contestant exist
      const event = await Event.findById(eventId);
      const contestant = await Contestant.findById(contestantId);
      const user = await User.findById(userId);

      if (!event || !contestant) {
        return res.status(404).json({ error: "Event or Contestant not found" });
      }
      const creator = await Event.findOne({ _id: event._id, user: user._id });
      if (creator) {
        return res
          .status(403)
          .json({ error: "Cannot submit scores as you are the creator" });
      }

      judge = await Judge.findOne({ eventId: event._id, userId: user._id });
      if (judge && judge.scoreSubmitted) {
        return res.status(403).json({ error: "Scores already submitted" });
      }

      const criteriaEntries = [];
      for (const criteria of criterias) {
        console.log(criteria["criteriaId"]);
        // // Ensure that criteria is an object and has a property named 'criteriaId'
        // if (typeof criteria !== 'object' || !criteria.hasOwnProperty('criteriaId')) {
        //   return res.status(400).json({ error: 'Invalid criteria format' });
        // }

        // // Validate ObjectId for criteriaId
        // if (!mongoose.Types.ObjectId.isValid(criteria.criteriaId)) {
        //   return res.status(400).json({ error: 'Invalid ObjectId(s) provided for criteria' });
        // }
        // Check if the criteria exists
        const criteriaObj = await Criteria.findById(criteria["criteriaId"]);
        if (!criteriaObj) {
          return res.status(404).json({ error: "Criteria not found" });
        }

        // Create the score card entry
        const scoreCardEntry = new ScoreCard({
          userId: user._id,
          eventId: event._id,
          criteria: {
            criteriaId: criteriaObj._id,
            criteriascore: criteria["scores"],
            rawScore: criteria["rawScore"],
            subCriteriaList: criteria["subCriteriaList"],
          },
          contestantId: contestant._id,
        });

        // Save the score card entry
        const savedScoreCardEntry = await scoreCardEntry.save();
        // Add the saved entry to the array
        criteriaEntries.push(savedScoreCardEntry);
      }

      // Add the criteria entries to the main array
      scoreCardEntries.push({
        eventId: event._id,
        contestantId: contestant._id,
        criteriaEntries,
      });
    }

    if (judge) {
      judge.scoreSubmitted = true;
      await judge.save();
    }
    res.status(201).json({
      message: "Score card entries created successfully",
      scoreCardEntries,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

router.get("/scorecards", async (req, res) => {
  try {
    const contestantId = req.query.contestantId;
    const eventId = req.query.eventId;
    const userId = req.query.userId;
    console.log(contestantId, eventId, userId);
    // Validate ObjectId for contestantId and eventId
    if (
      !mongoose.Types.ObjectId.isValid(contestantId) ||
      !mongoose.Types.ObjectId.isValid(eventId)
    ) {
      return res.status(400).json({
        error: "Invalid ObjectId provided for contestantId or eventId",
      });
    }

    // Fetch the contestant's scores for the specified event from the database
    const contestantScores = await ScoreCard.find({
      contestantId: new mongoose.Types.ObjectId(contestantId),
      eventId: new mongoose.Types.ObjectId(eventId),
    }).populate("criteria.criteriaId", "criterianame"); // Assuming you want to populate criteria details

    console.log(contestantScores);

    // Check if the contestant scores exist
    if (!contestantScores || contestantScores.length === 0) {
      return res.status(404).json({ error: "Scorecard not found" });
    }

    // Check if the userId is associated with the current event in the events collection
    const event = await Event.findOne({
      _id: new mongoose.Types.ObjectId(eventId),
      user: new mongoose.Types.ObjectId(userId),
    });

    if (!event) {
      return res.status(401).json({
        error:
          "Unauthorized: User does not have permission to access these scores",
      });
    }

    // Respond with the contestant's scores
    res.status(200).json({ scores: contestantScores });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

router.get("/judge-scorecards", async (req, res) => {
  try {
    const contestantId = req.query.contestantId;
    const eventId = req.query.eventId;
    const judgeId = req.query.judgeId; // New query parameter for judgeId
    const user = req.query.userId;

    console.log(contestantId, eventId, judgeId);

    // Validate ObjectId for contestantId, eventId, and judgeId
    if (
      !mongoose.Types.ObjectId.isValid(contestantId) ||
      !mongoose.Types.ObjectId.isValid(eventId) ||
      !mongoose.Types.ObjectId.isValid(judgeId)
    ) {
      return res.status(400).json({
        error:
          "Invalid ObjectId provided for contestantId, eventId, or judgeId",
      });
    }

    // Find the userId in the Judge collection using judgeId
    const judge = await Judge.findOne({
      _id: new mongoose.Types.ObjectId(judgeId),
    });

    // Check if the judge with the specified judgeId exists
    if (!judge) {
      return res.status(404).json({ error: "Judge not found" });
    }

    const userId = judge.userId;

    // Check if the userId is associated with the current event in the events collection
    // const event = await Event.findOne({ _id: new mongoose.Types.ObjectId(eventId), user: new mongoose.Types.ObjectId(user) });

    // if (!event) {
    //   return res.status(401).json({ error: 'Unauthorized: User does not have permission to access these scores' });
    // }

    // Fetch the contestant's scores for the specified event from the database
    const contestantScores = await ScoreCard.find({
      userId: new mongoose.Types.ObjectId(userId),
      eventId: new mongoose.Types.ObjectId(eventId),
    }).populate("criteria.criteriaId", "criterianame"); // Assuming you want to populate criteria details

    // Check if the contestant scores exist
    if (!contestantScores || contestantScores.length === 0) {
      return res.status(404).json({ error: "Scorecard not found" });
    }

    console.log("Contestant score:", contestantScores);

    // Respond with the contestant's scores
    res.status(200).json({ scores: contestantScores });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

// Add a new route to get the top three winners for a specific event
router.get("/winners/:eventId", async (req, res) => {
  try {
    const eventId = req.params.eventId;
    const event = await Event.findById(eventId);

    // Retrieve scorecards for the specific event
    const scorecards = await ScoreCard.find({ eventId })
      .populate("contestantId")
      .populate("criteria.criteriaId");
    console.log("hello");
    console.log(scorecards);
    const criterias = await Criteria.find({ eventId });
    const judges = await Judge.find({ eventId: eventId }).populate("userId");

    // Aggregate to calculate average score for each contestant
    const contestants = await ScoreCard.aggregate([
      {
        $match: { eventId: new mongoose.Types.ObjectId(eventId) },
      },
      {
        $group: {
          _id: "$contestantId",
          averageScore: {
            $sum: { $divide: ["$criteria.criteriascore", judges.length] },
          },
          // $sum: {
          //   $divide: [
          //     { $divide: ["$criteria.rawScore", criterias.length] },
          //     judges.length,
          //   ],
          // },
        },
      },
      {
        $sort: { averageScore: -1 }, // Sort by average score in descending order
      },
      {
        $lookup: {
          from: "contestants", // Assuming the contestants collection
          localField: "_id",
          foreignField: "_id",
          as: "contestantDetails",
        },
      },
      {
        $unwind: "$contestantDetails",
      },
      {
        $project: {
          _id: "$contestantDetails._id",
          name: "$contestantDetails.name",
          averageScore: 1,
        },
      },
    ]);

    io.emit("chartUpdate", { contestants });
    // Respond with the top three winners and their average scores
    const response = {
      eventName: event.event_name,
      eventStartDate: event.event_date,
      eventStartTime: event.event_time,
      criterias: criterias.map((criteria) => ({
        criteriaName: criteria.criterianame,
        criteriaPercentage: criteria.percentage,
        subCriteriaList: criteria.subCriteriaList,
      })),
      judges: judges.map((judge) => {
        const contestants = scorecards
          .filter(
            (scorecard) =>
              scorecard.userId.toString() === judge.userId._id.toString()
          )
          .map((scorecard) => ({
            contestantName: scorecard.contestantId.name,
            criteriaName: scorecard.criteria.criteriaId.criterianame,
            judgeRawScore: scorecard.criteria.rawScore,
            judgeCalculatedScore: scorecard.criteria.criteriascore,
            judgeSubCriteriaList: scorecard.criteria.subCriteriaList,
          }));

        return {
          judgeName: judge.userId.username,
          contestants: contestants,
        };
      }),
    };
    console.log("DSdsd");
    console.log(response);
    // Respond with the top three winners, event details, scorecards, contestants, and judges
    res.status(200).json({ contestants, response });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

router.get("/winners-pageants/:eventId", async (req, res) => {
  try {
    const eventId = req.params.eventId;

    // Retrieve event details
    const event = await Event.findById(eventId);

    // Retrieve scorecards for the specific event
    const scorecards = await ScoreCard.find({ eventId }).populate(
      "contestantId"
    );

    // Retrieve criteria for the specific event
    const criterias = await Criteria.find({ eventId });

    // Retrieve confirmed judges for the specific event
    const judges = await Judge.find({ eventId: eventId, isConfirm: true });

    const contestantAverageScores = {};

    // Calculate average score for each contestant based on judges' count
    scorecards.forEach((scorecard) => {
      const contestantId = scorecard.contestantId;
      let totalScore = 0;
      if (scorecard.criteria && typeof scorecard.criteria === "object") {
        // If scorecard.criteria is an object, assume it contains a single score
        totalScore = scorecard.criteria.criteriascore;
      }

      const averageScore = totalScore / judges.length;
      if (!isNaN(averageScore)) {
        // Ensure averageScore is a valid number
        contestantAverageScores[contestantId] = averageScore;
      }
    });

    // Log contestant average scores for debugging
    console.log(contestantAverageScores);

    const response = [];

    // Iterate over each criteria
    for (const criteria of criterias) {
      // Filter scorecards for the current criteria
      const criteriaScorecards = scorecards.filter((scorecard) => {
        console.log(
          "Scorecard criteria",
          scorecard.criteria.criteriaId.toString()
        );
        console.log("criteria Id", criteria._id.toString());
        return (
          scorecard.criteria.criteriaId.toString() === criteria._id.toString()
        );
      });

      console.log(criteriaScorecards);

      // Sort scorecards based on criteria score
      criteriaScorecards.sort(
        (a, b) => b.criteria.criteriascore - a.criteria.criteriascore
      );

      // Extract top three contestants for the current criteria
      const topThreeContestants = criteriaScorecards
        .slice(0, 3)
        .map((scorecard) => ({
          contestantId: scorecard.contestantId._id,
          contestantName: scorecard.contestantId.name,
          score: scorecard.criteria.criteriascore,
        }));

      // Add criteria details along with top three contestants to the response
      response.push({
        criteriaId: criteria._id,
        criteriaName: criteria.criterianame,
        topThreeContestants: topThreeContestants,
      });
    }

    console.log(response);

    // Respond with the top three winners, event details, scorecards, contestants, and judges
    res.status(200).json(response); // Return response as a list
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});


module.exports = router;
