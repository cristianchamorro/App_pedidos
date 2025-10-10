const pool = require('../db');
const { cambiarEstadoPedido } = require('./pedidosController');

const ESTADOS_ACTIVOS = ['pendiente', 'preparando', 'listo'];
const ESTADOS_HISTORICOS = ['entregado', 'cancelado'];

// Devuelve un mapa columna->tipo y resuelve sinónimos
const getDriversColumns = async () => {
  const q = `
    SELECT column_name, udt_name
    FROM information_schema.columns
    WHERE table_name = 'drivers'
  `;
  const { rows } = await pool.query(q);
  const cols = rows.reduce((acc, r) => {
    acc[r.column_name.toLowerCase()] = r.udt_name.toLowerCase();
    return acc;
  }, {});

  // Resolver sinónimos
  const pickFirst = (...names) => names.find(n => cols[n] !== undefined);

  const statusCol = pickFirst('status', 'estado');
  const locationCol = pickFirst('location', 'ubicacion', 'posicion');
  const updatedAtCol = pickFirst('updated_at', 'actualizado', 'fecha_actualizacion', 'fecha_update');

  return {
    raw: cols,
    statusCol,
    locationCol,
    updatedAtCol,
    locationType: locationCol ? cols[locationCol] : undefined, // geography o geometry
  };
};

const getTextArrayPlaceholder = (arr) => {
  return arr && Array.isArray(arr) && arr.length ? arr : null;
};

// GET /drivers/:driverId
const obtenerPerfilDriver = async (req, res) => {
  const { driverId } = req.params;
  if (!driverId) return res.status(400).json({ error: 'Falta driverId' });

  try {
    const cols = await getDriversColumns();

    const selectParts = ['id'];

    // status
    if (cols.statusCol) {
      selectParts.push(`${cols.statusCol} AS status`);
    } else {
      selectParts.push('NULL::text AS status');
    }

    // location -> lat/lng
    if (cols.locationCol) {
      selectParts.push(`COALESCE(ST_Y(${cols.locationCol}::geometry), NULL) AS lat`);
      selectParts.push(`COALESCE(ST_X(${cols.locationCol}::geometry), NULL) AS lng`);
    } else {
      selectParts.push('NULL::double precision AS lat');
      selectParts.push('NULL::double precision AS lng');
    }

    // updated_at
    if (cols.updatedAtCol) {
      selectParts.push(`${cols.updatedAtCol} AS updated_at`);
    } else {
      selectParts.push('NULL::timestamptz AS updated_at');
    }

    const q = `
      SELECT ${selectParts.join(', ')}
      FROM drivers
      WHERE id = $1
      LIMIT 1
    `;

    const { rows } = await pool.query(q, [driverId]);
    if (!rows.length) return res.status(404).json({ error: 'Domiciliario no encontrado' });

    return res.json({ success: true, driver: rows[0] });
  } catch (err) {
    console.error('Error en obtenerPerfilDriver:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// PATCH /drivers/:driverId/location
const actualizarUbicacion = async (req, res) => {
  const { driverId } = req.params;
  const { lat, lng } = req.body;

  if (!driverId || typeof lat !== 'number' || typeof lng !== 'number') {
    return res.status(400).json({ error: 'Parámetros inválidos (driverId, lat, lng)' });
  }

  try {
    const cols = await getDriversColumns();
    if (!cols.locationCol) {
      return res.status(400).json({ error: "La columna de ubicación no existe en drivers (location/ubicacion/posicion)" });
    }

    const isGeography = String(cols.locationType || '').includes('geography');
    const locationExpr = isGeography
      ? 'ST_SetSRID(ST_MakePoint($1, $2), 4326)::geography'
      : 'ST_SetSRID(ST_MakePoint($1, $2), 4326)';

    const setParts = [`${cols.locationCol} = ${locationExpr}`];
    if (cols.updatedAtCol) setParts.push(`${cols.updatedAtCol} = NOW()`);

    const q = `
      UPDATE drivers
      SET ${setParts.join(', ')}
      WHERE id = $3
      RETURNING id
    `;
    const { rows } = await pool.query(q, [lng, lat, driverId]);
    if (!rows.length) return res.status(404).json({ error: 'Domiciliario no encontrado' });
    return res.json({ success: true });
  } catch (err) {
    console.error('Error en actualizarUbicacion:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// PATCH /drivers/:driverId/status
const actualizarEstadoDriver = async (req, res) => {
  const { driverId } = req.params;
  const { status } = req.body;

  const ALLOW = ['available', 'busy', 'offline'];
  if (!driverId || !ALLOW.includes(String(status || '').toLowerCase())) {
    return res.status(400).json({ error: "Estado inválido. Use: 'available' | 'busy' | 'offline'" });
  }

  try {
    const cols = await getDriversColumns();
    if (!cols.statusCol) {
      return res.status(400).json({ error: "La columna de estado no existe en drivers (status/estado)" });
    }

    const setParts = [`${cols.statusCol} = $1`];
    if (cols.updatedAtCol) setParts.push(`${cols.updatedAtCol} = NOW()`);

    const q = `
      UPDATE drivers
      SET ${setParts.join(', ')}
      WHERE id = $2
      RETURNING id, ${cols.statusCol} AS status
    `;
    const { rows } = await pool.query(q, [status.toLowerCase(), driverId]);
    if (!rows.length) return res.status(404).json({ error: 'Domiciliario no encontrado' });
    return res.json({ success: true, driver: rows[0] });
  } catch (err) {
    console.error('Error en actualizarEstadoDriver:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// GET /drivers/:driverId/orders?estados=pendiente,listo
const obtenerPedidosAsignados = async (req, res) => {
  const { driverId } = req.params;
  const { estados } = req.query;

  if (!driverId) return res.status(400).json({ error: 'Falta driverId' });

  let estadosFiltro = ESTADOS_ACTIVOS;
  if (typeof estados === 'string' && estados.trim().length) {
    estadosFiltro = estados.split(',').map(s => s.trim().toLowerCase()).filter(Boolean);
  }

  try {
    const q = `
      SELECT 
        o.id AS order_id,
        o.total,
        o.status,
        o.created_at,
        u.name  AS cliente_nombre,
        u.phone AS cliente_telefono,
        u.address AS direccion_entrega,
        json_agg(
          json_build_object(
            'product_id', oi.product_id,
            'nombre', p.name,
            'cantidad', oi.quantity,
            'price', oi.price
          )
        ) AS productos
      FROM orders o
      JOIN users u ON u.id = o.user_id
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON p.id = oi.product_id
      WHERE o.driver_id = $1
        AND ($2::text[] IS NULL OR LOWER(TRIM(o.status)) = ANY($2))
      GROUP BY o.id, o.total, o.status, o.created_at, u.name, u.phone, u.address
      ORDER BY o.created_at ASC
    `;
    const arrayParam = getTextArrayPlaceholder(estadosFiltro);
    const { rows } = await pool.query(q, [driverId, arrayParam]);
    return res.json({ success: true, pedidos: rows });
  } catch (err) {
    console.error('Error en obtenerPedidosAsignados:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// GET /drivers/:driverId/orders/history
const obtenerHistorialPedidos = async (req, res) => {
  const { driverId } = req.params;
  if (!driverId) return res.status(400).json({ error: 'Falta driverId' });

  try {
    const q = `
      SELECT 
        o.id AS order_id,
        o.total,
        o.status,
        o.created_at,
        u.name  AS cliente_nombre,
        u.phone AS cliente_telefono,
        u.address AS direccion_entrega,
        json_agg(
          json_build_object(
            'product_id', oi.product_id,
            'nombre', p.name,
            'cantidad', oi.quantity,
            'price', oi.price
          )
        ) AS productos
      FROM orders o
      JOIN users u ON u.id = o.user_id
      JOIN order_items oi ON oi.order_id = o.id
      JOIN products p ON p.id = oi.product_id
      WHERE o.driver_id = $1
        AND LOWER(TRIM(o.status)) = ANY($2)
      GROUP BY o.id, o.total, o.status, o.created_at, u.name, u.phone, u.address
      ORDER BY o.created_at DESC
      LIMIT 100
    `;
    const { rows } = await pool.query(q, [driverId, ESTADOS_HISTORICOS]);
    return res.json({ success: true, pedidos: rows });
  } catch (err) {
    console.error('Error en obtenerHistorialPedidos:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// POST /drivers/:driverId/orders/:orderId/picked-up
const marcarPedidoRecogido = async (req, res) => {
  const { driverId, orderId } = req.params;
  if (!driverId || !orderId) return res.status(400).json({ error: 'Faltan parámetros' });

  try {
    await pool.query(
      `INSERT INTO status_history (order_id, status, changed_by)
       VALUES ($1, $2, $3)`,
      [orderId, 'picked_up', driverId]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('Error en marcarPedidoRecogido:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// POST /drivers/:driverId/orders/:orderId/on-route
const marcarPedidoEnRuta = async (req, res) => {
  const { driverId, orderId } = req.params;
  if (!driverId || !orderId) return res.status(400).json({ error: 'Faltan parámetros' });

  try {
    await pool.query(
      `INSERT INTO status_history (order_id, status, changed_by)
       VALUES ($1, $2, $3)`,
      [orderId, 'on_route', driverId]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('Error en marcarPedidoEnRuta:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

// POST /drivers/:driverId/orders/:orderId/delivered
const marcarPedidoEntregadoDriver = async (req, res) => {
  const { driverId, orderId } = req.params;
  if (!driverId || !orderId) return res.status(400).json({ error: 'Faltan parámetros' });

  try {
    const result = await cambiarEstadoPedido(orderId, 'entregado', driverId);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    return res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    console.error('Error en marcarPedidoEntregadoDriver:', err);
    return res.status(500).json({ error: 'Error en el servidor', details: err.message });
  }
};

module.exports = {
  obtenerPerfilDriver,
  actualizarUbicacion,
  actualizarEstadoDriver,
  obtenerPedidosAsignados,
  obtenerHistorialPedidos,
  marcarPedidoRecogido,
  marcarPedidoEnRuta,
  marcarPedidoEntregadoDriver,
};