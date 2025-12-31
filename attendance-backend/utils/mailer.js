const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'workingera009@gmail.com',
        pass: 'guij wamh tiln koll', // Gmail App Password
    },
});

async function sendAttendanceEmail(parentEmail, studentName, status) {
    const today = new Date().toDateString();

    const dailyMessages = [
        "Regular attendance helps build discipline and academic success.",
        "Thank you for supporting your child’s education.",
        "Consistent attendance plays a vital role in academic growth.",
        "Your cooperation helps us maintain academic excellence.",
    ];

    const extraMessage = dailyMessages[Math.floor(Math.random() * dailyMessages.length)];

    // Color and text based on status
    const color = status === 'Present' ? '#2ECC71' : '#E74C3C';
    const statusText = status;

    const mailOptions = {
        from: '"Punjab College Chichawatni" <workingera009@gmail.com>',
        to: parentEmail,
        subject: `Student Attendance Confirmation - ${statusText}`,
        html: `
            <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #2D3436;">
                <h2 style="color: #0FB9B1;">Punjab College, Chichawatni</h2>
                <hr />

                <p><strong>Dear Parent / Guardian,</strong></p>

                <p>
                    This is to inform you that your child,
                    <strong>${studentName}</strong>,
                    has been marked <strong style="color: ${color};">${statusText}</strong>
                    today.
                </p>

                <p><strong>Date:</strong> ${today}</p>

                <p style="margin-top: 15px;">
                    ${extraMessage}
                </p>

                <p>
                    If you have any questions or concerns, please feel free to contact the college administration.
                </p>

                <br />
                <p>
                    <strong>Regards,</strong><br />
                    Administration Office<br />
                    Punjab College, Chichawatni
                </p>

                <hr />
                <p style="font-size: 12px; color: #636E72;">
                    This is an automated message. Please do not reply to this email.
                </p>
            </div>
        `,
    };

    await transporter.sendMail(mailOptions);
}


module.exports = { sendAttendanceEmail };
