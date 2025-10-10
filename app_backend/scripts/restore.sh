#!/bin/bash
# Script para restaurar backup de la base de datos

# Configuración
DB_NAME="Bd_App"
DB_USER="postgres"

# Verificar que se proporcionó archivo de backup
if [ -z "$1" ]; then
    echo "Uso: ./restore.sh <archivo_backup.sql.gz>"
    echo "Ejemplo: ./restore.sh ~/backups/app_pedidos/backup_20251010_120000.sql.gz"
    exit 1
fi

BACKUP_FILE=$1

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: El archivo $BACKUP_FILE no existe"
    exit 1
fi

# Descomprimir si es .gz
if [[ $BACKUP_FILE == *.gz ]]; then
    echo "Descomprimiendo backup..."
    gunzip -c $BACKUP_FILE > /tmp/restore_temp.sql
    SQL_FILE="/tmp/restore_temp.sql"
else
    SQL_FILE=$BACKUP_FILE
fi

# Advertencia
echo "⚠️  ADVERTENCIA: Esto eliminará todos los datos actuales en $DB_NAME"
read -p "¿Continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Restauración cancelada"
    exit 1
fi

# Eliminar base de datos existente y recrear
echo "Eliminando base de datos existente..."
dropdb -U $DB_USER $DB_NAME
echo "Creando nueva base de datos..."
createdb -U $DB_USER $DB_NAME

# Restaurar backup
echo "Restaurando backup..."
psql -U $DB_USER $DB_NAME < $SQL_FILE

# Habilitar PostGIS nuevamente
echo "Habilitando PostGIS..."
psql -U $DB_USER $DB_NAME -c "CREATE EXTENSION IF NOT EXISTS postgis;"

echo "✅ Restauración completada"

# Limpiar archivo temporal
if [ -f "/tmp/restore_temp.sql" ]; then
    rm /tmp/restore_temp.sql
fi
