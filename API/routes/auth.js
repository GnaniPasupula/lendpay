const express = require('express');
const bcrypt = require('bcrypt');
const User = require('../Models/User');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');

const router = express.Router();

const temporaryStorage = {};

function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function sendOTP(email, otp) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.MAIL_EMAIL, 
      pass: process.env.MAIL_PASS, 
    },
  });

  const mailOptions = {
    from: process.env.MAIL_EMAIL,
    to: email,
    subject: 'Verify Your Email - OTP',
    text: `Your OTP for email verification is: ${otp}`,
  };

  await transporter.sendMail(mailOptions);
}

router.post('/signup', async (req, res) => {
  try {
    const { email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const otp = generateOTP();
    await sendOTP(email, otp);

    temporaryStorage[email] = { email, password, otp };

    res.status(200).json({ message: 'OTP sent successfully'});
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});

router.post('/verify-otp', async (req, res) => {
  try {
    const { email, otp } = req.body;

    const signupDetails = temporaryStorage[email];

    if (!signupDetails) {
      return res.status(400).json({ message: 'Signup details not found' });
    }

    if (signupDetails.otp !== otp) {
      return res.status(401).json({ message: 'Invalid OTP' });
    }

    const hashedPassword = await bcrypt.hash(signupDetails.password, 10);
    const newUser = new User({ email: signupDetails.email, password: hashedPassword });
    await newUser.save();

    delete temporaryStorage[email];

    res.status(201).json({ message: 'User registered successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});


router.post('/signin', async (req, res) => {
    try {
      const { email, password } = req.body;

      // console.log("user email "+email);
    
      const user = await User.findOne({ email });
  
      if (!user) {
        return res.status(401).json({ message: 'User doesn\'t exist' });
      }

      const isPasswordValid = await bcrypt.compare(password, user.password);
  
      if (!isPasswordValid) {
        return res.status(401).json({ message: 'Invalid email or password' });
      }

      const payLoad={
        userId:user._id,
        userEmail:user.email,
        timestamp: new Date().getTime()
      }

      // console.log("Payload"+payLoad);

      const authToken = jwt.sign(payLoad, process.env.SECRET_KEY);

      // console.log(authToken);
  
      res.status(200).json({ message: 'Signin successful', token: authToken });

    } catch (error) {
      console.error('Error:', error);
      res.status(500).json({ message: 'An error occurred' });
    }
});

router.post('/logout', async (req, res) => {
  try {
    res.status(200).json({ message: 'Logout successful' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'An error occurred' });
  }
});
  
module.exports = router;