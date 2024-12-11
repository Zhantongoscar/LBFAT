const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// 验证 JWT Token
const verifyToken = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            code: 401,
            message: '未提供认证令牌'
        });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({
            code: 401,
            message: '无效的认证令牌'
        });
    }
};

// 检查是否是管理员
const isAdmin = (req, res, next) => {
    if (!req.user) {
        return res.status(401).json({
            code: 401,
            message: '未经授权的访问'
        });
    }

    if (req.user.role !== 'admin') {
        return res.status(403).json({
            code: 403,
            message: '需要管理员权限'
        });
    }

    next();
};

module.exports = {
    verifyToken,
    isAdmin
}; 