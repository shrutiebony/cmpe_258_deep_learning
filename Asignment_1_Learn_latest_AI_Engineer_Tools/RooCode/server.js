const express = require('express');
const path = require('path');
const app = express();
const port = 3001;

// Middleware to serve static files from the frontend folder
app.use(express.static(path.join(__dirname, '../frontend')));

// API endpoint
app.get('/api/data', (req, res) => {
    res.json({ message: 'Hello from the backend!' });
});

// Route to serve the frontend
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend', 'index.html'));
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running at http://localhost:${port}`);
});