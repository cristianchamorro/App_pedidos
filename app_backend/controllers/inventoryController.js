const pool = require('../db');

// ==================== GET ALL INVENTORY ====================
// GET /inventory
// Obtener todo el inventario con información del producto
const getAllInventory = async (req, res) => {
  try {
    const { lowStock } = req.query;

    let query = `
      SELECT 
        i.id,
        i.product_id,
        p.name AS product_name,
        c.name AS category_name,
        v.name AS vendor_name,
        i.quantity,
        i.min_quantity,
        i.max_quantity,
        i.unit_cost,
        i.last_purchase_date,
        i.last_updated,
        CASE 
          WHEN i.quantity = 0 THEN 'out_of_stock'
          WHEN i.quantity <= i.min_quantity THEN 'low_stock'
          WHEN i.quantity > i.max_quantity THEN 'excess_stock'
          ELSE 'normal'
        END AS stock_status
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN vendors v ON p.vendor_id = v.id
    `;

    if (lowStock === 'true') {
      query += ' WHERE i.quantity <= i.min_quantity';
    }

    query += ' ORDER BY c.name, p.name';

    const result = await pool.query(query);
    res.json({ success: true, inventory: result.rows });
  } catch (err) {
    console.error('Error en getAllInventory:', err);
    res.status(500).json({ error: 'Error al obtener inventario', details: err.message });
  }
};

// ==================== GET INVENTORY BY PRODUCT ====================
// GET /inventory/:productId
// Obtener stock de un producto específico
const getInventoryByProduct = async (req, res) => {
  const { productId } = req.params;

  try {
    const result = await pool.query(
      `SELECT 
        i.*,
        p.name AS product_name,
        p.price,
        c.name AS category_name,
        v.name AS vendor_name
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN vendors v ON p.vendor_id = v.id
      WHERE i.product_id = $1`,
      [productId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado en inventario' });
    }

    res.json({ success: true, inventory: result.rows[0] });
  } catch (err) {
    console.error('Error en getInventoryByProduct:', err);
    res.status(500).json({ error: 'Error al obtener inventario del producto', details: err.message });
  }
};

// ==================== ADD STOCK ====================
// POST /inventory/:productId/add
// Agregar stock (compras, devoluciones)
const addStock = async (req, res) => {
  const { productId } = req.params;
  const { quantity, cost, reason, userId } = req.body;

  if (!quantity || quantity <= 0) {
    return res.status(400).json({ error: 'La cantidad debe ser mayor a 0' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Obtener cantidad actual
    const currentInv = await client.query(
      'SELECT quantity FROM inventory WHERE product_id = $1',
      [productId]
    );

    if (currentInv.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Producto no encontrado en inventario' });
    }

    const previousQuantity = currentInv.rows[0].quantity;
    const newQuantity = previousQuantity + parseInt(quantity);

    // Actualizar inventario
    await client.query(
      `UPDATE inventory 
       SET quantity = $1, 
           last_updated = NOW(),
           unit_cost = COALESCE($2, unit_cost),
           last_purchase_date = CASE WHEN $2 IS NOT NULL THEN NOW() ELSE last_purchase_date END
       WHERE product_id = $3`,
      [newQuantity, cost, productId]
    );

    // Registrar movimiento
    await client.query(
      `INSERT INTO inventory_movements 
       (product_id, movement_type, quantity, previous_quantity, new_quantity, reason, cost, user_id)
       VALUES ($1, 'entrada', $2, $3, $4, $5, $6, $7)`,
      [productId, quantity, previousQuantity, newQuantity, reason, cost, userId]
    );

    await client.query('COMMIT');

    res.json({ 
      success: true, 
      message: 'Stock agregado correctamente',
      previousQuantity,
      newQuantity
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error en addStock:', err);
    res.status(500).json({ error: 'Error al agregar stock', details: err.message });
  } finally {
    client.release();
  }
};

// ==================== REMOVE STOCK ====================
// POST /inventory/:productId/remove
// Quitar stock (ventas, mermas)
const removeStock = async (req, res) => {
  const { productId } = req.params;
  const { quantity, reason, userId, orderId } = req.body;

  if (!quantity || quantity <= 0) {
    return res.status(400).json({ error: 'La cantidad debe ser mayor a 0' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Obtener cantidad actual
    const currentInv = await client.query(
      'SELECT quantity FROM inventory WHERE product_id = $1',
      [productId]
    );

    if (currentInv.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Producto no encontrado en inventario' });
    }

    const previousQuantity = currentInv.rows[0].quantity;

    if (previousQuantity < quantity) {
      await client.query('ROLLBACK');
      return res.status(400).json({ 
        error: 'Stock insuficiente',
        available: previousQuantity,
        requested: quantity
      });
    }

    const newQuantity = previousQuantity - parseInt(quantity);

    // Actualizar inventario
    await client.query(
      `UPDATE inventory 
       SET quantity = $1, last_updated = NOW()
       WHERE product_id = $2`,
      [newQuantity, productId]
    );

    // Registrar movimiento
    await client.query(
      `INSERT INTO inventory_movements 
       (product_id, movement_type, quantity, previous_quantity, new_quantity, reason, order_id, user_id)
       VALUES ($1, 'salida', $2, $3, $4, $5, $6, $7)`,
      [productId, -quantity, previousQuantity, newQuantity, reason, orderId, userId]
    );

    await client.query('COMMIT');

    res.json({ 
      success: true, 
      message: 'Stock removido correctamente',
      previousQuantity,
      newQuantity
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error en removeStock:', err);
    res.status(500).json({ error: 'Error al remover stock', details: err.message });
  } finally {
    client.release();
  }
};

// ==================== ADJUST STOCK ====================
// POST /inventory/:productId/adjust
// Ajustar stock (inventario físico, correcciones)
const adjustStock = async (req, res) => {
  const { productId } = req.params;
  const { newQuantity, reason, userId } = req.body;

  if (newQuantity === undefined || newQuantity < 0) {
    return res.status(400).json({ error: 'La cantidad debe ser 0 o mayor' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Obtener cantidad actual
    const currentInv = await client.query(
      'SELECT quantity FROM inventory WHERE product_id = $1',
      [productId]
    );

    if (currentInv.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Producto no encontrado en inventario' });
    }

    const previousQuantity = currentInv.rows[0].quantity;
    const difference = newQuantity - previousQuantity;

    // Actualizar inventario
    await client.query(
      `UPDATE inventory 
       SET quantity = $1, last_updated = NOW()
       WHERE product_id = $2`,
      [newQuantity, productId]
    );

    // Registrar movimiento
    await client.query(
      `INSERT INTO inventory_movements 
       (product_id, movement_type, quantity, previous_quantity, new_quantity, reason, user_id)
       VALUES ($1, 'ajuste', $2, $3, $4, $5, $6)`,
      [productId, difference, previousQuantity, newQuantity, reason || 'Ajuste de inventario', userId]
    );

    await client.query('COMMIT');

    res.json({ 
      success: true, 
      message: 'Inventario ajustado correctamente',
      previousQuantity,
      newQuantity,
      difference
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error en adjustStock:', err);
    res.status(500).json({ error: 'Error al ajustar stock', details: err.message });
  } finally {
    client.release();
  }
};

// ==================== GET MOVEMENTS ====================
// GET /inventory/movements
// Obtener historial de movimientos de inventario
const getMovements = async (req, res) => {
  const { productId, startDate, endDate, movementType, limit = 100 } = req.query;

  try {
    let query = `
      SELECT 
        im.*,
        p.name AS product_name,
        ua.name AS user_name
      FROM inventory_movements im
      JOIN products p ON im.product_id = p.id
      LEFT JOIN user_admin ua ON im.user_id = ua.id
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (productId) {
      query += ` AND im.product_id = $${paramCount++}`;
      params.push(productId);
    }

    if (startDate) {
      query += ` AND im.created_at >= $${paramCount++}`;
      params.push(startDate);
    }

    if (endDate) {
      query += ` AND im.created_at <= $${paramCount++}`;
      params.push(endDate);
    }

    if (movementType) {
      query += ` AND im.movement_type = $${paramCount++}`;
      params.push(movementType);
    }

    query += ` ORDER BY im.created_at DESC LIMIT $${paramCount}`;
    params.push(limit);

    const result = await pool.query(query, params);
    res.json({ success: true, movements: result.rows });
  } catch (err) {
    console.error('Error en getMovements:', err);
    res.status(500).json({ error: 'Error al obtener movimientos', details: err.message });
  }
};

// ==================== GET ALERTS ====================
// GET /inventory/alerts
// Obtener alertas de inventario
const getAlerts = async (req, res) => {
  const { resolved, alertType } = req.query;

  try {
    let query = `
      SELECT 
        ia.*,
        p.name AS product_name,
        i.quantity AS current_quantity,
        i.min_quantity,
        i.max_quantity
      FROM inventory_alerts ia
      JOIN products p ON ia.product_id = p.id
      JOIN inventory i ON ia.product_id = i.product_id
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (resolved !== undefined) {
      query += ` AND ia.resolved = $${paramCount++}`;
      params.push(resolved === 'true');
    }

    if (alertType) {
      query += ` AND ia.alert_type = $${paramCount++}`;
      params.push(alertType);
    }

    query += ' ORDER BY ia.alert_date DESC';

    const result = await pool.query(query, params);
    res.json({ success: true, alerts: result.rows });
  } catch (err) {
    console.error('Error en getAlerts:', err);
    res.status(500).json({ error: 'Error al obtener alertas', details: err.message });
  }
};

// ==================== RESOLVE ALERT ====================
// PUT /inventory/alerts/:alertId/resolve
// Marcar una alerta como resuelta
const resolveAlert = async (req, res) => {
  const { alertId } = req.params;
  const { userId } = req.body;

  try {
    const result = await pool.query(
      `UPDATE inventory_alerts 
       SET resolved = TRUE, resolved_date = NOW(), resolved_by = $1
       WHERE id = $2
       RETURNING *`,
      [userId, alertId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Alerta no encontrada' });
    }

    res.json({ success: true, alert: result.rows[0] });
  } catch (err) {
    console.error('Error en resolveAlert:', err);
    res.status(500).json({ error: 'Error al resolver alerta', details: err.message });
  }
};

// ==================== UPDATE INVENTORY SETTINGS ====================
// PUT /inventory/:productId/settings
// Actualizar configuración de inventario (min, max, cost)
const updateInventorySettings = async (req, res) => {
  const { productId } = req.params;
  const { minQuantity, maxQuantity, unitCost } = req.body;

  if (minQuantity !== undefined && maxQuantity !== undefined && minQuantity > maxQuantity) {
    return res.status(400).json({ error: 'La cantidad mínima no puede ser mayor que la máxima' });
  }

  try {
    const updates = [];
    const params = [];
    let paramCount = 1;

    if (minQuantity !== undefined) {
      updates.push(`min_quantity = $${paramCount++}`);
      params.push(minQuantity);
    }

    if (maxQuantity !== undefined) {
      updates.push(`max_quantity = $${paramCount++}`);
      params.push(maxQuantity);
    }

    if (unitCost !== undefined) {
      updates.push(`unit_cost = $${paramCount++}`);
      params.push(unitCost);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No hay cambios para aplicar' });
    }

    updates.push(`last_updated = NOW()`);
    params.push(productId);

    const result = await pool.query(
      `UPDATE inventory SET ${updates.join(', ')} WHERE product_id = $${paramCount} RETURNING *`,
      params
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado en inventario' });
    }

    res.json({ success: true, inventory: result.rows[0] });
  } catch (err) {
    console.error('Error en updateInventorySettings:', err);
    res.status(500).json({ error: 'Error al actualizar configuración', details: err.message });
  }
};

module.exports = {
  getAllInventory,
  getInventoryByProduct,
  addStock,
  removeStock,
  adjustStock,
  getMovements,
  getAlerts,
  resolveAlert,
  updateInventorySettings
};
