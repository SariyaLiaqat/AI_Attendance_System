
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
//     password: 'Golden-Eagle-2025',
//     port: 5432,
// });

// // Test Route
// app.get('/', (req, res) => {
//     res.send('Attendance Backend Running');
// });

// // Add New Student
// app.post('/addStudent', async (req, res) => {
//     try {
//        const { name, face_embedding, parent_email, other_info, class: studentClass } = req.body;

//      const query = `
//     INSERT INTO students (name, face_embedding, parent_email, other_info, class)
//     VALUES ($1, $2, $3, $4, $5)
//     RETURNING *;
// `;

// const values = [name, face_embedding, parent_email, other_info || {}, studentClass || 'Unknown'];


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


// app.get('/getAllStudents', async (req, res) => {
//   try {
//     const classFilter = req.query.class; // frontend se ?class=10-A
//     let query = 'SELECT * FROM students';
//     let values = [];

//     if (classFilter) {
//       query += ' WHERE class = $1';
//       values.push(classFilter);
//     }

//     const result = await pool.query(query, values);
//     res.json(result.rows);
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ error: 'Server Error' });
//   }
// });



// app.get('/getRecentActivity', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 s.name, 
//                 a.status, 
//                 TO_CHAR(a.date, 'HH12:MI AM') as time
//             FROM attendance a
//             JOIN students s ON a.student_id = s.id
//             ORDER BY a.id DESC
//             LIMIT 5;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Failed to fetch activity' });
//     }
// });

// // Get stats for the Bar Chart (Last 7 Days)
// app.get('/getWeeklyAttendance', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 TO_CHAR(date, 'Day') as day, 
//                 COUNT(*) as count 
//             FROM attendance 
//             WHERE date > CURRENT_DATE - INTERVAL '7 days'
//             GROUP BY day, date
//             ORDER BY date;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Weekly stats failed' });
//     }
// });


// // Get attendance of one student (daily / weekly / monthly)
// app.get('/getStudentAttendance/:studentId', async (req, res) => {
//   try {
//     const { studentId } = req.params;

//     const result = await pool.query(`
//       SELECT date, status
//       FROM attendance
//       WHERE student_id = $1
//       ORDER BY date DESC
//     `, [studentId]);

//     res.json(result.rows);
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ error: 'Failed to fetch student attendance' });
//   }
// });

// // Weekly attendance for ONE student
// app.get('/getStudentWeekly/:studentId', async (req, res) => {
//   try {
//     const { studentId } = req.params;
//     const result = await pool.query(`
//       SELECT 
//         TO_CHAR(date, 'Day') AS day,
//         COUNT(*) FILTER (WHERE status='Present') AS present,
//         COUNT(*) FILTER (WHERE status='Absent') AS absent
//       FROM attendance
//       WHERE student_id = $1
//         AND date >= CURRENT_DATE - INTERVAL '6 days'
//       GROUP BY date
//       ORDER BY date;
//     `, [studentId]);

//     res.json(result.rows);
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ error: 'Weekly data failed' });
//   }
// });

// // Monthly attendance for ONE student
// app.get('/getStudentMonthly/:studentId', async (req, res) => {
//   try {
//     const { studentId } = req.params;
//     const result = await pool.query(`
//       SELECT status, COUNT(*) AS count
//       FROM attendance
//       WHERE student_id = $1
//         AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
//       GROUP BY status;
//     `, [studentId]);

//     res.json(result.rows);
//   } catch (err) {
//     console.error(err);
//     res.status(500).json({ error: 'Monthly data failed' });
//   }
// });



// app.get('/getDailyStats', async (req, res) => {
//     try {
//         const totalRes = await pool.query('SELECT COUNT(*) FROM students');
//         const total = parseInt(totalRes.rows[0].count);

//         const presentTodayRes = await pool.query(
//             "SELECT COUNT(*) FROM attendance WHERE date = CURRENT_DATE AND status = 'Present'"
//         );
//         const presentToday = parseInt(presentTodayRes.rows[0].count);

//         const presentYesterdayRes = await pool.query(
//             "SELECT COUNT(*) FROM attendance WHERE date = CURRENT_DATE - INTERVAL '1 day' AND status = 'Present'"
//         );
//         const presentYesterday = parseInt(presentYesterdayRes.rows[0].count);

//         // Trend vs yesterday
//         let trend = 0;
//         if (presentYesterday > 0) {
//             trend = ((presentToday - presentYesterday) / presentYesterday) * 100;
//         }

//         // Last month absent %
//         const absentLastMonthRes = await pool.query(
//             "SELECT COUNT(*) FROM attendance WHERE date >= CURRENT_DATE - INTERVAL '30 days' AND status = 'Absent'"
//         );
//         const absentLastMonth = parseInt(absentLastMonthRes.rows[0].count);
//         const lastMonthPercent = total > 0 ? Math.round((absentLastMonth / total) * 100) : 0;

//         res.json({
//             total,
//             presentCount: presentToday,
//             absentCount: total - presentToday,
//             trend: trend.toFixed(1),
//             lastMonthAbsentPercent: lastMonthPercent
//         });
//     } catch (err) {
//         res.status(500).json({ error: 'Stats failed' });
//     }
// });

// // --- NEW REPORT APIS ---

// // 1. Get Monthly Attendance Trend (Day-by-Day for the last 30 days)
// app.get('/getMonthlyTrend', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 TO_CHAR(date, 'DD Mon') as date_label, 
//                 ROUND((COUNT(*) FILTER (WHERE status = 'Present')::numeric / COUNT(*)) * 100, 1) as percentage
//             FROM attendance
//             WHERE date >= CURRENT_DATE - INTERVAL '30 days'
//             GROUP BY date
//             ORDER BY date ASC;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Trend analysis failed' });
//     }
// });

// // 2. Get Class-wise Attendance Comparison
// app.get('/getClassComparison', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 s.class, 
//                 ROUND((COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) * 100, 1) as rate
//             FROM students s
//             JOIN attendance a ON s.id = a.student_id
//             GROUP BY s.class
//             ORDER BY rate DESC;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Class comparison failed' });
//     }
// });

// // 3. Get At-Risk Students (Attendance below 75%)
// app.get('/getRiskStudents', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 s.name, 
//                 s.class, 
//                 ROUND((COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) * 100, 1) as rate
//             FROM students s
//             JOIN attendance a ON s.id = a.student_id
//             GROUP BY s.id, s.name, s.class
//             HAVING (COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) < 0.75
//             ORDER BY rate ASC;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Risk assessment failed' });
//     }
// });


// app.get('/getClassSummary', async (req, res) => {
//     try {
//         const query = `
//             SELECT 
//                 class, 
//                 COUNT(id) as total_students,
//                 ROUND((COUNT(id) FILTER (WHERE id IN (SELECT student_id FROM attendance WHERE date = CURRENT_DATE AND status = 'Present'))::numeric / COUNT(id)) * 100) as today_percent
//             FROM students
//             GROUP BY class;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows);
//     } catch (err) {
//         res.status(500).json({ error: 'Class summary failed' });
//     }
// });


// // Get all absent students for today
// app.get('/getAbsentStudents', async (req, res) => {
//     try {
//         const query = `
//             SELECT s.id, s.name, s.class
//             FROM students s
//             WHERE s.id NOT IN (
//                 SELECT student_id
//                 FROM attendance
//                 WHERE date = CURRENT_DATE AND status = 'Present'
//             )
//             ORDER BY s.class, s.name;
//         `;
//         const result = await pool.query(query);
//         res.json(result.rows); // make sure 'rows' contains {id, name, class}
//     } catch (err) {
//         console.error(err);
//         res.status(500).json({ error: 'Failed to fetch absent students' });
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
    password: 'Golden-Eagle-2025',
    port: 5432,
});

// Test Route
app.get('/', (req, res) => {
    res.send('Attendance Backend Running');
});

// Add New Student
app.post('/addStudent', async (req, res) => {
    try {
       const { name, face_embedding, parent_email, other_info, class: studentClass } = req.body;

     const query = `
    INSERT INTO students (name, face_embedding, parent_email, other_info, class)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *;
`;

const values = [name, face_embedding, parent_email, other_info || {}, studentClass || 'Unknown'];


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

        // 1️⃣ Insert attendance record
        const attendanceQuery = `
            INSERT INTO attendance (student_id, date, status)
            VALUES ($1, CURRENT_DATE, $2)
            RETURNING *;
        `;
        const attendanceResult = await pool.query(attendanceQuery, [student_id, status]);

        // 2️⃣ Send email based on status (Present / Absent)
        const studentQuery = `SELECT name, parent_email FROM students WHERE id = $1`;
        const studentResult = await pool.query(studentQuery, [student_id]);

        if (studentResult.rows.length > 0) {
            const { name, parent_email } = studentResult.rows[0];
            if (parent_email) {
                sendAttendanceEmail(parent_email, name, status)
                    .then(() => console.log(`📧 Email sent to ${parent_email} for ${status}`))
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


app.get('/getAllStudents', async (req, res) => {
  try {
    const classFilter = req.query.class; // frontend se ?class=10-A
    let query = 'SELECT * FROM students';
    let values = [];

    if (classFilter) {
      query += ' WHERE class = $1';
      values.push(classFilter);
    }

    const result = await pool.query(query, values);
    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server Error' });
  }
});



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


// Get attendance of one student (daily / weekly / monthly)
app.get('/getStudentAttendance/:studentId', async (req, res) => {
  try {
    const { studentId } = req.params;

    const result = await pool.query(`
      SELECT date, status
      FROM attendance
      WHERE student_id = $1
      ORDER BY date DESC
    `, [studentId]);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to fetch student attendance' });
  }
});

// Weekly attendance for ONE student
app.get('/getStudentWeekly/:studentId', async (req, res) => {
  try {
    const { studentId } = req.params;
    const result = await pool.query(`
      SELECT 
        TO_CHAR(date, 'Day') AS day,
        COUNT(*) FILTER (WHERE status='Present') AS present,
        COUNT(*) FILTER (WHERE status='Absent') AS absent
      FROM attendance
      WHERE student_id = $1
        AND date >= CURRENT_DATE - INTERVAL '6 days'
      GROUP BY date
      ORDER BY date;
    `, [studentId]);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Weekly data failed' });
  }
});

// Monthly attendance for ONE student
app.get('/getStudentMonthly/:studentId', async (req, res) => {
  try {
    const { studentId } = req.params;
    const result = await pool.query(`
      SELECT status, COUNT(*) AS count
      FROM attendance
      WHERE student_id = $1
        AND DATE_TRUNC('month', date) = DATE_TRUNC('month', CURRENT_DATE)
      GROUP BY status;
    `, [studentId]);

    res.json(result.rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Monthly data failed' });
  }
});



app.get('/getDailyStats', async (req, res) => {
    try {
        const totalRes = await pool.query('SELECT COUNT(*) FROM students');
        const total = parseInt(totalRes.rows[0].count);

        const presentTodayRes = await pool.query(
            "SELECT COUNT(*) FROM attendance WHERE date = CURRENT_DATE AND status = 'Present'"
        );
        const presentToday = parseInt(presentTodayRes.rows[0].count);

        const presentYesterdayRes = await pool.query(
            "SELECT COUNT(*) FROM attendance WHERE date = CURRENT_DATE - INTERVAL '1 day' AND status = 'Present'"
        );
        const presentYesterday = parseInt(presentYesterdayRes.rows[0].count);

        // Trend vs yesterday
        let trend = 0;
        if (presentYesterday > 0) {
            trend = ((presentToday - presentYesterday) / presentYesterday) * 100;
        }

        // Last month absent %
        const absentLastMonthRes = await pool.query(
            "SELECT COUNT(*) FROM attendance WHERE date >= CURRENT_DATE - INTERVAL '30 days' AND status = 'Absent'"
        );
        const absentLastMonth = parseInt(absentLastMonthRes.rows[0].count);
        const lastMonthPercent = total > 0 ? Math.round((absentLastMonth / total) * 100) : 0;

        res.json({
            total,
            presentCount: presentToday,
            absentCount: total - presentToday,
            trend: trend.toFixed(1),
            lastMonthAbsentPercent: lastMonthPercent
        });
    } catch (err) {
        res.status(500).json({ error: 'Stats failed' });
    }
});

// --- NEW REPORT APIS ---

// 1. Get Monthly Attendance Trend (Day-by-Day for the last 30 days)
app.get('/getMonthlyTrend', async (req, res) => {
    try {
        const query = `
            SELECT 
                TO_CHAR(date, 'DD Mon') as date_label, 
                ROUND((COUNT(*) FILTER (WHERE status = 'Present')::numeric / COUNT(*)) * 100, 1) as percentage
            FROM attendance
            WHERE date >= CURRENT_DATE - INTERVAL '30 days'
            GROUP BY date
            ORDER BY date ASC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Trend analysis failed' });
    }
});

// 2. Get Class-wise Attendance Comparison
app.get('/getClassComparison', async (req, res) => {
    try {
        const query = `
            SELECT 
                s.class, 
                ROUND((COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) * 100, 1) as rate
            FROM students s
            JOIN attendance a ON s.id = a.student_id
            GROUP BY s.class
            ORDER BY rate DESC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Class comparison failed' });
    }
});

// 3. Get At-Risk Students (Attendance below 75%)
app.get('/getRiskStudents', async (req, res) => {
    try {
        const query = `
            SELECT 
                s.name, 
                s.class, 
                ROUND((COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) * 100, 1) as rate
            FROM students s
            JOIN attendance a ON s.id = a.student_id
            GROUP BY s.id, s.name, s.class
            HAVING (COUNT(a.id) FILTER (WHERE a.status = 'Present')::numeric / COUNT(a.id)) < 0.75
            ORDER BY rate ASC;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Risk assessment failed' });
    }
});


app.get('/getClassSummary', async (req, res) => {
    try {
        const query = `
            SELECT 
                class, 
                COUNT(id) as total_students,
                ROUND((COUNT(id) FILTER (WHERE id IN (SELECT student_id FROM attendance WHERE date = CURRENT_DATE AND status = 'Present'))::numeric / COUNT(id)) * 100) as today_percent
            FROM students
            GROUP BY class;
        `;
        const result = await pool.query(query);
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: 'Class summary failed' });
    }
});


// Get all absent students for today
app.get('/getAbsentStudents', async (req, res) => {
    try {
        const query = `
            SELECT s.id, s.name, s.class
            FROM students s
            WHERE s.id NOT IN (
                SELECT student_id
                FROM attendance
                WHERE date = CURRENT_DATE AND status = 'Present'
            )
            ORDER BY s.class, s.name;
        `;
        const result = await pool.query(query);
        res.json(result.rows); // make sure 'rows' contains {id, name, class}
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch absent students' });
    }
});


// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT} at 192.168.1.193`);
});