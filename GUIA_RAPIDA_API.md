# 🚀 Guía Rápida de API - App Pedidos

## 📋 Tabla de Contenidos

1. [Configuración Rápida](#configuración-rápida)
2. [Endpoints Principales](#endpoints-principales)
3. [Ejemplos de Uso](#ejemplos-de-uso)
4. [Códigos de Estado](#códigos-de-estado)
5. [Ejemplos con cURL](#ejemplos-con-curl)

---

## ⚙️ Configuración Rápida

### Backend
```bash
cd app_backend
npm install
node server.js
# Servidor en http://localhost:3000
```

### Base de Datos
```sql
-- PostgreSQL debe tener PostGIS instalado
CREATE DATABASE Bd_App;
CREATE EXTENSION postgis;
-- Ejecutar schema SQL proporcionado
```

### Frontend
```bash
cd app_frontend
flutter pub get
flutter run
```

---

## 🔌 Endpoints Principales

### Base URL
```
http://localhost:3000
```

---

## 1️⃣ AUTENTICACIÓN

### Login de Usuarios Administrativos

```http
POST /loginAdmin
Content-Type: application/json

{
  "username": "admin",
  "password": "password123"
}
```

**Respuesta Exitosa (200):**
```json
{
  "success": true,
  "role": "cajero",
  "userId": 1,
  "user": {
    "id": 1,
    "username": "admin",
    "name": "Juan Pérez",
    "role": {
      "id": 2,
      "name": "cajero"
    }
  }
}
```

**Roles posibles:** `cajero`, `cocinero`, `domiciliario`, `admin`

---

## 2️⃣ PRODUCTOS

### Obtener Catálogo de Productos

```http
GET /productos
```

**Respuesta (200):**
```json
[
  {
    "id": 1,
    "name": "Hamburguesa Clásica",
    "price": "15000.00",
    "description": "Hamburguesa con carne, queso y vegetales",
    "imageUrl": "https://example.com/burger.jpg",
    "categoryId": 1,
    "categoryName": "Comidas Rápidas",
    "vendorId": 1,
    "vendorName": "Restaurante Central"
  }
]
```

### Agregar Producto (Admin)

```http
POST /admin/products
Content-Type: application/json

{
  "name": "Pizza Margherita",
  "description": "Pizza con tomate, mozzarella y albahaca",
  "price": 25000,
  "imageUrl": "data:image/jpeg;base64,/9j/4AAQ...",
  "categoryId": 2,
  "vendorId": 1
}
```

**Respuesta (201):**
```json
{
  "message": "Product added successfully",
  "product": {
    "id": 15,
    "name": "Pizza Margherita",
    "price": "25000.00",
    ...
  }
}
```

### Actualizar Producto (Admin)

```http
PUT /admin/products/:id
Content-Type: application/json

{
  "name": "Pizza Margherita Especial",
  "price": 28000
}
```

---

## 3️⃣ PEDIDOS

### Crear Nuevo Pedido

```http
POST /pedidos
Content-Type: application/json

{
  "nombre": "Carlos Gómez",
  "telefono": "3001234567",
  "direccion_entrega": "Calle 123 #45-67",
  "ubicacion": {
    "lat": 4.6097,
    "lng": -74.0817
  },
  "productos": [
    {
      "id": 1,
      "name": "Hamburguesa",
      "price": 15000,
      "cantidad": 2
    },
    {
      "id": 5,
      "name": "Coca Cola",
      "price": 3000,
      "cantidad": 2
    }
  ]
}
```

**Respuesta (201):**
```json
{
  "success": true,
  "order_id": 42,
  "driver_id": 3,
  "total": "36000.00"
}
```

### Obtener Pedidos por Estado

```http
GET /pedidos?estado=pendiente
```

**Estados válidos:**
- `pendiente` - Recién creado, esperando pago
- `pagado` - Pago confirmado
- `preparando` - En cocina
- `listo` - Listo para entregar
- `entregado` - Completado
- `cancelado` - Cancelado

**Respuesta (200):**
```json
{
  "success": true,
  "pedidos": [
    {
      "order_id": 42,
      "total": "36000.00",
      "status": "pendiente",
      "created_at": "2024-01-15T10:30:00",
      "cliente_nombre": "Carlos Gómez",
      "cliente_telefono": "3001234567",
      "direccion_entrega": "Calle 123 #45-67",
      "productos": [
        {
          "product_id": 1,
          "nombre": "Hamburguesa",
          "cantidad": 2,
          "price": "15000.00"
        }
      ]
    }
  ]
}
```

### Obtener Todos los Pedidos

```http
GET /pedidos/all
```

### Obtener Pedido Específico

```http
GET /pedidos/:id
```

### Obtener Detalle Completo del Pedido

```http
GET /pedidos/:id/detalle
```

---

## 4️⃣ CAMBIOS DE ESTADO DE PEDIDOS

### Confirmar Pago (Cajero)

```http
PUT /pedidos/:id/pago
Content-Type: application/json

{
  "changed_by": 1
}
```

**Transición:** `pendiente` → `pagado`

### Iniciar Preparación (Cocinero)

```http
PUT /pedidos/:id/preparar
Content-Type: application/json

{
  "changed_by": 2
}
```

**Transición:** `pagado` → `preparando`

### Marcar Listo (Cocinero)

```http
PUT /pedidos/:id/listo
Content-Type: application/json

{
  "changed_by": 2
}
```

**Transición:** `preparando` → `listo`

### Marcar Entregado (Domiciliario)

```http
PUT /pedidos/:id/entregar
Content-Type: application/json

{
  "changed_by": 3
}
```

**Transición:** `listo` → `entregado`

### Cancelar Pedido

```http
PUT /pedidos/:id/cancelar
Content-Type: application/json

{
  "changed_by": 1,
  "motivo": "Cliente canceló"
}
```

**Transición:** cualquier estado → `cancelado`

---

## 5️⃣ DOMICILIARIOS

### Obtener Perfil de Domiciliario

```http
GET /drivers/:driverId
```

**Respuesta (200):**
```json
{
  "success": true,
  "driver": {
    "id": 3,
    "status": "available",
    "lat": 4.6097,
    "lng": -74.0817,
    "updated_at": "2024-01-15T10:45:00Z"
  }
}
```

### Actualizar Ubicación GPS

```http
PATCH /drivers/:driverId/location
Content-Type: application/json

{
  "lat": 4.6100,
  "lng": -74.0820
}
```

### Cambiar Estado de Disponibilidad

```http
PATCH /drivers/:driverId/status
Content-Type: application/json

{
  "status": "available"
}
```

**Estados válidos:** `available`, `busy`, `offline`

### Obtener Pedidos Asignados

```http
GET /drivers/:driverId/orders
```

**Con filtro de estados:**
```http
GET /drivers/:driverId/orders?estados=listo,preparando
```

**Respuesta (200):**
```json
{
  "success": true,
  "pedidos": [
    {
      "order_id": 42,
      "total": "36000.00",
      "status": "listo",
      "created_at": "2024-01-15T10:30:00",
      "cliente_nombre": "Carlos Gómez",
      "cliente_telefono": "3001234567",
      "direccion_entrega": "Calle 123 #45-67",
      "productos": [...]
    }
  ]
}
```

### Obtener Historial de Entregas

```http
GET /drivers/:driverId/orders/history
```

### Marcar Pedido Recogido

```http
POST /drivers/:driverId/orders/:orderId/picked-up
```

### Marcar En Camino

```http
POST /drivers/:driverId/orders/:orderId/on-route
```

### Marcar Entregado

```http
POST /drivers/:driverId/orders/:orderId/delivered
```

---

## 6️⃣ REPORTES DE CAJA (Cajero)

### Ventas del Día Actual

```http
GET /cajero/ventas/dia
```

**Respuesta (200):**
```json
{
  "success": true,
  "resumen": {
    "total_pedidos": "25",
    "total_ventas": "850000.00",
    "promedio_venta": "34000.00"
  },
  "por_estado": [
    {
      "status": "entregado",
      "cantidad": "18",
      "total": "650000.00"
    },
    {
      "status": "listo",
      "cantidad": "5",
      "total": "150000.00"
    }
  ]
}
```

### Reporte de Ventas por Período

```http
GET /cajero/ventas/reporte?fecha_inicio=2024-01-01&fecha_fin=2024-01-31
```

**Respuesta (200):**
```json
{
  "success": true,
  "periodo": {
    "fecha_inicio": "2024-01-01",
    "fecha_fin": "2024-01-31"
  },
  "resumen": {
    "total_pedidos": "450",
    "total_ventas": "15750000.00",
    "promedio_venta": "35000.00",
    "venta_minima": "8000.00",
    "venta_maxima": "125000.00"
  },
  "ventas_por_dia": [
    {
      "fecha": "2024-01-31",
      "pedidos": "28",
      "ventas": "980000.00"
    }
  ],
  "productos_mas_vendidos": [
    {
      "id": 1,
      "name": "Hamburguesa Clásica",
      "cantidad_vendida": "150",
      "total_ventas": "2250000.00"
    }
  ]
}
```

### Historial de Pagos

```http
GET /cajero/pagos/historial?limit=50&offset=0
```

**Respuesta (200):**
```json
{
  "success": true,
  "pagos": [
    {
      "pedido_id": 42,
      "total": "36000.00",
      "fecha_pedido": "2024-01-15T10:30:00",
      "cliente": "Carlos Gómez",
      "telefono": "3001234567",
      "fecha_pago": "2024-01-15T10:35:00",
      "cajero_id": 1
    }
  ],
  "total": 125,
  "limit": 50,
  "offset": 0
}
```

### Estadísticas Generales

```http
GET /cajero/estadisticas
```

**Respuesta (200):**
```json
{
  "success": true,
  "estadisticas": {
    "hoy": {
      "pedidos_hoy": "25",
      "total_hoy": "850000.00"
    },
    "semana": {
      "pedidos_semana": "156",
      "total_semana": "5460000.00"
    },
    "mes": {
      "pedidos_mes": "650",
      "total_mes": "22750000.00"
    },
    "pendientes": {
      "pedidos_pendientes": "8",
      "total_pendiente": "280000.00"
    }
  }
}
```

---

## 7️⃣ DATOS ADMINISTRATIVOS

### Obtener Categorías

```http
GET /admin/categories
```

**Respuesta (200):**
```json
[
  {
    "id": 1,
    "name": "Comidas Rápidas"
  },
  {
    "id": 2,
    "name": "Bebidas"
  }
]
```

### Obtener Vendedores

```http
GET /admin/vendors
```

**Respuesta (200):**
```json
[
  {
    "id": 1,
    "name": "Restaurante Central"
  },
  {
    "id": 2,
    "name": "Café Aroma"
  }
]
```

---

## 📊 Códigos de Estado HTTP

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | Operación exitosa |
| 201 | Created | Recurso creado exitosamente |
| 400 | Bad Request | Datos inválidos o faltantes |
| 401 | Unauthorized | Credenciales incorrectas |
| 404 | Not Found | Recurso no encontrado |
| 500 | Internal Server Error | Error en el servidor |

---

## 🔧 Ejemplos con cURL

### Login

```bash
curl -X POST http://localhost:3000/loginAdmin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "password123"
  }'
```

### Obtener Productos

```bash
curl http://localhost:3000/productos
```

### Crear Pedido

```bash
curl -X POST http://localhost:3000/pedidos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Carlos Gómez",
    "telefono": "3001234567",
    "direccion_entrega": "Calle 123 #45-67",
    "ubicacion": {
      "lat": 4.6097,
      "lng": -74.0817
    },
    "productos": [
      {
        "id": 1,
        "name": "Hamburguesa",
        "price": 15000,
        "cantidad": 2
      }
    ]
  }'
```

### Confirmar Pago

```bash
curl -X PUT http://localhost:3000/pedidos/42/pago \
  -H "Content-Type: application/json" \
  -d '{
    "changed_by": 1
  }'
```

### Obtener Pedidos Pendientes

```bash
curl "http://localhost:3000/pedidos?estado=pendiente"
```

### Actualizar Ubicación de Domiciliario

```bash
curl -X PATCH http://localhost:3000/drivers/3/location \
  -H "Content-Type: application/json" \
  -d '{
    "lat": 4.6100,
    "lng": -74.0820
  }'
```

### Obtener Reportes del Día

```bash
curl http://localhost:3000/cajero/ventas/dia
```

### Agregar Producto

```bash
curl -X POST http://localhost:3000/admin/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pizza Margherita",
    "description": "Pizza con tomate y queso",
    "price": 25000,
    "imageUrl": "https://example.com/pizza.jpg",
    "categoryId": 2,
    "vendorId": 1
  }'
```

---

## 🧪 Flujo de Prueba Completo

### 1. Login como Cajero
```bash
curl -X POST http://localhost:3000/loginAdmin \
  -H "Content-Type: application/json" \
  -d '{"username": "cajero1", "password": "pass123"}'
```

### 2. Ver Productos Disponibles
```bash
curl http://localhost:3000/productos
```

### 3. Cliente Crea Pedido
```bash
curl -X POST http://localhost:3000/pedidos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "María López",
    "telefono": "3009876543",
    "direccion_entrega": "Carrera 50 #10-20",
    "ubicacion": {"lat": 4.6097, "lng": -74.0817},
    "productos": [
      {"id": 1, "name": "Hamburguesa", "price": 15000, "cantidad": 1}
    ]
  }'
# Respuesta: {"success": true, "order_id": 1, ...}
```

### 4. Cajero Confirma Pago
```bash
curl -X PUT http://localhost:3000/pedidos/1/pago \
  -H "Content-Type: application/json" \
  -d '{"changed_by": 1}'
```

### 5. Cocinero Inicia Preparación
```bash
curl -X PUT http://localhost:3000/pedidos/1/preparar \
  -H "Content-Type: application/json" \
  -d '{"changed_by": 2}'
```

### 6. Cocinero Marca Listo
```bash
curl -X PUT http://localhost:3000/pedidos/1/listo \
  -H "Content-Type: application/json" \
  -d '{"changed_by": 2}'
```

### 7. Domiciliario Recoge Pedido
```bash
curl -X POST http://localhost:3000/drivers/3/orders/1/picked-up
```

### 8. Domiciliario Marca En Camino
```bash
curl -X POST http://localhost:3000/drivers/3/orders/1/on-route
```

### 9. Domiciliario Entrega
```bash
curl -X POST http://localhost:3000/drivers/3/orders/1/delivered
```

### 10. Ver Reporte del Día
```bash
curl http://localhost:3000/cajero/ventas/dia
```

---

## 💡 Tips y Mejores Prácticas

### 1. Manejo de Errores

Siempre verifica el código de estado:

```javascript
// JavaScript/Flutter
try {
  const response = await fetch('http://localhost:3000/pedidos', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(pedidoData)
  });
  
  if (!response.ok) {
    const error = await response.json();
    console.error('Error:', error.error, error.details);
    return;
  }
  
  const data = await response.json();
  console.log('Pedido creado:', data.order_id);
} catch (err) {
  console.error('Error de red:', err);
}
```

### 2. Ubicación GPS

La ubicación debe estar en formato:
```json
{
  "lat": 4.6097,    // Latitud (número decimal)
  "lng": -74.0817   // Longitud (número decimal)
}
```

### 3. Imágenes de Productos

Para desarrollo, puedes usar base64:
```json
{
  "imageUrl": "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ..."
}
```

Para producción, usa URLs:
```json
{
  "imageUrl": "https://cdn.example.com/products/hamburguesa.jpg"
}
```

### 4. Fechas

Usa formato ISO 8601 para fechas:
```
2024-01-15T10:30:00
```

### 5. Precios

Los precios se almacenan como NUMERIC(10,2):
- Siempre usa dos decimales
- Ejemplo: "15000.00" no "15000"

### 6. Paginación

Para endpoints con muchos resultados:
```http
GET /cajero/pagos/historial?limit=50&offset=0
```

- `limit`: Número de resultados por página
- `offset`: Número de resultados a saltar

---

## 🔍 Debugging

### Ver Logs del Backend

```bash
# Los logs se muestran en la consola donde ejecutaste node server.js
[2024-01-15T10:30:00.000Z] POST /pedidos
[2024-01-15T10:30:00.100Z] ✅ Pedido creado exitosamente: 42
```

### Verificar Estado de la Base de Datos

```sql
-- Ver pedidos recientes
SELECT id, status, total, created_at 
FROM orders 
ORDER BY created_at DESC 
LIMIT 10;

-- Ver historial de un pedido
SELECT * FROM status_history 
WHERE order_id = 42 
ORDER BY changed_at;

-- Ver domiciliarios disponibles
SELECT id, name, status, updated_at 
FROM drivers 
WHERE status = 'available';
```

### Probar Conectividad

```bash
# Probar que el servidor responde
curl http://localhost:3000/productos

# Si falla, verificar:
# 1. ¿Está corriendo el servidor? (node server.js)
# 2. ¿PostgreSQL está corriendo?
# 3. ¿Las credenciales en db.js son correctas?
```

---

## 📞 Soporte

Para más información, consulta:
- [Documentación Completa del Sistema](./DOCUMENTACION_COMPLETA_SISTEMA.md)
- [Diagramas de Arquitectura](./DIAGRAMA_ARQUITECTURA.md)
- Repositorio: https://github.com/cristianchamorro/App_pedidos

---

**Última actualización:** 2024  
**Versión de API:** 1.0.0
