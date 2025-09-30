const pool = require('../db');

// -------------------- Estados --------------------
const ESTADOS = {
  PENDIENTE: 'pendiente',
  PREPARANDO: 'preparando',
  LISTO: 'listo',
  ENTREGADO: 'entregado',
  CANCELADO: 'cancelado',
  PAGADO: 'pagado'
};

// -------------------- Funciones internas --------------------

// Cambia el estado de un pedido y guarda en status_history
const cambiarEstadoPedido = async (id, nuevoEstado, changed_by = null) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const result = await client.query(
      `UPDATE orders SET status=$1 WHERE id=$2 RETURNING *`,
      [nuevoEstado, id]
    );

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return { success: false, notFound: true };
    }

    await client.query(
      `INSERT INTO status_history (order_id, status, changed_by)
       VALUES ($1, $2, $3)`,
      [id, nuevoEstado, changed_by]
    );

    await client.query('COMMIT');
    return { success: true, pedido: result.rows[0] };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// -------------------- Endpoints --------------------

// Crear pedido
const crearPedido = async (req, res) => {
  const { nombre, telefono, direccion_entrega, productos, ubicacion } = req.body;

  if (!nombre || !telefono || !productos || productos.length === 0 || !ubicacion) {
    return res.status(400).json({ error: 'Faltan datos requeridos' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Verificar usuario
    let userResult = await client.query(
      'SELECT id FROM users WHERE name=$1 AND phone=$2 LIMIT 1',
      [nombre, telefono]
    );

    let user_id;
    if (userResult.rows.length === 0) {
      const insertUser = await client.query(
        `INSERT INTO users (name, phone, address, created_at)
         VALUES ($1, $2, $3, NOW()) RETURNING id`,
        [nombre, telefono, direccion_entrega]
      );
      user_id = insertUser.rows[0].id;
    } else {
      user_id = userResult.rows[0].id;
      await client.query(`UPDATE users SET address=$1 WHERE id=$2`, [direccion_entrega, user_id]);
    }

    // Asignar driver más cercano
    const driverResult = await client.query(
      `SELECT id
       FROM drivers
       WHERE status='available'
       ORDER BY location <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
       LIMIT 1`,
      [ubicacion.lng, ubicacion.lat]
    );

    if (driverResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: 'No hay drivers disponibles' });
    }

    const driver_id = driverResult.rows[0].id;

    // Calcular total
    const total = productos.reduce((sum, p) => sum + p.price * p.cantidad, 0);

    // Insertar pedido
    const orderResult = await client.query(
      `INSERT INTO orders (user_id, total, status, driver_id, order_channel, created_at)
       VALUES ($1, $2, $3, $4, $5, NOW()) RETURNING id`,
      [user_id, total, ESTADOS.PENDIENTE, driver_id, 'APP']
    );
    const order_id = orderResult.rows[0].id;

    // Insertar productos
    for (const p of productos) {
      await client.query(
        `INSERT INTO order_items (order_id, product_id, quantity, price)
         VALUES ($1, $2, $3, $4)`,
        [order_id, p.id, p.cantidad, p.price]
      );
    }

    // Registrar en status_history
    await client.query(
      `INSERT INTO status_history (order_id, status, changed_by)
       VALUES ($1, $2, $3)`,
      [order_id, ESTADOS.PENDIENTE, null]
    );

    await client.query('COMMIT');
    res.status(201).json({ success: true, order_id, driver_id, total });
  } catch (err) {
    await client.query('ROLLBACK');
    res.status(500).json({ error: 'Error al crear pedido', details: err.message });
  } finally {
    client.release();
  }
};

// Obtener pedidos por estado
const obtenerPedidosPorEstado = async (req, res) => {
  let { estado } = req.query;
  estado = estado ? estado.trim() : '';

  if (!estado) return res.status(400).json({ error: 'Falta el parámetro de estado' });

  const client = await pool.connect();
  try {
    const result = await client.query(
      `SELECT 
         o.id AS order_id,
         o.total,
         o.status,
         o.created_at,
         u.name AS cliente_nombre,
         u.phone AS cliente_telefono,
         u.address AS direccion_entrega,
         json_agg(
           json_build_object(
             'product_id', oi.product_id,
             'cantidad', oi.quantity,
             'price', oi.price
           )
         ) AS productos
       FROM orders o
       JOIN users u ON u.id=o.user_id
       JOIN order_items oi ON oi.order_id=o.id
       WHERE LOWER(TRIM(o.status))=LOWER($1)
       GROUP BY o.id, o.total, o.status, o.created_at, u.name, u.phone, u.address
       ORDER BY o.created_at ASC`,
      [estado]
    );

    res.json({ success: true, pedidos: result.rows });
  } catch (err) {
    res.status(500).json({ error: 'Error al obtener pedidos', details: err.message });
  } finally {
    client.release();
  }
};

// Marcar preparando
const marcarPreparando = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.PREPARANDO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

// Marcar listo
const marcarListo = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.LISTO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

// Marcar entregado
const marcarEntregado = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.ENTREGADO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

// Cancelar pedido
const cancelarPedido = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.CANCELADO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

// Confirmar pago
const confirmarPago = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.PAGADO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al confirmar pago', details: err.message });
  }
};

// Marcar listo en cocina
const marcarListoCocina = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.LISTO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al marcar pedido listo', details: err.message });
  }
};

// Marcar entregado por cliente
const marcarEntregadoCliente = async (req, res) => {
  try {
    const { id } = req.params;
    const changed_by = req.body.changed_by || null;
    const result = await cambiarEstadoPedido(id, ESTADOS.ENTREGADO, changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al entregar pedido', details: err.message });
  }
};

// -------------------- Exportar --------------------
module.exports = {
  crearPedido,
  obtenerPedidosPorEstado,
  marcarPreparando,
  marcarListo,
  marcarEntregado,
  cancelarPedido,
  confirmarPago,
  marcarListoCocina,
  marcarEntregadoCliente,
  cambiarEstadoPedido
};
