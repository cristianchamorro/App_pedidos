# 🛠️ Scripts de Mantenimiento de Base de Datos

Scripts útiles para el mantenimiento y administración de la base de datos.

---

## 📋 Scripts Disponibles

### 1. backup.sh
Crea un backup comprimido de la base de datos.

**Uso:**
```bash
./backup.sh
```

**Características:**
- Crea backup en formato SQL
- Comprime automáticamente con gzip
- Guarda en `~/backups/app_pedidos/`
- Elimina backups antiguos (>7 días)
- Incluye timestamp en el nombre del archivo

**Ejemplo de salida:**
```
backup_20251010_153045.sql.gz
```

### 2. restore.sh
Restaura la base de datos desde un backup.

**Uso:**
```bash
./restore.sh <ruta_al_backup.sql.gz>
```

**Ejemplo:**
```bash
./restore.sh ~/backups/app_pedidos/backup_20251010_153045.sql.gz
```

**⚠️ ADVERTENCIA:** Este script elimina todos los datos actuales antes de restaurar.

---

## 🔄 Automatizar Backups

### Con Cron (Linux/Mac)

```bash
# Editar crontab
crontab -e

# Agregar línea para backup diario a las 2 AM
0 2 * * * /ruta/a/App_pedidos/app_backend/scripts/backup.sh

# O cada 6 horas
0 */6 * * * /ruta/a/App_pedidos/app_backend/scripts/backup.sh
```

### Con systemd timer (Linux)

Crear archivo de servicio:
```bash
sudo nano /etc/systemd/system/app-backup.service
```

Contenido:
```ini
[Unit]
Description=Backup App Pedidos Database

[Service]
Type=oneshot
ExecStart=/ruta/a/App_pedidos/app_backend/scripts/backup.sh
User=tu_usuario
```

Crear timer:
```bash
sudo nano /etc/systemd/system/app-backup.timer
```

Contenido:
```ini
[Unit]
Description=Daily backup of App Pedidos Database

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

Activar:
```bash
sudo systemctl enable app-backup.timer
sudo systemctl start app-backup.timer
```

---

## 📊 Comandos Útiles de Mantenimiento

### Ver tamaño de la base de datos
```bash
psql -U postgres -d Bd_App -c "
SELECT 
    pg_size_pretty(pg_database_size('Bd_App')) as db_size;
"
```

### Ver tamaño de cada tabla
```bash
psql -U postgres -d Bd_App -c "
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"
```

### Vacuum y Analyze (optimización)
```bash
psql -U postgres -d Bd_App -c "VACUUM ANALYZE;"
```

### Ver conexiones activas
```bash
psql -U postgres -d Bd_App -c "
SELECT 
    pid,
    usename,
    application_name,
    client_addr,
    state,
    query
FROM pg_stat_activity
WHERE datname = 'Bd_App';
"
```

### Ver índices no utilizados
```bash
psql -U postgres -d Bd_App -c "
SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan
FROM pg_stat_user_indexes
WHERE idx_scan = 0
ORDER BY schemaname, tablename;
"
```

---

## 🔐 Seguridad de Backups

### Encriptar backup
```bash
# Crear backup encriptado
./backup.sh
gpg --encrypt --recipient tu_email@ejemplo.com ~/backups/app_pedidos/backup_20251010_153045.sql.gz

# Desencriptar
gpg --decrypt backup_20251010_153045.sql.gz.gpg > backup_20251010_153045.sql.gz
```

### Copiar a servidor remoto
```bash
# Con SCP
scp ~/backups/app_pedidos/backup_*.sql.gz usuario@servidor:/ruta/backups/

# Con rsync
rsync -avz ~/backups/app_pedidos/ usuario@servidor:/ruta/backups/
```

---

## 📈 Monitoreo de Base de Datos

### Estadísticas de queries
```sql
-- Top 10 queries más lentas
SELECT 
    query,
    calls,
    total_time,
    mean_time,
    max_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

### Estadísticas de tablas
```sql
-- Tablas más accedidas
SELECT 
    schemaname,
    relname,
    seq_scan,
    idx_scan,
    n_live_tup
FROM pg_stat_user_tables
ORDER BY seq_scan + idx_scan DESC
LIMIT 10;
```

---

## 🧪 Datos de Prueba

### Limpiar datos de prueba
```sql
-- Eliminar pedidos de prueba
DELETE FROM orders WHERE user_id IN (
    SELECT id FROM users WHERE phone LIKE '555-%'
);

-- Resetear secuencias
ALTER SEQUENCE orders_id_seq RESTART WITH 1;
```

### Insertar datos de prueba
```sql
-- Ejecutar esquema.sql que ya incluye datos iniciales
\i esquema.sql
```

---

## 📝 Notas

- Los backups se guardan por defecto en `~/backups/app_pedidos/`
- Los scripts requieren permisos de ejecución (`chmod +x`)
- Asegurar que el usuario tiene permisos en PostgreSQL
- Los backups antiguos (>7 días) se eliminan automáticamente

---

¡Mantén tus datos seguros! 🔒
