const express = require('express');
const router = express.Router();
const { getProductos } = require('../controllers/productosController');

// Definimos la ruta
router.get('/', getProductos);

module.exports = router;
