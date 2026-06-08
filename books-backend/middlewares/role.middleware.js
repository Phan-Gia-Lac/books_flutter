// src/middlewares/role.middleware.js

/**
 * @param {Array} allowedRoles - Mảng các role được phép (VD: ['ADMIN', 'STAFF'])
 */
module.exports = (allowedRoles) => {
    return (req, res, next) => {
        // Đảm bảo req.user đã tồn tại (phải đi qua auth.middleware trước)
        if (!req.user || !req.user.role) {
            return res.status(401).json({
                success: false,
                message: 'Không tìm thấy thông tin định danh người dùng'
            });
        }

        // Kiểm tra xem role của user có nằm trong mảng cho phép không
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                success: false,
                message: 'Bạn không có quyền thực hiện hành động này'
            });
        }

        next();
    };
};