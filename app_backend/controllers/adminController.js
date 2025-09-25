const pool = require('../db');

exports.loginAdmin = async (req, res) => {
  const { username, password } = req.body;
  console.log(`[${new Date().toISOString()}] POST /loginAdmin recibido`, { username });

  try {
    const result = await pool.query(
      "SELECT * FROM user_admin WHERE username = $1 AND password = $2",
      [username, password]
    );

    console.log(`[${new Date().toISOString()}] Resultado query:`, result.rows.length, "fila(s) encontradas");

    if (result.rows.length > 0) {
      console.log(`[${new Date().toISOString()}] Login exitoso para usuario:`, username);
      res.json({ success: true, admin: result.rows[0] });
    } else {
      console.log(`[${new Date().toISOString()}] Login fallido para usuario:`, username);
      res.status(401).json({ success: false, message: "Credenciales incorrectas" });
    }
  } catch (err) {
    console.error(`[${new Date().toISOString()}] Error en /loginAdmin:`, err);
    res.status(500).json({ error: "Error en el servidor" });
  }
};
