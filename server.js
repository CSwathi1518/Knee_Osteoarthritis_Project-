// server.js (Node.js with Express)

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(bodyParser.json());

let users = []; // Temporary storage for users (in memory)

// Endpoint to handle user registration
app.post('/register', (req, res) => {
  const { username, password } = req.body;

  // Check if username already exists
  if (users.some(user => user.username === username)) {
    return res.status(400).json({ status: 'error', message: 'Username already exists' });
  }

  // Add user to the users array
  users.push({ username, password });
  res.json({ status: 'success', message: 'User registered successfully' });
});

// Endpoint to handle user login
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Check if username and password match
  const user = users.find(user => user.username === username && user.password === password);
  if (!user) {
    return res.status(401).json({ status: 'error', message: 'Invalid username or password' });
  }

  res.json({ status: 'success', message: 'Login successful' });
});

const PORT = 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
