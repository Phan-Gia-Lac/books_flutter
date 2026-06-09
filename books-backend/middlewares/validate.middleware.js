// src/middlewares/validate.middleware.js

/**
 * @param {Object} schema - Joi schema (Sẽ được định nghĩa ở Utils hoặc Routes)
 */
module.exports = (schema) => {
    return (req, res, next) => {
        // Kiểm tra dữ liệu trong req.body dựa trên schema
        const { error } = schema.validate(req.body, { abortEarly: false });

        if (error) {
            // Gom tất cả các lỗi thành một mảng text dễ đọc
            const errorMessages = error.details.map((detail) => detail.message);

            return res.status(400).json({
                success: false,
                message: 'Dữ liệu đầu vào không hợp lệ',
                errors: errorMessages
            });
        }

        next();
    };
};