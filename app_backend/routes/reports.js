const express = require('express');
const router = express.Router();
const reportsController = require('../controllers/reportsController');

// ==================== REPORTS ROUTES ====================

// Dashboard summary
// GET /reports/dashboard
router.get('/dashboard', reportsController.getDashboardSummary);

// Daily sales report
// GET /reports/daily?date=2025-10-14
router.get('/daily', reportsController.getDailySales);

// Period sales report
// GET /reports/period?startDate=2025-10-01&endDate=2025-10-14
router.get('/period', reportsController.getPeriodSales);

// Top selling products
// GET /reports/by-product?startDate=2025-10-01&endDate=2025-10-14&limit=20
router.get('/by-product', reportsController.getTopProducts);

// Sales by category
// GET /reports/by-category?startDate=2025-10-01&endDate=2025-10-14
router.get('/by-category', reportsController.getSalesByCategory);

// Profit report
// GET /reports/profit?startDate=2025-10-01&endDate=2025-10-14
router.get('/profit', reportsController.getProfitReport);

module.exports = router;
