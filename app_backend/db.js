// db.js
const { Pool } = require('pg');

// Configura con tus credenciales de Postgres
const pool = new Pool({
  user: 'tu_usuario',
  host: 'localhost',  // o la IP del servidor donde esté Postgres
  database: 'nombre_base_datos',
  password: 'tu_password',
  port: 5432, // puerto por defecto de Postgres
});

module.exports = pool;
