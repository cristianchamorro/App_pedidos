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
// Configuración de PostgreSQL
// -----------------------------
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Bd_App',
  password: 'root',
  port: 5432,
});

pool.connect()
  .then(() => console.log('Conectado a PostgreSQL ✅'))
  .catch(err => console.error('Error conectando a PostgreSQL ❌', err));

// -----------------------------
// ENDPOINTS
// -----------------------------

// Middleware de log para todas las peticiones
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// Obtener productos
app.get('/productos', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT 
        p.id,
        p.name,
        p.price,
        p.description,
        p.image_url AS "imageUrl",
        p.category_id AS "categoryId",
        c.name AS "categoryName",
        p.vendor_id AS "vendorId",
        v.name AS "vendorName"
      FROM products p
      LEFT JOIN categories c ON p.category_id = c.id
      LEFT JOIN vendors v ON p.vendor_id = v.id
      ORDER BY c.name, v.name, p.name;
    `);
    console.log('Productos obtenidos:', result.rows.length);
    res.json(result.rows);
  } catch (err) {
    console.error('Error GET /productos:', err.message);
    res.status(500).json({ error: 'Error al obtener productos' });
  }
});

// Agregar producto
app.post('/productos', async (req, res) => {
  const { name, description, price, imageUrl, categoryId, vendorId } = req.body;
  console.log('POST /productos body:', req.body);

  if (!name || !price || !categoryId || !vendorId) {
    console.warn('Faltan campos obligatorios');
    return res.status(400).json({
      error: 'Faltan datos requeridos: name, price, categoryId o vendorId'
    });
  }

  try {
    const result = await pool.query(
      `INSERT INTO products (name, description, price, image_url, category_id, vendor_id)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING *`,
      [name, description || null, price, imageUrl || null, categoryId, vendorId]
    );
    console.log('Producto agregado:', result.rows[0]);
    res.status(201).json({
      message: 'Producto agregado correctamente',
      producto: result.rows[0]
    });
  } catch (err) {
    console.error('Error POST /productos:', err.message);
    res.status(500).json({ error: 'Error al agregar producto', details: err.message });
  }
});

// -----------------------------
// Actualizar producto parcialmente
// -----------------------------
app.put('/productos/:id', async (req, res) => {
  console.log('PUT /productos/:id');
  const { id } = req.params;
  console.log('ID recibido:', id);
  console.log('Body recibido:', req.body);

  try {
    // 1️⃣ Buscar el producto existente
    const existing = await pool.query('SELECT * FROM products WHERE id=$1', [id]);
    if (existing.rows.length === 0) {
      console.log('Producto no encontrado');
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const current = existing.rows[0];

    // 2️⃣ Tomar los campos enviados o mantener los existentes
    const name = req.body.name || current.name;
    const description = req.body.description !== undefined ? req.body.description : current.description;
    const price = req.body.price || current.price;
    const image_url = req.body.image_url || current.image_url;
    const category_id = req.body.category_id || current.category_id;
    const vendor_id = req.body.vendor_id || current.vendor_id;

    // 3️⃣ Actualizar
    const result = await pool.query(
      `UPDATE products
       SET name=$1, description=$2, price=$3, image_url=$4, category_id=$5, vendor_id=$6
       WHERE id=$7
       RETURNING *`,
      [name, description, price, image_url, category_id, vendor_id, id]
    );

    console.log('Producto actualizado correctamente:', result.rows[0]);
    res.json({
      message: 'Producto actualizado correctamente',
      producto: result.rows[0]
    });

  } catch (err) {
    console.error('Error al actualizar producto:', err.message);
    res.status(500).json({ error: 'Error al actualizar producto', details: err.message });
  }
});


// Obtener categorías
app.get('/categorias', async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, name FROM categories ORDER BY name;`);
    console.log('Categorías obtenidas:', result.rows.length);
    res.json(result.rows);
  } catch (err) {
    console.error('Error GET /categorias:', err.message);
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

// Obtener vendors
app.get('/vendors', async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, name FROM vendors ORDER BY name;`);
    console.log('Vendors obtenidos:', result.rows.length);
    res.json(result.rows);
  } catch (err) {
    console.error('Error GET /vendors:', err.message);
    res.status(500).json({ error: 'Error al obtener vendors' });
  }
});

// -----------------------------
// INICIAR SERVIDOR
// -----------------------------
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://127.0.0.1:${PORT}`);
});
