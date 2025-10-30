# 🍔 App Pedidos - Sistema de Gestión de Pedidos

Aplicación multiplataforma para gestión de pedidos de comida a domicilio con backend Node.js/Express, base de datos PostgreSQL con PostGIS, y frontend Flutter.

## 🚀 Características Principales

- ✅ Sistema de pedidos en tiempo real
- ✅ Asignación automática de domiciliarios con geolocalización (PostGIS)
- ✅ Seguimiento de estados de pedidos
- ✅ Módulos especializados por rol (Cliente, Cajero, Cocinero, Domiciliario)
- ✅ Reportes y estadísticas de ventas
- ✅ Gestión completa de inventario

## 📚 Documentación

### 🆕 **Documentación Nueva y Completa**

Para entender el sistema completo, empieza por estos documentos:

1. **[📖 DOCUMENTACION_COMPLETA_SISTEMA.md](./DOCUMENTACION_COMPLETA_SISTEMA.md)** ⭐ **EMPIEZA AQUÍ**
   - Análisis completo del esquema de base de datos
   - Documentación de todos los endpoints de API
   - Arquitectura del sistema completa
   - Flujos de usuario por rol
   - Stack tecnológico

2. **[📐 DIAGRAMA_ARQUITECTURA.md](./DIAGRAMA_ARQUITECTURA.md)**
   - Diagramas visuales del sistema
   - ERD (Entity Relationship Diagram)
   - Diagramas de secuencia
   - Máquinas de estado
   - Arquitectura de capas

3. **[🚀 GUIA_RAPIDA_API.md](./GUIA_RAPIDA_API.md)**
   - Referencia rápida de API
   - Ejemplos con cURL
   - Códigos de estado
   - Flujos de prueba

4. **[📚 INDICE_DOCUMENTACION.md](./INDICE_DOCUMENTACION.md)**
   - Índice completo de toda la documentación
   - Rutas de aprendizaje recomendadas
   - Búsqueda rápida por tema

### 📂 Documentación por Módulo

El sistema cuenta con más de 60 documentos organizados por módulo. Consulta [INDICE_DOCUMENTACION.md](./INDICE_DOCUMENTACION.md) para el listado completo.

## 🛠️ Stack Tecnológico

### Backend
- **Node.js** + **Express** 4.19.2
- **PostgreSQL** 17.6 + **PostGIS**
- **pg** 8.16.3 (PostgreSQL client)

### Frontend
- **Flutter** SDK >=3.0.0
- **Dart** 3.0+
- **Google Maps** integration
- **Geolocator** para GPS

## ⚡ Inicio Rápido

### Requisitos Previos
- Node.js 14+
- PostgreSQL 17.6 con PostGIS
- Flutter SDK 3.0+

### Backend
```bash
cd app_backend
npm install
node server.js
# Servidor en http://localhost:3000
```

### Frontend
```bash
cd app_frontend
flutter pub get
flutter run
```

### Base de Datos
```bash
# Crear base de datos
createdb Bd_App

# Instalar PostGIS
psql Bd_App
CREATE EXTENSION postgis;

# Ejecutar schema (ver esquema SQL en DOCUMENTACION_COMPLETA_SISTEMA.md)
```

## 🗄️ Esquema de Base de Datos

El sistema utiliza PostgreSQL con PostGIS para gestión de datos y funcionalidades geoespaciales:

- **Usuarios:** `users`, `user_admin`, `roles`
- **Productos:** `products`, `categories`, `vendors`, `product_media`
- **Pedidos:** `orders`, `order_items`, `order_status`, `status_history`
- **Entregas:** `drivers`

Ver análisis completo en [DOCUMENTACION_COMPLETA_SISTEMA.md](./DOCUMENTACION_COMPLETA_SISTEMA.md)

## 📱 Roles de Usuario

### 👤 Cliente
- Selección de ubicación con GPS
- Navegación de productos por categoría
- Carrito de compras
- Creación de pedidos

### 💰 Cajero
- Gestión de pagos
- Reportes de ventas
- Estadísticas en tiempo real
- Historial de transacciones

### 🍳 Cocinero
- Ver pedidos pagados
- Gestión de preparación
- Marcar pedidos listos
- Notificaciones de nuevos pedidos

### 🚴 Domiciliario
- Ver pedidos asignados
- Tracking GPS en tiempo real
- Gestión de entregas
- Historial de entregas

## 🔌 API Endpoints Principales

```
POST   /loginAdmin           # Autenticación
GET    /productos            # Catálogo de productos
POST   /pedidos              # Crear pedido
GET    /pedidos?estado=...   # Filtrar pedidos
PUT    /pedidos/:id/pago     # Confirmar pago
GET    /drivers/:id          # Perfil de driver
PATCH  /drivers/:id/location # Actualizar GPS
GET    /cajero/ventas/dia    # Reportes de caja
```

Ver lista completa en [GUIA_RAPIDA_API.md](./GUIA_RAPIDA_API.md)

## 🗺️ Características Geoespaciales

El sistema utiliza PostGIS para:
- Asignación automática del domiciliario más cercano
- Cálculo de distancias en tiempo real
- Tracking GPS de domiciliarios
- Visualización en Google Maps

## 📊 Flujo de un Pedido

```
Cliente crea pedido
      ↓
Sistema asigna domiciliario más cercano
      ↓
Cajero confirma pago (pendiente → pagado)
      ↓
Cocinero prepara (pagado → preparando)
      ↓
Cocinero marca listo (preparando → listo)
      ↓
Domiciliario entrega (listo → entregado)
```

## 🧪 Testing

Consulta las guías de testing por módulo en [INDICE_DOCUMENTACION.md](./INDICE_DOCUMENTACION.md)

## 🔐 Seguridad

- Autenticación por roles
- Transacciones SQL atómicas
- Validación de entrada
- Manejo de concurrencia con `FOR UPDATE SKIP LOCKED`

Ver detalles en [DOCUMENTACION_COMPLETA_SISTEMA.md](./DOCUMENTACION_COMPLETA_SISTEMA.md) → Sección Seguridad

## 📞 Soporte

- **Documentación:** Ver [INDICE_DOCUMENTACION.md](./INDICE_DOCUMENTACION.md)
- **Repositorio:** https://github.com/cristianchamorro/App_pedidos

## 📄 Licencia

Este proyecto es parte de un sistema de gestión de pedidos.

---

**Versión:** 1.0.0  
**Última actualización:** 2024
