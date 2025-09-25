const express = require('express');
const router = express.Router();
const adminDataController = require('../controllers/adminDataController');

// 🔹 Get categories
router.get('/categories', adminDataController.getCategories);

// 🔹 Get vendors
router.get('/vendors', adminDataController.getVendors);

module.exports = router;
