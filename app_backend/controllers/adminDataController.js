const pool = require('../db');

// 🔹 Get categories
exports.getCategories = async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name FROM categories ORDER BY name;');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching categories', details: err.message });
  }
};

// 🔹 Get vendors
exports.getVendors = async (req, res) => {
  try {
    const result = await pool.query('SELECT id, name FROM vendors ORDER BY name;');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: 'Error fetching vendors', details: err.message });
  }
};
