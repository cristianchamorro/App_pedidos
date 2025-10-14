const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');

// ==================== INVENTORY ROUTES ====================

// Get all inventory (with optional filter for low stock)
// GET /inventory?lowStock=true
router.get('/', inventoryController.getAllInventory);

// Get inventory movements history
// GET /inventory/movements?productId=1&startDate=2025-01-01&endDate=2025-01-31&movementType=entrada&limit=100
router.get('/movements', inventoryController.getMovements);

// Get inventory alerts
// GET /inventory/alerts?resolved=false&alertType=low_stock
router.get('/alerts', inventoryController.getAlerts);

// Resolve an alert
// PUT /inventory/alerts/:alertId/resolve
router.put('/alerts/:alertId/resolve', inventoryController.resolveAlert);

// Get inventory for a specific product
// GET /inventory/:productId
router.get('/:productId', inventoryController.getInventoryByProduct);

// Add stock to a product (purchases, returns)
// POST /inventory/:productId/add
// Body: { quantity, cost, reason, userId }
router.post('/:productId/add', inventoryController.addStock);

// Remove stock from a product (sales, shrinkage)
// POST /inventory/:productId/remove
// Body: { quantity, reason, userId, orderId }
router.post('/:productId/remove', inventoryController.removeStock);

// Adjust stock (physical inventory count)
// POST /inventory/:productId/adjust
// Body: { newQuantity, reason, userId }
router.post('/:productId/adjust', inventoryController.adjustStock);

// Update inventory settings (min, max, cost)
// PUT /inventory/:productId/settings
// Body: { minQuantity, maxQuantity, unitCost }
router.put('/:productId/settings', inventoryController.updateInventorySettings);

module.exports = router;
