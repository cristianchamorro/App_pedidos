# 🔧 Guía de Solución de Problemas - App Pedidos

Esta guía ayuda a resolver problemas comunes en el sistema.

---

## 📋 Tabla de Contenidos

1. [Problemas de Backend](#problemas-de-backend)
2. [Problemas de Base de Datos](#problemas-de-base-de-datos)
3. [Problemas de Frontend](#problemas-de-frontend)
4. [Problemas de Conexión](#problemas-de-conexión)
5. [Problemas de PostGIS](#problemas-de-postgis)
6. [Problemas de Dependencias](#problemas-de-dependencias)

---

## 🔴 Problemas de Backend

### Error: "Cannot find module 'express'"

**Causa:** Dependencias no instaladas.

**Solución:**
```bash
cd app_backend
npm install
```

### Error: "EADDRINUSE: address already in use :::3000"

**Causa:** El puerto 3000 ya está en uso.

**Solución 1 - Cambiar puerto:**
```bash
# Editar server.js
const PORT = 3001; // Cambiar a otro puerto
```

**Solución 2 - Liberar puerto:**
```bash
# Encontrar proceso
lsof -i :3000

# Matar proceso
kill -9 <PID>
```

### Error: "Cannot read property of undefined"

**Causa:** Datos faltantes en la petición.

**Solución:**
- Verificar que todos los campos requeridos estén presentes en el body
- Revisar la documentación de API
- Usar Postman para probar endpoints

### Backend se cuelga o no responde

**Diagnóstico:**
```bash
# Ver logs con PM2
pm2 logs app_pedidos

# Ver uso de CPU y memoria
pm2 monit

# Reiniciar aplicación
pm2 restart app_pedidos
```

---

## 💾 Problemas de Base de Datos

### Error: "ECONNREFUSED ::1:5432"

**Causa:** PostgreSQL no está corriendo o no acepta conexiones.

**Solución:**
```bash
# Verificar status
sudo systemctl status postgresql

# Iniciar PostgreSQL
sudo systemctl start postgresql

# Habilitar al inicio
sudo systemctl enable postgresql
```

### Error: "password authentication failed"

**Causa:** Credenciales incorrectas en db.js.

**Solución:**
```javascript
// Verificar db.js
const pool = new Pool({
  user: 'postgres',        // ¿Usuario correcto?
  password: 'root',        // ¿Contraseña correcta?
  database: 'Bd_App',      // ¿Base de datos existe?
  host: 'localhost',
  port: 5432,
});
```

**Verificar contraseña:**
```bash
# Intentar conectar manualmente
psql -U postgres -d Bd_App

# Si falla, cambiar contraseña
sudo -u postgres psql
ALTER USER postgres PASSWORD 'nueva_contraseña';
\q
```

### Error: "database "Bd_App" does not exist"

**Causa:** Base de datos no creada.

**Solución:**
```bash
sudo -u postgres psql
CREATE DATABASE "Bd_App";
\q
```

### Error: "relation 'products' does not exist"

**Causa:** Esquema no cargado.

**Solución:**
```bash
cd app_backend
psql -U postgres -d Bd_App -f esquema.sql
```

### Error: "duplicate key value violates unique constraint"

**Causa:** Intentando insertar datos que ya existen.

**Solución:**
```sql
-- Ver datos existentes
SELECT * FROM products;

-- Eliminar duplicados si es necesario
DELETE FROM products WHERE id = X;

-- O usar ON CONFLICT en INSERT
INSERT INTO products ... ON CONFLICT DO NOTHING;
```

### Base de datos muy lenta

**Diagnóstico:**
```sql
-- Ver queries lentas
SELECT * FROM pg_stat_activity WHERE state = 'active';

-- Ver tamaño de tablas
SELECT 
    relname AS table_name,
    pg_size_pretty(pg_total_relation_size(relid)) AS size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;
```

**Solución:**
```sql
-- Vacuum y analyze
VACUUM ANALYZE;

-- Reindex si es necesario
REINDEX DATABASE "Bd_App";
```

---

## 🎨 Problemas de Frontend

### Error: "flutter: command not found"

**Causa:** Flutter no instalado o no en PATH.

**Solución:**
```bash
# Verificar instalación
which flutter

# Agregar al PATH (en ~/.bashrc o ~/.zshrc)
export PATH="$PATH:/ruta/a/flutter/bin"
source ~/.bashrc
```

### Error: "XMLHttpRequest error"

**Causa:** CORS o backend no accesible desde el frontend.

**Solución 1 - Verificar URL:**
```dart
// En api_service.dart
final String baseUrl = 'http://localhost:3000'; // ¿Correcta?
```

**Solución 2 - Android Emulator:**
```dart
// Usar 10.0.2.2 en lugar de localhost
final String baseUrl = 'http://10.0.2.2:3000';
```

**Solución 3 - Dispositivo físico:**
```dart
// Usar IP de tu computadora
final String baseUrl = 'http://192.168.1.100:3000';
```

### Error: "Failed host lookup: 'localhost'"

**Causa:** Dispositivo móvil no puede resolver localhost.

**Solución:**
```bash
# Encontrar tu IP local
# En Linux/Mac:
ifconfig | grep "inet "

# En Windows:
ipconfig

# Usar esa IP en api_service.dart
final String baseUrl = 'http://192.168.1.100:3000';
```

### Error: "MissingPluginException"

**Causa:** Plugin no configurado correctamente.

**Solución:**
```bash
cd app_frontend

# Limpiar
flutter clean

# Reinstalar
flutter pub get

# Reconstruir
flutter run
```

### App móvil no conecta al backend

**Diagnóstico:**
```bash
# Verificar que ambos estén en la misma red
ping <IP_del_servidor>

# Verificar firewall
sudo ufw status

# Permitir puerto 3000
sudo ufw allow 3000/tcp
```

---

## 🌐 Problemas de Conexión

### "Network request failed"

**Causa:** Backend no accesible.

**Verificación:**
```bash
# ¿Backend corriendo?
curl http://localhost:3000/productos

# ¿Puerto abierto?
netstat -tulpn | grep 3000
```

### CORS Error en el navegador

**Causa:** Frontend y backend en diferentes orígenes.

**Solución:**
```javascript
// En server.js, ya debería estar:
const cors = require('cors');
app.use(cors());

// O especificar origen:
app.use(cors({
  origin: 'http://localhost:8080' // URL del frontend
}));
```

### Timeout en peticiones

**Causa:** Backend muy lento o consultas pesadas.

**Solución 1 - Aumentar timeout:**
```dart
final response = await http.get(
  url,
  // Agregar timeout (por defecto no hay)
).timeout(Duration(seconds: 30));
```

**Solución 2 - Optimizar queries:**
```sql
-- Agregar índices
CREATE INDEX idx_orders_status ON orders(status);

-- Usar EXPLAIN para analizar
EXPLAIN ANALYZE SELECT * FROM orders WHERE status = 'pendiente';
```

---

## 🗺️ Problemas de PostGIS

### Error: "type "geometry" does not exist"

**Causa:** PostGIS no instalado o no habilitado.

**Solución:**
```bash
# Instalar PostGIS
sudo apt install postgis

# Habilitar en la base de datos
sudo -u postgres psql -d Bd_App
CREATE EXTENSION postgis;
\q
```

### Error en driver location queries

**Causa:** Coordenadas mal formadas.

**Verificación:**
```sql
-- Ver drivers y sus coordenadas
SELECT 
    id, 
    name, 
    ST_AsText(location) as coords,
    ST_Y(location) as lat,
    ST_X(location) as lng
FROM drivers;
```

**Solución:**
```sql
-- Actualizar coordenadas correctamente
UPDATE drivers 
SET location = ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)
WHERE id = 1;
```

### No hay drivers disponibles

**Causa:** Todos los drivers están ocupados o no hay drivers en el sistema.

**Verificación:**
```sql
SELECT id, name, status, ST_AsText(location) 
FROM drivers 
WHERE status = 'available';
```

**Solución:**
```sql
-- Agregar drivers de prueba
INSERT INTO drivers (name, phone, status, location) VALUES 
    ('Driver Test', '555-0000', 'available', 
     ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326));

-- O cambiar estado de drivers existentes
UPDATE drivers SET status = 'available' WHERE id = 1;
```

---

## 📦 Problemas de Dependencias

### npm install falla

**Solución:**
```bash
# Limpiar caché
npm cache clean --force

# Eliminar node_modules y package-lock.json
rm -rf node_modules package-lock.json

# Reinstalar
npm install
```

### flutter pub get falla

**Solución:**
```bash
# Limpiar
flutter clean

# Actualizar Flutter
flutter upgrade

# Reinstalar
flutter pub get
```

### Conflictos de versiones

**Solución:**
```bash
# Backend
npm outdated
npm update

# Frontend
flutter pub outdated
flutter pub upgrade
```

---

## 🔍 Herramientas de Diagnóstico

### Verificar estado general del sistema

```bash
# Backend
cd app_backend
npm start # ¿Inicia correctamente?

# Base de datos
psql -U postgres -d Bd_App -c "SELECT COUNT(*) FROM products;"

# Frontend
cd app_frontend
flutter doctor # Verificar instalación de Flutter
```

### Logs importantes

```bash
# Backend (PM2)
pm2 logs app_pedidos --lines 100

# PostgreSQL
sudo tail -100 /var/log/postgresql/postgresql-*.log

# Nginx
sudo tail -100 /var/log/nginx/error.log

# Sistema
dmesg | tail -50
```

### Verificar conectividad

```bash
# Ping al servidor
ping <IP_servidor>

# Test de puerto
telnet <IP_servidor> 3000

# O con nc
nc -zv <IP_servidor> 3000

# Test HTTP
curl -v http://<IP_servidor>:3000/productos
```

---

## 📞 Obtener Ayuda Adicional

Si ninguna de estas soluciones funciona:

1. **Revisar logs completos** con detalles del error
2. **Probar en modo debug** en el backend
3. **Verificar versiones** de todas las dependencias
4. **Crear un issue** en GitHub con:
   - Descripción del problema
   - Pasos para reproducir
   - Logs completos
   - Versiones de software (Node, PostgreSQL, Flutter)
   - Sistema operativo

---

## ✅ Checklist de Diagnóstico

Antes de reportar un problema, verificar:

- [ ] Backend está corriendo (pm2 status o npm start)
- [ ] PostgreSQL está corriendo (systemctl status postgresql)
- [ ] Base de datos existe y tiene datos (psql -d Bd_App -c "\dt")
- [ ] Todas las dependencias instaladas (npm list / flutter doctor)
- [ ] URL correcta en frontend (api_service.dart)
- [ ] Firewall permite conexiones (ufw status)
- [ ] Logs revisados (pm2 logs / console.log)
- [ ] Postman puede conectarse al backend
- [ ] Variables de entorno configuradas (.env)

---

¡La mayoría de problemas se pueden resolver verificando estos puntos! 🎯
