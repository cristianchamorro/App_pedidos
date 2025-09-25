const express = require('express');
const router = express.Router();
const pedidosController = require('../controllers/pedidosController');

// Endpoint: POST /pedidos
router.post('/', pedidosController.crearPedido);

module.exports = router;
