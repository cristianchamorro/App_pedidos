const express = require('express');
const router = express.Router();
const pedidosController = require('../controllers/pedidosController');

// -------------------- Pedidos --------------------

// Crear pedido
router.post('/', pedidosController.crearPedido);

// Obtener pedidos por estado (?estado=pendiente|pagado|listo|...)
router.get('/', pedidosController.obtenerPedidosPorEstado);

// Obtener todos los pedidos (sin filtrar)
router.get('/all', pedidosController.obtenerPedidos);

// IMPORTANTE: las rutas específicas deben ir antes que '/:id' para que no las capture el parámetro
// Detalle (opcional si lo usas)
router.get('/:id/detalle', pedidosController.obtenerDetallePedido);

// Obtener pedido por id (si tu UI lo usa)
router.get('/:id', pedidosController.obtenerPedidoPorId);

// -------------------- Cambios de estado --------------------
router.put('/:id/preparar', pedidosController.marcarPreparando);
router.put('/:id/listo', pedidosController.marcarListo);
router.put('/:id/entregar', pedidosController.marcarEntregado);
router.put('/:id/cancelar', pedidosController.cancelarPedido);
router.put('/:id/pago', pedidosController.confirmarPago);

// -------------------- Cocina y cliente --------------------
router.put('/:id/listo-cocina', pedidosController.marcarListoCocina);
router.put('/:id/entregado-cliente', pedidosController.marcarEntregadoCliente);

module.exports = router;