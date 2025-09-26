const pool = require('../db');

exports.loginAdmin = async (req, res) => {
  const { username, password } = req.body;
  console.log(`[${new Date().toISOString()}] POST /loginAdmin recibido`, { username });

  try {
    // JOIN con Roles usando solo role_id
    const result = await pool.query(
      `SELECT ua.id, ua.username, ua.name, ua.password,
              r.id AS role_id, r.name AS role_name
       FROM user_admin ua
       JOIN roles r ON ua.role_id = r.id
       WHERE ua.username = $1 AND ua.password = $2`,
      [username, password]
    );

    console.log(`[${new Date().toISOString()}] Resultado query:`, result.rows.length, "fila(s) encontradas");

    if (result.rows.length > 0) {
      const user = result.rows[0];

      console.log(`[${new Date().toISOString()}] Login exitoso para usuario:`, username);

      res.json({
        success: true,
        user: {
          id: user.id,
          username: user.username,
          name: user.name,
          role: {
            id: user.role_id,
            name: user.role_name
          }
        }
      });
    } else {
      console.log(`[${new Date().toISOString()}] Login fallido para usuario:`, username);
      res.status(401).json({ success: false, message: "Credenciales incorrectas" });
    }
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Error en /loginAdmin:`, err);
    res.status(500).json({ error: "Error en el servidor" });
  }
};
