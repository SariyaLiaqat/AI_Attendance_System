const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
app.use(bodyParser.json());
app.use(cors());

// PostgreSQL Pool
const pool = new Pool({
    user: 'postgres',
    host: 'localhost',
    database: 'attendance_system',
    password: 'heartbroken009',
    port: 5432,
});

// Test Route
app.get('/', (req, res) => {
    res.send('Attendance Backend Running');
});

// Add New Student
app.post('/addStudent', async (req, res) => {
    try {
        const { name, face_embedding, parent_email, other_info } = req.body;

        const query = `
            INSERT INTO students (name, face_embedding, parent_email, other_info)
            VALUES ($1, $2, $3, $4)
            RETURNING *;
        `;

        const values = [name, face_embedding, parent_email, other_info || {}];
        const result = await pool.query(query, values);

        res.json({ success: true, student: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ success: false, error: 'Server Error' });
    }
});
// 1. Find Student by Roll Number
// 1. Find Student by Roll Number
app.get('/getStudent/:rollNo', async (req, res) => {
    try {
        const { rollNo } = req.params;
        
        // 📢 ADD THIS LOG HERE
        console.log(`🔍 Received request for Roll No: ${rollNo} at ${new Date().toLocaleTimeString()}`);

        const query = "SELECT * FROM students WHERE other_info->>'roll_no' = $1";
        const result = await pool.query(query, [rollNo]);
        
        if (result.rows.length > 0) {
            console.log(`✅ Student Found: ${result.rows[0].name}`); // Log success
            res.json(result.rows[0]);
        } else {
            console.log(`❌ Student Not Found for Roll: ${rollNo}`); // Log failure
            res.status(404).json({ error: 'Student not found' });
        }
    } catch (err) {
        console.error("🔥 Server Error:", err);
        res.status(500).send('Server Error');
    }
});

// 2. Mark Attendance
app.post('/markAttendance', async (req, res) => {
    try {
        const { student_id, status } = req.body;
        const query = 'INSERT INTO attendance (student_id, date, status) VALUES ($1, CURRENT_DATE, $2) RETURNING *';
        const result = await pool.query(query, [student_id, status || 'Present']);
        res.json({ success: true, record: result.rows[0] });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database Error' });
    }
});

// Get All Students
app.get('/getAllStudents', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM students');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Server Error' });
    }
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT} at 192.168.1.193`);
});
