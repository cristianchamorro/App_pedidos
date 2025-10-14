# Módulo de Inventario - Sistema POS

## 📦 Descripción

Módulo completo de gestión de inventario que incluye:
- Control de stock en tiempo real
- Historial de movimientos de inventario
- Alertas automáticas de stock bajo/agotado/exceso
- Integración automática con sistema de pedidos
- Restauración de inventario en cancelaciones

## 🗂️ Estructura de Tablas

### 1. `inventory`
Control de stock de productos.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | SERIAL | ID único |
| product_id | INTEGER | Referencia a productos (único) |
| quantity | INTEGER | Cantidad actual en stock |
| min_quantity | INTEGER | Stock mínimo (genera alerta) |
| max_quantity | INTEGER | Stock máximo recomendado |
| unit_cost | DECIMAL(10,2) | Costo unitario del producto |
| last_purchase_date | TIMESTAMP | Fecha de última compra |
| last_updated | TIMESTAMP | Última actualización |

### 2. `inventory_movements`
Historial de todos los movimientos de inventario.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | SERIAL | ID único |
| product_id | INTEGER | Producto afectado |
| movement_type | VARCHAR(20) | Tipo: entrada, salida, ajuste, merma, devolucion |
| quantity | INTEGER | Cantidad (+ para entrada, - para salida) |
| previous_quantity | INTEGER | Cantidad antes del movimiento |
| new_quantity | INTEGER | Cantidad después del movimiento |
| reason | VARCHAR(200) | Razón del movimiento |
| cost | DECIMAL(10,2) | Costo del movimiento |
| order_id | INTEGER | ID del pedido (si aplica) |
| user_id | INTEGER | Usuario que realizó el movimiento |
| created_at | TIMESTAMP | Fecha del movimiento |

### 3. `inventory_alerts`
Alertas automáticas de inventario.

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | SERIAL | ID único |
| product_id | INTEGER | Producto con alerta |
| alert_type | VARCHAR(20) | Tipo: low_stock, out_of_stock, excess_stock |
| alert_date | TIMESTAMP | Fecha de la alerta |
| resolved | BOOLEAN | Si la alerta fue resuelta |
| resolved_date | TIMESTAMP | Fecha de resolución |
| resolved_by | INTEGER | Usuario que resolvió |

## 🔄 Funcionalidad Automática

### Alertas Automáticas
Se generan automáticamente cuando:
- **low_stock**: `quantity <= min_quantity` (pero > 0)
- **out_of_stock**: `quantity = 0`
- **excess_stock**: `quantity > max_quantity`

Las alertas se resuelven automáticamente cuando el stock vuelve a niveles normales.

### Integración con Pedidos

#### Al Crear un Pedido:
1. Se verifica si cada producto tiene registro en inventario
2. Si hay stock suficiente, se reduce automáticamente
3. Se registra el movimiento de tipo "salida"
4. **Importante**: Si el stock es insuficiente, el pedido NO se bloquea (solo se registra warning)

#### Al Cancelar un Pedido:
1. Se restaura automáticamente el stock de todos los productos
2. Se registra el movimiento de tipo "devolucion"
3. Las alertas se actualizan si el stock vuelve a niveles normales

## 🚀 API Endpoints

### Consultas

#### `GET /inventory`
Obtener todo el inventario.

**Query params:**
- `lowStock=true` - Filtrar solo productos con stock bajo

**Respuesta:**
```json
{
  "success": true,
  "inventory": [
    {
      "id": 1,
      "product_id": 5,
      "product_name": "Hamburguesa Simple",
      "category_name": "Hamburguesas",
      "vendor_name": "Proveedor A",
      "quantity": 8,
      "min_quantity": 10,
      "max_quantity": 100,
      "unit_cost": 3500.00,
      "stock_status": "low_stock",
      "last_updated": "2025-10-14T10:30:00"
    }
  ]
}
```

#### `GET /inventory/:productId`
Obtener inventario de un producto específico.

**Respuesta:**
```json
{
  "success": true,
  "inventory": {
    "id": 1,
    "product_id": 5,
    "product_name": "Hamburguesa Simple",
    "quantity": 8,
    "min_quantity": 10,
    "max_quantity": 100,
    "unit_cost": 3500.00
  }
}
```

#### `GET /inventory/movements`
Obtener historial de movimientos.

**Query params:**
- `productId` - Filtrar por producto
- `startDate` - Fecha inicio (YYYY-MM-DD)
- `endDate` - Fecha fin
- `movementType` - Tipo de movimiento
- `limit` - Límite de resultados (default: 100)

**Respuesta:**
```json
{
  "success": true,
  "movements": [
    {
      "id": 1,
      "product_id": 5,
      "product_name": "Hamburguesa Simple",
      "movement_type": "salida",
      "quantity": -2,
      "previous_quantity": 10,
      "new_quantity": 8,
      "reason": "Venta - Pedido #123",
      "order_id": 123,
      "user_name": "Juan Pérez",
      "created_at": "2025-10-14T10:30:00"
    }
  ]
}
```

#### `GET /inventory/alerts`
Obtener alertas de inventario.

**Query params:**
- `resolved=false` - Solo alertas sin resolver
- `alertType` - Tipo de alerta (low_stock, out_of_stock, excess_stock)

**Respuesta:**
```json
{
  "success": true,
  "alerts": [
    {
      "id": 1,
      "product_id": 5,
      "product_name": "Hamburguesa Simple",
      "alert_type": "low_stock",
      "current_quantity": 8,
      "min_quantity": 10,
      "resolved": false,
      "alert_date": "2025-10-14T10:30:00"
    }
  ]
}
```

### Operaciones de Inventario

#### `POST /inventory/:productId/add`
Agregar stock (compras, devoluciones de proveedores).

**Body:**
```json
{
  "quantity": 50,
  "cost": 3500.00,
  "reason": "Compra a proveedor",
  "userId": 1
}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Stock agregado correctamente",
  "previousQuantity": 8,
  "newQuantity": 58
}
```

#### `POST /inventory/:productId/remove`
Quitar stock (mermas, pérdidas).

**Body:**
```json
{
  "quantity": 2,
  "reason": "Producto dañado",
  "userId": 1
}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Stock removido correctamente",
  "previousQuantity": 58,
  "newQuantity": 56
}
```

**Error si stock insuficiente:**
```json
{
  "error": "Stock insuficiente",
  "available": 5,
  "requested": 10
}
```

#### `POST /inventory/:productId/adjust`
Ajustar stock (inventario físico, correcciones).

**Body:**
```json
{
  "newQuantity": 100,
  "reason": "Conteo físico de inventario",
  "userId": 1
}
```

**Respuesta:**
```json
{
  "success": true,
  "message": "Inventario ajustado correctamente",
  "previousQuantity": 58,
  "newQuantity": 100,
  "difference": 42
}
```

#### `PUT /inventory/:productId/settings`
Actualizar configuración de inventario.

**Body:**
```json
{
  "minQuantity": 15,
  "maxQuantity": 200,
  "unitCost": 3800.00
}
```

**Respuesta:**
```json
{
  "success": true,
  "inventory": {
    "id": 1,
    "product_id": 5,
    "quantity": 100,
    "min_quantity": 15,
    "max_quantity": 200,
    "unit_cost": 3800.00
  }
}
```

#### `PUT /inventory/alerts/:alertId/resolve`
Marcar una alerta como resuelta manualmente.

**Body:**
```json
{
  "userId": 1
}
```

## 📊 Casos de Uso

### 1. Recepción de Mercancía
```bash
# Agregar 100 unidades de producto ID 5
POST /inventory/5/add
{
  "quantity": 100,
  "cost": 3500.00,
  "reason": "Compra semanal a proveedor",
  "userId": 1
}
```

### 2. Registrar Merma
```bash
# Remover 3 unidades dañadas
POST /inventory/5/remove
{
  "quantity": 3,
  "reason": "Producto vencido",
  "userId": 1
}
```

### 3. Inventario Físico
```bash
# Ajustar según conteo físico
POST /inventory/5/adjust
{
  "newQuantity": 95,
  "reason": "Inventario mensual",
  "userId": 1
}
```

### 4. Consultar Productos con Stock Bajo
```bash
GET /inventory?lowStock=true
```

### 5. Ver Movimientos de un Producto en un Período
```bash
GET /inventory/movements?productId=5&startDate=2025-10-01&endDate=2025-10-14
```

### 6. Obtener Alertas Activas
```bash
GET /inventory/alerts?resolved=false
```

## 🔧 Instalación

### 1. Ejecutar Migración SQL
```bash
# Conectarse a PostgreSQL
psql -U postgres -d Bd_App

# Ejecutar migración
\i app_backend/migrations/001_create_inventory.sql
```

### 2. Verificar Tablas Creadas
```sql
-- Ver tablas
\dt inventory*

-- Ver datos iniciales
SELECT i.product_id, p.name, i.quantity, i.min_quantity 
FROM inventory i 
JOIN products p ON i.product_id = p.id 
LIMIT 5;
```

## ⚠️ Consideraciones Importantes

### No Bloquea Pedidos
El sistema de inventario **NO bloquea** la creación de pedidos si el stock es insuficiente:
- Los pedidos se crean normalmente
- Se registra un warning en los logs
- Esto previene que errores de inventario afecten las ventas
- El negocio puede manejar situaciones de stockout sin perder ventas

### Seguridad
- Todos los endpoints requieren autenticación (implementar middleware)
- Los movimientos deben registrar el usuario que los realiza
- Las operaciones son transaccionales y atómicas

### Performance
- Índices en product_id, quantity, created_at
- Límite de 100 movimientos por defecto en consultas
- Trigger eficiente para alertas automáticas

### Auditoría
- Todos los movimientos quedan registrados permanentemente
- Se mantiene historial completo (previous_quantity, new_quantity)
- Se registra el order_id cuando el movimiento viene de un pedido

## 🎯 Próximos Pasos

1. ✅ Módulo de inventario implementado
2. 🔄 Agregar reportes de costos y utilidades
3. 🔄 Implementar órdenes de compra a proveedores
4. 🔄 Dashboard con métricas de inventario
5. 🔄 Notificaciones push para alertas críticas

## 🐛 Troubleshooting

### Error: "no hay drivers disponibles"
El inventario no afecta esto. Es un error del sistema de drivers.

### Stock negativo después de cancelar pedido
Verificar que la función `restaurarInventarioPorOrder` esté siendo llamada en `cancelarPedido`.

### Alertas no se generan
Verificar que el trigger `trigger_inventory_alerts` esté activo:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_inventory_alerts';
```

### No se reduce stock al crear pedido
Verificar que la tabla `inventory` existe y tiene datos:
```sql
SELECT COUNT(*) FROM inventory;
```

## 📝 Changelog

### v1.0.0 - 2025-10-14
- ✅ Creación de tablas (inventory, inventory_movements, inventory_alerts)
- ✅ Triggers automáticos para alertas
- ✅ API completa de inventario (9 endpoints)
- ✅ Integración con sistema de pedidos
- ✅ Restauración automática en cancelaciones
- ✅ Datos iniciales para productos existentes
