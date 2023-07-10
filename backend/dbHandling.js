const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const { body, validationResult } = require('express-validator');

require('dotenv').config();

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

const supabase = createClient(url, anonKey);

const isAuthenticated = async (req, res, next) => {
    const { data: user } = await supabase.auth.getUser();
    if (!user) {
        return res.status(401).json({ message: 'Unauthorized. You are not signed in.' });
    }
    next();
};

const createContentSchema = [
    body('title')
        .notEmpty()
        .withMessage('Title is required'),
    // Add more validation rules for other fields if needed
];

const updateContentSchema = [
    body('id')
        .notEmpty()
        .withMessage('ID required for update.'),
];

router.post('/content', isAuthenticated, createContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array() });
    }
    const { title, body } = req.body;
    try {
        const { data, error } = await supabase.from('content').insert([
            {
                Title: title,
                Body: body,
            },
        ]);

        if (error) {
            throw new Error(error.message);
        }

        return res.status(200).json(req.body);
    } catch (error) {
        console.error('Write error: ', error.message);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

router.get('/content', isAuthenticated, async (_, res) => {
    try {
        const { data, error } = await supabase.from('content').select();

        if (error) {
            throw new Error(error.message);
        }

        return res.send(data);
    } catch (error) {
        console.error('Read error: ', error.message);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

router.get('/content/:id', isAuthenticated, async (req, res) => {
    try {
        const { data, error } = await supabase.from('content').select().eq("id", req.params.id);

        if (error) {
            throw new Error(error.message); // Retrieve the error message from the error object
        }

        return res.send(data);
    } catch (error) {
        console.error("Read error: ", error.message);
        return res.status(500).json({ message: 'Internal server error.', error: error.message }); // Include the error message in the response
    }
});


router.put('/content/:id', isAuthenticated, updateContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty())
        return res.status(400).json({ message: errors.array() });
    try {
        const now = new Date();
        const isoNow = now.toISOString();
        const formattedNow = isoNow.replace('Z', '+00:00');
        const { id, title, body } = req.body;

        const { data, error } = await supabase.from('content').update({
            Title: title ? title : data[0].Title,
            Body: body ? body : data[0].Body,
            updated_at: formattedNow
        }).eq('id', id);

        if (error)
            throw new Error(error);
        return res.status(200).json(req.body);
    } catch (error) {
        console.log("Error updating: ", error.message);
        return res.send({ message: "Internal server error." });
    }
});

module.exports = router;
