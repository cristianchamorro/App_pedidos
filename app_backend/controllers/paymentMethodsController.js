const pool = require('../db');

// ==================== GET ALL PAYMENT METHODS ====================
// GET /payment-methods
// Obtener todos los métodos de pago
const getAllPaymentMethods = async (req, res) => {
  try {
    const { activeOnly } = req.query;

    let query = 'SELECT * FROM payment_methods';
    
    if (activeOnly === 'true') {
      query += ' WHERE active = true';
    }

    query += ' ORDER BY name';

    const result = await pool.query(query);
    res.json({ success: true, paymentMethods: result.rows });
  } catch (err) {
    console.error('Error en getAllPaymentMethods:', err);
    res.status(500).json({ error: 'Error al obtener métodos de pago', details: err.message });
  }
};

// ==================== CREATE PAYMENT METHOD ====================
// POST /payment-methods
// Crear un nuevo método de pago
const createPaymentMethod = async (req, res) => {
  const { name, active = true } = req.body;

  if (!name) {
    return res.status(400).json({ error: 'El nombre es requerido' });
  }

  try {
    const result = await pool.query(
      'INSERT INTO payment_methods (name, active) VALUES ($1, $2) RETURNING *',
      [name, active]
    );

    res.status(201).json({
      success: true,
      message: 'Método de pago creado correctamente',
      paymentMethod: result.rows[0]
    });
  } catch (err) {
    if (err.code === '23505') { // Unique violation
      return res.status(400).json({ error: 'Ya existe un método de pago con ese nombre' });
    }
    console.error('Error en createPaymentMethod:', err);
    res.status(500).json({ error: 'Error al crear método de pago', details: err.message });
  }
};

// ==================== UPDATE PAYMENT METHOD ====================
// PUT /payment-methods/:id
// Actualizar un método de pago
const updatePaymentMethod = async (req, res) => {
  const { id } = req.params;
  const { name, active } = req.body;

  try {
    const updates = [];
    const params = [];
    let paramCount = 1;

    if (name !== undefined) {
      updates.push(`name = $${paramCount++}`);
      params.push(name);
    }

    if (active !== undefined) {
      updates.push(`active = $${paramCount++}`);
      params.push(active);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No hay cambios para aplicar' });
    }

    params.push(id);

    const result = await pool.query(
      `UPDATE payment_methods SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      params
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Método de pago no encontrado' });
    }

    res.json({
      success: true,
      message: 'Método de pago actualizado correctamente',
      paymentMethod: result.rows[0]
    });
  } catch (err) {
    if (err.code === '23505') { // Unique violation
      return res.status(400).json({ error: 'Ya existe un método de pago con ese nombre' });
    }
    console.error('Error en updatePaymentMethod:', err);
    res.status(500).json({ error: 'Error al actualizar método de pago', details: err.message });
  }
};

// ==================== REGISTER ORDER PAYMENT ====================
// POST /payment-methods/order-payment
// Registrar un pago para un pedido
const registerOrderPayment = async (req, res) => {
  const { orderId, paymentMethodId, amount, reference, userId } = req.body;

  if (!orderId || !paymentMethodId || !amount) {
    return res.status(400).json({ error: 'Faltan campos requeridos: orderId, paymentMethodId, amount' });
  }

  if (amount <= 0) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Verify order exists
    const orderCheck = await client.query('SELECT id, total FROM orders WHERE id = $1', [orderId]);
    if (orderCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Pedido no encontrado' });
    }

    // Verify payment method exists and is active
    const pmCheck = await client.query(
      'SELECT id FROM payment_methods WHERE id = $1 AND active = true',
      [paymentMethodId]
    );
    if (pmCheck.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'Método de pago no válido o inactivo' });
    }

    // Register payment
    const result = await client.query(
      `INSERT INTO order_payments (order_id, payment_method_id, amount, reference, created_by)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING *`,
      [orderId, paymentMethodId, amount, reference, userId]
    );

    // Update order payment status
    const totalPaid = await client.query(
      'SELECT COALESCE(SUM(amount), 0) as total_paid FROM order_payments WHERE order_id = $1',
      [orderId]
    );

    const orderTotal = parseFloat(orderCheck.rows[0].total);
    const paidAmount = parseFloat(totalPaid.rows[0].total_paid);

    let paymentStatus = 'pendiente';
    if (paidAmount >= orderTotal) {
      paymentStatus = 'pagado';
    } else if (paidAmount > 0) {
      paymentStatus = 'parcial';
    }

    await client.query(
      'UPDATE orders SET payment_status = $1, payment_method_id = $2 WHERE id = $3',
      [paymentStatus, paymentMethodId, orderId]
    );

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Pago registrado correctamente',
      payment: result.rows[0],
      paymentStatus
    });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Error en registerOrderPayment:', err);
    res.status(500).json({ error: 'Error al registrar pago', details: err.message });
  } finally {
    client.release();
  }
};

// ==================== GET ORDER PAYMENTS ====================
// GET /payment-methods/order/:orderId
// Obtener todos los pagos de un pedido
const getOrderPayments = async (req, res) => {
  const { orderId } = req.params;

  try {
    const result = await pool.query(
      `SELECT 
        op.*,
        pm.name as payment_method_name,
        ua.name as created_by_name
      FROM order_payments op
      JOIN payment_methods pm ON op.payment_method_id = pm.id
      LEFT JOIN user_admin ua ON op.created_by = ua.id
      WHERE op.order_id = $1
      ORDER BY op.payment_date DESC`,
      [orderId]
    );

    res.json({ success: true, payments: result.rows });
  } catch (err) {
    console.error('Error en getOrderPayments:', err);
    res.status(500).json({ error: 'Error al obtener pagos del pedido', details: err.message });
  }
};

module.exports = {
  getAllPaymentMethods,
  createPaymentMethod,
  updatePaymentMethod,
  registerOrderPayment,
  getOrderPayments
};
