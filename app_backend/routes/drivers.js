const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/driversController');

// Perfil y estado del driver
router.get('/:driverId', ctrl.obtenerPerfilDriver);
router.patch('/:driverId/location', ctrl.actualizarUbicacion);
router.patch('/:driverId/status', ctrl.actualizarEstadoDriver);

// Pedidos del driver
router.get('/:driverId/orders', ctrl.obtenerPedidosAsignados);
router.get('/:driverId/orders/history', ctrl.obtenerHistorialPedidos);

// Eventos de entrega
router.post('/:driverId/orders/:orderId/picked-up', ctrl.marcarPedidoRecogido);
router.post('/:driverId/orders/:orderId/on-route', ctrl.marcarPedidoEnRuta);
router.post('/:driverId/orders/:orderId/delivered', ctrl.marcarPedidoEntregadoDriver);

module.exports = router;