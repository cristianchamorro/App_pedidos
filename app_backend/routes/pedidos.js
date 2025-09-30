const express = require('express');
const router = express.Router();
const pedidosController = require('../controllers/pedidosController');

// Crear pedido
router.post('/', pedidosController.crearPedido);

// Obtener pedidos por estado (?estado=pendiente)
router.get('/', pedidosController.obtenerPedidosPorEstado);

// Cambios de estado
router.put('/:id/preparar', pedidosController.marcarPreparando);
router.put('/:id/listo', pedidosController.marcarListo);
router.put('/:id/entregar', pedidosController.marcarEntregado);
router.put('/:id/cancelar', pedidosController.cancelarPedido);

// Confirmar pago
router.put('/:id/pago', pedidosController.confirmarPago);

// Marcar listo desde cocina
router.put('/:id/listo-cocina', pedidosController.marcarListoCocina);

// Marcar entregado por el cliente
router.put('/:id/entregado-cliente', pedidosController.marcarEntregadoCliente);

module.exports = router;
