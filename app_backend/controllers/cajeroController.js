const pool = require('../db');

// -------------------- Reportes de Caja --------------------

/**
 * Obtener resumen de ventas del día actual
 */
const obtenerVentasDelDia = async (req, res) => {
  const client = await pool.connect();
  try {
    // Ventas del día actual
    const result = await client.query(
      `SELECT 
         COUNT(*) as total_pedidos,
         SUM(total) as total_ventas,
         AVG(total) as promedio_venta
       FROM orders
       WHERE DATE(created_at) = CURRENT_DATE
       AND status != 'cancelado'`
    );

    // Ventas por estado
    const porEstado = await client.query(
      `SELECT 
         status,
         COUNT(*) as cantidad,
         SUM(total) as total
       FROM orders
       WHERE DATE(created_at) = CURRENT_DATE
       GROUP BY status
       ORDER BY status`
    );

    res.json({
      success: true,
      resumen: result.rows[0],
      por_estado: porEstado.rows
    });
  } catch (err) {
    console.error("❌ Error en obtenerVentasDelDia:", err);
    res.status(500).json({ error: 'Error al obtener ventas del día', details: err.message });
  } finally {
    client.release();
  }
};

/**
 * Obtener reporte de ventas por rango de fechas
 */
const obtenerReporteVentas = async (req, res) => {
  const { fecha_inicio, fecha_fin } = req.query;
  
  if (!fecha_inicio || !fecha_fin) {
    return res.status(400).json({ error: 'Se requieren fecha_inicio y fecha_fin' });
  }

  const client = await pool.connect();
  try {
    // Resumen general
    const resumen = await client.query(
      `SELECT 
         COUNT(*) as total_pedidos,
         SUM(total) as total_ventas,
         AVG(total) as promedio_venta,
         MIN(total) as venta_minima,
         MAX(total) as venta_maxima
       FROM orders
       WHERE created_at BETWEEN $1 AND $2
       AND status != 'cancelado'`,
      [fecha_inicio, fecha_fin]
    );

    // Ventas por día
    const porDia = await client.query(
      `SELECT 
         DATE(created_at) as fecha,
         COUNT(*) as pedidos,
         SUM(total) as ventas
       FROM orders
       WHERE created_at BETWEEN $1 AND $2
       AND status != 'cancelado'
       GROUP BY DATE(created_at)
       ORDER BY fecha DESC`,
      [fecha_inicio, fecha_fin]
    );

    // Productos más vendidos
    const productosTop = await client.query(
      `SELECT 
         p.id,
         p.name,
         SUM(oi.quantity) as cantidad_vendida,
         SUM(oi.quantity * oi.price) as total_ventas
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       JOIN orders o ON o.id = oi.order_id
       WHERE o.created_at BETWEEN $1 AND $2
       AND o.status != 'cancelado'
       GROUP BY p.id, p.name
       ORDER BY cantidad_vendida DESC
       LIMIT 10`,
      [fecha_inicio, fecha_fin]
    );

    res.json({
      success: true,
      periodo: { fecha_inicio, fecha_fin },
      resumen: resumen.rows[0],
      ventas_por_dia: porDia.rows,
      productos_mas_vendidos: productosTop.rows
    });
  } catch (err) {
    console.error("❌ Error en obtenerReporteVentas:", err);
    res.status(500).json({ error: 'Error al obtener reporte de ventas', details: err.message });
  } finally {
    client.release();
  }
};

/**
 * Obtener historial de transacciones (pagos)
 */
const obtenerHistorialPagos = async (req, res) => {
  const { limit = 50, offset = 0 } = req.query;
  
  const client = await pool.connect();
  try {
    const result = await client.query(
      `SELECT 
         o.id as pedido_id,
         o.total,
         o.created_at as fecha_pedido,
         u.name as cliente,
         u.phone as telefono,
         sh.changed_at as fecha_pago,
         sh.changed_by as cajero_id
       FROM orders o
       JOIN users u ON u.id = o.user_id
       LEFT JOIN status_history sh ON sh.order_id = o.id AND sh.status = 'pagado'
       WHERE o.status IN ('pagado', 'preparando', 'listo', 'entregado')
       ORDER BY sh.changed_at DESC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );

    const countResult = await client.query(
      `SELECT COUNT(*) as total
       FROM orders
       WHERE status IN ('pagado', 'preparando', 'listo', 'entregado')`
    );

    res.json({
      success: true,
      pagos: result.rows,
      total: parseInt(countResult.rows[0].total),
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
  } catch (err) {
    console.error("❌ Error en obtenerHistorialPagos:", err);
    res.status(500).json({ error: 'Error al obtener historial de pagos', details: err.message });
  } finally {
    client.release();
  }
};

/**
 * Obtener estadísticas de caja
 */
const obtenerEstadisticasCaja = async (req, res) => {
  const client = await pool.connect();
  try {
    // Total del día
    const hoy = await client.query(
      `SELECT 
         COUNT(*) as pedidos_hoy,
         COALESCE(SUM(total), 0) as total_hoy
       FROM orders
       WHERE DATE(created_at) = CURRENT_DATE
       AND status != 'cancelado'`
    );

    // Total de la semana
    const semana = await client.query(
      `SELECT 
         COUNT(*) as pedidos_semana,
         COALESCE(SUM(total), 0) as total_semana
       FROM orders
       WHERE created_at >= DATE_TRUNC('week', CURRENT_DATE)
       AND status != 'cancelado'`
    );

    // Total del mes
    const mes = await client.query(
      `SELECT 
         COUNT(*) as pedidos_mes,
         COALESCE(SUM(total), 0) as total_mes
       FROM orders
       WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)
       AND status != 'cancelado'`
    );

    // Pendientes de pago
    const pendientes = await client.query(
      `SELECT 
         COUNT(*) as pedidos_pendientes,
         COALESCE(SUM(total), 0) as total_pendiente
       FROM orders
       WHERE status = 'pendiente'`
    );

    res.json({
      success: true,
      estadisticas: {
        hoy: hoy.rows[0],
        semana: semana.rows[0],
        mes: mes.rows[0],
        pendientes: pendientes.rows[0]
      }
    });
  } catch (err) {
    console.error("❌ Error en obtenerEstadisticasCaja:", err);
    res.status(500).json({ error: 'Error al obtener estadísticas', details: err.message });
  } finally {
    client.release();
  }
};

module.exports = {
  obtenerVentasDelDia,
  obtenerReporteVentas,
  obtenerHistorialPagos,
  obtenerEstadisticasCaja
};
