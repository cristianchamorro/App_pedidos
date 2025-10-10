# 📚 Documentación de la API - App Pedidos

Base URL: `http://localhost:3000`

---

## 📦 Productos

### Obtener todos los productos
```
GET /productos
```

**Respuesta exitosa (200):**
```json
[
  {
    "id": 1,
    "name": "Hamburguesa Clásica",
    "price": "8.50",
    "description": "Hamburguesa con carne, lechuga, tomate y queso",
    "imageUrl": "https://via.placeholder.com/150",
    "categoryId": 2,
    "categoryName": "Comida Rápida",
    "vendorId": 1,
    "vendorName": "Restaurante Central"
  }
]
```

### Agregar un producto (Admin)
```
POST /admin/products
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Hamburguesa BBQ",
  "description": "Hamburguesa con salsa BBQ",
  "price": 9.50,
  "imageUrl": "https://example.com/image.jpg",
  "categoryId": 2,
  "vendorId": 1
}
```

**Respuesta exitosa (201):**
```json
{
  "message": "Product added successfully",
  "product": {
    "id": 6,
    "name": "Hamburguesa BBQ",
    "description": "Hamburguesa con salsa BBQ",
    "price": "9.50",
    "image_url": "https://example.com/image.jpg",
    "category_id": 2,
    "vendor_id": 1,
    "created_at": "2025-10-10T15:30:00.000Z"
  }
}
```

### Actualizar un producto (Admin)
```
PUT /admin/products/:id
Content-Type: application/json
```

**Body:**
```json
{
  "name": "Hamburguesa BBQ Premium",
  "price": 10.50
}
```

**Respuesta exitosa (200):**
```json
{
  "message": "Product updated successfully",
  "product": {
    "id": 6,
    "name": "Hamburguesa BBQ Premium",
    "price": "10.50",
    ...
  }
}
```

---

## 🛒 Pedidos

### Crear un nuevo pedido
```
POST /pedidos
Content-Type: application/json
```

**Body:**
```json
{
  "nombre": "Juan Pérez",
  "telefono": "555-1234",
  "direccion_entrega": "Calle Principal 123, Ciudad",
  "productos": [
    {
      "id": 1,
      "price": 8.50,
      "cantidad": 2
    },
    {
      "id": 2,
      "price": 2.00,
      "cantidad": 1
    }
  ],
  "ubicacion": {
    "lat": 40.7128,
    "lng": -74.0060
  }
}
```

**Respuesta exitosa (201):**
```json
{
  "success": true,
  "order_id": 15,
  "driver_id": 1,
  "total": "19.00"
}
```

**Errores posibles:**
- 400: "Faltan datos requeridos"
- 400: "No hay drivers disponibles"
- 500: "Error al crear pedido"

### Obtener pedidos por estado
```
GET /pedidos?estado=pendiente
```

**Parámetros de consulta:**
- `estado`: pendiente | preparando | listo | entregado | cancelado | pagado

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "pedidos": [
    {
      "order_id": 15,
      "total": "19.00",
      "status": "pendiente",
      "created_at": "2025-10-10T15:30:00.000Z",
      "cliente_nombre": "Juan Pérez",
      "cliente_telefono": "555-1234",
      "direccion_entrega": "Calle Principal 123, Ciudad",
      "productos": [
        {
          "product_id": 1,
          "nombre": "Hamburguesa Clásica",
          "cantidad": 2,
          "price": "8.50"
        },
        {
          "product_id": 2,
          "nombre": "Coca Cola",
          "cantidad": 1,
          "price": "2.00"
        }
      ]
    }
  ]
}
```

### Obtener todos los pedidos
```
GET /pedidos/all
```

**Respuesta:** Igual que pedidos por estado, pero incluye todos los estados.

### Obtener detalle de un pedido
```
GET /pedidos/:id
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "pedido": {
    "order_id": 15,
    "cliente_nombre": "Juan Pérez",
    "cliente_telefono": "555-1234",
    "direccion_entrega": "Calle Principal 123, Ciudad",
    "total": "19.00",
    "status": "pendiente",
    "productos": [
      {
        "product_id": 1,
        "name": "Hamburguesa Clásica",
        "cantidad": 2,
        "price": "8.50"
      }
    ]
  }
}
```

### Marcar pedido como "Preparando"
```
PUT /pedidos/:id/preparar
Content-Type: application/json
```

**Body (opcional):**
```json
{
  "changed_by": 3
}
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "pedido": {
    "id": 15,
    "status": "preparando",
    ...
  }
}
```

### Marcar pedido como "Listo"
```
PUT /pedidos/:id/listo
Content-Type: application/json
```

### Marcar pedido como "Entregado"
```
PUT /pedidos/:id/entregar
Content-Type: application/json
```

### Cancelar pedido
```
PUT /pedidos/:id/cancelar
Content-Type: application/json
```

### Confirmar pago
```
PUT /pedidos/:id/pago
Content-Type: application/json
```

### Marcar listo desde cocina
```
PUT /pedidos/:id/listo-cocina
Content-Type: application/json
```

### Marcar entregado al cliente
```
PUT /pedidos/:id/entregado-cliente
Content-Type: application/json
```

### Actualizar pedido
```
PUT /pedidos/:id
Content-Type: application/json
```

**Body:**
```json
{
  "nota": "Sin cebolla",
  "productos": [
    {
      "id": 1,
      "cantidad": 3,
      "price": 8.50
    }
  ]
}
```

---

## 🔐 Administración

### Login de administrador
```
POST /loginAdmin
Content-Type: application/json
```

**Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Respuesta exitosa (200):**
```json
{
  "success": true,
  "role": "admin",
  "userId": 1,
  "user": {
    "id": 1,
    "username": "admin",
    "name": "Administrador",
    "role": {
      "id": 1,
      "name": "admin"
    }
  }
}
```

**Error (401):**
```json
{
  "success": false,
  "message": "Credenciales incorrectas"
}
```

### Obtener categorías
```
GET /admin/categories
```

**Respuesta exitosa (200):**
```json
[
  {
    "id": 1,
    "name": "Bebidas"
  },
  {
    "id": 2,
    "name": "Comida Rápida"
  }
]
```

### Obtener proveedores
```
GET /admin/vendors
```

**Respuesta exitosa (200):**
```json
[
  {
    "id": 1,
    "name": "Restaurante Central"
  },
  {
    "id": 2,
    "name": "Cafetería Express"
  }
]
```

---

## 📝 Estados de Pedidos

| Estado      | Descripción                        |
|-------------|------------------------------------|
| pendiente   | Pedido recién creado               |
| preparando  | Pedido en cocina                   |
| listo       | Pedido listo para entregar         |
| entregado   | Pedido entregado al cliente        |
| cancelado   | Pedido cancelado                   |
| pagado      | Pedido pagado                      |

---

## 🔑 Usuarios de Prueba

| Usuario   | Contraseña    | Rol       |
|-----------|---------------|-----------|
| admin     | admin123      | admin     |
| cajero    | cajero123     | cajero    |
| cocinero  | cocinero123   | cocinero  |

---

## ❌ Códigos de Error Comunes

| Código | Descripción                        |
|--------|------------------------------------|
| 200    | OK - Solicitud exitosa             |
| 201    | Created - Recurso creado           |
| 400    | Bad Request - Datos inválidos      |
| 401    | Unauthorized - No autorizado       |
| 404    | Not Found - Recurso no encontrado  |
| 500    | Internal Server Error              |

---

## 🧪 Ejemplos de Uso con cURL

### Crear un pedido:
```bash
curl -X POST http://localhost:3000/pedidos \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan Pérez",
    "telefono": "555-1234",
    "direccion_entrega": "Calle Principal 123",
    "productos": [
      {"id": 1, "price": 8.50, "cantidad": 2}
    ],
    "ubicacion": {"lat": 40.7128, "lng": -74.0060}
  }'
```

### Obtener productos:
```bash
curl http://localhost:3000/productos
```

### Login de administrador:
```bash
curl -X POST http://localhost:3000/loginAdmin \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "password": "admin123"
  }'
```

---

¡API lista para usar! 🚀
