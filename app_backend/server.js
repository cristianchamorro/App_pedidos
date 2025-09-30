// server.js
const express = require('express');
const cors = require('cors');

// -----------------------------
// crear App
// -----------------------------
const app = express();
const PORT = 3000;

// -----------------------------
// Middleware
// -----------------------------
app.use(cors());

// ⬇️ Aquí debes configurar el límite ANTES de usar cualquier ruta
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Middleware de log (después de json/urlencoded)
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

app.use('/productos', productosRoutes);
app.use('/pedidos', pedidosRoutes);
app.use('/', adminRoutes);
app.use('/admin', adminProductsRoutes);
app.use('/admin', adminDataRoutes);

// -----------------------------
// Iniciar servidor
// -----------------------------
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://127.0.0.1:${PORT}`);
});
