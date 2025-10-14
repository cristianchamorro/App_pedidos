const pool = require('../db');

// ==================== DAILY SALES REPORT ====================
// GET /reports/daily?date=2025-10-14
// Reporte de ventas del día
const getDailySales = async (req, res) => {
  try {
    const { date } = req.query;
    const targetDate = date || new Date().toISOString().split('T')[0];

    const result = await pool.query(
      `SELECT 
        COUNT(*) as total_orders,
        COUNT(*) FILTER (WHERE status = 'entregado') as completed_orders,
        COUNT(*) FILTER (WHERE status = 'cancelado') as canceled_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales,
        COALESCE(SUM(total) FILTER (WHERE status != 'cancelado'), 0) as pending_sales
      FROM orders
      WHERE DATE(created_at) = $1`,
      [targetDate]
    );

    // Get payment breakdown
    const paymentBreakdown = await pool.query(
      `SELECT 
        pm.name as payment_method,
        COALESCE(SUM(op.amount), 0) as total
      FROM payment_methods pm
      LEFT JOIN order_payments op ON pm.id = op.payment_method_id
        AND DATE(op.payment_date) = $1
      WHERE pm.active = true
      GROUP BY pm.id, pm.name
      ORDER BY pm.name`,
      [targetDate]
    );

    // Get top selling products
    const topProducts = await pool.query(
      `SELECT 
        p.id,
        p.name as product_name,
        SUM(oi.quantity) as quantity_sold,
        COALESCE(SUM(oi.quantity * oi.price), 0) as total_revenue
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE DATE(o.created_at) = $1
        AND o.status != 'cancelado'
      GROUP BY p.id, p.name
      ORDER BY quantity_sold DESC
      LIMIT 10`,
      [targetDate]
    );

    res.json({
      success: true,
      date: targetDate,
      summary: result.rows[0],
      paymentBreakdown: paymentBreakdown.rows,
      topProducts: topProducts.rows
    });
  } catch (err) {
    console.error('Error en getDailySales:', err);
    res.status(500).json({ error: 'Error al obtener reporte diario', details: err.message });
  }
};

// ==================== PERIOD SALES REPORT ====================
// GET /reports/period?startDate=2025-10-01&endDate=2025-10-14
// Reporte de ventas por período
const getPeriodSales = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Se requieren startDate y endDate' });
    }

    // Overall summary
    const summary = await pool.query(
      `SELECT 
        COUNT(*) as total_orders,
        COUNT(*) FILTER (WHERE status = 'entregado') as completed_orders,
        COUNT(*) FILTER (WHERE status = 'cancelado') as canceled_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales,
        COALESCE(AVG(total) FILTER (WHERE status = 'entregado'), 0) as average_order_value
      FROM orders
      WHERE DATE(created_at) BETWEEN $1 AND $2`,
      [startDate, endDate]
    );

    // Daily breakdown
    const dailyBreakdown = await pool.query(
      `SELECT 
        DATE(created_at) as date,
        COUNT(*) as total_orders,
        COUNT(*) FILTER (WHERE status = 'entregado') as completed_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales
      FROM orders
      WHERE DATE(created_at) BETWEEN $1 AND $2
      GROUP BY DATE(created_at)
      ORDER BY date`,
      [startDate, endDate]
    );

    // Payment methods breakdown
    const paymentBreakdown = await pool.query(
      `SELECT 
        pm.name as payment_method,
        COUNT(op.id) as transaction_count,
        COALESCE(SUM(op.amount), 0) as total_amount
      FROM payment_methods pm
      LEFT JOIN order_payments op ON pm.id = op.payment_method_id
        AND DATE(op.payment_date) BETWEEN $1 AND $2
      WHERE pm.active = true
      GROUP BY pm.id, pm.name
      ORDER BY total_amount DESC`,
      [startDate, endDate]
    );

    res.json({
      success: true,
      period: { startDate, endDate },
      summary: summary.rows[0],
      dailyBreakdown: dailyBreakdown.rows,
      paymentBreakdown: paymentBreakdown.rows
    });
  } catch (err) {
    console.error('Error en getPeriodSales:', err);
    res.status(500).json({ error: 'Error al obtener reporte de período', details: err.message });
  }
};

// ==================== TOP PRODUCTS REPORT ====================
// GET /reports/by-product?startDate=2025-10-01&endDate=2025-10-14&limit=20
// Productos más vendidos
const getTopProducts = async (req, res) => {
  try {
    const { startDate, endDate, limit = 20 } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Se requieren startDate y endDate' });
    }

    const result = await pool.query(
      `SELECT 
        p.id,
        p.name as product_name,
        c.name as category_name,
        SUM(oi.quantity) as quantity_sold,
        COALESCE(SUM(oi.quantity * oi.price), 0) as total_revenue,
        COALESCE(AVG(oi.price), 0) as average_price,
        COUNT(DISTINCT oi.order_id) as order_count
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE DATE(o.created_at) BETWEEN $1 AND $2
        AND o.status != 'cancelado'
      GROUP BY p.id, p.name, c.name
      ORDER BY quantity_sold DESC
      LIMIT $3`,
      [startDate, endDate, limit]
    );

    res.json({
      success: true,
      period: { startDate, endDate },
      topProducts: result.rows
    });
  } catch (err) {
    console.error('Error en getTopProducts:', err);
    res.status(500).json({ error: 'Error al obtener productos más vendidos', details: err.message });
  }
};

// ==================== SALES BY CATEGORY ====================
// GET /reports/by-category?startDate=2025-10-01&endDate=2025-10-14
// Ventas por categoría
const getSalesByCategory = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Se requieren startDate y endDate' });
    }

    const result = await pool.query(
      `SELECT 
        c.id as category_id,
        c.name as category_name,
        COUNT(DISTINCT oi.order_id) as order_count,
        SUM(oi.quantity) as quantity_sold,
        COALESCE(SUM(oi.quantity * oi.price), 0) as total_revenue,
        COUNT(DISTINCT p.id) as unique_products
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE DATE(o.created_at) BETWEEN $1 AND $2
        AND o.status != 'cancelado'
      GROUP BY c.id, c.name
      ORDER BY total_revenue DESC`,
      [startDate, endDate]
    );

    res.json({
      success: true,
      period: { startDate, endDate },
      categorySales: result.rows
    });
  } catch (err) {
    console.error('Error en getSalesByCategory:', err);
    res.status(500).json({ error: 'Error al obtener ventas por categoría', details: err.message });
  }
};

// ==================== PROFIT REPORT ====================
// GET /reports/profit?startDate=2025-10-01&endDate=2025-10-14
// Reporte de utilidades (requiere inventario con costos)
const getProfitReport = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Se requieren startDate y endDate' });
    }

    // Calculate revenue and costs
    const result = await pool.query(
      `SELECT 
        COUNT(DISTINCT o.id) as total_orders,
        COALESCE(SUM(oi.quantity * oi.price), 0) as total_revenue,
        COALESCE(SUM(oi.quantity * COALESCE(i.unit_cost, 0)), 0) as total_cost,
        COALESCE(SUM(oi.quantity * oi.price) - SUM(oi.quantity * COALESCE(i.unit_cost, 0)), 0) as gross_profit
      FROM orders o
      JOIN order_items oi ON o.id = oi.order_id
      LEFT JOIN inventory i ON oi.product_id = i.product_id
      WHERE DATE(o.created_at) BETWEEN $1 AND $2
        AND o.status = 'entregado'`,
      [startDate, endDate]
    );

    // Get expenses for the period
    const expenses = await pool.query(
      `SELECT 
        COALESCE(SUM(amount), 0) as total_expenses,
        COUNT(*) as expense_count
      FROM expenses
      WHERE expense_date BETWEEN $1 AND $2`,
      [startDate, endDate]
    );

    const grossProfit = parseFloat(result.rows[0].gross_profit) || 0;
    const totalExpenses = parseFloat(expenses.rows[0].total_expenses) || 0;
    const netProfit = grossProfit - totalExpenses;

    // Profit by product
    const profitByProduct = await pool.query(
      `SELECT 
        p.id,
        p.name as product_name,
        SUM(oi.quantity) as quantity_sold,
        COALESCE(SUM(oi.quantity * oi.price), 0) as revenue,
        COALESCE(SUM(oi.quantity * COALESCE(i.unit_cost, 0)), 0) as cost,
        COALESCE(SUM(oi.quantity * oi.price) - SUM(oi.quantity * COALESCE(i.unit_cost, 0)), 0) as profit,
        CASE 
          WHEN SUM(oi.quantity * COALESCE(i.unit_cost, 0)) > 0 
          THEN ROUND((SUM(oi.quantity * oi.price) - SUM(oi.quantity * COALESCE(i.unit_cost, 0))) / SUM(oi.quantity * COALESCE(i.unit_cost, 0)) * 100, 2)
          ELSE 0
        END as profit_margin_pct
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      LEFT JOIN inventory i ON p.id = i.product_id
      WHERE DATE(o.created_at) BETWEEN $1 AND $2
        AND o.status = 'entregado'
      GROUP BY p.id, p.name
      ORDER BY profit DESC
      LIMIT 20`,
      [startDate, endDate]
    );

    res.json({
      success: true,
      period: { startDate, endDate },
      summary: {
        ...result.rows[0],
        total_expenses: totalExpenses,
        net_profit: netProfit,
        profit_margin: result.rows[0].total_revenue > 0 
          ? ((grossProfit / result.rows[0].total_revenue) * 100).toFixed(2) + '%'
          : '0%'
      },
      profitByProduct: profitByProduct.rows
    });
  } catch (err) {
    console.error('Error en getProfitReport:', err);
    res.status(500).json({ error: 'Error al obtener reporte de utilidades', details: err.message });
  }
};

// ==================== DASHBOARD SUMMARY ====================
// GET /reports/dashboard
// Resumen general para el dashboard
const getDashboardSummary = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    
    // Today's sales
    const todaySales = await pool.query(
      `SELECT 
        COUNT(*) as total_orders,
        COUNT(*) FILTER (WHERE status = 'entregado') as completed_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales
      FROM orders
      WHERE DATE(created_at) = $1`,
      [today]
    );

    // This week's sales (last 7 days)
    const weekSales = await pool.query(
      `SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales
      FROM orders
      WHERE DATE(created_at) >= CURRENT_DATE - INTERVAL '7 days'`
    );

    // This month's sales
    const monthSales = await pool.query(
      `SELECT 
        COUNT(*) as total_orders,
        COALESCE(SUM(total) FILTER (WHERE status = 'entregado'), 0) as total_sales
      FROM orders
      WHERE DATE(created_at) >= DATE_TRUNC('month', CURRENT_DATE)`
    );

    // Active orders (not delivered or canceled)
    const activeOrders = await pool.query(
      `SELECT COUNT(*) as active_orders
      FROM orders
      WHERE status NOT IN ('entregado', 'cancelado')`
    );

    // Low stock alerts
    const lowStockCount = await pool.query(
      `SELECT COUNT(*) as low_stock_count
      FROM inventory
      WHERE quantity <= min_quantity AND quantity > 0`
    );

    // Out of stock alerts
    const outOfStockCount = await pool.query(
      `SELECT COUNT(*) as out_of_stock_count
      FROM inventory
      WHERE quantity = 0`
    );

    res.json({
      success: true,
      today: todaySales.rows[0],
      thisWeek: weekSales.rows[0],
      thisMonth: monthSales.rows[0],
      activeOrders: activeOrders.rows[0].active_orders,
      alerts: {
        lowStock: parseInt(lowStockCount.rows[0].low_stock_count) || 0,
        outOfStock: parseInt(outOfStockCount.rows[0].out_of_stock_count) || 0
      }
    });
  } catch (err) {
    console.error('Error en getDashboardSummary:', err);
    res.status(500).json({ error: 'Error al obtener resumen del dashboard', details: err.message });
  }
};

module.exports = {
  getDailySales,
  getPeriodSales,
  getTopProducts,
  getSalesByCategory,
  getProfitReport,
  getDashboardSummary
};
