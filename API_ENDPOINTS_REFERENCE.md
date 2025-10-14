# 📚 Referencia Completa de API Endpoints

## Sistema POS - App_pedidos

### 🎯 Índice Rápido
- [Pedidos (Existente)](#pedidos)
- [Productos (Existente)](#productos)
- [Drivers (Existente)](#drivers)
- [Admin (Existente)](#admin)
- [🆕 Inventario](#inventario-nuevo)
- [🆕 Reportes](#reportes-nuevo)
- [🆕 Gastos](#gastos-nuevo)
- [🆕 Métodos de Pago](#métodos-de-pago-nuevo)

---

## Pedidos

### GET /pedidos
Obtener pedidos por estado
- **Query params:** `estado` (pendiente, pagado, listo, etc)
- **Response:** Lista de pedidos filtrados

### GET /pedidos/all
Obtener todos los pedidos sin filtrar

### POST /pedidos
Crear un nuevo pedido
- **Body:** `{ nombre, telefono, direccion_entrega, productos[], ubicacion }`
- **Response:** `{ success, order_id, driver_id, total }`
- **🆕 Efecto:** Reduce stock automáticamente

### GET /pedidos/:id
Obtener pedido por ID

### GET /pedidos/:id/detalle
Obtener detalle completo de un pedido

### PUT /pedidos/:id/preparar
Cambiar estado a "preparando"

### PUT /pedidos/:id/listo
Cambiar estado a "listo"

### PUT /pedidos/:id/entregar
Cambiar estado a "entregado"
- **🆕 Efecto:** Libera driver automáticamente

### PUT /pedidos/:id/cancelar
Cancelar pedido
- **🆕 Efecto:** Libera driver y restaura stock automáticamente

### PUT /pedidos/:id/pago
Confirmar pago del pedido

### PUT /pedidos/:id/listo-cocina
Marcar pedido listo desde cocina

### PUT /pedidos/:id/entregado-cliente
Marcar pedido entregado a cliente
- **🆕 Efecto:** Libera driver automáticamente

---

## Productos

### GET /productos
Obtener todos los productos con categorías y vendors

---

## Drivers

### GET /drivers/:driverId
Obtener perfil del driver

### PATCH /drivers/:driverId/location
Actualizar ubicación del driver
- **Body:** `{ lat, lng }`

### PATCH /drivers/:driverId/status
Actualizar estado del driver
- **Body:** `{ status }` (available, busy, offline)

### GET /drivers/:driverId/orders
Obtener pedidos asignados al driver
- **Query params:** `estados` (comma-separated)

### GET /drivers/:driverId/orders/history
Obtener historial de pedidos entregados

### POST /drivers/:driverId/orders/:orderId/picked-up
Marcar pedido como recogido

### POST /drivers/:driverId/orders/:orderId/on-route
Marcar pedido en ruta

### POST /drivers/:driverId/orders/:orderId/delivered
Marcar pedido como entregado por el driver

---

## Admin

### POST /loginAdmin
Login de usuarios administrativos
- **Body:** `{ username, password }`
- **Response:** `{ success, role, userId, user }`

### GET /admin/categories
Obtener categorías

### GET /admin/vendors
Obtener vendors/proveedores

### POST /admin/products
Agregar nuevo producto (admin)

### PUT /admin/products/:id
Actualizar producto (admin)

---

## 🆕 Inventario (NUEVO)

### GET /inventory
Listar todo el inventario
- **Query params:** `lowStock=true` (filtrar stock bajo)
- **Response:** 
```json
{
  "success": true,
  "inventory": [{
    "id": 1,
    "product_id": 5,
    "product_name": "Hamburguesa Simple",
    "category_name": "Hamburguesas",
    "quantity": 8,
    "min_quantity": 10,
    "stock_status": "low_stock"
  }]
}
```

### GET /inventory/:productId
Ver stock de un producto específico

### POST /inventory/:productId/add
Agregar stock (compras, devoluciones)
- **Body:** 
```json
{
  "quantity": 100,
  "cost": 3500.00,
  "reason": "Compra semanal",
  "userId": 1
}
```

### POST /inventory/:productId/remove
Quitar stock (mermas, pérdidas)
- **Body:** 
```json
{
  "quantity": 3,
  "reason": "Producto dañado",
  "userId": 1
}
```

### POST /inventory/:productId/adjust
Ajustar stock (inventario físico)
- **Body:** 
```json
{
  "newQuantity": 100,
  "reason": "Conteo físico",
  "userId": 1
}
```

### PUT /inventory/:productId/settings
Actualizar configuración de inventario
- **Body:** 
```json
{
  "minQuantity": 15,
  "maxQuantity": 200,
  "unitCost": 3800.00
}
```

### GET /inventory/movements
Historial de movimientos de inventario
- **Query params:** 
  - `productId` - Filtrar por producto
  - `startDate` - Fecha inicio (YYYY-MM-DD)
  - `endDate` - Fecha fin
  - `movementType` - entrada, salida, ajuste, merma
  - `limit` - Límite de resultados (default: 100)

### GET /inventory/alerts
Obtener alertas de inventario
- **Query params:** 
  - `resolved=false` - Solo sin resolver
  - `alertType` - low_stock, out_of_stock, excess_stock
- **Response:**
```json
{
  "success": true,
  "alerts": [{
    "id": 1,
    "product_name": "Hamburguesa Simple",
    "alert_type": "low_stock",
    "current_quantity": 8,
    "min_quantity": 10,
    "resolved": false
  }]
}
```

### PUT /inventory/alerts/:alertId/resolve
Marcar alerta como resuelta
- **Body:** `{ userId: 1 }`

---

## 🆕 Reportes (NUEVO)

### GET /reports/dashboard
Resumen general del negocio
- **Response:**
```json
{
  "success": true,
  "today": {
    "total_orders": 12,
    "completed_orders": 10,
    "total_sales": 180000.00
  },
  "thisWeek": {
    "total_orders": 85,
    "total_sales": 1200000.00
  },
  "thisMonth": {
    "total_orders": 320,
    "total_sales": 4800000.00
  },
  "activeOrders": 5,
  "alerts": {
    "lowStock": 3,
    "outOfStock": 1
  }
}
```

### GET /reports/daily
Reporte de ventas del día
- **Query params:** `date=2025-10-14` (default: hoy)
- **Response:** Ventas del día + breakdown por método de pago + top productos

### GET /reports/period
Reporte de ventas por período
- **Query params:** `startDate=2025-10-01&endDate=2025-10-14` (requeridos)
- **Response:** Summary + breakdown diario + métodos de pago

### GET /reports/by-product
Productos más vendidos
- **Query params:** 
  - `startDate`, `endDate` (requeridos)
  - `limit=20` (default: 20)
- **Response:**
```json
{
  "success": true,
  "topProducts": [{
    "product_name": "Hamburguesa Doble",
    "quantity_sold": 150,
    "total_revenue": 450000.00,
    "average_price": 3000.00
  }]
}
```

### GET /reports/by-category
Ventas por categoría
- **Query params:** `startDate`, `endDate` (requeridos)

### GET /reports/profit
Reporte de utilidades
- **Query params:** `startDate`, `endDate` (requeridos)
- **Response:**
```json
{
  "success": true,
  "summary": {
    "total_revenue": 5000000.00,
    "total_cost": 3000000.00,
    "gross_profit": 2000000.00,
    "total_expenses": 500000.00,
    "net_profit": 1500000.00,
    "profit_margin": "40.00%"
  },
  "profitByProduct": [...]
}
```

---

## 🆕 Gastos (NUEVO)

### GET /expenses
Listar gastos con filtros
- **Query params:**
  - `startDate` - Fecha inicio
  - `endDate` - Fecha fin
  - `category` - servicios, sueldos, mantenimiento, etc
  - `limit=100` (default: 100)

### GET /expenses/summary
Resumen de gastos por categoría
- **Query params:** `startDate`, `endDate` (requeridos)
- **Response:**
```json
{
  "success": true,
  "summary": {
    "total_expenses": 10,
    "total_amount": 850000.00
  },
  "byCategory": [
    { "category": "servicios", "total_amount": 400000.00 },
    { "category": "sueldos", "total_amount": 450000.00 }
  ]
}
```

### POST /expenses
Registrar un nuevo gasto
- **Body:**
```json
{
  "expenseDate": "2025-10-14",
  "category": "servicios",
  "description": "Pago de luz",
  "amount": 85000,
  "paymentMethod": "transferencia",
  "receiptNumber": "12345",
  "userId": 1
}
```

### GET /expenses/:id
Obtener detalle de un gasto

### PUT /expenses/:id
Actualizar un gasto
- **Body:** Campos a actualizar

### DELETE /expenses/:id
Eliminar un gasto

---

## 🆕 Métodos de Pago (NUEVO)

### GET /payment-methods
Listar métodos de pago
- **Query params:** `activeOnly=true` (solo activos)
- **Response:**
```json
{
  "success": true,
  "paymentMethods": [
    { "id": 1, "name": "efectivo", "active": true },
    { "id": 2, "name": "tarjeta", "active": true },
    { "id": 3, "name": "transferencia", "active": true }
  ]
}
```

### POST /payment-methods
Crear un nuevo método de pago
- **Body:** `{ name: "daviplata", active: true }`

### PUT /payment-methods/:id
Actualizar método de pago
- **Body:** `{ name: "...", active: true/false }`

### POST /payment-methods/order-payment
Registrar pago para un pedido
- **Body:**
```json
{
  "orderId": 123,
  "paymentMethodId": 1,
  "amount": 25000,
  "reference": "Voucher 12345",
  "userId": 1
}
```
- **Response:** Incluye el nuevo `paymentStatus` del pedido (pendiente/parcial/pagado)

### GET /payment-methods/order/:orderId
Ver todos los pagos de un pedido

---

## 📊 Resumen de Endpoints

### Total: **57 endpoints**

| Módulo | Endpoints | Estado |
|--------|-----------|--------|
| Pedidos | 12 | ✅ Existente + Mejorado |
| Productos | 1 | ✅ Existente |
| Drivers | 8 | ✅ Existente |
| Admin | 5 | ✅ Existente |
| **Inventario** | **9** | **🆕 Nuevo** |
| **Reportes** | **6** | **🆕 Nuevo** |
| **Gastos** | **6** | **🆕 Nuevo** |
| **Métodos de Pago** | **5** | **🆕 Nuevo** |

---

## 🔐 Autenticación (Pendiente)

**⚠️ Importante:** Actualmente los endpoints NO requieren autenticación.

### Recomendación:
Agregar middleware de autenticación JWT:
```javascript
// authMiddleware.js
const verifyToken = (req, res, next) => {
  const token = req.headers['authorization'];
  if (!token) return res.status(403).json({ error: 'No token provided' });
  
  jwt.verify(token, SECRET, (err, decoded) => {
    if (err) return res.status(401).json({ error: 'Invalid token' });
    req.userId = decoded.id;
    req.userRole = decoded.role;
    next();
  });
};

// Aplicar a rutas sensibles
app.use('/inventory', verifyToken, inventoryRoutes);
app.use('/reports', verifyToken, reportsRoutes);
app.use('/expenses', verifyToken, expensesRoutes);
```

---

## 🧪 Testing con cURL

### Ejemplo 1: Ver Dashboard
```bash
curl http://localhost:3000/reports/dashboard
```

### Ejemplo 2: Agregar Stock
```bash
curl -X POST http://localhost:3000/inventory/1/add \
  -H "Content-Type: application/json" \
  -d '{
    "quantity": 50,
    "cost": 3500,
    "reason": "Compra semanal",
    "userId": 1
  }'
```

### Ejemplo 3: Registrar Gasto
```bash
curl -X POST http://localhost:3000/expenses \
  -H "Content-Type: application/json" \
  -d '{
    "category": "servicios",
    "description": "Pago de internet",
    "amount": 65000,
    "userId": 1
  }'
```

### Ejemplo 4: Ver Ventas del Período
```bash
curl "http://localhost:3000/reports/period?startDate=2025-10-01&endDate=2025-10-14"
```

### Ejemplo 5: Ver Alertas de Stock
```bash
curl "http://localhost:3000/inventory/alerts?resolved=false"
```

---

## 📱 Integración con Flutter

### Ejemplo de Servicio API:

```dart
class POSApiService {
  final String baseUrl = 'http://localhost:3000';
  
  // Dashboard
  Future<DashboardData> getDashboard() async {
    final response = await http.get(Uri.parse('$baseUrl/reports/dashboard'));
    if (response.statusCode == 200) {
      return DashboardData.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load dashboard');
  }
  
  // Inventario
  Future<List<InventoryItem>> getInventory({bool lowStockOnly = false}) async {
    String url = '$baseUrl/inventory';
    if (lowStockOnly) url += '?lowStock=true';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['inventory'] as List)
        .map((item) => InventoryItem.fromJson(item))
        .toList();
    }
    throw Exception('Failed to load inventory');
  }
  
  // Agregar Stock
  Future<bool> addStock(int productId, int quantity, double cost, String reason, int userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/inventory/$productId/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'quantity': quantity,
        'cost': cost,
        'reason': reason,
        'userId': userId,
      }),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
  
  // Reportes
  Future<DailySalesReport> getDailySales([String? date]) async {
    String url = '$baseUrl/reports/daily';
    if (date != null) url += '?date=$date';
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return DailySalesReport.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load sales report');
  }
  
  // Gastos
  Future<bool> createExpense(Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );
    return response.statusCode == 201;
  }
}
```

---

## 🎯 Casos de Uso Comunes

### Caso 1: Recibir Mercancía del Proveedor
1. `POST /inventory/:productId/add` - Agregar stock
2. `GET /inventory/:productId` - Verificar nuevo stock
3. `GET /inventory/alerts` - Ver si se resolvieron alertas

### Caso 2: Cierre de Caja Diario
1. `GET /reports/daily` - Ver ventas del día
2. `GET /payment-methods/order/:orderId` - Verificar pagos
3. `GET /expenses?startDate=today&endDate=today` - Ver gastos del día

### Caso 3: Reporte Mensual
1. `GET /reports/period?startDate=2025-10-01&endDate=2025-10-31` - Ventas
2. `GET /reports/profit?startDate=2025-10-01&endDate=2025-10-31` - Utilidades
3. `GET /expenses/summary?startDate=2025-10-01&endDate=2025-10-31` - Gastos

### Caso 4: Inventario Físico
1. `GET /inventory` - Ver stock actual
2. Contar físicamente
3. `POST /inventory/:productId/adjust` - Ajustar diferencias
4. `GET /inventory/movements` - Ver movimientos de ajuste

---

## 📚 Recursos Adicionales

- **POS_SYSTEM_ANALYSIS.md** - Análisis completo y roadmap
- **INVENTORY_MODULE_README.md** - Documentación detallada de inventario
- **POS_IMPLEMENTATION_SUMMARY.md** - Resumen de lo implementado
- **NEXT_STEPS_GUIDE.md** - Guía de próximos pasos

---

**Última actualización:** 2025-10-14
**Versión del API:** 1.0.0
**Base URL:** `http://localhost:3000`
