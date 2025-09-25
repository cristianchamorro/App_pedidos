// server.js
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');

const app = express();
const PORT = 3000;

// -----------------------------
// Middleware
// -----------------------------
app.use(cors());
app.use(express.json());

// -----------------------------
// Middleware de log
// -----------------------------
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// -----------------------------
// Rutas
// -----------------------------
const productosRoutes = require('./routes/productos');
const pedidosRoutes = require('./routes/pedidos');
const adminRoutes = require('./routes/admin');
const adminProductsRoutes = require('./routes/adminProducts');
const adminDataRoutes = require('./routes/adminData');

// rutas generales
app.use('/productos', productosRoutes);
app.use('/pedidos', pedidosRoutes);
app.use('/', adminRoutes);

// rutas de admin
app.use('/admin', adminProductsRoutes); 
app.use('/admin', adminDataRoutes);

// -----------------------------
// INICIAR SERVIDOR
// -----------------------------
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://127.0.0.1:${PORT}`);
});
