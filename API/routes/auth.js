const express = require('express');
const bcrypt = require('bcrypt');
const User = require('../Models/User');
const jwt = require('jsonwebtoken');
const router = express.Router();

router.post('/signup', async (req, res) => {
  try {
    const { email, password } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = new User({ email, password: hashedPassword });
    await newUser.save();

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
  
module.exports = router;