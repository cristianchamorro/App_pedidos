const pool = require('../db');

// ==================== GET ALL EXPENSES ====================
// GET /expenses?startDate=2025-10-01&endDate=2025-10-14&category=servicios
// Obtener gastos con filtros
const getAllExpenses = async (req, res) => {
  try {
    const { startDate, endDate, category, limit = 100 } = req.query;

    let query = `
      SELECT 
        e.*,
        ua.name as created_by_name
      FROM expenses e
      LEFT JOIN user_admin ua ON e.created_by = ua.id
      WHERE 1=1
    `;

    const params = [];
    let paramCount = 1;

    if (startDate) {
      query += ` AND e.expense_date >= $${paramCount++}`;
      params.push(startDate);
    }

    if (endDate) {
      query += ` AND e.expense_date <= $${paramCount++}`;
      params.push(endDate);
    }

    if (category) {
      query += ` AND LOWER(e.category) = LOWER($${paramCount++})`;
      params.push(category);
    }

    query += ` ORDER BY e.expense_date DESC, e.created_at DESC LIMIT $${paramCount}`;
    params.push(limit);

    const result = await pool.query(query, params);
    res.json({ success: true, expenses: result.rows });
  } catch (err) {
    console.error('Error en getAllExpenses:', err);
    res.status(500).json({ error: 'Error al obtener gastos', details: err.message });
  }
};

// ==================== CREATE EXPENSE ====================
// POST /expenses
// Registrar un nuevo gasto
const createExpense = async (req, res) => {
  const { expenseDate, category, description, amount, paymentMethod, receiptNumber, userId } = req.body;

  if (!category || !description || !amount) {
    return res.status(400).json({ error: 'Faltan campos requeridos: category, description, amount' });
  }

  if (amount <= 0) {
    return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO expenses (expense_date, category, description, amount, payment_method, receipt_number, created_by)
       VALUES ($1, $2, $3, $4, $5, $6, $7)
       RETURNING *`,
      [
        expenseDate || new Date().toISOString().split('T')[0],
        category,
        description,
        amount,
        paymentMethod,
        receiptNumber,
        userId
      ]
    );

    res.status(201).json({
      success: true,
      message: 'Gasto registrado correctamente',
      expense: result.rows[0]
    });
  } catch (err) {
    console.error('Error en createExpense:', err);
    res.status(500).json({ error: 'Error al registrar gasto', details: err.message });
  }
};

// ==================== GET EXPENSE BY ID ====================
// GET /expenses/:id
// Obtener detalle de un gasto
const getExpenseById = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query(
      `SELECT 
        e.*,
        ua.name as created_by_name
      FROM expenses e
      LEFT JOIN user_admin ua ON e.created_by = ua.id
      WHERE e.id = $1`,
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Gasto no encontrado' });
    }

    res.json({ success: true, expense: result.rows[0] });
  } catch (err) {
    console.error('Error en getExpenseById:', err);
    res.status(500).json({ error: 'Error al obtener gasto', details: err.message });
  }
};

// ==================== UPDATE EXPENSE ====================
// PUT /expenses/:id
// Actualizar un gasto
const updateExpense = async (req, res) => {
  const { id } = req.params;
  const { expenseDate, category, description, amount, paymentMethod, receiptNumber } = req.body;

  try {
    // Check if expense exists
    const exists = await pool.query('SELECT id FROM expenses WHERE id = $1', [id]);
    if (exists.rows.length === 0) {
      return res.status(404).json({ error: 'Gasto no encontrado' });
    }

    const updates = [];
    const params = [];
    let paramCount = 1;

    if (expenseDate !== undefined) {
      updates.push(`expense_date = $${paramCount++}`);
      params.push(expenseDate);
    }

    if (category !== undefined) {
      updates.push(`category = $${paramCount++}`);
      params.push(category);
    }

    if (description !== undefined) {
      updates.push(`description = $${paramCount++}`);
      params.push(description);
    }

    if (amount !== undefined) {
      if (amount <= 0) {
        return res.status(400).json({ error: 'El monto debe ser mayor a 0' });
      }
      updates.push(`amount = $${paramCount++}`);
      params.push(amount);
    }

    if (paymentMethod !== undefined) {
      updates.push(`payment_method = $${paramCount++}`);
      params.push(paymentMethod);
    }

    if (receiptNumber !== undefined) {
      updates.push(`receipt_number = $${paramCount++}`);
      params.push(receiptNumber);
    }

    if (updates.length === 0) {
      return res.status(400).json({ error: 'No hay cambios para aplicar' });
    }

    params.push(id);

    const result = await pool.query(
      `UPDATE expenses SET ${updates.join(', ')} WHERE id = $${paramCount} RETURNING *`,
      params
    );

    res.json({
      success: true,
      message: 'Gasto actualizado correctamente',
      expense: result.rows[0]
    });
  } catch (err) {
    console.error('Error en updateExpense:', err);
    res.status(500).json({ error: 'Error al actualizar gasto', details: err.message });
  }
};

// ==================== DELETE EXPENSE ====================
// DELETE /expenses/:id
// Eliminar un gasto
const deleteExpense = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM expenses WHERE id = $1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Gasto no encontrado' });
    }

    res.json({
      success: true,
      message: 'Gasto eliminado correctamente'
    });
  } catch (err) {
    console.error('Error en deleteExpense:', err);
    res.status(500).json({ error: 'Error al eliminar gasto', details: err.message });
  }
};

// ==================== GET EXPENSE SUMMARY ====================
// GET /expenses/summary?startDate=2025-10-01&endDate=2025-10-14
// Resumen de gastos por categoría
const getExpenseSummary = async (req, res) => {
  try {
    const { startDate, endDate } = req.query;

    if (!startDate || !endDate) {
      return res.status(400).json({ error: 'Se requieren startDate y endDate' });
    }

    // Total by category
    const byCategory = await pool.query(
      `SELECT 
        category,
        COUNT(*) as expense_count,
        COALESCE(SUM(amount), 0) as total_amount,
        COALESCE(AVG(amount), 0) as average_amount
      FROM expenses
      WHERE expense_date BETWEEN $1 AND $2
      GROUP BY category
      ORDER BY total_amount DESC`,
      [startDate, endDate]
    );

    // Total by payment method
    const byPaymentMethod = await pool.query(
      `SELECT 
        payment_method,
        COUNT(*) as expense_count,
        COALESCE(SUM(amount), 0) as total_amount
      FROM expenses
      WHERE expense_date BETWEEN $1 AND $2
        AND payment_method IS NOT NULL
      GROUP BY payment_method
      ORDER BY total_amount DESC`,
      [startDate, endDate]
    );

    // Overall total
    const total = await pool.query(
      `SELECT 
        COUNT(*) as total_expenses,
        COALESCE(SUM(amount), 0) as total_amount
      FROM expenses
      WHERE expense_date BETWEEN $1 AND $2`,
      [startDate, endDate]
    );

    res.json({
      success: true,
      period: { startDate, endDate },
      summary: total.rows[0],
      byCategory: byCategory.rows,
      byPaymentMethod: byPaymentMethod.rows
    });
  } catch (err) {
    console.error('Error en getExpenseSummary:', err);
    res.status(500).json({ error: 'Error al obtener resumen de gastos', details: err.message });
  }
};

module.exports = {
  getAllExpenses,
  createExpense,
  getExpenseById,
  updateExpense,
  deleteExpense,
  getExpenseSummary
};
