# 📋 Documentación Completa del Sistema - App Pedidos

## 📊 Resumen Ejecutivo

**App Pedidos** es una aplicación multiplataforma completa para gestión de pedidos de comida a domicilio. El sistema integra un backend en Node.js con Express, una base de datos PostgreSQL con soporte geoespacial (PostGIS), y un frontend móvil desarrollado en Flutter.

### Características Principales
- ✅ Sistema de pedidos en tiempo real
- ✅ Asignación automática de domiciliarios basada en geolocalización
- ✅ Seguimiento de estados de pedidos
- ✅ Módulos especializados para diferentes roles (Cliente, Cajero, Cocinero, Domiciliario)
- ✅ Reportes y estadísticas de ventas
- ✅ Gestión de inventario de productos

---

## 🗄️ Análisis del Esquema de Base de Datos

### 1. Extensiones PostgreSQL

```sql
-- PostGIS: Soporte para datos geoespaciales
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;
```

El sistema utiliza PostGIS para manejar ubicaciones geográficas y calcular distancias entre usuarios, domiciliarios y vendedores.

### 2. Tablas Principales y Relaciones

#### 2.1 Gestión de Usuarios

##### `users` - Usuarios Clientes
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    name VARCHAR(100),
    address VARCHAR(200),
    location GEOGRAPHY(Point, 4326),  -- Ubicación geoespacial
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_location ON users USING gist (location);
```

**Propósito:** Almacena información de los clientes que realizan pedidos.

**Campos clave:**
- `location`: Coordenadas GPS (latitud/longitud) del usuario en formato PostGIS
- `phone`: Identificador principal para clientes
- `address`: Dirección de entrega

##### `user_admin` - Usuarios Administrativos
```sql
CREATE TABLE user_admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role_id INTEGER REFERENCES roles(id),
    name VARCHAR(100)
);
```

**Propósito:** Credenciales y perfiles de usuarios del sistema (cajeros, cocineros, administradores).

**Roles soportados:** Ver tabla `roles`

##### `roles` - Roles del Sistema
```sql
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT
);
```

**Propósito:** Define los diferentes roles administrativos del sistema.

**Roles típicos:**
- `cajero`: Gestiona pagos y reportes de caja
- `cocinero`: Maneja preparación de pedidos
- `domiciliario`: Entrega pedidos
- `admin`: Administración completa

#### 2.2 Catálogo de Productos

##### `categories` - Categorías de Productos
```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);
```

**Propósito:** Organización y clasificación de productos (ej: Bebidas, Platos Principales, Postres).

##### `vendors` - Vendedores/Proveedores
```sql
CREATE TABLE vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    contact_phone VARCHAR(20),
    location GEOGRAPHY(Point, 4326)
);
CREATE INDEX idx_vendors_location ON vendors USING gist (location);
```

**Propósito:** Información de los restaurantes o proveedores que ofrecen productos.

**Uso geoespacial:** La ubicación permite calcular distancias y tiempos de entrega.

##### `products` - Productos Disponibles
```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INTEGER REFERENCES categories(id),
    vendor_id INTEGER REFERENCES vendors(id),
    price NUMERIC(10,2) NOT NULL,
    description TEXT,
    image_url TEXT
);
```

**Propósito:** Catálogo completo de productos disponibles para pedidos.

**Relaciones:**
- Cada producto pertenece a una categoría
- Cada producto está asociado a un vendedor

##### `product_media` - Media de Productos
```sql
CREATE TABLE product_media (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    media_type VARCHAR(20) NOT NULL,  -- 'image', 'video'
    media_url TEXT NOT NULL,
    description TEXT
);
```

**Propósito:** Soporte para múltiples imágenes y videos por producto.

#### 2.3 Sistema de Pedidos

##### `orders` - Pedidos
```sql
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total NUMERIC(10,2) NOT NULL,
    status VARCHAR(20) DEFAULT 'pendiente',
    driver_id INTEGER REFERENCES drivers(id),
    order_channel VARCHAR(20) DEFAULT 'app',  -- 'app', 'web', 'phone'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Propósito:** Registro principal de cada pedido realizado.

**Estados posibles:**
- `pendiente`: Pedido creado, esperando pago
- `pagado`: Pago confirmado
- `preparando`: En cocina
- `listo`: Listo para entregar
- `entregado`: Completado
- `cancelado`: Cancelado

**Campos clave:**
- `driver_id`: Domiciliario asignado automáticamente
- `order_channel`: Canal de origen del pedido

##### `order_items` - Ítems del Pedido
```sql
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price NUMERIC(10,2) NOT NULL  -- Precio al momento del pedido
);
```

**Propósito:** Detalle de productos en cada pedido.

**Nota:** El precio se guarda para mantener histórico, incluso si cambia el precio del producto.

##### `order_status` - Estados Válidos
```sql
CREATE TABLE order_status (
    id SERIAL PRIMARY KEY,
    status VARCHAR(20) UNIQUE NOT NULL
);
```

**Propósito:** Catálogo de estados válidos para pedidos (tabla de referencia).

##### `status_history` - Historial de Cambios
```sql
CREATE TABLE status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    changed_by INTEGER,  -- user_admin.id que hizo el cambio
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Propósito:** Auditoría completa de cambios de estado en cada pedido.

**Uso:** Permite rastrear:
- Quién cambió el estado
- Cuándo ocurrió el cambio
- Secuencia completa del procesamiento del pedido

#### 2.4 Sistema de Entregas

##### `drivers` - Domiciliarios
```sql
CREATE TABLE drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    phone VARCHAR(20),
    location GEOGRAPHY(Point, 4326),
    status VARCHAR(20) DEFAULT 'available',  -- 'available', 'busy', 'offline'
    updated_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_drivers_location ON drivers USING gist (location);
```

**Propósito:** Gestión de domiciliarios y su disponibilidad.

**Estados:**
- `available`: Disponible para asignar pedidos
- `busy`: Ocupado con un pedido
- `offline`: No disponible

**Sistema de asignación:** El backend asigna automáticamente el domiciliario más cercano usando cálculos PostGIS.

---

## 🔧 Arquitectura del Backend (Node.js + Express)

### Estructura del Proyecto

```
app_backend/
├── server.js              # Punto de entrada
├── db.js                  # Configuración PostgreSQL
├── package.json           # Dependencias
├── controllers/           # Lógica de negocio
│   ├── adminController.js
│   ├── adminDataController.js
│   ├── adminProductsController.js
│   ├── cajeroController.js
│   ├── driversController.js
│   ├── pedidosController.js
│   └── productosController.js
└── routes/                # Definición de rutas API
    ├── admin.js
    ├── adminData.js
    ├── adminProducts.js
    ├── cajero.js
    ├── drivers.js
    ├── pedidos.js
    └── productos.js
```

### Configuración (server.js)

```javascript
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// Rutas
app.use('/productos', productosRoutes);
app.use('/pedidos', pedidosRoutes);
app.use('/', adminRoutes);
app.use('/admin', adminProductsRoutes);
app.use('/admin', adminDataRoutes);
app.use('/drivers', driversRoutes);
app.use('/cajero', cajeroRoutes);

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor en http://127.0.0.1:${PORT}`);
});
```

### Conexión a Base de Datos (db.js)

```javascript
const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Bd_App',
  password: 'root',
  port: 5432,
});

pool.connect()
  .then(() => console.log('Conectado a PostgreSQL ✅'))
  .catch(err => console.error('Error PostgreSQL ❌', err));

module.exports = pool;
```

---

## 🔌 Documentación de API Endpoints

### 1. Autenticación y Usuarios

#### `POST /loginAdmin`
**Propósito:** Autenticación de usuarios administrativos.

**Request Body:**
```json
{
  "username": "admin",
  "password": "password123"
}
```

**Response (Éxito):**
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

**Response (Fallo):**
```json
{
  "success": false,
  "message": "Credenciales incorrectas"
}
```

---

### 2. Gestión de Productos

#### `GET /productos`
**Propósito:** Obtener catálogo completo de productos.

**Response:**
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

**Uso:** Mostrar productos disponibles en la aplicación móvil.

#### `POST /admin/products`
**Propósito:** Agregar nuevo producto (solo administradores).

**Request Body:**
```json
{
  "name": "Pizza Margherita",
  "description": "Pizza con tomate, mozzarella y albahaca",
  "price": 25000,
  "imageUrl": "data:image/jpeg;base64,...",
  "categoryId": 2,
  "vendorId": 1
}
```

**Response:**
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

#### `PUT /admin/products/:id`
**Propósito:** Actualizar producto existente.

**Request Body:** (campos opcionales)
```json
{
  "name": "Pizza Margherita Especial",
  "price": 28000
}
```

---

### 3. Gestión de Pedidos

#### `POST /pedidos`
**Propósito:** Crear nuevo pedido.

**Request Body:**
```json
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

**Proceso interno:**
1. Verifica o crea el usuario en la tabla `users`
2. Asigna domiciliario más cercano disponible usando PostGIS:
   ```sql
   SELECT id FROM drivers
   WHERE status='available'
   ORDER BY location <-> ST_SetSRID(ST_MakePoint(lng, lat), 4326)
   LIMIT 1
   FOR UPDATE SKIP LOCKED
   ```
3. Crea el pedido en `orders`
4. Registra productos en `order_items`
5. Registra cambio en `status_history`

**Response:**
```json
{
  "success": true,
  "order_id": 42,
  "driver_id": 3,
  "total": "36000.00"
}
```

#### `GET /pedidos?estado=pendiente`
**Propósito:** Obtener pedidos filtrados por estado.

**Query Parameters:**
- `estado`: pendiente | pagado | preparando | listo | entregado | cancelado

**Response:**
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

#### `GET /pedidos/all`
**Propósito:** Obtener todos los pedidos sin filtrar.

#### `GET /pedidos/:id`
**Propósito:** Obtener detalle de un pedido específico.

#### `GET /pedidos/:id/detalle`
**Propósito:** Obtener detalle completo con historial de estados.

---

### 4. Cambios de Estado de Pedidos

#### `PUT /pedidos/:id/pago`
**Propósito:** Confirmar pago de pedido (Cajero).

**Request Body:**
```json
{
  "changed_by": 1  // ID del cajero
}
```

**Cambia estado:** `pendiente` → `pagado`

#### `PUT /pedidos/:id/preparar`
**Propósito:** Marcar pedido en preparación (Cocinero).

**Cambia estado:** `pagado` → `preparando`

#### `PUT /pedidos/:id/listo` o `/pedidos/:id/listo-cocina`
**Propósito:** Marcar pedido listo (Cocinero).

**Cambia estado:** `preparando` → `listo`

#### `PUT /pedidos/:id/entregar` o `/pedidos/:id/entregado-cliente`
**Propósito:** Marcar pedido entregado (Domiciliario).

**Cambia estado:** `listo` → `entregado`

**Proceso interno:**
- Cambia estado del pedido
- Libera el domiciliario (status → 'available')
- Registra en historial

#### `PUT /pedidos/:id/cancelar`
**Propósito:** Cancelar pedido.

**Cambia estado:** cualquier estado → `cancelado`

---

### 5. Gestión de Domiciliarios

#### `GET /drivers/:driverId`
**Propósito:** Obtener perfil de domiciliario.

**Response:**
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

#### `PATCH /drivers/:driverId/location`
**Propósito:** Actualizar ubicación GPS del domiciliario.

**Request Body:**
```json
{
  "lat": 4.6100,
  "lng": -74.0820
}
```

**Uso:** El app móvil del domiciliario envía actualizaciones periódicas de ubicación.

#### `PATCH /drivers/:driverId/status`
**Propósito:** Cambiar disponibilidad del domiciliario.

**Request Body:**
```json
{
  "status": "available"  // 'available' | 'busy' | 'offline'
}
```

#### `GET /drivers/:driverId/orders?estados=listo,preparando`
**Propósito:** Obtener pedidos asignados al domiciliario.

**Query Parameters:**
- `estados`: (opcional) filtro de estados separados por coma

**Response:**
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

#### `GET /drivers/:driverId/orders/history`
**Propósito:** Historial de entregas completadas.

#### `POST /drivers/:driverId/orders/:orderId/picked-up`
**Propósito:** Marcar que recogió el pedido.

**Uso:** Registra evento en `status_history` con status 'picked_up'.

#### `POST /drivers/:driverId/orders/:orderId/on-route`
**Propósito:** Marcar que va en camino.

**Uso:** Registra evento en `status_history` con status 'on_route'.

#### `POST /drivers/:driverId/orders/:orderId/delivered`
**Propósito:** Marcar pedido entregado.

**Uso:** Cambia estado a 'entregado' y libera al domiciliario.

---

### 6. Módulo de Caja (Cajero)

#### `GET /cajero/ventas/dia`
**Propósito:** Resumen de ventas del día actual.

**Response:**
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

#### `GET /cajero/ventas/reporte?fecha_inicio=2024-01-01&fecha_fin=2024-01-31`
**Propósito:** Reporte detallado de ventas por rango de fechas.

**Response:**
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

#### `GET /cajero/pagos/historial?limit=50&offset=0`
**Propósito:** Historial de transacciones de pago.

**Response:**
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

#### `GET /cajero/estadisticas`
**Propósito:** Estadísticas generales de caja.

**Response:**
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

### 7. Datos Administrativos

#### `GET /admin/categories`
**Propósito:** Obtener lista de categorías.

**Response:**
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

#### `GET /admin/vendors`
**Propósito:** Obtener lista de vendedores.

**Response:**
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

## 📱 Arquitectura del Frontend (Flutter)

### Estructura del Proyecto

```
app_frontend/lib/
├── main.dart              # Punto de entrada
├── api_service.dart       # Cliente HTTP para backend
├── models/                # Modelos de datos
│   ├── product.dart
│   ├── categoria.dart
│   └── vendor.dart
├── pages/                 # Páginas principales
│   ├── login_choice_page.dart
│   ├── login_admin_page.dart
│   ├── productos_por_categoria_page.dart
│   ├── agregar_producto_page.dart
│   ├── confirmar_pedido_page.dart
│   ├── pago_page.dart
│   ├── pedidos_cajero_page.dart
│   ├── pedidos_cocinero_page.dart
│   ├── pedidos_listos_page.dart
│   ├── cajero_dashboard_page.dart
│   ├── domiciliario_page.dart
│   └── detalle_pedido_page.dart
├── screens/               # Pantallas auxiliares
│   └── location_screen.dart
├── theme/                 # Tema visual
│   └── app_theme.dart
└── utils/                 # Utilidades
```

### Dependencias Principales (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2                    # Cliente HTTP
  geolocator: 14.0.2              # Geolocalización
  google_maps_flutter: ^2.6.1     # Mapas
  geocoding: ^2.1.0               # Geocodificación
  url_launcher: ^6.1.10           # Abrir URLs/teléfonos
  font_awesome_flutter: 10.10.0   # Iconos
  intl: ^0.19.0                   # Formateo de números/fechas
  audioplayers: ^6.0.0            # Notificaciones sonoras
```

---

## 🎨 Flujos de Usuario por Rol

### 1. Cliente (Usuario Final)

#### Flujo de Pedido Completo

1. **Inicio de Sesión**
   - Pantalla: `LoginChoicePage`
   - Usuario selecciona "Cliente" → Navega a `LocationScreen`

2. **Selección de Ubicación**
   - Pantalla: `LocationScreen`
   - Ingresa dirección manualmente o usa GPS
   - Verifica ubicación en mapa Google Maps
   - Botón "Continuar" → Navega a `ProductosPorCategoriaPage`

3. **Exploración de Productos**
   - Pantalla: `ProductosPorCategoriaPage`
   - Funcionalidades:
     - Búsqueda de productos por nombre
     - Filtrado por categoría
     - Vista organizada por vendedor
     - Agregar productos al carrito con cantidad
   - Botón "Ver Carrito" → Modal con resumen
   - Botón "Confirmar Pedido" → Navega a `ConfirmarPedidoPage`

4. **Confirmación y Envío**
   - Pantalla: `ConfirmarPedidoPage`
   - Muestra:
     - Resumen del pedido
     - Total a pagar
     - Dirección de entrega
   - Solicita:
     - Nombre
     - Teléfono
   - Obtiene ubicación GPS automáticamente
   - Botón "Enviar Pedido" → API `POST /pedidos`
   - Mensaje de éxito con ID de pedido

### 2. Cajero

#### Flujo de Gestión de Caja

1. **Inicio de Sesión**
   - Pantalla: `LoginChoicePage` → `LoginAdminPage`
   - Ingresa credenciales
   - API: `POST /loginAdmin`
   - Si role='cajero' → Navega a `PedidosCajeroPage`

2. **Gestión de Pedidos Pendientes**
   - Pantalla: `PedidosCajeroPage`
   - Vista de pestañas:
     - **Pendientes**: Pedidos sin pagar
     - **Pagados**: Pedidos confirmados
     - **Historial**: Todos los pedidos
   - Para cada pedido pendiente:
     - Ver detalle completo
     - Botón "Confirmar Pago" → API `PUT /pedidos/:id/pago`
     - Animación de confirmación
     - Notificación sonora

3. **Dashboard de Ventas**
   - Pantalla: `CajeroDashboardPage` (si existe)
   - Estadísticas en tiempo real:
     - Ventas del día
     - Total de pedidos
     - Gráficos de ventas
   - API: `GET /cajero/estadisticas`

4. **Reportes**
   - Acceso a reportes detallados
   - APIs:
     - `GET /cajero/ventas/dia`
     - `GET /cajero/ventas/reporte`
     - `GET /cajero/pagos/historial`

### 3. Cocinero

#### Flujo de Preparación de Pedidos

1. **Inicio de Sesión**
   - Pantalla: `LoginChoicePage` → `LoginAdminPage`
   - API: `POST /loginAdmin`
   - Si role='cocinero' → Navega a `PedidosCocineroPage`

2. **Gestión de Cocina**
   - Pantalla: `PedidosCocineroPage`
   - Vista de pestañas:
     - **Pagados**: Pedidos listos para preparar
     - **En Preparación**: Pedidos en cocina
     - **Listos**: Pedidos completados
   
3. **Acciones por Pedido**
   - En estado "Pagado":
     - Ver detalle de productos
     - Botón "Iniciar Preparación" → API `PUT /pedidos/:id/preparar`
   - En estado "Preparando":
     - Ver tiempo transcurrido
     - Botón "Marcar Listo" → API `PUT /pedidos/:id/listo-cocina`
   - Notificaciones sonoras al recibir nuevos pedidos

4. **Pantalla de Pedidos Listos**
   - Pantalla: `PedidosListosPage`
   - Lista de pedidos listos para recoger
   - Información del domiciliario asignado
   - Estado de la entrega

### 4. Domiciliario

#### Flujo de Entrega de Pedidos

1. **Inicio de Sesión**
   - Pantalla: `LoginChoicePage` → `LoginAdminPage`
   - API: `POST /loginAdmin`
   - Si role='domiciliario' → Navega a `DomiciliarioPage`

2. **Gestión de Entregas**
   - Pantalla: `DomiciliarioPage`
   - Vista de pestañas:
     - **Asignados**: Pedidos para entregar
     - **Historial**: Entregas completadas
   
3. **Información del Domiciliario**
   - Muestra perfil del domiciliario
   - Estado actual (disponible/ocupado)
   - Ubicación GPS en mapa
   - API: `GET /drivers/:driverId`

4. **Proceso de Entrega**
   - Para cada pedido asignado:
     - Ver detalles del pedido
     - Dirección de entrega
     - Datos del cliente (nombre, teléfono)
     - Total a cobrar
   - Acciones:
     - Botón "Pedido Recogido" → API `POST /drivers/:driverId/orders/:orderId/picked-up`
     - Botón "En Camino" → API `POST /drivers/:driverId/orders/:orderId/on-route`
     - Botón "Entregar" → API `POST /drivers/:driverId/orders/:orderId/delivered`
   - Integración:
     - Llamar al cliente (url_launcher)
     - Ver ubicación en Google Maps
   - Actualización periódica de ubicación GPS
     - API: `PATCH /drivers/:driverId/location`

5. **Control de Disponibilidad**
   - Toggle de disponibilidad
   - API: `PATCH /drivers/:driverId/status`
   - Estados: available | offline

### 5. Administrador

#### Flujo de Gestión de Productos

1. **Inicio de Sesión**
   - Similar a otros roles
   - Acceso completo a todas las funcionalidades

2. **Agregar Productos**
   - Pantalla: `AgregarProductoPage`
   - Formulario:
     - Nombre del producto
     - Descripción
     - Precio
     - Imagen (base64)
     - Categoría (dropdown)
     - Vendedor (dropdown)
   - APIs auxiliares:
     - `GET /admin/categories`
     - `GET /admin/vendors`
   - Envío: API `POST /admin/products`

3. **Editar Productos**
   - Selección de producto existente
   - API: `PUT /admin/products/:id`

---

## 🔐 Características de Seguridad

### 1. Autenticación
- Login con usuario y contraseña
- Validación de roles en backend
- Respuestas normalizadas (roles en minúsculas)

### 2. Autorización por Roles
- Cajero: Solo acceso a gestión de pagos y reportes
- Cocinero: Solo cambios de estado de preparación
- Domiciliario: Solo entregas asignadas a él
- Admin: Acceso completo

### 3. Integridad de Datos
- Transacciones SQL (BEGIN/COMMIT/ROLLBACK)
- Cascadas de eliminación (ON DELETE CASCADE)
- Validaciones de entrada en controllers

### 4. Concurrencia
- `FOR UPDATE SKIP LOCKED` para asignación atómica de domiciliarios
- Evita condiciones de carrera en asignación de pedidos

---

## 🗺️ Características Geoespaciales (PostGIS)

### 1. Almacenamiento de Ubicaciones

```sql
-- Tipo de dato: GEOGRAPHY(Point, 4326)
-- 4326 = Sistema de coordenadas WGS84 (GPS estándar)
location GEOGRAPHY(Point, 4326)
```

### 2. Asignación Inteligente de Domiciliarios

**Algoritmo:**
1. Obtiene ubicación del usuario que hace el pedido
2. Busca el domiciliario disponible más cercano
3. Usa operador de distancia PostGIS (`<->`)
4. Bloquea el registro para evitar doble asignación

**SQL:**
```sql
SELECT id
FROM drivers
WHERE status='available'
ORDER BY location <-> ST_SetSRID(ST_MakePoint($lng, $lat), 4326)
LIMIT 1
FOR UPDATE SKIP LOCKED
```

### 3. Tracking de Domiciliarios
- Actualización periódica de ubicación GPS
- Cálculo de distancias en tiempo real
- Visualización en mapas Google Maps

### 4. Índices Espaciales (GIST)
```sql
CREATE INDEX idx_drivers_location ON drivers USING gist (location);
CREATE INDEX idx_users_location ON users USING gist (location);
CREATE INDEX idx_vendors_location ON vendors USING gist (location);
```

**Beneficio:** Consultas geoespaciales ultra-rápidas incluso con miles de registros.

---

## 📊 Sistema de Estados y Workflows

### Ciclo de Vida de un Pedido

```
┌─────────────┐
│  pendiente  │ (Pedido creado)
└──────┬──────┘
       │ [Cajero confirma pago]
       ↓
┌─────────────┐
│   pagado    │ (Pago confirmado)
└──────┬──────┘
       │ [Cocinero inicia preparación]
       ↓
┌─────────────┐
│ preparando  │ (En cocina)
└──────┬──────┘
       │ [Cocinero marca listo]
       ↓
┌─────────────┐
│    listo    │ (Listo para entregar)
└──────┬──────┘
       │ [Domiciliario entrega]
       ↓
┌─────────────┐
│ entregado   │ (Completado)
└─────────────┘

En cualquier momento:
┌─────────────┐
│ cancelado   │ (Cancelado)
└─────────────┘
```

### Estados Intermedios (en status_history)

- `picked_up`: Domiciliario recogió el pedido
- `on_route`: Domiciliario en camino al cliente

---

## 🎨 Sistema de Temas (AppTheme)

### Configuración de Tema

```dart
// theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      elevation: 2,
    ),
    // ... más configuraciones
  );
}
```

### Uso en la Aplicación
- Colores consistentes en toda la app
- Tipografía estandarizada
- Componentes reutilizables

---

## 🔔 Notificaciones y Alertas

### 1. Notificaciones Sonoras
- Biblioteca: `audioplayers`
- Uso: Alertar nuevos pedidos a cocineros
- Assets: `assets/sounds/`

### 2. SnackBars y Dialogs
- Confirmaciones de acciones
- Mensajes de error
- Alertas de éxito

---

## 📈 Reportes y Analítica

### Métricas Disponibles

1. **Ventas por Día**
   - Total de pedidos
   - Total de ingresos
   - Promedio por pedido

2. **Ventas por Período**
   - Rango de fechas personalizado
   - Desglose diario
   - Productos más vendidos

3. **Estadísticas en Tiempo Real**
   - Pedidos del día/semana/mes
   - Pedidos pendientes de pago
   - Tendencias de ventas

4. **Historial de Transacciones**
   - Registro de pagos
   - Cajero que procesó el pago
   - Paginación de resultados

---

## 🚀 Tecnologías Utilizadas

### Backend
- **Node.js** v14+
- **Express** 4.19.2 - Framework web
- **PostgreSQL** 17.6 - Base de datos
- **PostGIS** - Extensión geoespacial
- **pg** 8.16.3 - Cliente PostgreSQL
- **cors** 2.8.5 - CORS middleware

### Frontend
- **Flutter** SDK >=3.0.0
- **Dart** 3.0+
- **http** 1.2.2 - Cliente HTTP
- **geolocator** 14.0.2 - GPS
- **google_maps_flutter** 2.6.1 - Mapas
- **geocoding** 2.1.0 - Geocodificación
- **audioplayers** 6.0.0 - Audio
- **intl** 0.19.0 - Internacionalización

---

## 📝 Convenciones de Código

### Backend (JavaScript)

```javascript
// Nombres de funciones: camelCase
const crearPedido = async (req, res) => { ... }

// Nombres de constantes: UPPER_SNAKE_CASE
const ESTADOS = {
  PENDIENTE: 'pendiente',
  PAGADO: 'pagado'
};

// Uso de async/await para operaciones asíncronas
const client = await pool.connect();
try {
  await client.query('BEGIN');
  // ... operaciones
  await client.query('COMMIT');
} catch (err) {
  await client.query('ROLLBACK');
  throw err;
} finally {
  client.release();
}
```

### Frontend (Dart/Flutter)

```dart
// Nombres de clases: PascalCase
class ProductosPorCategoriaPage extends StatefulWidget { ... }

// Nombres de variables: camelCase
List<Product> carrito = [];

// Nombres de archivos: snake_case
// productos_por_categoria_page.dart
```

---

## 🔄 Flujo de Datos

### 1. Cliente → Backend → Base de Datos

```
[Flutter App]
    │
    │ HTTP Request (JSON)
    ↓
[Express Routes]
    │
    ↓
[Controllers]
    │
    │ SQL Query
    ↓
[PostgreSQL DB]
```

### 2. Base de Datos → Backend → Cliente

```
[PostgreSQL DB]
    │
    │ Result Rows
    ↓
[Controllers]
    │
    │ JSON Formatting
    ↓
[Express Routes]
    │
    │ HTTP Response
    ↓
[Flutter App]
```

---

## 🧪 Puntos de Prueba Recomendados

### Backend

1. **Creación de Pedidos**
   - Pedido con usuario nuevo vs. existente
   - Pedido sin domiciliarios disponibles
   - Cálculo correcto del total

2. **Asignación de Domiciliarios**
   - Asignación al más cercano
   - Manejo de concurrencia (múltiples pedidos simultáneos)
   - Liberación correcta al entregar

3. **Cambios de Estado**
   - Transiciones válidas
   - Registro en historial
   - Transacciones atómicas

4. **Reportes**
   - Cálculos correctos de totales
   - Filtros por fecha
   - Productos más vendidos

### Frontend

1. **Geolocalización**
   - Permisos de ubicación
   - Manejo de GPS desactivado
   - Integración con Google Maps

2. **Carrito de Compras**
   - Agregar/quitar productos
   - Actualización de cantidades
   - Cálculo de total

3. **Roles de Usuario**
   - Navegación según rol
   - Restricciones de acceso
   - Persistencia de sesión

4. **Notificaciones**
   - Alertas sonoras
   - Mensajes de confirmación
   - Manejo de errores

---

## 📚 Recursos Adicionales

### Documentación de Referencia
- [Express.js Documentation](https://expressjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [PostGIS Documentation](https://postgis.net/documentation/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

### Archivos de Documentación Existentes
El repositorio ya contiene extensa documentación sobre mejoras recientes:
- `COMPLETE_SUMMARY.md` - Resumen completo de implementaciones
- `CASHIER_README.md` - Módulo de cajero
- `KITCHEN_ENHANCEMENT_FINAL_SUMMARY.md` - Mejoras de cocina
- `PEDIDOS_LISTOS_README.md` - Pantalla de pedidos listos
- `THEME_DOCUMENTATION.md` - Sistema de temas
- `LOCATION_SCREEN_README.md` - Pantalla de ubicación

---

## 🔮 Posibles Mejoras Futuras

1. **Notificaciones Push**
   - Alertas en tiempo real para clientes
   - Notificaciones de estado de pedido
   - Firebase Cloud Messaging

2. **Autenticación Mejorada**
   - JWT tokens
   - OAuth2 / Social login
   - Refresh tokens

3. **Pagos en Línea**
   - Integración con pasarelas de pago
   - Múltiples métodos de pago
   - Facturación electrónica

4. **Análisis Avanzado**
   - Dashboard de analytics
   - Predicción de demanda
   - Reportes automáticos

5. **Gestión de Inventario**
   - Stock de productos
   - Alertas de bajo inventario
   - Órdenes de reabastecimiento

6. **Calificaciones y Reseñas**
   - Rating de productos
   - Comentarios de clientes
   - Rating de domiciliarios

7. **Chat en Tiempo Real**
   - Comunicación cliente-domiciliario
   - Soporte técnico
   - WebSocket o Socket.io

---

## 📞 Soporte y Contacto

Para preguntas o soporte sobre el sistema, consulte:
- Repositorio: [cristianchamorro/App_pedidos](https://github.com/cristianchamorro/App_pedidos)
- Documentación adicional en la carpeta raíz del proyecto

---

**Última actualización:** 2024
**Versión del sistema:** 1.0.0
**Mantenido por:** Equipo de desarrollo App Pedidos
