const express = require('express');
const User = require('../models/user.model');
const router = express.Router();
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const jwt = require('jsonwebtoken');
const secretKey = process.env.JWT_SECRET || 'defaultSecretKey';
const emailUser =  'avbreyrd@gmail.com'   // process.env.EMAIL_USER;
const emailPassword = 'PasswordniAubrey016880'// process.env.EMAIL_PASSWORD

// Middleware to verify JWT
const verifyToken = (req, res, next) => {
    const token = req.headers.authorization;

    if (!token) {
        return res.status(401).json({ message: 'Unauthorized: Missing token' });
    }

    jwt.verify(token, secretKey, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: 'Unauthorized: Invalid token' });
        }

        req.userId = decoded.userId;
        next();
    });
};

router.post('/signin', async (req, res) => {
  const { username, email, password } = req.body;

  try {
      // Check if a user with the given email or username already exists
      const existingUser = await User.findOne({
          $or: [
              { username: username },
              { email: email }
          ]
      });

      if (existingUser) {
          return res.status(400).json({ message: 'Username or Email already exists' });
      }

      // If the user doesn't exist, create a new user
      const newUser = new User({
          username: username,
          email: email,
          password: password
      });

      // Save the new user to the database
      await newUser.save();

      // Respond with a success message and JWT token
      const token = jwt.sign({ userId: newUser.id }, secretKey, { expiresIn: '30d' });
      res.status(201).json({ message: 'User registered successfully', token: token });
  } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error' });
  }
});


router.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
   
    const user = await User.findOne({ username: username });

    if (!user) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Invalid username or password' });
    }

    const token = jwt.sign(
      { userId: user._id, email: user.email, username: user.username },
      secretKey,
      { expiresIn: '1h' }
    );
    res.status(200).json({ message: 'Successful login', user: user, token: token });
    console.log('Received Token:', token);

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
});

router.get('/protected-route', verifyToken, (req, res) => {
  res.status(200).json({ message: 'Access granted' });
});

// forgot password

router.post('/send-verification-code', async (req, res) => {
  const userEmail = req.body.email; 
  const verificationCode = generateVerificationCode(); 

  const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 587,
    secure: false,
    requireTLS: true,
    auth: {
      user: 'avbreyrd@gmail.com',
      pass: 'dbde fhua iozz wxxy',
    },
    tls: {
      ciphers: 'SSLv3',
      minVersion: 'TLSv1.2',
    },
  });
  
  // Email content
  const mailOptions = {
    from: 'avbreyrd@gmail.com',
    to: userEmail,
    subject: 'Password Reset Verification Code',
    text: `Your verification code is: ${verificationCode}`,
  };

  try {
    // Send email
    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: 'Verification code sent successfully' });
  } catch (error) {
    console.error('Error sending verification code:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

function generateVerificationCode() {
  return Math.floor(1000 + Math.random() * 9000).toString();
}
  router.post('/reset-password', async (req, res) => {
    const { resetToken, newPassword } = req.body;
    console.log('Received resetToken:', resetToken);
    console.log('Received newPassword:', newPassword);
    try {
      const user = await User.findOne({
        resetToken,
        resetTokenExpiration: { $gt: Date.now() },
      });
  
      if (!user) {
        return res.status(400).json({ message: 'Invalid or expired reset token' });
      }
  
      // Update the user's password
      const hashedPassword = await bcrypt.hash(newPassword, 10);
      console.log('Hashed Password:', hashedPassword);
      user.password = hashedPassword;
      user.resetToken = null;
      user.resetTokenExpiration = null;
      console.log('User Before Update:', user);
      await user.save();
      console.log('User Updated:', user);
  
      res.status(200).json({ message: 'Password reset successfully' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error' });
    }
  });

  router.post('/api-join-event', (req, res) => {
    // Extract data from the request body
    const userId = req.body._id;
    const eventId = req.body.eventId;
  
    // Perform any necessary logic (e.g., save the join request to a database)
  
    // Respond with a success message
    res.status(200).json({ message: 'Join request successful' });
  });





module.exports = router;
