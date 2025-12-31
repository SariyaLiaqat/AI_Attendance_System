// ----------------------------------------
// Load Class Cards
// ----------------------------------------
async function loadClasses() {
  try {
    // ✅ Correct backend route
    const classes = await apiGet("/getClassSummary");
    const grid = document.getElementById("classGrid");

    if (!classes || classes.length === 0) {
      grid.innerHTML = `<p style="text-align:center; color:#718096;">No classes found.</p>`;
      return;
    }

    grid.innerHTML = classes.map(c => `
      <div class="class-card">
        <div class="class-title">CLASS</div>
        <h2>${c.class}</h2>
        <div class="student-count">${c.total_students || 0} Students enrolled</div>

        <div class="attendance-progress-box">
          <div class="progress-label">
            <span>Today's Attendance</span>
            <span>${c.today_percent || 0}%</span>
          </div>
          <div class="progress-bar">
            <div class="progress-fill" style="width: ${c.today_percent || 0}%"></div>
          </div>
        </div>

        <button class="take-attendance-btn"
          onclick="location.href='manual.html?class=${encodeURIComponent(c.class)}'">
          MARK ATTENDANCE
        </button>
      </div>
    `).join('');
  } catch (err) {
    console.error("Load Classes Error:", err);
    document.getElementById("classGrid").innerHTML = `<p style="color:red; text-align:center;">Failed to load classes.</p>`;
  }
}

// ----------------------------
// INITIAL CALL
// ----------------------------
loadClasses();
