const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const { checkSchema, validationResult } = require('express-validator');

require('dotenv').config();

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

const supabase = createClient(url, anonKey);

const isAuthenticated = (req, res, next) => {
    if (!supabase.auth.user()) 
        return res.status(401).json({ message: 'Unauthorized. You are not signed in.' });
    next();
}

const createContentSchema = checkSchema({
    name: {
      in: ['body'],
      notEmpty: {
        errorMessage: 'Name is required',
      },
    },
    // Add more validation rules for other fields if needed
});

router.post('/content', isAuthenticated, createContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if(!errors.isEmpty()) 
        return res.status(400).json({ message: errors.array() });

    try {
        const { title, desc, contents } = req.body;

        const { data, error } = await supabase.from('content').insert([{
            name: title,
            description: desc,
            data: contents,
        }]);

        if (error) {
            throw new Error(error.message);
        }
    } catch(error) {
        console.error('Write error: ', e.message);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

router.get('/content', isAuthenticated, createContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) 
        return res.status(400).json({ message: errors.array() });

    try {
        const { data, error } = await supabase.from('content').select('id', 'data', 'name', 'description');

        if (error) {
            throw new Error(error.message);
        }
    } catch (error) {
        console.error("Read error: ", e.message);
        return res.status(500).json({ message: 'Internal server error.' });
    }
});

module.exports = router;