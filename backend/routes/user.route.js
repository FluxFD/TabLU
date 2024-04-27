const express = require("express");
const User = require("../models/user.model");
const router = express.Router();
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const validator = require("validator");
const nodemailer = require("nodemailer");
const Judge = require("../models/judges.model");
const jwt = require("jsonwebtoken");
const secretKey = process.env.JWT_SECRET || "defaultSecretKey";
const emailUser = "avbreyrd@gmail.com"; // process.env.EMAIL_USER;
const emailPassword = "PasswordniAubrey016880"; // process.env.EMAIL_PASSWORD
const UserVerification = require("../models/UserVerification.model");

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
  const token = req.headers.authorization;

  if (!token) {
    return res.status(401).json({ message: "Unauthorized: Missing token" });
  }

  jwt.verify(token, secretKey, (err, decoded) => {
    if (err) {
      return res.status(401).json({ message: "Unauthorized: Invalid token" });
    }

    req.userId = decoded.userId;
    next();
  });
};

router.post("/signin", async (req, res) => {
  const { username, email, password } = req.body;
  console.log(req.body);
  try {
    // Check if a user with the given email or username already exists
    const existingUser = await User.findOne({
      $or: [{ username: username }, { email: email }],
      isEmailVerified: true,
    });

    const existingNotVerifiedUser = await User.findOne({
      $or: [{ username: username }, { email: email }],
      isEmailVerified: false,
    });

    if (!validator.isEmail(email)) {
      return res
        .status(400)
        .json({ message: "Invalid email address", error: "email" });
    }

    if (existingUser) {
      return res.status(401).json({
        message: "Username or Email already exists",
        error: "username",
      });
    }

    const verificationCode = generateVerificationCode();

    if (existingNotVerifiedUser) {
      existingNotVerifiedUser.verificationCode = verificationCode;
      existingNotVerifiedUser.username = username;
      existingNotVerifiedUser.email = email;
      existingNotVerifiedUser.password = password;
      existingNotVerifiedUser.save();
    } else {
      const newUser = new User({
        username: username,
        email: email,
        password: password,
        verificationCode: verificationCode,
      });
      // Save the new user to the database
      newUser.isEmailVerified = false;
      await newUser.save();
    }

    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 587,
      secure: false,
      requireTLS: true,
      auth: {
        user: "group5tablu@gmail.com",
        pass: "dtnu elfi gdmy amro",
      },
      tls: {
        ciphers: "SSLv3",
        minVersion: "TLSv1.2",
      },
    });

    // Email content
    const mailOptions = {
      from: "group5tablu@gmail.com",
      to: email,
      subject: "Verify you account with TabLU",
      html: `<p>Hi there <strong>${email}</strong></p>
       <p>Thanks for joining TabLU! Get Ready to Crush Your Event Planning!</p>
      <p>To complete your registration and unlock all the features of TabLU, simply verify your email address using the following code:</p>
      <h2>${verificationCode}</h2>
    <p>Just enter this code in the designated field within the TabLU app, and your email will be verified. Then, you're good to go!</p>
    <p><strong>Didn't request this email?</strong></p>
    <p>No worries! If you didn't intend to create a TabLU account, you can simply disregard this message. Your privacy is important to us, and we won't send you any further messages unless you confirm your email address.
    </p>
    <p>Welcome to the TabLU community!</p>
    <p>Best regards</p>
    <p>"The TabLU Team"</p>
  
      `,
    };

    await transporter.sendMail(mailOptions);

    const user = await User.findOne({ username: username });

    const token = jwt.sign(
      { userId: user._id, email: user.email, username: user.username },
      secretKey
    );

    res.status(201).json({
      message: "User registered successfully",
      user: user,
      token: token,
      verificationCode: verificationCode,
    });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ message: "Internal server error", error: error.message });
  }
});

router.post("/verify-email", async (req, res) => {
  const { email, verificationCode } = req.body;
  console.log(email, verificationCode);

  try {
    // Find the user by email
    const user = await User.findOne({ email: email });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (user.isEmailVerified) {
      return res.status(400).json({ message: "Email already verified" });
    }

    // Check if the verification code matches
    if (user.verificationCode !== verificationCode) {
      return res.status(400).json({ message: "Wrong verification code" });
    }

    // Update user's email verification status
    user.isEmailVerified = true;
    await user.save();

    // You can also generate a JWT token here if needed

    res.status(200).json({ message: "Email verified successfully" });
  } catch (error) {
    console.error(error);
    res
      .status(500)
      .json({ message: "Internal server error", error: error.message });
  }
});

router.post("/login", async (req, res) => {
  const { username, password, fcmToken } = req.body;
  try {
    const user = await User.findOne({ username: username });

    if (!user || user.isEmailVerified == false) {
      return res.status(401).json({ message: "Invalid username or password" });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid username or password" });
    }

    const token = jwt.sign(
      {
        userId: user._id,
        email: user.email,
        username: user.username,
        fcmToken: user.fcmToken,
        profilePic: user.profilePic,
      },
      secretKey
    );

    const refreshToken = jwt.sign({ userId: user._id }, secretKey, {
      expiresIn: "7d",
    });

    user.fcmToken = fcmToken;
    user.save();
    res
      .status(200)
      .json({ message: "Successful login", user: user, token: token });
    console.log("Received Token:", token);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Internal server error" });
  }
});

router.get("/protected-route", verifyToken, (req, res) => {
  res.status(200).json({ message: "Access granted" });
});

// forgot password

router.post("/send-verification-code", async (req, res) => {
  const userEmail = req.body.email;

  // Check if userEmail is null or undefined
  if (!userEmail) {
    return res.status(400).json({ error: "Invalid email address" });
  }

  const user = await User.findOne({ email: userEmail });

  if (!user) {
    return res.status(404).json({ error: "Email not found" });
  }

  const verificationCode = generateVerificationCode();

  const userVerification = new UserVerification({
    userId: user._id,
    userEmail: userEmail,
    accessCode: verificationCode,
  });

  try {
    await userVerification.save();

    // Send email
    const transporter = nodemailer.createTransport({
      host: "smtp.gmail.com",
      port: 587,
      secure: false,
      requireTLS: true,
      auth: {
        user: "group5tablu@gmail.com",
        pass: "dtnu elfi gdmy amro",
      },
      tls: {
        ciphers: "SSLv3",
        minVersion: "TLSv1.2",
      },
    });

    // Email content
    const mailOptions = {
      from: "group5tablu@gmail.com",
      to: userEmail,
      subject: "Password Reset Verification Code",
      html: `<p>Hi there <strong>${userEmail}</strong></p>
      <p>We understand you might be having trouble accessing your TabLU account. No worries, we're here to help!</p>
      <p>To reset your forgotten passcode, follow these simple steps:</p>
      <ul>
        <li>Copy the six-digit code: <strong>${verificationCode}</strong></li>
        <li>Launch the TabLU app and enter the code in the designated field.</li>
        <li>Create a strong new password for your account.</li>
      </ul>
      <p><strong>Didn't request this?</strong></p>
      <p>If you remember your password or didn't request a reset, simply disregard this email. Your account security is our priority.</p>
      <p>Need further assistance?</p>
      <p>Contact our support team at group5tablu@gmail.com</p>
      <p>Best regards,</p>
      <p>The TabLU Team</p>
      `,
    };

    await transporter.sendMail(mailOptions);

    // Modify the server response to include resetToken and accessCode
    res.status(200).json({
      message: "Verification code sent successfully",
      resetToken: userVerification.userId, // Assuming userId is the resetToken
      accessCode: userVerification.accessCode,
    });
  } catch (error) {
    console.error("Error sending verification code:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

function generateVerificationCode() {
  return Math.floor(1000 + Math.random() * 9000).toString();
}

router.post("/reset-password", async (req, res) => {
  const { resetToken, newPassword, accessCode } = req.body;

  try {
    // Find user verification info
    const userVerification = await UserVerification.findOne({
      userId: resetToken,
      accessCode: accessCode,
    });

    if (!userVerification) {
      return res.status(400).json({ message: "Invalid access code" });
    }

    const user = await User.findById(resetToken);

    if (!user) {
      return res.status(400).json({ message: "User not found" });
    }

    // const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = newPassword;

    await UserVerification.deleteOne({ userId: resetToken });

    await user.save();
    res.status(200).json({ message: "Password reset successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
});

router.post("/api-join-event", async (req, res) => {
  try {
    let userId = req.body.userId;
    let eventId = req.body.eventId;

    // Check if the user is already a judge for this event
    const existingJudge = await Judge.findOne({
      eventId: eventId,
      userId: userId,
    });

    console.log(existingJudge);

    if (existingJudge) {
      return res
        .status(400)
        .json({ message: "User is already a judge for this event" });
    }

    // If the user is not already a judge, create a new judge entry
    const newJudge = new Judge({
      eventId: eventId,
      userId: userId,
      // Add any other judge-specific fields as needed
    });

    // Save the new judge to the database
    await newJudge.save();

    // Respond with a success message
    res
      .status(200)
      .json({ message: "Join request successful", judge: newJudge });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
});

router.get("/event-judges/:eventId", async (req, res) => {
  try {
    const eventId = req.params.eventId;

    // Retrieve judges for the specified event and populate the 'userId' field with user details
    const judges = await Judge.find({ eventId: eventId }).populate(
      "userId",
      "username"
    );

    if (!judges || judges.length === 0) {
      return res
        .status(404)
        .json({ message: "No judges found for the specified event" });
    }

    // Extract relevant details for response
    const formattedJudges = judges.map((judge) => ({
      judgeId: judge._id,
      eventId: judge.eventId,
      username: judge.userId.username, // Include the username
    }));

    res.status(200).json({
      message: "Judges retrieved successfully",
      judges: formattedJudges,
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Internal server error" });
  }
});

router.get("/get-username/:userId", async (req, res) => {
  try {
    // Assuming userId is the MongoDB ObjectId
    const userId = req.params.userId;

    // Find the user by userId and retrieve the username
    const user = await User.findById(userId);

    if (user) {
      res
        .status(200)
        .json({ username: user.username, profilePic: user.profilePic });
    } else {
      res.status(404).json({ error: "User not found" });
    }
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

module.exports = router;
