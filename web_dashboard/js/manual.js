let students = [];

// Set today's date
document.getElementById("displayDate").innerText =
    new Date().toDateString();

/* ==========================
   LOAD STUDENTS
========================== */
async function loadStudents() {
    try {
        const classSelect = document.getElementById("classSelect").value;

        let url = "/getAllStudents";
        if (classSelect) {
            url += `?class=${encodeURIComponent(classSelect)}`;
        }

        students = await apiGet(url);

        const table = document.getElementById("studentsTable");
        table.innerHTML = "";

        students.forEach(s => {
            table.innerHTML += `
                <tr>
                    <td><strong>${s.other_info?.roll_no || "-"}</strong></td>
                    <td>${s.name}</td>
                    <td class="center">
                        <input 
                            type="checkbox"
                            class="present-check"
                            data-id="${s.id}"
                            id="p-${s.id}"
                            checked
                            onclick="toggleRow('${s.id}', 'present')"
                        >
                    </td>
                    <td class="center">
                        <input 
                            type="checkbox"
                            class="absent-check"
                            data-id="${s.id}"
                            id="a-${s.id}"
                            onclick="toggleRow('${s.id}', 'absent')"
                        >
                    </td>
                </tr>
            `;
        });

    } catch (err) {
        console.error("Load Students Error:", err);
        alert("❌ Failed to load students");
    }
}

/* ==========================
   CHECKBOX LOGIC
========================== */
function toggleRow(id, type) {
    const pCheck = document.getElementById(`p-${id}`);
    const aCheck = document.getElementById(`a-${id}`);

    if (type === "present" && pCheck.checked) {
        aCheck.checked = false;
    }

    if (type === "absent" && aCheck.checked) {
        pCheck.checked = false;
    }
}

/* ==========================
   SUBMIT ATTENDANCE
========================== */
async function submitAttendance() {
    try {
        const btn = document.querySelector(".submit-btn");
        btn.innerText = "Submitting...";
        btn.disabled = true;

        for (const s of students) {
            const isPresent = document.getElementById(`p-${s.id}`).checked;

            await apiPost("/markAttendance", {
                student_id: s.id,
                status: isPresent ? "Present" : "Absent"
            });
        }

        alert("✅ Attendance submitted successfully!");

    } catch (err) {
        console.error("Attendance Error:", err);
        alert("❌ Failed to submit attendance");
    } finally {
        const btn = document.querySelector(".submit-btn");
        btn.innerText = "Submit Attendance";
        btn.disabled = false;
    }
}

/* ==========================
   INIT
========================== */
loadStudents();
