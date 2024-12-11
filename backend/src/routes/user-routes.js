const express = require('express');
const router = express.Router();
const userController = require('../controllers/user-controller');
const { verifyToken, isAdmin } = require('../middleware/auth');

// 公开路由
router.post('/login', userController.login);

// 需要登录的路由
router.get('/current', verifyToken, userController.getCurrentUser);

// 需要管理员权限的路由
router.get('/', verifyToken, isAdmin, userController.getAllUsers);
router.post('/', verifyToken, isAdmin, userController.createUser);
router.put('/:id', verifyToken, isAdmin, userController.updateUser);
router.delete('/:id', verifyToken, isAdmin, userController.deleteUser);

module.exports = router; 