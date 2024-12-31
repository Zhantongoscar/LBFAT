const express = require('express');
const router = express.Router();

const testGroupRoutes = require('./test-group-routes');
const testItemRoutes = require('./test-item-routes');
const truthTableRoutes = require('./truth-table');
const testInstanceRoutes = require('./test-instance-routes');

router.use('/test-groups', testGroupRoutes);
router.use('/test-items', testItemRoutes);
router.use('/truth-tables', truthTableRoutes);
router.use('/test-instances', testInstanceRoutes);

module.exports = router; 