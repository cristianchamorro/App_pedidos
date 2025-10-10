#!/bin/bash
# Script para hacer backup de la base de datos

# Configuración
DB_NAME="Bd_App"
DB_USER="postgres"
BACKUP_DIR="$HOME/backups/app_pedidos"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$DATE.sql"

# Crear directorio de backups si no existe
mkdir -p $BACKUP_DIR

# Hacer backup
echo "Haciendo backup de $DB_NAME..."
pg_dump -U $DB_USER $DB_NAME > $BACKUP_FILE

# Comprimir backup
gzip $BACKUP_FILE
echo "Backup completado: ${BACKUP_FILE}.gz"

# Eliminar backups antiguos (más de 7 días)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
echo "Backups antiguos eliminados"

# Mostrar tamaño del backup
ls -lh ${BACKUP_FILE}.gz
