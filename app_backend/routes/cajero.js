const express = require('express');
const router = express.Router();
const cajeroController = require('../controllers/cajeroController');

// -------------------- Reportes de Caja --------------------

// Obtener ventas del día actual
router.get('/ventas/dia', cajeroController.obtenerVentasDelDia);

// Obtener reporte de ventas por rango de fechas
// Parámetros: ?fecha_inicio=2024-01-01&fecha_fin=2024-01-31
router.get('/ventas/reporte', cajeroController.obtenerReporteVentas);

// Obtener historial de pagos
// Parámetros opcionales: ?limit=50&offset=0
router.get('/pagos/historial', cajeroController.obtenerHistorialPagos);

// Obtener estadísticas generales de caja
router.get('/estadisticas', cajeroController.obtenerEstadisticasCaja);

module.exports = router;
