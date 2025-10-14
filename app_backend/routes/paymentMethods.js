const express = require('express');
const router = express.Router();
const paymentMethodsController = require('../controllers/paymentMethodsController');

// ==================== PAYMENT METHODS ROUTES ====================

// Register a payment for an order (must be before /:id)
// POST /payment-methods/order-payment
// Body: { orderId, paymentMethodId, amount, reference, userId }
router.post('/order-payment', paymentMethodsController.registerOrderPayment);

// Get all payments for an order
// GET /payment-methods/order/:orderId
router.get('/order/:orderId', paymentMethodsController.getOrderPayments);

// Get all payment methods
// GET /payment-methods?activeOnly=true
router.get('/', paymentMethodsController.getAllPaymentMethods);

// Create payment method
// POST /payment-methods
// Body: { name, active }
router.post('/', paymentMethodsController.createPaymentMethod);

// Update payment method
// PUT /payment-methods/:id
// Body: { name, active }
router.put('/:id', paymentMethodsController.updatePaymentMethod);

module.exports = router;
