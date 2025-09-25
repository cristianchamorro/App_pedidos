const express = require('express');
const router = express.Router();
const adminProductsController = require('../controllers/adminProductsController');

// 🔹 Add new product (only admins)
router.post('/products', adminProductsController.addNewProduct);

// 🔹 Update product (only admins)
router.put('/products/:id', adminProductsController.updateProductAdmin);

module.exports = router;
