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
    body('name')
        .notEmpty()
        .withMessage('Name is required'),
    // Add more validation rules for other fields if needed
];

router.post('/content', isAuthenticated, createContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ message: errors.array() });
    }

    try {
        const { data, error } = await supabase.from('content').insert([
            {
                Title: req.title,
                Body: req.body,
            },
        ]);

        if (error) {
            throw new Error(error.message);
        }

        res.status(200).json(request.body);
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
            throw new Error(error);
        }

        return res.send(data);
    } catch (error) {
        return res.send({ error });
    }
});

module.exports = router;
