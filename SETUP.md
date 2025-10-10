# 🚀 App Pedidos - Guía de Configuración Completa

Sistema completo de gestión de pedidos con backend Node.js/Express/PostgreSQL y frontend Flutter.

## 📋 Tabla de Contenidos
1. [Requisitos Previos](#requisitos-previos)
2. [Configuración de la Base de Datos](#configuración-de-la-base-de-datos)
3. [Configuración del Backend](#configuración-del-backend)
4. [Configuración del Frontend](#configuración-del-frontend)
5. [Datos de Prueba](#datos-de-prueba)
6. [Arquitectura del Sistema](#arquitectura-del-sistema)

---

## 📦 Requisitos Previos

### Backend
- **Node.js** v14 o superior
- **PostgreSQL** v12 o superior
- **PostGIS** (extensión de PostgreSQL para geolocalización)

### Frontend
- **Flutter SDK** v3.0 o superior
- **Dart** v2.17 o superior
- Android Studio / Xcode (para desarrollo móvil)

---

## 🗄️ Configuración de la Base de Datos

### 1. Instalar PostgreSQL y PostGIS

#### En Ubuntu/Debian:
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib postgis
```

#### En macOS (con Homebrew):
```bash
brew install postgresql postgis
brew services start postgresql
```

#### En Windows:
Descargar e instalar desde [postgresql.org](https://www.postgresql.org/download/windows/)

### 2. Crear la Base de Datos

```bash
# Conectar como usuario postgres
sudo -u postgres psql

# Crear la base de datos
CREATE DATABASE "Bd_App";

# Conectar a la base de datos
\c Bd_App

# Habilitar la extensión PostGIS
CREATE EXTENSION postgis;

# Salir
\q
```

### 3. Ejecutar el Esquema

```bash
# Desde la carpeta app_backend
psql -U postgres -d Bd_App -f esquema.sql
```

O manualmente:
```bash
sudo -u postgres psql -d Bd_App -f /ruta/a/app_backend/esquema.sql
```

### 4. Verificar las Tablas Creadas

```bash
sudo -u postgres psql -d Bd_App

# Listar todas las tablas
\dt

# Deberías ver:
# - roles
# - user_admin
# - categories
# - vendors
# - products
# - users
# - drivers
# - orders
# - order_items
# - status_history
```

---

## 🔧 Configuración del Backend

### 1. Instalar Dependencias

```bash
cd app_backend
npm install
```

### 2. Configurar Conexión a la Base de Datos

Editar `app_backend/db.js` con tus credenciales:

```javascript
const pool = new Pool({
  user: 'postgres',        // Tu usuario de PostgreSQL
  host: 'localhost',       // Host de PostgreSQL
  database: 'Bd_App',      // Nombre de la base de datos
  password: 'root',        // Tu contraseña de PostgreSQL
  port: 5432,              // Puerto de PostgreSQL (por defecto 5432)
});
```

### 3. Iniciar el Servidor

```bash
npm start
```

El servidor estará disponible en: `http://localhost:3000`

### 4. Verificar Endpoints

Prueba los siguientes endpoints en tu navegador o con Postman:

- **GET** `http://localhost:3000/productos` - Lista de productos
- **GET** `http://localhost:3000/admin/categories` - Categorías
- **GET** `http://localhost:3000/admin/vendors` - Proveedores
- **POST** `http://localhost:3000/loginAdmin` - Login de administrador

---

## 📱 Configuración del Frontend

### 1. Instalar Flutter

Sigue la guía oficial: [flutter.dev](https://docs.flutter.dev/get-started/install)

### 2. Verificar Instalación

```bash
flutter doctor
```

### 3. Configurar Conexión al Backend

Editar `app_frontend/lib/api_service.dart`:

```dart
class ApiService {
  // Cambia esta URL según tu configuración
  final String baseUrl = 'http://localhost:3000';  // Para web/desktop
  // final String baseUrl = 'http://10.0.2.2:3000';  // Para Android Emulator
  // final String baseUrl = 'http://TU_IP:3000';     // Para dispositivo físico
```

### 4. Instalar Dependencias de Flutter

```bash
cd app_frontend
flutter pub get
```

### 5. Ejecutar la Aplicación

#### En Chrome (Web):
```bash
flutter run -d chrome
```

#### En Android Emulator:
```bash
flutter run -d emulator-xxxx
```

#### En iOS Simulator:
```bash
flutter run -d iPhone
```

---

## 🧪 Datos de Prueba

El esquema incluye datos de prueba. Aquí están las credenciales:

### Usuarios Administrativos

| Usuario   | Contraseña    | Rol       |
|-----------|---------------|-----------|
| admin     | admin123      | admin     |
| cajero    | cajero123     | cajero    |
| cocinero  | cocinero123   | cocinero  |

### Productos de Ejemplo

- Hamburguesa Clásica - $8.50
- Coca Cola - $2.00
- Pizza Pepperoni - $12.00
- Ensalada César - $7.50
- Helado de Chocolate - $4.00

### Drivers Disponibles

- Juan Pérez (555-0101) - Disponible
- María García (555-0102) - Disponible
- Carlos Rodríguez (555-0103) - Ocupado

---

## 🏗️ Arquitectura del Sistema

### Estructura de la Base de Datos

```
roles
├── user_admin (administradores)
│
categories
├── products
│   └── order_items
│       └── orders
│           ├── users (clientes)
│           ├── drivers (repartidores)
│           └── status_history
│
vendors
└── products
```

### Estados de Pedidos

1. **pendiente** - Pedido recién creado
2. **preparando** - Pedido en cocina
3. **listo** - Pedido listo para entregar
4. **entregado** - Pedido entregado al cliente
5. **cancelado** - Pedido cancelado
6. **pagado** - Pedido pagado

### Roles de Usuario

- **admin**: Acceso completo al sistema
- **cajero**: Gestión de pagos y estados de pedidos
- **cocinero**: Visualización y preparación de pedidos

---

## 🔗 Endpoints del API

### Productos
- `GET /productos` - Listar todos los productos
- `POST /admin/products` - Agregar producto (admin)
- `PUT /admin/products/:id` - Actualizar producto (admin)

### Pedidos
- `POST /pedidos` - Crear nuevo pedido
- `GET /pedidos` - Obtener pedidos por estado (?estado=pendiente)
- `GET /pedidos/all` - Todos los pedidos
- `GET /pedidos/:id` - Detalle de pedido
- `PUT /pedidos/:id/preparar` - Marcar como preparando
- `PUT /pedidos/:id/listo` - Marcar como listo
- `PUT /pedidos/:id/entregar` - Marcar como entregado
- `PUT /pedidos/:id/cancelar` - Cancelar pedido
- `PUT /pedidos/:id/pago` - Confirmar pago

### Administración
- `POST /loginAdmin` - Login de administrador
- `GET /admin/categories` - Listar categorías
- `GET /admin/vendors` - Listar proveedores

---

## 🐛 Solución de Problemas

### Backend no inicia

1. Verificar que PostgreSQL esté corriendo:
   ```bash
   sudo service postgresql status
   ```

2. Verificar credenciales en `db.js`

3. Verificar que el puerto 3000 esté libre:
   ```bash
   lsof -i :3000
   ```

### Frontend no conecta al Backend

1. Verificar la URL en `api_service.dart`
2. Para Android Emulator, usar `10.0.2.2` en lugar de `localhost`
3. Para dispositivos físicos, usar la IP de tu computadora

### Error de PostGIS

Si recibes errores relacionados con PostGIS:
```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

---

## 📝 Notas Importantes

1. **Seguridad**: Las contraseñas están en texto plano. En producción, usar bcrypt o similar.
2. **CORS**: El backend tiene CORS habilitado para todos los orígenes en desarrollo.
3. **PostGIS**: Necesario para la asignación de drivers por geolocalización.
4. **Imágenes**: Los productos usan URLs de placeholder. Actualizar con imágenes reales.

---

## 📞 Soporte

Para problemas o preguntas, consultar la documentación del código o revisar los logs:
- Backend: Consola donde se ejecuta `npm start`
- Frontend: Consola de Flutter o Android Studio/Xcode

---

¡Sistema listo para usar! 🎉
