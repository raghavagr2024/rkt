const express = require('express');
const { body, validationResult, param } = require('express-validator');
const multer = require('multer');
const { createClient } = require('@supabase/supabase-js');
const ffmpeg = require('fluent-ffmpeg');

const router = express.Router();
//const upload = multer({ dest: '/uploads' });
const upload = multer();

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
    body('title').notEmpty().withMessage('Title is required'),
    // Add more validation rules for other fields if needed
];

const idContentSchema = [
    param('id').notEmpty().withMessage('ID required for update.'),
];

router.post('/content', isAuthenticated, createContentSchema, async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    const { title, body } = req.body;
    try {
        const { data, error } = await supabase.from('content').insert([{ Title: title, Body: body }]);

        if (error) {
            throw new Error(error.message);
        }

        return res.status(200).json(req.body);
    } catch (error) {
        console.error('Write error: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
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
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

router.get('/content/:id', isAuthenticated, idContentSchema, async (req, res) => {
    try {
        const { id } = req.params;
        const { data, error } = await supabase.from('content').select().eq('id', id);

        if (error) {
            throw new Error(error.message);
        }

        return res.send(data);
    } catch (error) {
        console.error('Read error: ', error.message);
        return res.status(500).json({ message: 'Internal server error.', error: error.message });
    }
});

router.put('/content/:id', isAuthenticated, idContentSchema, async (req, res) => {
    const errors = validationResult(req);
    const { id } = req.params;
    if (!errors.isEmpty())
        return res.status(400).json({ message: errors.array() });
    try {
        const now = new Date();
        const isoNow = now.toISOString();
        const formattedNow = isoNow.replace('Z', '+00:00');
        const { title, body } = req.body;

        // Retrieve existing data before updating
        const { data: existingData, error: fetchError } = await supabase.from('content').select().eq('id', id);

        if (fetchError) {
            throw new Error(fetchError.message);
        }

        const { data, error } = await supabase
            .from('content')
            .update({
                Title: title ? title : existingData[0].Title,
                Body: body ? body : existingData[0].Body,
                updated_at: formattedNow,
            })
            .eq('id', id);

        if (error) {
            throw new Error(error.message);
        }
        if (error)
            throw new Error(error);
        return res.status(200).json({ message: `Updated id: ${id} successfully` });
    } catch (error) {
        console.log('Error updating: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

router.delete('/content/delete/:id', isAuthenticated, idContentSchema, async (req, res) => {
    const { id } = req.params;
    try {
        const { data, error } = await supabase.from('content').delete().eq('id', id);

        if (error) {
            throw new Error(error.message);
        }

        return res.status(200).json({ message: `Deleted ${id} successfully.` });
    } catch (error) {
        console.log('Delete error: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

router.post('/upload', upload.single('file'), async (req, res) => {
    try {
        // Testing code
        // console.log(req.file);
        
        const { folderName } = req.body || { folderName: '' }

        // Check if file exists
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        // Remove spaces from file name
        const formattedName = req.file.originalname.replace(/\s+/g, "_");
        req.file.originalName = formattedName;

        // Upload file to Supabase storage bucket using the standard upload method
        const { data, error } = await supabase.storage.from('uploads').upload(folderName ? `${folderName}/${formattedName}` : formattedName, req.file.buffer);

        if (error) {
            // Handle error
            console.error(error.message);
            return res.status(500).send('Error uploading file');
        }

        return res.status(200).json({ message: 'File uploaded successfully' });
    } catch (error) {
        console.error('Write error: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

/*
router.post('/upload', upload.single('file'), async (req, res) => {
    try {
        // Check if file exists
        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        // Check if file size is greater than or equal to 10MB (10 * 1024 * 1024 bytes)
        const fileSizeInBytes = req.file.size;
        const maxSizeInBytes = 10 * 1024 * 1024;

        if (fileSizeInBytes >= maxSizeInBytes) {
            // Perform lossless compression using ffmpeg in-memory
            ffmpeg(req.file.buffer)
                .outputOptions('-c:v', 'libx264') // Use H.264 codec for video
                .outputOptions('-c:a', 'copy') // Copy the original audio codec
                .outputOptions('-preset', 'medium') // Set the compression preset
                .format('mp4') // Specify the output format (you can change this as needed)
                .on('end', async (stdout, stderr) => {
                    const compressedFileName = req.file.originalname.replace(/\s+/g, "_");
                    req.file.originalName = compressedFileName;

                    // Upload the compressed file to Supabase storage bucket
                    const { data, error } = await supabase.storage.from('uploads').upload(compressedFileName, stdout);
                    
                    if (error) {
                        // Handle error
                        console.error(error.message);
                        return res.status(500).send('Error uploading file');
                    }

                    return res.status(200).json({ message: 'File uploaded successfully (compressed)' });
                })
                .on('error', (err) => {
                    console.error('Error during compression:', err.message);
                    return res.status(500).json({ message: 'Error during compression' });
                })
                .pipe(); // Pipe the output to the next operation (uploading)
        } else {
            // File size is smaller than 10MB, upload the file directly
            const formattedName = req.file.originalname.replace(/\s+/g, "_");
            req.file.originalName = formattedName;
            
            const { data, error } = await supabase.storage.from('uploads').upload(formattedName, req.file.buffer);
            
            if (error) {
                // Handle error
                console.error(error.message);
                return res.status(500).send('Error uploading file');
            }
            
            return res.status(200).json({ message: 'File uploaded successfully' });
        }
    } catch (error) {
        console.error('Write error: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});
*/

router.get('/upload', isAuthenticated, async (req, res) => {
    try {
        const { data, error } = await supabase.storage.from('uploads').list('', {
            limit: 100,
            offset: 0,
            sortBy: { column: 'name', order: 'asc' },
        });

        if (error) {
            console.error(error.message);
            return res.status(500).json({ message: 'Error reading files.' });
        }

        // Extract file names from the 'data' array
        const fileNames = data.map(file => file.name);
        console.log(data);
        console.log(fileNames);

        return res.status(200).send(fileNames);
    } catch (error) {
        console.error('File read error: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

router.get('/upload/:folder/:name', isAuthenticated, async (req, res) => {
    let dir = req.params.folder;
    let name = req.params.name;

    try {

        if (dir === 'root')
            dir = '';

        const { data, error } = await supabase.storage.from('uploads').createSignedUrl(`${dir}/${name}`, 600);

        if (error) throw new Error(error.message);

        return res.status(200).send(data);
    } catch (error) {
        console.log('Error creating file link: ', error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.' });
    }
});

router.post('/upload/base64', isAuthenticated, async (req, res) => {
    try {
        const { name, size, content } = req.body;

        if (!name || !size || !content) return res.status(400).json({ message: 'Invalid or incomplete file data.' });

        const { _, error } = await supabase.storage.from('uploads').upload(name, Buffer.from(content, 'base64'))


        if (error) {
            console.error(error.message);
            return res.status(500).json({message: 'Error uploading file. Check console.'})
        }

        return res.status(200).json({ message: 'File uploaded successfully. '});
    } catch (error) {
        console.error(error.message);
        return res.status(500).json({ message: 'Internal server error. Check console.'})
    }
});

module.exports = router;
