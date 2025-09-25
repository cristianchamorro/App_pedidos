const db = require('../db'); // importamos la conexión

// Controlador para obtener productos
const getProductos = async (req, res) => {
  try {
    const result = await db.query(`
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
};

module.exports = { getProductos };
