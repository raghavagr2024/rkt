const express = require('express');
const router = express.Router();
const { createClient }  = require('@supabase/supabase-js');

require('dotenv').config();

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

const supabase = createClient(url, anonKey);

// other auth code to make sure that user is authenticated before db is queried.

module.exports = router;