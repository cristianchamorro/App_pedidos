const pool = require('../db');

// 🔹 Add new product (only admins)
exports.addNewProduct = async (req, res) => {
  const { name, description, price, imageUrl, categoryId, vendorId } = req.body;

  if (!name || !price || !categoryId || !vendorId) {
    return res.status(400).json({
      error: 'Missing required fields: name, price, categoryId or vendorId'
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
      message: 'Product added successfully',
      product: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: 'Error adding product', details: err.message });
  }
};

// 🔹 Update product (only admins)
exports.updateProductAdmin = async (req, res) => {
  const { id } = req.params;

  try {
    const existing = await pool.query('SELECT * FROM products WHERE id=$1', [id]);
    if (existing.rows.length === 0) {
      return res.status(404).json({ error: 'Product not found' });
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
      message: 'Product updated successfully',
      product: result.rows[0]
    });
  } catch (err) {
    res.status(500).json({ error: 'Error updating product', details: err.message });
  }
};
