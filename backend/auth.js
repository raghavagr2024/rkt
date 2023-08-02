const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const jwt = require('jsonwebtoken');

require('dotenv').config();

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

const supabase = createClient(url, anonKey);

// other auth code to make sure that user is authenticated before db is queried.

router.post('/signup/:type', async (req, res) => {
    try {
        const { type } = req.params;
        const userType = type || 'parent';

        if (!type) 
            type = 'parent';

        const { email, pass } = req.body;

        console.log(type);

        if (!email || !pass) return res.status(401).json({ message: 'Email or password not provided.' });

        const { data, error } = await supabase.auth.signUp(
            {
                email: email,
                password: pass,
                options: {
                    data: {
                        type: userType
                    }
                }
            });

        if (error) throw new Error(error.message);

        return res.status(200).json({ message: "Sign up successful." });
    } catch (error) {
        console.error("Auth error:", error.message);
        return res.status(500).json({ message: "Internal server error, check console." })
    }
});
});

router.post('/signin', async (req, res) => {
    try {
        const { email, pass } = req.body;

        const { data, error } = await supabase.auth.signInWithPassword({
            email: email,
            password: pass
        })

        if (error) throw new Error(error.message);

        const payload = {
            id: data.user.id,
            email: data.user.email,
            refresh_token: data.session.refresh_token,
        }

        const userType = data.user.user_metadata.type;

        let isTeacher = null;

        if (userType === 'teacher') 
            isTeacher = true;
        else 
            isTeacher = false;

        const options = {
            expiresIn: '1h',
        }

        const token = jwt.sign(payload, process.env.JWT_SECRET, options);

        return res.status(200).json({ user_data_token: token, access_token: data.session.access_token, teacherAccount: isTeacher });
    } catch (error) {
        console.error("Login error: ", error.message);
        return res.status(500).json({ message: "Internal server error, check console." });
    }
});

router.post('/signout', async (req, res) => {
    try {
        const { error } = await supabase.auth.signOut();

        if (error) throw new Error(error.message);

        return res.status(200).json({ message: "Signed out successfully." });
    } catch (error) {
        console.error("Logout error: ", error.message);
        return res.status(500).json({ message: "Internal server error, check console." });
    }
});

router.get('/userData/:token', async (req, res) => {
    try {
        const { token } = req.params;

        const { data: { user } } = await supabase.auth.getUser(token)

        //if (error) throw new Error(error.message);

        return res.status(200).send(user);
    } catch (error) {
        console.error(error.message);
        return res.status(500).json({ message: "Internal server error, check console."});
    }
});

module.exports = router;
