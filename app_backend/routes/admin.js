const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');

router.post('/loginAdmin', adminController.loginAdmin);

module.exports = router;
