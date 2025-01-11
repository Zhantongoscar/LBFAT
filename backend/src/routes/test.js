const express = require('express')
const router = express.Router()
const testController = require('../controllers/test-controller')

router.post('/execute', testController.executeTest)

module.exports = router 