// api.js should define API_BASE and apiGet
// import { apiGet } from './api.js';

document.addEventListener("DOMContentLoaded", () => {
    loadMonthlyTrend();
    loadClassComparison();
    loadRiskStudents();
});

/* ==========================
   MONTHLY ATTENDANCE TREND
========================== */
async function loadMonthlyTrend() {
    try {
        const chartEl = document.getElementById("monthlyTrendChart");
        if (!chartEl) return console.warn("Monthly Trend canvas not found");

        const data = await apiGet("/getMonthlyTrend");
        if (!data || data.length === 0) {
            chartEl.parentElement.innerHTML = "<p>No monthly attendance data available.</p>";
            return;
        }

        const labels = data.map(d => d.date_label || "");
        const percentages = data.map(d => Number(d.percentage || 0));

        new Chart(chartEl.getContext("2d"), {
            type: "line",
            data: {
                labels,
                datasets: [{
                    label: "Attendance %",
                    data: percentages,
                    borderColor: "#1a2a44",
                    backgroundColor: "rgba(26, 42, 68, 0.1)",
                    fill: true,
                    tension: 0.4,
                    pointRadius: 3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    } catch (err) {
        console.error("Monthly Trend Error:", err);
    }
}

/* ==========================
   CLASS COMPARISON
========================== */
async function loadClassComparison() {
    try {
        const chartEl = document.getElementById("classComparisonChart");
        if (!chartEl) return console.warn("Class Comparison canvas not found");

        const data = await apiGet("/getClassComparison");
        if (!data || data.length === 0) {
            chartEl.parentElement.innerHTML = "<p>No class comparison data available.</p>";
            return;
        }

        const labels = data.map(d => d.class || "");
        const rates = data.map(d => Number(d.rate || 0));

        new Chart(chartEl.getContext("2d"), {
            type: "bar",
            data: {
                labels,
                datasets: [{
                    label: "Attendance %",
                    data: rates,
                    backgroundColor: "#3b82f6",
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: { y: { beginAtZero: true, max: 100 } }
            }
        });
    } catch (err) {
        console.error("Class Comparison Error:", err);
    }
}

/* ==========================
   AT-RISK STUDENTS
========================== */
async function loadRiskStudents() {
    try {
        const table = document.getElementById("riskTable");
        if (!table) return console.warn("Risk Table element not found");

        const data = await apiGet("/getRiskStudents");
        if (!data || data.length === 0) {
            table.innerHTML = `
                <tr>
                    <td colspan="3" style="text-align:center;">
                        🎉 No students at risk. Well done!
                    </td>
                </tr>`;
            return;
        }

        table.innerHTML = data.map(s => `
            <tr>
                <td>${s.name || "-"}</td>
                <td>${s.class || "-"}</td>
                <td>
                    <span class="risk-badge">${s.rate !== undefined ? s.rate + "%" : "N/A"}</span>
                </td>
            </tr>
        `).join("");
    } catch (err) {
        console.error("Risk Students Error:", err);
    }
}
