const { createTransport } = require("nodemailer");
const env = require("./config/env"); // Import cấu hình tập trung

const transporter = createTransport({
    service: "gmail",
    auth: {
        user: env.email.user, // Dùng từ file config
        pass: env.email.pass,
    },
});

// Hàm hỗ trợ gửi mã OTP cho 2-step verification
const sendOTP = async (toEmail, otpCode) => {
    try {
        const info = await transporter.sendMail({
            from: `"Book Store Support" <${process.env.EMAIL_USER}>`,
            to: toEmail,
            subject: "Your 2-Step Verification Code",
            text: `Your verification code is: ${otpCode}. It will expire in 5 minutes.`,
            html: `<b>Your verification code is:</b> <h2>${otpCode}</h2><p>It will expire in 5 minutes.</p>`,
        });
        return info;
    } catch (error) {
        console.error("Error sending OTP email: ", error);
        throw error;
    }
};

module.exports = {
    transporter,
    sendOTP
};