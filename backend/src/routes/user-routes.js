const express = require('express');
const router = express.Router();
const userController = require('../controllers/user-controller');

// 获取用户列表
router.get('/', userController.getAllUsers);

// 获取单个用户
router.get('/:id', userController.getUser);

// 创建用户
router.post('/', userController.createUser);

// 更新用户
router.put('/:id', userController.updateUser);

// 删除用户
router.delete('/:id', userController.deleteUser);

module.exports = router; 