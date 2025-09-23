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
// Middleware de log
// -----------------------------
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
  next();
});

// -----------------------------
// ENDPOINTS
// -----------------------------

// 🔹 Login administrador
app.post('/loginAdmin', async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ success: false, message: 'Usuario y contraseña son requeridos' });
  }

  try {
    const result = await pool.query(
      `SELECT * FROM user_admin WHERE username=$1 AND password=$2 LIMIT 1`,
      [username, password]
    );

    if (result.rows.length === 0) {
      return res.json({ success: false, message: 'Credenciales inválidas' });
    }

    const user = result.rows[0];

    if (user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'No autorizado' });
    }

    console.log('Administrador autenticado:', username);
    res.json({ success: true, role: user.role });
  } catch (err) {
    console.error('Error en /loginAdmin:', err.message);
    res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
});

// 🔹 Obtener productos (todos)
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

// 🔹 Crear un nuevo pedido (usuario dinámico)
// 🔹 Crear un nuevo pedido (usuario dinámico) con logs
app.post('/pedidos', async (req, res) => {
  const { nombre, telefono, direccion_entrega, productos, ubicacion } = req.body;

  console.log('POST /pedidos recibido:', req.body); // <--- log completo del body

  // Validaciones
  if (!nombre) console.log('⚠️ nombre faltante');
  if (!telefono) console.log('⚠️ telefono faltante');
  if (!productos || productos.length === 0) console.log('⚠️ productos faltantes o vacíos');
  if (!ubicacion) console.log('⚠️ ubicacion faltante');

  if (!nombre || !telefono || !productos || productos.length === 0 || !ubicacion) {
    return res.status(400).json({ error: 'Faltan datos requeridos' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1️⃣ Verificar si el usuario ya existe
    let userResult = await client.query(
      'SELECT id FROM users WHERE name=$1 AND phone=$2 LIMIT 1',
      [nombre, telefono]
    );

    let user_id;
    if (userResult.rows.length === 0) {
      console.log('Creando usuario nuevo...');
      const insertUser = await client.query(
        `INSERT INTO users (name, phone, address, created_at)
         VALUES ($1, $2, $3, NOW())
         RETURNING id`,
        [nombre, telefono, direccion_entrega]
      );
      user_id = insertUser.rows[0].id;
      console.log('Usuario creado con id:', user_id);
    } else {
      user_id = userResult.rows[0].id;
      console.log('Usuario existente encontrado con id:', user_id);

      // Actualizar dirección si se modificó
      await client.query(`UPDATE users SET address=$1 WHERE id=$2`, [direccion_entrega, user_id]);
      console.log('Dirección actualizada a:', direccion_entrega);
    }

    // 2️⃣ Calcular driver más cercano disponible
    const driverResult = await client.query(
      `SELECT id
       FROM drivers
       WHERE status = 'available'
       ORDER BY location <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
       LIMIT 1`,
      [ubicacion.lng, ubicacion.lat]
    );

    if (driverResult.rows.length === 0) {
      await client.query('ROLLBACK');
      console.log('❌ No hay drivers disponibles');
      return res.status(400).json({ error: 'No hay drivers disponibles' });
    }

    const driver_id = driverResult.rows[0].id;
    console.log('Driver asignado con id:', driver_id);

    // 3️⃣ Calcular total del pedido
    const total = productos.reduce((sum, p) => sum + (p.price * p.cantidad), 0);
    console.log('Total calculado del pedido:', total);

    // 4️⃣ Insertar en ORDERS
    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total, status, driver_id, order_channel, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       RETURNING id`,
      [user_id, total, 'pending', driver_id, 'APP']
    );
    const order_id = orderResult.rows[0].id;
    console.log('Pedido creado con id:', order_id);

    // 5️⃣ Insertar productos en ORDER_ITEMS
    for (const p of productos) {
      console.log('Agregando producto al pedido:', p);
      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, price)
         VALUES ($1, $2, $3, $4)`,
        [order_id, p.id, p.cantidad, p.price]
      );
    }

    await client.query('COMMIT');
    console.log('✅ Pedido confirmado exitosamente');

    res.status(201).json({ success: true, order_id, driver_id, total });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('💥 Error POST /pedidos:', err);
    res.status(500).json({ error: 'Error al crear pedido', details: err.message });
  } finally {
    client.release();
  }
});

// 🔹 Agregar producto (solo admins)
app.post('/productos', async (req, res) => {
  const { name, description, price, imageUrl, categoryId, vendorId } = req.body;

  if (!name || !price || !categoryId || !vendorId) {
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
    res.status(201).json({
      message: 'Producto agregado correctamente',
      producto: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al agregar producto', details: err.message });
  }
});

// 🔹 Actualizar producto (solo admins)
app.put('/productos/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const existing = await pool.query('SELECT * FROM products WHERE id=$1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const current = existing.rows[0];
    const name = req.body.name || current.name;
    const description = req.body.description !== undefined ? req.body.description : current.description;
    const price = req.body.price || current.price;
    const image_url = req.body.image_url || current.image_url;
    const category_id = req.body.category_id || current.category_id;
    const vendor_id = req.body.vendor_id || current.vendor_id;

    const result = await pool.query(
      `UPDATE products
       SET name=$1, description=$2, price=$3, image_url=$4, category_id=$5, vendor_id=$6
       WHERE id=$7
       RETURNING *`,
      [name, description, price, image_url, category_id, vendor_id, id]
    );

    res.json({
      message: 'Producto actualizado correctamente',
      producto: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar producto', details: err.message });
  }
});

// 🔹 Obtener categorías
app.get('/categorias', async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, name FROM categories ORDER BY name;`);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener categorías' });
  }
});

// 🔹 Obtener vendors
app.get('/vendors', async (req, res) => {
  try {
    const result = await pool.query(`SELECT id, name FROM vendors ORDER BY name;`);
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener vendors' });
  }
});

// -----------------------------
// INICIAR SERVIDOR
// -----------------------------
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://127.0.0.1:${PORT}`);
});

