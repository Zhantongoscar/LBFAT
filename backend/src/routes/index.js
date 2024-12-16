const express = require('express');
const router = express.Router();

const truthTableRoutes = require('./truth-table-routes');
const testGroupRoutes = require('./test-group-routes');
const testInstanceRoutes = require('./test-instance-routes');

// 注册路由
router.use('/api/truth-tables', truthTableRoutes);
router.use('/api/test-groups', testGroupRoutes);
router.use('/api/test-instances', testInstanceRoutes);

module.exports = router; 