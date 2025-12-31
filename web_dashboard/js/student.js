// ----------------------------------------
// Student Analytics Page
// ----------------------------------------
const params = new URLSearchParams(window.location.search);
const studentId = params.get("id");

if (!studentId) {
  alert("Student ID missing in URL");
  throw new Error("Student ID missing");
}

// ----------------------------
// Load Student Info
// ----------------------------
async function loadStudent() {
  try {
    const students = await apiGet("/getAllStudents");
    const student = students.find(s => s.id == studentId);
    if (!student) return;

    document.getElementById("studentName").innerText = student.name;
    document.getElementById("rollNo").innerText = student.other_info?.roll_no || "-";
  } catch (err) {
    console.error("Load Student Error:", err);
  }
}

// ----------------------------
// Load Attendance Table
// ----------------------------
async function loadAttendance() {
  try {
    const records = await apiGet(`/getStudentAttendance/${studentId}`);

    // Attendance Rate
    const total = records.length;
    const presentCount = records.filter(r => r.status === 'Present').length;
    const rate = total > 0 ? Math.round((presentCount / total) * 100) : 0;

    document.getElementById("attendanceRate").innerText = rate + "%";

    // Populate Table
    const table = document.getElementById("attendanceTable");
    table.innerHTML = records.map(r => `
      <tr>
        <td>${new Date(r.date).toLocaleDateString()}</td>
        <td>
          <span class="trend ${r.status === 'Present' ? 'up' : 'down'}">
            ${r.status}
          </span>
        </td>
      </tr>
    `).join('');
  } catch (err) {
    console.error("Load Attendance Error:", err);
  }
}

// ----------------------------
// Weekly Chart
// ----------------------------
async function loadWeeklyChart() {
  try {
    const data = await apiGet(`/getStudentWeekly/${studentId}`);

    const labels = data.map(d => d.day.trim());
    const present = data.map(d => Number(d.present || 0));
    const absent = data.map(d => Number(d.absent || 0));

    const ctx = document.getElementById("weeklyChart").getContext("2d");

    new Chart(ctx, {
      type: 'bar',
      data: {
        labels,
        datasets: [
          { label: 'Present', data: present, backgroundColor: '#4CAF50' },
          { label: 'Absent', data: absent, backgroundColor: '#F44336' }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: 'top' } },
        scales: { y: { beginAtZero: true } }
      }
    });
  } catch (err) {
    console.error("Weekly Chart Error:", err);
  }
}

// ----------------------------
// Monthly Chart
// ----------------------------
async function loadMonthlyChart() {
  try {
    const data = await apiGet(`/getStudentMonthly/${studentId}`);

    let present = 0, absent = 0;
    data.forEach(d => {
      if (d.status === 'Present') present = d.count;
      else if (d.status === 'Absent') absent = d.count;
    });

    const ctx = document.getElementById("monthlyChart").getContext("2d");

    new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Present', 'Absent'],
        datasets: [{
          data: [present, absent],
          backgroundColor: ['#2196F3', '#FF9800']
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { position: 'top' } }
      }
    });
  } catch (err) {
    console.error("Monthly Chart Error:", err);
  }
}

// ----------------------------
// Tabs Logic
// ----------------------------
function showTab(tabId, element) {
  document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
  document.querySelectorAll('.tab-link').forEach(b => b.classList.remove('active'));

  document.getElementById(tabId).classList.add('active');
  element.classList.add('active');

  if (tabId === 'analytics') {
    loadWeeklyChart();
    loadMonthlyChart();
  }
}

// ----------------------------
// INITIAL LOAD
// ----------------------------
loadStudent();
loadAttendance();
// Charts are lazy-loaded when 'analytics' tab is clicked
