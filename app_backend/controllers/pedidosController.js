const pool = require('../db');

// Crear un nuevo pedido
exports.crearPedido = async (req, res) => {
  const { nombre, telefono, direccion_entrega, productos, ubicacion } = req.body;

  console.log('POST /pedidos recibido:', req.body);

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
      const insertUser = await client.query(
        `INSERT INTO users (name, phone, address, created_at)
         VALUES ($1, $2, $3, NOW())
         RETURNING id`,
        [nombre, telefono, direccion_entrega]
      );
      user_id = insertUser.rows[0].id;
    } else {
      user_id = userResult.rows[0].id;
      await client.query(`UPDATE users SET address=$1 WHERE id=$2`, [direccion_entrega, user_id]);
    }

    // 2️⃣ Asignar driver más cercano
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
      return res.status(400).json({ error: 'No hay drivers disponibles' });
    }

    const driver_id = driverResult.rows[0].id;

    // 3️⃣ Calcular total del pedido
    const total = productos.reduce((sum, p) => sum + (p.price * p.cantidad), 0);

    // 4️⃣ Insertar en ORDERS
    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total, status, driver_id, order_channel, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW())
       RETURNING id`,
      [user_id, total, 'pending', driver_id, 'APP']
    );
    const order_id = orderResult.rows[0].id;

    // 5️⃣ Insertar productos en ORDER_ITEMS
    for (const p of productos) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, price)
         VALUES ($1, $2, $3, $4)`,
        [order_id, p.id, p.cantidad, p.price]
      );
    }

    await client.query('COMMIT');
    res.status(201).json({ success: true, order_id, driver_id, total });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('💥 Error POST /pedidos:', err);
    res.status(500).json({ error: 'Error al crear pedido', details: err.message });
  } finally {
    client.release();
  }
};
