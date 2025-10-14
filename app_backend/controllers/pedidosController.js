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

// -------------------- Helpers --------------------
// Helper para normalizar changed_by (acepta number/numérico en string; cualquier otro => null)
const normalizeChangedBy = (val) => {
  if (val === undefined || val === null) return null;
  const n = Number(val);
  return Number.isFinite(n) ? Math.trunc(n) : null;
};

// -------------------- Funciones internas --------------------

// Helper function to release a driver back to 'available' status
const liberarDriverPorOrder = async (client, orderId) => {
  await client.query(
    `UPDATE drivers SET status='available', updated_at=NOW() 
     WHERE id=(SELECT driver_id FROM orders WHERE id=$1)`,
    [orderId]
  );
};

// Helper function to restore inventory when an order is canceled
const restaurarInventarioPorOrder = async (client, orderId) => {
  try {
    // Get all products from the canceled order
    const orderItems = await client.query(
      `SELECT oi.product_id, oi.quantity 
       FROM order_items oi
       WHERE oi.order_id = $1`,
      [orderId]
    );

    // Restore inventory for each product
    for (const item of orderItems.rows) {
      const invCheck = await client.query(
        'SELECT quantity FROM inventory WHERE product_id = $1',
        [item.product_id]
      );

      if (invCheck.rows.length > 0) {
        const currentQty = invCheck.rows[0].quantity;
        const newQty = currentQty + item.quantity;

        await client.query(
          'UPDATE inventory SET quantity = $1, last_updated = NOW() WHERE product_id = $2',
          [newQty, item.product_id]
        );

        // Log inventory movement
        await client.query(
          `INSERT INTO inventory_movements 
           (product_id, movement_type, quantity, previous_quantity, new_quantity, reason, order_id)
           VALUES ($1, 'devolucion', $2, $3, $4, $5, $6)`,
          [item.product_id, item.quantity, currentQty, newQty, 'Devolución - Pedido cancelado #' + orderId, orderId]
        );
      }
    }
  } catch (err) {
    console.error('⚠️ Error al restaurar inventario:', err.message);
    // Don't throw - we don't want to fail the cancellation
  }
};

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

    const changedByVal = normalizeChangedBy(changed_by);

    await client.query(
      `INSERT INTO status_history (order_id, status, changed_by)
       VALUES ($1, $2, $3)`,
      [id, nuevoEstado, changedByVal]
    );

    await client.query('COMMIT');
    return { success: true, pedido: result.rows[0] };
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Error en cambiarEstadoPedido:', {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
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

    // Asignar driver más cercano de forma atómica
    const driverResult = await client.query(
      `WITH candidato AS (
         SELECT id
         FROM drivers
         WHERE status='available'
         ORDER BY location <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
         LIMIT 1
         FOR UPDATE SKIP LOCKED
       )
       UPDATE drivers d
       SET status='busy', updated_at=NOW()
       FROM candidato c
       WHERE d.id=c.id
       RETURNING d.id`,
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

    // Reducir stock de inventario (si existe la tabla)
    try {
      for (const p of productos) {
        // Check if product has inventory record
        const invCheck = await client.query(
          'SELECT quantity FROM inventory WHERE product_id = $1',
          [p.id]
        );

        if (invCheck.rows.length > 0) {
          const currentQty = invCheck.rows[0].quantity;
          
          // Only deduct if there's enough stock (warning, don't block order)
          if (currentQty >= p.cantidad) {
            const newQty = currentQty - p.cantidad;
            await client.query(
              'UPDATE inventory SET quantity = $1, last_updated = NOW() WHERE product_id = $2',
              [newQty, p.id]
            );

            // Log inventory movement
            await client.query(
              `INSERT INTO inventory_movements 
               (product_id, movement_type, quantity, previous_quantity, new_quantity, reason, order_id)
               VALUES ($1, 'salida', $2, $3, $4, $5, $6)`,
              [p.id, -p.cantidad, currentQty, newQty, 'Venta - Pedido #' + order_id, order_id]
            );
          } else {
            console.warn(`⚠️ Stock insuficiente para producto ${p.id}. Disponible: ${currentQty}, Solicitado: ${p.cantidad}`);
          }
        }
      }
    } catch (invErr) {
      // Don't fail the order if inventory update fails
      console.error('⚠️ Error al actualizar inventario (orden continúa):', invErr.message);
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
    console.error('❌ Error en crearPedido:', {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
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
         'nombre', p.name,
         'cantidad', oi.quantity,
         'price', oi.price
       )
     ) AS productos
   FROM orders o
   JOIN users u ON u.id=o.user_id
   JOIN order_items oi ON oi.order_id=o.id
   JOIN products p ON p.id = oi.product_id
   WHERE LOWER(TRIM(o.status))=LOWER($1)
   GROUP BY o.id, o.total, o.status, o.created_at, u.name, u.phone, u.address
   ORDER BY o.created_at ASC`,
  [estado]
);

    res.json({ success: true, pedidos: result.rows });
  } catch (err) {
    console.error("❌ Error en obtenerPedidosPorEstado:", {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
    res.status(500).json({ error: 'Error al obtener pedidos', details: err.message });
  } finally {
    client.release();
  }
};

// Obtener todos los pedidos
const obtenerPedidos = async (req, res) => {
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
         'nombre', p.name,
         'cantidad', oi.quantity,
         'price', oi.price
       )
     ) AS productos
   FROM orders o
   JOIN users u ON u.id=o.user_id
   JOIN order_items oi ON oi.order_id=o.id
   JOIN products p ON p.id = oi.product_id
   GROUP BY o.id, o.total, o.status, o.created_at, u.name, u.phone, u.address
   ORDER BY o.created_at ASC`
);

    res.json({ success: true, pedidos: result.rows });
  } catch (err) {
    console.error("❌ Error en obtenerPedidos:", {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
    res.status(500).json({ error: 'Error al obtener pedidos', details: err.message });
  } finally {
    client.release();
  }
};

// -------------------- Cambios de estado --------------------
const marcarPreparando = (req, res) =>
  cambiarEstadoPedido(req.params.id, ESTADOS.PREPARANDO, req.body.changed_by)
    .then(result => {
      if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
      res.json({ success: true, pedido: result.pedido });
    })
    .catch(err => {
      console.error('❌ Error en marcarPreparando:', {
        code: err.code,
        message: err.message,
        detail: err.detail,
        stack: err.stack,
      });
      res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
    });

const marcarListo = (req, res) =>
  cambiarEstadoPedido(req.params.id, ESTADOS.LISTO, req.body.changed_by)
    .then(result => {
      if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
      res.json({ success: true, pedido: result.pedido });
    })
    .catch(err => {
      console.error('❌ Error en marcarListo:', {
        code: err.code,
        message: err.message,
        detail: err.detail,
        stack: err.stack,
      });
      res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
    });

const marcarEntregado = async (req, res) => {
  try {
    const result = await cambiarEstadoPedido(req.params.id, ESTADOS.ENTREGADO, req.body.changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    
    // Release driver back to available status
    if (result.success) {
      try {
        const client = await pool.connect();
        try {
          await liberarDriverPorOrder(client, req.params.id);
        } finally {
          client.release();
        }
      } catch (releaseErr) {
        console.error('Error al liberar driver:', releaseErr);
        // Continue with successful response even if driver release fails
      }
    }
    
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

const cancelarPedido = async (req, res) => {
  try {
    const result = await cambiarEstadoPedido(req.params.id, ESTADOS.CANCELADO, req.body.changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
    
    // Release driver and restore inventory
    if (result.success) {
      try {
        const client = await pool.connect();
        try {
          await liberarDriverPorOrder(client, req.params.id);
          await restaurarInventarioPorOrder(client, req.params.id);
        } finally {
          client.release();
        }
      } catch (releaseErr) {
        console.error('Error al liberar driver o restaurar inventario:', releaseErr);
        // Continue with successful response even if these operations fail
      }
    }
    
    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al actualizar estado', details: err.message });
  }
};

const confirmarPago = (req, res) =>
  cambiarEstadoPedido(req.params.id, ESTADOS.PAGADO, req.body.changed_by)
    .then(result => {
      if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
      res.json({ success: true, pedido: result.pedido });
    })
    .catch(err => {
      console.error('❌ Error en confirmarPago:', {
        code: err.code,
        message: err.message,
        detail: err.detail,
        stack: err.stack,
      });
      res.status(500).json({ error: 'Error al confirmar pago', details: err.message });
    });

const marcarListoCocina = (req, res) =>
  cambiarEstadoPedido(req.params.id, ESTADOS.LISTO, req.body.changed_by)
    .then(result => {
      if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });
      res.json({ success: true, pedido: result.pedido });
    })
    .catch(err => {
      console.error('❌ Error en marcarListoCocina:', {
        code: err.code,
        message: err.message,
        detail: err.detail,
        stack: err.stack,
      });
      res.status(500).json({ error: 'Error al marcar pedido listo', details: err.message });
    });

const marcarEntregadoCliente = async (req, res) => {
  try {
    const result = await cambiarEstadoPedido(req.params.id, ESTADOS.ENTREGADO, req.body.changed_by);
    if (result.notFound) return res.status(404).json({ success: false, message: 'Pedido no encontrado' });

    // Release driver back to available status
    if (result.success) {
      try {
        const client = await pool.connect();
        try {
          await liberarDriverPorOrder(client, req.params.id);
        } finally {
          client.release();
        }
      } catch (releaseErr) {
        console.error('Error al liberar driver:', releaseErr);
        // Continue with successful response even if driver release fails
      }
    }

    res.json({ success: true, pedido: result.pedido });
  } catch (err) {
    res.status(500).json({ error: 'Error al entregar pedido', details: err.message });
  }
};

// -------------------- Obtener detalle de pedido --------------------
const obtenerPedidoPorId = async (req, res) => {
  const { id } = req.params;
  const client = await pool.connect();
  try {
    const resultPedido = await client.query(
      `SELECT 
         o.id AS order_id, 
         u.name AS cliente_nombre, 
         u.phone AS cliente_telefono,
         u.address AS direccion_entrega, 
         o.total, 
         o.status
       FROM orders o
       JOIN users u ON u.id = o.user_id
       WHERE o.id = $1`,
      [id]
    );

    if (resultPedido.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Pedido no encontrado" });
    }

    const resultProductos = await client.query(
      `SELECT 
         oi.product_id, 
         p.name, 
         oi.quantity AS cantidad, 
         oi.price
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = $1`,
      [id]
    );

    res.json({
      success: true,
      pedido: {
        ...resultPedido.rows[0],
        productos: resultProductos.rows
      }
    });
  } catch (err) {
    console.error("❌ Error en obtenerPedidoPorId:", {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
    res.status(500).json({ success: false, error: "Error en el servidor" });
  } finally {
    client.release();
  }
};

const obtenerDetallePedido = async (req, res) => {
  const { id } = req.params;
  const client = await pool.connect();
  try {
    const resultPedido = await client.query(
      `SELECT 
         o.id AS order_id,
         u.name AS cliente_nombre,
         u.phone AS cliente_telefono,
         u.address AS direccion_entrega,
         o.total,
         o.status
       FROM orders o
       JOIN users u ON u.id=o.user_id
       WHERE o.id = $1`,
      [id]
    );

    if (resultPedido.rows.length === 0) {
      return res.status(404).json({ success: false, message: "Pedido no encontrado" });
    }

    const resultProductos = await client.query(
      `SELECT 
         oi.product_id, 
         p.name, 
         oi.quantity AS cantidad, 
         oi.price
       FROM order_items oi
       JOIN products p ON oi.product_id = p.id
       WHERE oi.order_id = $1`,
      [id]
    );

    res.json({
      success: true,
      pedido: {
        ...resultPedido.rows[0],
        productos: resultProductos.rows
      }
    });
  } catch (err) {
    console.error("❌ Error en obtenerDetallePedido:", {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
    res.status(500).json({ success: false, error: "Error en el servidor" });
  } finally {
    client.release();
  }
};

// -------------------- Actualizar pedido --------------------
const actualizarPedido = async (req, res) => {
  const { id } = req.params;
  const { nota, productos } = req.body;

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    if (nota !== undefined) {
      await client.query(`UPDATE orders SET nota = $1 WHERE id = $2`, [nota, id]);
    }

    if (Array.isArray(productos)) {
      for (const prod of productos) {
        await client.query(
          `UPDATE order_items
           SET quantity = $1, price = $2
           WHERE order_id = $3 AND product_id = $4`,
          [prod.cantidad, prod.price, id, prod.id]
        );
      }
    }

    await client.query('COMMIT');
    res.json({ success: true, message: "Pedido actualizado correctamente" });
  } catch (err) {
    await client.query('ROLLBACK');
    console.error("❌ Error en actualizarPedido:", {
      code: err.code,
      message: err.message,
      detail: err.detail,
      stack: err.stack,
    });
    res.status(500).json({ success: false, error: err.message });
  } finally {
    client.release();
  }
};

// -------------------- Export --------------------
module.exports = {
  crearPedido,
  obtenerPedidosPorEstado,
  obtenerPedidos,
  // Asegúrate que estas funciones estén definidas arriba
  obtenerPedidoPorId,
  obtenerDetallePedido,

  // Estados
  marcarPreparando,
  marcarListo,
  marcarEntregado,
  cancelarPedido,
  confirmarPago,
  marcarListoCocina,
  marcarEntregadoCliente,

  // Utilidades que usas en otros módulos (si aplica)
  cambiarEstadoPedido,

  // Actualización
  actualizarPedido,
};