
// Date
document.getElementById("todayDate").innerText =
  new Date().toDateString();

/* ==========================
   FETCH DAILY STATS
========================== */
async function loadStats() {
    try {
        const data = await apiGet("/getDailyStats");


        document.getElementById("totalStudents").innerText = data.total;
        document.getElementById("presentToday").innerText = data.presentCount;
        document.getElementById("absentToday").innerText = data.absentCount;

        const trendEl = document.getElementById("totalTrend");
        const isUp = data.trend >= 0;
        trendEl.innerHTML = `${isUp ? '▲' : '▼'} ${Math.abs(data.trend)}% since yesterday`;

        document.getElementById("absentTrend").innerText =
            `${data.lastMonthAbsentPercent}% last month`;
    } catch (err) {
        console.error("Stats Error:", err);
    }
}


/* ==========================
   FETCH RECENT ACTIVITY
========================== */
async function loadRecentActivity() {
    try {
        const data = await apiGet("/getRecentActivity");
        const table = document.getElementById("activityTable");
        table.innerHTML = "";

        data.forEach(item => {
            table.innerHTML += `
                <tr>
                    <td>${item.name}</td>
                    <td>${item.status}</td>
                    <td>${item.time}</td>
                </tr>
            `;
        });
    } catch (err) {
        console.error("Activity Error:", err);
    }
}



async function initChart() {
    const ctx = document.getElementById('attendanceChart').getContext('2d');
    
    // Create Gradients
    const blueGradient = ctx.createLinearGradient(0, 0, 0, 400);
    blueGradient.addColorStop(0, 'rgba(59, 130, 246, 0.2)');
    blueGradient.addColorStop(1, 'rgba(59, 130, 246, 0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
            datasets: [{
                label: 'Attendance',
                data: [2, 5, 4, 6, 8, 7], // You can map your backend 'getWeeklyAttendance' data here
                borderColor: '#1a2a44',
                backgroundColor: blueGradient,
                fill: true,
                tension: 0.4, // This makes the line "curvy"
                pointRadius: 0
            }, {
                label: 'Previous',
                data: [1, 3, 2, 5, 4, 6],
                borderColor: '#48bb78',
                fill: false,
                tension: 0.4,
                pointRadius: 0,
                borderDash: [5, 5]
            }]
        },
        options: {
            responsive: true,
            plugins: { legend: { display: false } },
            scales: {
                y: { beginAtZero: true, grid: { display: false } },
                x: { grid: { display: false } }
            }
        }
    });
}


async function loadWeeklyChart() {
    try {
        const data = await apiGet("/getWeeklyAttendance");


        const labels = data.map(item => item.day.trim());
        const values = data.map(item => item.count);

        renderChart(labels, values);
    } catch (err) {
        console.error("Weekly Chart Error:", err);
    }
}

function renderChart(labels, values) {
    const ctx = document.getElementById('attendanceChart').getContext('2d');
    
    // Gradient for the area under the curve
    const gradient = ctx.createLinearGradient(0, 0, 0, 400);
    gradient.addColorStop(0, 'rgba(26, 42, 68, 0.3)');
    gradient.addColorStop(1, 'rgba(26, 42, 68, 0)');

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels, // Live days from DB
            datasets: [{
                label: 'Present Students',
                data: values, // Live counts from DB
                borderColor: '#1a2a44',
                backgroundColor: gradient,
                fill: true,
                tension: 0.4, 
                borderWidth: 3,
                pointBackgroundColor: '#fff',
                pointBorderColor: '#1a2a44',
                pointRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: { legend: { display: false } },
            scales: {
                y: { 
                    beginAtZero: true,
                    grid: { color: '#edf2f7' },
                    ticks: { stepSize: 1 }
                },
                x: { grid: { display: false } }
            }
        }
    });
}

async function loadAbsentStudents() {
    try {
        const data = await apiGet("/getAbsentStudents");


        document.getElementById("absentToday").innerText = data.length;
        const table = document.getElementById("activityTable");
        table.innerHTML = "";

        data.forEach(student => {
            table.innerHTML += `
                <tr>
                    <td>${student.name}</td>
                    <td>Absent</td>
                    <td>-</td>
                </tr>
            `;
        });
    } catch (err) {
        console.error("Absent Students Error:", err);
    }
}




/* ==========================
   INIT DASHBOARD
========================== */
// Call this at the bottom of your file
loadStats();            // load total, present, absent count
    loadWeeklyChart();      // chart
    loadRecentActivity();   // recent table
    loadAbsentStudents();   // populate absent table
    initChart();
