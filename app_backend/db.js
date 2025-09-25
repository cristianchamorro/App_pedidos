// db.js
const { Pool } = require('pg');

/// -----------------------------
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

module.exports = pool;
