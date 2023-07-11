const express = require('express');
const serverless = require('serverless-http');
const cors = require('cors');

const app = express();
const authRoutes = require('./auth');
const dbRoutes = require('./dbHandling');

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors());

app.use('/api/auth', authRoutes);
app.use('/api/db', dbRoutes);

if (process.env.NODE_ENV !== 'production') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server running off of http://localhost:${PORT}`);
    });
} else {
    module.exports = app;
    module.exports.handler = serverless(app);
}