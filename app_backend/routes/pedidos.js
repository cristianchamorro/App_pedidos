const express = require('express');
const router = express.Router();
const pedidosController = require('../controllers/pedidosController');

// -------------------- Pedidos --------------------

// Crear pedido
router.post('/', pedidosController.crearPedido);

// Obtener pedidos por estado (?estado=pendiente)
router.get('/', pedidosController.obtenerPedidosPorEstado);

// Obtener todos los pedidos (sin filtrar)
router.get('/all', pedidosController.obtenerPedidos);

// -------------------- Cambios de estado --------------------
router.put('/:id/preparar', pedidosController.marcarPreparando);
router.put('/:id/listo', pedidosController.marcarListo);
router.put('/:id/entregar', pedidosController.marcarEntregado);
router.put('/:id/cancelar', pedidosController.cancelarPedido);
router.put('/:id/pago', pedidosController.confirmarPago);

// -------------------- Cocina y cliente --------------------
router.put('/:id/listo-cocina', pedidosController.marcarListoCocina);
router.put('/:id/entregado-cliente', pedidosController.marcarEntregadoCliente);

// -------------------- Pedidos detalle --------------------
router.get('/detalle/:id', pedidosController.obtenerDetallePedido); // primero la más específica
router.get('/:id', pedidosController.obtenerPedidoPorId);

// -------------------- Actualizar pedido --------------------
router.put('/:id', pedidosController.actualizarPedido);

module.exports = router;
