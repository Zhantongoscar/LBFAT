const express = require('express');
const router = express.Router();

const testGroupRoutes = require('./test-group-routes');
const testItemRoutes = require('./test-item-routes');
const truthTableRoutes = require('./truth-table');

router.use('/test-groups', testGroupRoutes);
router.use('/test-items', testItemRoutes);
router.use('/truth-tables', truthTableRoutes);

module.exports = router; 