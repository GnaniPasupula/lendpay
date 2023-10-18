require('dotenv').config();
const express = require('express');
const cors = require('cors');

function startServer() {
  const app = express();

  app.use(express.json());

  app.use(cors());

  const PORT = process.env.PORT || 3000;

  app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
  });
}

startServer();