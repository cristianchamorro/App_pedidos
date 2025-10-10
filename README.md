# 🍔 App Pedidos

Aplicación multiplataforma completa para la realización y gestión de pedidos de comida.

## 📱 Descripción

Sistema integral de gestión de pedidos que incluye:
- **Backend**: Node.js + Express + PostgreSQL con PostGIS
- **Frontend**: Flutter (iOS, Android, Web)
- **Roles**: Clientes, Administradores, Cajeros, Cocineros
- **Funcionalidades**: Gestión de productos, pedidos, usuarios, drivers con geolocalización

## 🚀 Inicio Rápido

### 1. Configurar Base de Datos
```bash
# Crear base de datos
sudo -u postgres psql
CREATE DATABASE "Bd_App";
\c Bd_App
CREATE EXTENSION postgis;
\q

# Ejecutar esquema
cd app_backend
psql -U postgres -d Bd_App -f esquema.sql
```

### 2. Iniciar Backend
```bash
cd app_backend
npm install
npm start
```

### 3. Ejecutar Frontend
```bash
cd app_frontend
flutter pub get
flutter run -d chrome
```

## 📚 Documentación Completa

- **[SETUP.md](SETUP.md)** - Guía completa de instalación y configuración
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Documentación detallada de todos los endpoints

## 🏗️ Estructura del Proyecto

```
App_pedidos/
├── app_backend/          # Backend Node.js
│   ├── controllers/      # Lógica de negocio
│   ├── routes/          # Definición de rutas
│   ├── db.js            # Conexión a PostgreSQL
│   ├── server.js        # Servidor Express
│   └── esquema.sql      # Schema de base de datos
│
├── app_frontend/        # Frontend Flutter
│   ├── lib/
│   │   ├── models/      # Modelos de datos
│   │   ├── pages/       # Pantallas de la app
│   │   ├── screens/     # Pantallas adicionales
│   │   └── api_service.dart  # Cliente HTTP
│   └── pubspec.yaml
│
├── SETUP.md             # Guía de configuración
└── API_DOCUMENTATION.md # Documentación de API
```

## 🔑 Credenciales de Prueba

| Usuario   | Contraseña    | Rol       |
|-----------|---------------|-----------|
| admin     | admin123      | admin     |
| cajero    | cajero123     | cajero    |
| cocinero  | cocinero123   | cocinero  |

## 🌟 Características Principales

- ✅ Gestión completa de productos con categorías y proveedores
- ✅ Sistema de pedidos con estados (pendiente, preparando, listo, entregado)
- ✅ Asignación automática de drivers por geolocalización (PostGIS)
- ✅ Panel de administración para gestionar productos
- ✅ Interface para cajeros (gestión de pagos)
- ✅ Interface para cocineros (preparación de pedidos)
- ✅ Historial de cambios de estado de pedidos
- ✅ API RESTful completa

## 🛠️ Tecnologías

**Backend:**
- Node.js
- Express.js
- PostgreSQL
- PostGIS (geolocalización)

**Frontend:**
- Flutter/Dart
- HTTP package
- Geolocator
- Google Maps

## 📦 Base de Datos

El esquema incluye las siguientes tablas:
- `roles` - Roles de usuario
- `user_admin` - Usuarios administrativos
- `categories` - Categorías de productos
- `vendors` - Proveedores
- `products` - Productos disponibles
- `users` - Clientes
- `drivers` - Conductores con geolocalización
- `orders` - Pedidos
- `order_items` - Productos de cada pedido
- `status_history` - Historial de estados

## 📞 API Endpoints

### Productos
- `GET /productos` - Listar productos
- `POST /admin/products` - Agregar producto
- `PUT /admin/products/:id` - Actualizar producto

### Pedidos
- `POST /pedidos` - Crear pedido
- `GET /pedidos?estado=pendiente` - Obtener por estado
- `PUT /pedidos/:id/preparar` - Cambiar a preparando
- `PUT /pedidos/:id/listo` - Cambiar a listo
- `PUT /pedidos/:id/entregar` - Cambiar a entregado

### Administración
- `POST /loginAdmin` - Login
- `GET /admin/categories` - Listar categorías
- `GET /admin/vendors` - Listar proveedores

Ver [API_DOCUMENTATION.md](API_DOCUMENTATION.md) para más detalles.

## 🤝 Contribuciones

Este es un proyecto educativo. Para mejoras o sugerencias, crear un issue o pull request.

## 📄 Licencia

ISC

---

**Desarrollado con ❤️ usando Node.js y Flutter**
