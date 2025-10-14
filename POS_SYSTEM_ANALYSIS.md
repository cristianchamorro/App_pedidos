# Análisis del Sistema y Propuesta de Mejoras POS

## 📊 Estado Actual del Sistema

### ✅ Funcionalidades Existentes

#### 1. **Sistema de Pedidos (Orders)**
- ✅ Creación de pedidos con productos
- ✅ Gestión de estados: pendiente, preparando, listo, entregado, cancelado, pagado
- ✅ Asignación atómica de drivers (domiciliarios)
- ✅ Historial de cambios de estado
- ✅ Actualización de pedidos (notas, productos)

#### 2. **Gestión de Productos**
- ✅ Listado de productos con categorías y proveedores
- ✅ Alta y modificación de productos (admin)
- ✅ Relación con categorías y vendors (proveedores)

#### 3. **Sistema de Domiciliarios (Drivers)**
- ✅ Perfil de driver
- ✅ Actualización de ubicación GPS
- ✅ Estados: available, busy, offline
- ✅ Asignación automática por proximidad
- ✅ Historial de entregas

#### 4. **Panel Administrativo**
- ✅ Login de usuarios administrativos
- ✅ Roles: admin, cajero, cocina, pantalla
- ✅ Gestión de categorías y vendors

#### 5. **Base de Datos Actual**
Tablas identificadas:
- `users` - Clientes
- `orders` - Pedidos
- `order_items` - Items de pedidos
- `products` - Productos
- `categories` - Categorías de productos
- `vendors` - Proveedores
- `drivers` - Domiciliarios
- `status_history` - Historial de estados
- `user_admin` - Usuarios administrativos
- `roles` - Roles del sistema

---

## 🚀 Mejoras Propuestas para Sistema POS Completo

### 1. **Gestión de Inventario** 🏪
**Prioridad: ALTA**

#### Nuevas Tablas:
```sql
-- Control de stock de productos
CREATE TABLE inventory (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL DEFAULT 0,
  min_quantity INTEGER DEFAULT 10,  -- Stock mínimo
  max_quantity INTEGER DEFAULT 100, -- Stock máximo
  unit_cost DECIMAL(10,2),          -- Costo unitario
  last_purchase_date TIMESTAMP,
  last_updated TIMESTAMP DEFAULT NOW(),
  UNIQUE(product_id)
);

-- Movimientos de inventario
CREATE TABLE inventory_movements (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  movement_type VARCHAR(20) NOT NULL, -- 'entrada', 'salida', 'ajuste', 'merma'
  quantity INTEGER NOT NULL,
  previous_quantity INTEGER NOT NULL,
  new_quantity INTEGER NOT NULL,
  reason VARCHAR(200),
  cost DECIMAL(10,2),               -- Costo del movimiento
  user_id INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Alertas de stock
CREATE TABLE inventory_alerts (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id),
  alert_type VARCHAR(20) NOT NULL, -- 'low_stock', 'out_of_stock', 'excess_stock'
  alert_date TIMESTAMP DEFAULT NOW(),
  resolved BOOLEAN DEFAULT FALSE,
  resolved_date TIMESTAMP
);
```

#### Nuevos Endpoints:
```javascript
// Inventario
GET    /inventory                    // Listar inventario completo
GET    /inventory/:productId         // Ver stock de un producto
POST   /inventory/:productId/add     // Agregar stock (compras)
POST   /inventory/:productId/remove  // Quitar stock (ventas, mermas)
POST   /inventory/:productId/adjust  // Ajustar stock (inventario físico)
GET    /inventory/alerts             // Ver alertas de stock bajo
GET    /inventory/movements          // Historial de movimientos

// Al crear un pedido, automáticamente reducir stock
// Al cancelar un pedido, restaurar stock
```

---

### 2. **Gestión de Proveedores (Suppliers) Mejorada** 📦
**Prioridad: ALTA**

#### Ampliar Tabla Vendors:
```sql
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS contact_person VARCHAR(100);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50);  -- NIT/RUC
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(50); -- 'contado', '30 días', etc
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
```

#### Nueva Tabla - Órdenes de Compra:
```sql
CREATE TABLE purchase_orders (
  id SERIAL PRIMARY KEY,
  vendor_id INTEGER NOT NULL REFERENCES vendors(id),
  order_number VARCHAR(50) UNIQUE,
  order_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expected_date DATE,
  received_date DATE,
  status VARCHAR(20) DEFAULT 'pendiente', -- 'pendiente', 'recibido', 'cancelado'
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  notes TEXT,
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE purchase_order_items (
  id SERIAL PRIMARY KEY,
  purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id),
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL,
  unit_cost DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL
);
```

#### Nuevos Endpoints:
```javascript
// Proveedores
GET    /vendors                      // Listar proveedores (mejorado con más info)
POST   /vendors                      // Crear proveedor
PUT    /vendors/:id                  // Actualizar proveedor
DELETE /vendors/:id                  // Desactivar proveedor

// Órdenes de compra
GET    /purchase-orders              // Listar órdenes de compra
POST   /purchase-orders              // Crear orden de compra
GET    /purchase-orders/:id          // Ver detalle de orden
PUT    /purchase-orders/:id/receive  // Marcar como recibida (actualiza inventario)
PUT    /purchase-orders/:id/cancel   // Cancelar orden
```

---

### 3. **Contabilidad y Reportes de Ventas** 💰
**Prioridad: ALTA**

#### Nuevas Tablas:
```sql
-- Ventas diarias consolidadas
CREATE TABLE daily_sales (
  id SERIAL PRIMARY KEY,
  sale_date DATE NOT NULL UNIQUE,
  total_orders INTEGER NOT NULL DEFAULT 0,
  total_sales DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_cash DECIMAL(10,2) DEFAULT 0,
  total_card DECIMAL(10,2) DEFAULT 0,
  total_costs DECIMAL(10,2) DEFAULT 0,    -- Costos de productos vendidos
  gross_profit DECIMAL(10,2) DEFAULT 0,   -- Utilidad bruta
  created_at TIMESTAMP DEFAULT NOW()
);

-- Métodos de pago
CREATE TABLE payment_methods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,  -- 'efectivo', 'tarjeta', 'transferencia', etc
  active BOOLEAN DEFAULT TRUE
);

-- Pagos de pedidos
CREATE TABLE order_payments (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id),
  payment_method_id INTEGER NOT NULL REFERENCES payment_methods(id),
  amount DECIMAL(10,2) NOT NULL,
  payment_date TIMESTAMP DEFAULT NOW(),
  reference VARCHAR(100),  -- Número de transacción, voucher, etc
  created_by INTEGER REFERENCES user_admin(id)
);

-- Gastos operativos
CREATE TABLE expenses (
  id SERIAL PRIMARY KEY,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category VARCHAR(50) NOT NULL,  -- 'servicios', 'sueldos', 'mantenimiento', etc
  description TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(50),
  receipt_number VARCHAR(50),
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### Nuevos Endpoints:
```javascript
// Reportes de ventas
GET    /reports/daily                // Ventas del día
GET    /reports/period               // Ventas por período (fecha inicio/fin)
GET    /reports/by-product           // Productos más vendidos
GET    /reports/by-category          // Ventas por categoría
GET    /reports/by-payment-method    // Ventas por método de pago
GET    /reports/profit               // Reporte de utilidades

// Métodos de pago
GET    /payment-methods              // Listar métodos de pago
POST   /order-payments                // Registrar pago de pedido

// Gastos
GET    /expenses                     // Listar gastos
POST   /expenses                     // Registrar gasto
GET    /expenses/summary             // Resumen de gastos por categoría

// Dashboard
GET    /dashboard/summary            // Resumen general (ventas hoy, semana, mes)
GET    /dashboard/alerts             // Alertas importantes (stock bajo, etc)
```

---

### 4. **Gestión de Clientes Mejorada** 👥
**Prioridad: MEDIA**

#### Ampliar Tabla Users:
```sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE users ADD COLUMN IF NOT EXISTS birth_date DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS loyalty_points INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_orders INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS total_spent DECIMAL(10,2) DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_order_date TIMESTAMP;
ALTER TABLE users ADD COLUMN IF NOT EXISTS customer_type VARCHAR(20) DEFAULT 'regular'; -- 'nuevo', 'regular', 'vip'
ALTER TABLE users ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;
```

#### Nuevos Endpoints:
```javascript
// Clientes
GET    /customers                    // Listar clientes
GET    /customers/:id                // Ver perfil de cliente
GET    /customers/:id/orders         // Historial de pedidos del cliente
GET    /customers/top                // Mejores clientes (por gasto)
PUT    /customers/:id                // Actualizar información del cliente
```

---

### 5. **Caja y Turno de Cajeros** 💵
**Prioridad: MEDIA**

#### Nuevas Tablas:
```sql
-- Turnos de caja
CREATE TABLE cash_register_shifts (
  id SERIAL PRIMARY KEY,
  cashier_id INTEGER NOT NULL REFERENCES user_admin(id),
  start_time TIMESTAMP NOT NULL DEFAULT NOW(),
  end_time TIMESTAMP,
  initial_cash DECIMAL(10,2) NOT NULL,
  final_cash DECIMAL(10,2),
  expected_cash DECIMAL(10,2),     -- Efectivo esperado según ventas
  difference DECIMAL(10,2),        -- Diferencia (faltante o sobrante)
  total_sales DECIMAL(10,2),
  total_orders INTEGER,
  status VARCHAR(20) DEFAULT 'abierto', -- 'abierto', 'cerrado'
  notes TEXT
);

-- Movimientos de caja
CREATE TABLE cash_movements (
  id SERIAL PRIMARY KEY,
  shift_id INTEGER REFERENCES cash_register_shifts(id),
  movement_type VARCHAR(20) NOT NULL, -- 'ingreso', 'egreso', 'retiro'
  amount DECIMAL(10,2) NOT NULL,
  reason TEXT,
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### Nuevos Endpoints:
```javascript
// Caja
POST   /cash-register/open           // Abrir turno de caja
POST   /cash-register/close          // Cerrar turno de caja
GET    /cash-register/current        // Ver turno actual
POST   /cash-register/movement       // Registrar movimiento (retiro, gasto)
GET    /cash-register/shifts         // Historial de turnos
```

---

### 6. **Mejoras al Sistema de Pedidos Actual** 📋
**Prioridad: BAJA (mejoras incrementales)**

#### Campos Adicionales a Orders:
```sql
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(50);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_type VARCHAR(20) DEFAULT 'delivery'; -- 'delivery', 'pickup', 'dine-in'
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'pendiente'; -- 'pendiente', 'pagado', 'parcial'
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal DECIMAL(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method_id INTEGER REFERENCES payment_methods(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS estimated_delivery_time TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS actual_delivery_time TIMESTAMP;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;
```

---

## 📝 Plan de Implementación Recomendado

### Fase 1 - Fundamentos POS (Semana 1-2)
1. ✅ Revisar y documentar sistema actual (COMPLETADO)
2. 🔄 Implementar gestión de inventario básica
3. 🔄 Agregar control de stock en pedidos
4. 🔄 Sistema de alertas de stock bajo

### Fase 2 - Contabilidad Básica (Semana 3-4)
1. 🔄 Reportes de ventas diarias
2. 🔄 Métodos de pago
3. 🔄 Dashboard básico
4. 🔄 Registro de gastos

### Fase 3 - Proveedores y Compras (Semana 5-6)
1. 🔄 Ampliar información de proveedores
2. 🔄 Órdenes de compra
3. 🔄 Recepción de mercancía (actualiza inventario)

### Fase 4 - Caja y Reportes Avanzados (Semana 7-8)
1. 🔄 Sistema de turnos de caja
2. 🔄 Reportes de utilidad
3. 🔄 Análisis de productos más vendidos
4. 🔄 Gestión de clientes VIP

---

## 🎯 Prioridades Inmediatas

### CRÍTICO - Hacer Primero:
1. **Inventario básico** - Sin esto no hay control de costos ni stock
2. **Métodos de pago** - Esencial para reportes financieros
3. **Reportes de ventas diarias** - Necesario para contabilidad

### IMPORTANTE - Hacer Segundo:
4. **Órdenes de compra** - Para control de proveedores
5. **Gastos operativos** - Para cálculo de rentabilidad
6. **Dashboard administrativo** - Visibilidad del negocio

### ÚTIL - Hacer Después:
7. **Sistema de caja** - Mejor control de efectivo
8. **Clientes VIP** - Programa de lealtad
9. **Reportes avanzados** - Analytics detallados

---

## ⚠️ Consideraciones Importantes

### Mantener Funcionalidad Actual:
- ✅ No modificar la lógica de estados de pedidos
- ✅ No cambiar la asignación de drivers
- ✅ No alterar el flujo de cocina
- ✅ No modificar las rutas existentes sin versionar
- ✅ Todas las nuevas funciones deben ser ADITIVAS, no sustitutivas

### Seguridad:
- Todos los endpoints financieros deben validar roles (admin/cajero)
- Auditoría en operaciones críticas (cambios de inventario, pagos)
- Logs de todas las transacciones monetarias

### Performance:
- Índices en tablas de reportes (fechas, product_id)
- Caché para dashboard (actualizar cada 5 minutos)
- Paginación en listados grandes

### Testing:
- Probar que las ventas actualizan inventario correctamente
- Verificar que cancelaciones restauran stock
- Validar cálculos de costos y utilidades
- Probar concurrencia en movimientos de inventario

---

## 📁 Estructura de Archivos Propuesta

```
app_backend/
├── controllers/
│   ├── inventoryController.js       (NUEVO)
│   ├── purchaseOrdersController.js  (NUEVO)
│   ├── reportsController.js         (NUEVO)
│   ├── expensesController.js        (NUEVO)
│   ├── cashRegisterController.js    (NUEVO)
│   ├── customersController.js       (NUEVO)
│   └── (existentes sin modificar)
├── routes/
│   ├── inventory.js                 (NUEVO)
│   ├── purchaseOrders.js            (NUEVO)
│   ├── reports.js                   (NUEVO)
│   ├── expenses.js                  (NUEVO)
│   ├── cashRegister.js              (NUEVO)
│   ├── customers.js                 (NUEVO)
│   └── (existentes sin modificar)
├── migrations/
│   ├── 001_create_inventory.sql     (NUEVO)
│   ├── 002_create_purchase_orders.sql (NUEVO)
│   ├── 003_create_financial_tables.sql (NUEVO)
│   └── 004_alter_existing_tables.sql (NUEVO)
└── utils/
    ├── inventoryHelper.js           (NUEVO)
    └── reportHelper.js              (NUEVO)
```

---

## 🎉 Beneficios del Sistema POS Completo

1. **Control Total de Inventario**
   - Saber qué hay en stock en tiempo real
   - Alertas automáticas de productos por agotarse
   - Evitar pérdidas por falta de stock

2. **Visibilidad Financiera**
   - Conocer ventas diarias, semanales, mensuales
   - Calcular costos y utilidades reales
   - Tomar decisiones basadas en datos

3. **Gestión de Proveedores**
   - Órdenes de compra organizadas
   - Historial de compras por proveedor
   - Control de pagos a proveedores

4. **Análisis de Negocio**
   - Productos más y menos vendidos
   - Horas pico de ventas
   - Clientes más frecuentes

5. **Eficiencia Operativa**
   - Turnos de caja controlados
   - Reducción de errores en inventario
   - Mejor planificación de compras

---

## 📌 Próximos Pasos

1. **Revisar y aprobar** este análisis
2. **Priorizar** qué funciones implementar primero
3. **Crear migraciones SQL** para las nuevas tablas
4. **Implementar endpoints** de forma incremental
5. **Actualizar frontend** para consumir nuevos endpoints
6. **Probar exhaustivamente** cada módulo

¿Por cuál módulo te gustaría que empecemos? Recomiendo:
1. **Inventario** (más crítico)
2. **Reportes de Ventas** (más visible)
3. **Proveedores** (importante pero puede esperar)
