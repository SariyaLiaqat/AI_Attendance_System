// const express = require('express');
// const bodyParser = require('body-parser');
// const cors = require('cors');
// const { Pool } = require('pg');
// const { sendAttendanceEmail } = require('./utils/mailer');

// const app = express();
// app.use(bodyParser.json());
// app.use(cors());

// // PostgreSQL Pool
// const pool = new Pool({
//     user: 'postgres',
//     host: 'localhost',
//     database: 'attendance_system',
//     password: 'heartbroken009',
//     port: 5432,
// });

// // Test Route
// app.get('/', (req, res) => {
//     res.send('Attendance Backend Running');
// });

// // Add New Student
// app.post('/addStudent', async (req, res) => {
//     try {
//         const { name, face_embedding, parent_email, other_info } = req.body;

//         const query = `
//             INSERT INTO students (name, face_embedding, parent_email, other_info)
//             VALUES ($1, $2, $3, $4)
//             RETURNING *;
//         `;

//         const values = [name, face_embedding, parent_email, other_info || {}];
//         const result = await pool.query(query, values);

//         res.json({ success: true, student: result.rows[0] });
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ success: false, error: 'Server Error' });
//     }
// });
// // 1. Find Student by Roll Number
// // 1. Find Student by Roll Number
// app.get('/getStudent/:rollNo', async (req, res) => {
//     try {
//         const { rollNo } = req.params;
        
//         // 📢 ADD THIS LOG HERE
//         console.log(`🔍 Received request for Roll No: ${rollNo} at ${new Date().toLocaleTimeString()}`);

//         const query = "SELECT * FROM students WHERE other_info->>'roll_no' = $1";
//         const result = await pool.query(query, [rollNo]);
        
//         if (result.rows.length > 0) {
//             console.log(`✅ Student Found: ${result.rows[0].name}`); // Log success
//             res.json(result.rows[0]);
//         } else {
//             console.log(`❌ Student Not Found for Roll: ${rollNo}`); // Log failure
//             res.status(404).json({ error: 'Student not found' });
//         }
//     } catch (err) {
//         console.error("🔥 Server Error:", err);
//         res.status(500).send('Server Error');
//     }
// });

// // 2. Mark Attendance
// app.post('/markAttendance', async (req, res) => {
//     try {
//         const { student_id, status } = req.body;

//         // 1️⃣ Mark attendance
//         const attendanceQuery = `
//             INSERT INTO attendance (student_id, date, status)
//             VALUES ($1, CURRENT_DATE, $2)
//             RETURNING *;
//         `;
//         const attendanceResult = await pool.query(attendanceQuery, [
//             student_id,
//             status || 'Present'
//         ]);

//         // 2️⃣ Fetch student + parent email
//         const studentQuery = `
//             SELECT name, parent_email
//             FROM students
//             WHERE id = $1
//         `;
//         const studentResult = await pool.query(studentQuery, [student_id]);

//         if (studentResult.rows.length > 0) {
//             const { name, parent_email } = studentResult.rows[0];

//             // 3️⃣ Send Email (ASYNC, non-blocking)
//             if (parent_email) {
//                 sendAttendanceEmail(parent_email, name)
//                     .then(() => console.log(`📧 Email sent to ${parent_email}`))
//                     .catch(err => console.error('❌ Email failed:', err));
//             }
//         }

//         res.json({
//             success: true,
//             record: attendanceResult.rows[0],
//         });

//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Attendance Failed' });
//     }
// });


// // Get All Students
// app.get('/getAllStudents', async (req, res) => {
//     try {
//         const result = await pool.query('SELECT * FROM students');
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Server Error' });
//     }
// });

// // Start Server
// const PORT = process.env.PORT || 5000;
// app.listen(PORT, '0.0.0.0', () => {
//     console.log(`Server running on port ${PORT} at 192.168.1.193`);
// });
















const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const { Pool } = require('pg');
const { sendAttendanceEmail } = require('./utils/mailer');

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

        // 1️⃣ Mark attendance
        const attendanceQuery = `
            INSERT INTO attendance (student_id, date, status)
            VALUES ($1, CURRENT_DATE, $2)
            RETURNING *;
        `;
        const attendanceResult = await pool.query(attendanceQuery, [
            student_id,
            status || 'Present'
        ]);

        // 2️⃣ Fetch student + parent email
        const studentQuery = `
            SELECT name, parent_email
            FROM students
            WHERE id = $1
        `;
        const studentResult = await pool.query(studentQuery, [student_id]);

        if (studentResult.rows.length > 0) {
            const { name, parent_email } = studentResult.rows[0];

            // 3️⃣ Send Email (ASYNC, non-blocking)
            if (parent_email) {
                sendAttendanceEmail(parent_email, name)
                    .then(() => console.log(`📧 Email sent to ${parent_email}`))
                    .catch(err => console.error('❌ Email failed:', err));
            }
        }

        res.json({
            success: true,
            record: attendanceResult.rows[0],
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Attendance Failed' });
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


// Get Daily Attendance Stats for Dashboard
app.get('/getDailyStats', async (req, res) => {
    try {
        // 1. Get total number of students
        const totalResult = await pool.query('SELECT COUNT(*) FROM students');
        const totalStudents = parseInt(totalResult.rows[0].count);

        // 2. Get number of students marked 'Present' today
        const presentResult = await pool.query(
            "SELECT COUNT(*) FROM attendance WHERE date = CURRENT_DATE AND status = 'Present'"
        );
        const presentCount = parseInt(presentResult.rows[0].count);

        if (totalStudents === 0) {
            return res.json({ presentPercent: 0, absentPercent: 0, total: 0 });
        }

        const presentPercent = Math.round((presentCount / totalStudents) * 100);
        const absentPercent = 100 - presentPercent;

        res.json({
            presentPercent,
            absentPercent,
            total: totalStudents,
            presentCount
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Stats Calculation Failed' });
    }
});


// Fetch the 5 most recent attendance logs
app.get('/getRecentActivity', async (req, res) => {
    try {
        const query = `
            SELECT 
                s.name, 
                a.status, 
                TO_CHAR(a.date, 'HH12:MI AM') as time
            FROM attendance a
            JOIN students s ON a.student_id = s.id
            ORDER BY a.id DESC
            LIMIT 5;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch activity' });
    }
});

// Get stats for the Bar Chart (Last 7 Days)
app.get('/getWeeklyAttendance', async (req, res) => {
    try {
        const query = `
            SELECT 
                TO_CHAR(date, 'Day') as day, 
                COUNT(*) as count 
            FROM attendance 
            WHERE date > CURRENT_DATE - INTERVAL '7 days'
            GROUP BY day, date
            ORDER BY date;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Weekly stats failed' });
    }
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT} at 192.168.1.193`);
});
