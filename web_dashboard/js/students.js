

async function loadStudents() {
    try {
        const students = await apiGet("/getAllStudents");

        const table = document.getElementById("studentsTable");
        table.innerHTML = "";

        students.forEach(s => {
            const roll = s.other_info?.roll_no || "N/A";
            table.innerHTML += `
                <tr>
                    <td>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <div class="user-avatar" style="width: 30px; height: 30px; font-size: 12px;">👤</div>
                            ${s.name}
                        </div>
                    </td>
                    <td><span style="color: #718096;">#</span> ${roll}</td>
                    <td>
                        <a href="mailto:${s.parent_email}" class="email-link">
                          ${s.parent_email || "-"}
                        </a>
                    </td>
                    <td class="center">
                        <button class="view-btn" onclick="viewStudent(${s.id})">
                          VIEW PROFILE
                        </button>
                    </td>
                </tr>
            `;
        });
    } catch (err) {
        console.error("Load students error:", err);
    }
}

function filterStudents() {
    const input = document.getElementById("studentSearch").value.toUpperCase();
    const rows = document.getElementById("studentsTable").getElementsByTagName("tr");

    for (let i = 0; i < rows.length; i++) {
        const nameCell = rows[i].getElementsByTagName("td")[0];
        const rollCell = rows[i].getElementsByTagName("td")[1];
        if (nameCell || rollCell) {
            const txtValue = (nameCell.textContent || nameCell.innerText) + 
                             (rollCell.textContent || rollCell.innerText);
            rows[i].style.display = txtValue.toUpperCase().indexOf(input) > -1 ? "" : "none";
        }
    }
}

function viewStudent(id) {
    window.location.href = `student.html?id=${id}`;
}

loadStudents();