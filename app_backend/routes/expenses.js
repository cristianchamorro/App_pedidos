const express = require('express');
const router = express.Router();
const expensesController = require('../controllers/expensesController');

// ==================== EXPENSES ROUTES ====================

// Get expense summary (must be before /:id to avoid route conflict)
// GET /expenses/summary?startDate=2025-10-01&endDate=2025-10-14
router.get('/summary', expensesController.getExpenseSummary);

// Get all expenses with filters
// GET /expenses?startDate=2025-10-01&endDate=2025-10-14&category=servicios&limit=100
router.get('/', expensesController.getAllExpenses);

// Create new expense
// POST /expenses
// Body: { expenseDate, category, description, amount, paymentMethod, receiptNumber, userId }
router.post('/', expensesController.createExpense);

// Get expense by ID
// GET /expenses/:id
router.get('/:id', expensesController.getExpenseById);

// Update expense
// PUT /expenses/:id
// Body: { expenseDate, category, description, amount, paymentMethod, receiptNumber }
router.put('/:id', expensesController.updateExpense);

// Delete expense
// DELETE /expenses/:id
router.delete('/:id', expensesController.deleteExpense);

module.exports = router;
