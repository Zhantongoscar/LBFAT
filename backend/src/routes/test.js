const express = require('express')
const router = express.Router()
const testController = require('../controllers/test-controller')

// 添加日志中间件
router.use((req, res, next) => {
  console.log('Test Router:', req.method, req.path)
  next()
})

router.post('/execute', testController.executeTest)

module.exports = router 