const express = require('express');
const router = express.Router();
const { createClient }  = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');
const jwtSecret = process.env.JWT_SECRET;

require('dotenv').config();

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

const supabase = createClient(url, anonKey);

// other auth code to make sure that user is authenticated before db is queried.

router.post('/signup/:type', async (req, res) => {
    try {
        const { userType } = req.params.type ? 'teacher' : 'parent';
        const { email, pass } = req.body;

        if (!email || !pass) return res.status(401).json({ message: 'Email or password not provided.'});

        const { data, error } = await suapabase.auth.signUp(
            {
                email: email,
                password: pass,
                options: {
                    data: {
                        type: userType
                    }
                }
            }
        );

        if (error) throw new Error(error.message);

        return res.status(200).json({
            sessionToken: session,
            refreshToken: refresh
        });
    } catch (error) {

    }
});

router.post('signin', async (req, res) => {

});

router.post('/signout', async (req, res) => {

});

module.exports = router;
