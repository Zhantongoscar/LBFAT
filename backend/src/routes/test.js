const express = require('express')
const router = express.Router()
const testController = require('../controllers/test-controller')
const testPlanRoutes = require('./test-plan-routes')

// 添加日志中间件
router.use((req, res, next) => {
  console.log('Test Router:', req.method, req.path)
  next()
})

router.post('/execute', testController.executeTest)

// 添加测试计划路由
router.use('/plans', testPlanRoutes)

module.exports = router 