# 📐 Diagramas de Arquitectura - App Pedidos

## 📊 Diagrama de Relaciones de Base de Datos (ERD)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SISTEMA DE GESTIÓN DE PEDIDOS                         │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│     roles        │
├──────────────────┤
│ PK  id          │
│     name   (UK) │◄─┐
│     description │  │
└──────────────────┘  │
                      │
                      │ role_id
                      │
┌──────────────────┐  │         ┌──────────────────┐
│   user_admin     │  │         │   categories     │
├──────────────────┤  │         ├──────────────────┤
│ PK  id          │  │         │ PK  id          │
│     username(UK)│  │         │     name        │◄─┐
│     password    │  │         │     description │  │
│ FK  role_id     │──┘         └──────────────────┘  │
│     name        │                                   │
└──────────────────┘                                  │ category_id
                                                      │
┌──────────────────┐            ┌──────────────────┐ │
│     vendors      │            │    products      │ │
├──────────────────┤            ├──────────────────┤ │
│ PK  id          │            │ PK  id          │ │
│     name        │◄───────────│ FK  category_id │─┘
│ contact_phone   │ vendor_id  │ FK  vendor_id   │
│     location    │            │     name        │
│     (GPS)       │            │     price       │
└──────────────────┘            │     description │
       (INDEX: location)        │     image_url   │◄─┐
                                └──────────────────┘  │
                                                      │
                                                      │ product_id
                                                      │
                                ┌──────────────────┐ │
                                │  product_media   │ │
                                ├──────────────────┤ │
                                │ PK  id          │ │
                                │ FK  product_id  │─┘
                                │     media_type  │
                                │     media_url   │
                                │     description │
                                └──────────────────┘


┌──────────────────┐            ┌──────────────────┐            ┌──────────────────┐
│      users       │            │      orders      │            │     drivers      │
├──────────────────┤            ├──────────────────┤            ├──────────────────┤
│ PK  id          │            │ PK  id          │            │ PK  id          │
│     phone       │◄───────────│ FK  user_id     │            │     name        │
│     name        │  user_id   │ FK  driver_id   │────────────│     phone       │
│     address     │            │     total       │  driver_id │     location    │
│     location    │            │     status      │            │     (GPS)       │
│     (GPS)       │            │ order_channel   │            │     status      │
│     created_at  │            │     created_at  │            │     updated_at  │
└──────────────────┘            └──────────────────┘            └──────────────────┘
    (INDEX: location)                   │                           (INDEX: location)
                                        │
                            ┌───────────┴───────────┐
                            │                       │
                            ↓                       ↓
                  ┌──────────────────┐    ┌──────────────────┐
                  │   order_items    │    │  status_history  │
                  ├──────────────────┤    ├──────────────────┤
                  │ PK  id          │    │ PK  id          │
                  │ FK  order_id    │    │ FK  order_id    │
                  │ FK  product_id  │────│     status      │
                  │     quantity    │    │ FK  changed_by  │──► user_admin.id
                  │     price       │    │     changed_at  │
                  └──────────────────┘    └──────────────────┘
                           │
                           │ product_id
                           │
                           ↓
                  ┌──────────────────┐
                  │    products      │
                  │   (referencia)   │
                  └──────────────────┘


┌──────────────────┐
│  order_status    │  (Tabla de referencia)
├──────────────────┤
│ PK  id          │
│     status (UK) │
└──────────────────┘

Estados válidos:
  • pendiente
  • pagado
  • preparando
  • listo
  • entregado
  • cancelado
```

---

## 🏗️ Arquitectura del Sistema (3 Capas)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CAPA DE PRESENTACIÓN                        │
│                                  (Flutter)                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   Cliente   │  │   Cajero    │  │  Cocinero   │  │Domiciliario │   │
│  │             │  │             │  │             │  │             │   │
│  │ • Ubicación │  │ • Pagos     │  │• Preparar   │  │• Entregas   │   │
│  │ • Productos │  │ • Reportes  │  │• Marcar     │  │• GPS Track  │   │
│  │ • Carrito   │  │ • Estadís.  │  │  Listo      │  │• Estado     │   │
│  │ • Pedido    │  │ • Historial │  │• Notific.   │  │• Historial  │   │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘   │
│                                                                           │
│  ┌─────────────┐                                                         │
│  │ API Service │  (http package)                                        │
│  └──────┬──────┘                                                         │
└─────────┼────────────────────────────────────────────────────────────────┘
          │
          │ HTTP/JSON
          │ REST API
          ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                           CAPA DE APLICACIÓN                             │
│                         (Node.js + Express)                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                         RUTAS (Routes)                           │   │
│  │                                                                  │   │
│  │  /productos      /pedidos       /admin        /drivers          │   │
│  │  /cajero         /loginAdmin    /admin/...                      │   │
│  └────────────────────────┬─────────────────────────────────────────┘   │
│                           │                                              │
│                           ↓                                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    CONTROLADORES (Controllers)                   │   │
│  │                                                                  │   │
│  │  • productosController    → Catálogo de productos               │   │
│  │  • pedidosController      → Creación y gestión de pedidos       │   │
│  │  • adminController        → Autenticación                       │   │
│  │  • adminProductsController→ CRUD de productos                   │   │
│  │  • adminDataController    → Categorías y vendors                │   │
│  │  • cajeroController       → Reportes y estadísticas             │   │
│  │  • driversController      → Gestión de domiciliarios            │   │
│  │                                                                  │   │
│  │  Lógica de negocio:                                             │   │
│  │  • Validaciones                                                 │   │
│  │  • Transacciones SQL                                            │   │
│  │  • Asignación de drivers (PostGIS)                              │   │
│  │  • Cambios de estado                                            │   │
│  │  • Cálculos de totales                                          │   │
│  └────────────────────────┬─────────────────────────────────────────┘   │
│                           │                                              │
│                           ↓                                              │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    CAPA DE ACCESO A DATOS                        │   │
│  │                        (Pool de pg)                              │   │
│  │                                                                  │   │
│  │  • pool.query(sql, params)                                      │   │
│  │  • Transacciones (BEGIN/COMMIT/ROLLBACK)                        │   │
│  │  • Connection pooling                                           │   │
│  └────────────────────────┬─────────────────────────────────────────┘   │
└───────────────────────────┼──────────────────────────────────────────────┘
                            │
                            │ SQL/PostgreSQL Protocol
                            ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                          CAPA DE PERSISTENCIA                            │
│                      (PostgreSQL 17.6 + PostGIS)                         │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                       BASE DE DATOS: Bd_App                      │   │
│  │                                                                  │   │
│  │  📊 Tablas Principales:                                         │   │
│  │  • users, user_admin, roles                                     │   │
│  │  • products, categories, vendors, product_media                 │   │
│  │  • orders, order_items, order_status                            │   │
│  │  • drivers                                                      │   │
│  │  • status_history                                               │   │
│  │                                                                  │   │
│  │  🗺️  PostGIS Extensions:                                        │   │
│  │  • GEOGRAPHY(Point, 4326) para ubicaciones GPS                  │   │
│  │  • Índices GIST para búsquedas espaciales                       │   │
│  │  • Operador de distancia (<->)                                  │   │
│  │  • ST_MakePoint, ST_SetSRID                                     │   │
│  │                                                                  │   │
│  │  🔒 Constraints y Relaciones:                                   │   │
│  │  • Foreign Keys con CASCADE                                     │   │
│  │  • UNIQUE constraints                                           │   │
│  │  • Primary Keys (SERIAL)                                        │   │
│  │                                                                  │   │
│  │  ⚡ Optimizaciones:                                              │   │
│  │  • FOR UPDATE SKIP LOCKED (concurrencia)                        │   │
│  │  • Transacciones ACID                                           │   │
│  │  • Índices espaciales                                           │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Flujo de Creación de Pedido (Secuencia Completa)

```
┌──────┐        ┌──────────┐       ┌─────────┐      ┌──────────┐      ┌──────────┐
│Cliente│        │ Flutter  │       │ Backend │      │PostgreSQL│      │ PostGIS  │
│ App  │        │   App    │       │ Express │      │          │      │  Engine  │
└───┬──┘        └────┬─────┘       └────┬────┘      └────┬─────┘      └────┬─────┘
    │                │                   │                │                 │
    │ 1. Selecciona  │                   │                │                 │
    │    productos   │                   │                │                 │
    │───────────────>│                   │                │                 │
    │                │                   │                │                 │
    │ 2. Obtiene GPS │                   │                │                 │
    │    Location    │                   │                │                 │
    │───────────────>│                   │                │                 │
    │                │                   │                │                 │
    │ 3. Confirma    │                   │                │                 │
    │    Pedido      │                   │                │                 │
    │───────────────>│                   │                │                 │
    │                │                   │                │                 │
    │                │ POST /pedidos     │                │                 │
    │                │  {nombre, tel,    │                │                 │
    │                │   direccion,      │                │                 │
    │                │   ubicacion,      │                │                 │
    │                │   productos}      │                │                 │
    │                │──────────────────>│                │                 │
    │                │                   │                │                 │
    │                │                   │ BEGIN          │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ SELECT user    │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ INSERT/UPDATE  │                 │
    │                │                   │    user        │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ SELECT driver  │                 │
    │                │                   │ más cercano    │  Calcula        │
    │                │                   │───────────────>│  distancias     │
    │                │                   │                │────────────────>│
    │                │                   │                │                 │
    │                │                   │                │  Devuelve más   │
    │                │                   │                │  cercano        │
    │                │                   │                │<────────────────│
    │                │                   │                │                 │
    │                │                   │ UPDATE driver  │                 │
    │                │                   │  status='busy' │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ INSERT order   │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ INSERT items   │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ INSERT history │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │                   │ COMMIT         │                 │
    │                │                   │───────────────>│                 │
    │                │                   │                │                 │
    │                │ Response 201      │                │                 │
    │                │  {success: true,  │                │                 │
    │                │   order_id: 42,   │                │                 │
    │                │   driver_id: 3}   │                │                 │
    │                │<──────────────────│                │                 │
    │                │                   │                │                 │
    │ 4. Mensaje     │                   │                │                 │
    │    "Pedido     │                   │                │                 │
    │    creado #42" │                   │                │                 │
    │<───────────────│                   │                │                 │
    │                │                   │                │                 │
```

---

## 🍳 Flujo de Procesamiento de Pedido (Estados)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      CICLO DE VIDA DEL PEDIDO                                │
└─────────────────────────────────────────────────────────────────────────────┘

    [CLIENTE]                    [CAJERO]                 [COCINERO]
        │                            │                         │
        │ Crea pedido                │                         │
        │ POST /pedidos              │                         │
        ↓                            │                         │
┌────────────────┐                   │                         │
│   PENDIENTE    │                   │                         │
│  (created)     │                   │                         │
└────────────────┘                   │                         │
        │                            │                         │
        │                            │ Confirma pago           │
        │                            │ PUT /pedidos/:id/pago   │
        │                            ↓                         │
        │                    ┌────────────────┐               │
        │                    │     PAGADO     │               │
        │                    │                │               │
        │                    └────────────────┘               │
        │                            │                         │
        │                            │                         │ Inicia preparación
        │                            │                         │ PUT /pedidos/:id/preparar
        │                            │                         ↓
        │                            │                 ┌────────────────┐
        │                            │                 │  PREPARANDO    │
        │                            │                 │  (En cocina)   │
        │                            │                 └────────────────┘
        │                            │                         │
        │                            │                         │ Marca listo
        │                            │                         │ PUT /pedidos/:id/listo
        │                            │                         ↓
        │                            │                 ┌────────────────┐
        │                            │                 │     LISTO      │
        │                            │                 │ (Para entregar)│
        │                            │                 └────────────────┘
        │                            │                         │
        │                            │                         │
        │                                                      │
        │                      [DOMICILIARIO]                  │
        │                            │                         │
        │                            │ Recoge pedido           │
        │                            │ POST .../picked-up      │
        │                            ↓                         │
        │                    ┌────────────────┐               │
        │                    │  (picked_up)   │               │
        │                    │   en history   │               │
        │                    └────────────────┘               │
        │                            │                         │
        │                            │ En camino               │
        │                            │ POST .../on-route       │
        │                            ↓                         │
        │                    ┌────────────────┐               │
        │                    │  (on_route)    │               │
        │                    │   en history   │               │
        │                    └────────────────┘               │
        │                            │                         │
        │                            │ Entrega                 │
        │                            │ POST .../delivered      │
        │                            ↓                         │
        │                    ┌────────────────┐               │
        │                    │   ENTREGADO    │               │
        │                    │   (Completo)   │               │
        │                    └────────────────┘               │
        │                            │                         │
        │                            │ Driver → available      │
        │                            ↓                         │
        │                      [FIN DEL CICLO]                 │
        │                                                      │
        │                                                      │
        │           En cualquier momento:                      │
        │                   ↓                                  │
        │            ┌────────────────┐                        │
        │            │   CANCELADO    │                        │
        │            │                │                        │
        │            └────────────────┘                        │
```

---

## 🗺️ Sistema de Asignación Geoespacial

```
┌─────────────────────────────────────────────────────────────────────────────┐
│          ASIGNACIÓN INTELIGENTE DE DOMICILIARIOS (PostGIS)                   │
└─────────────────────────────────────────────────────────────────────────────┘

Escenario: Cliente en ubicación (4.6097, -74.0817) hace pedido


  1. Cliente                                 2. Backend consulta PostGIS
     └─ Ubicación: (4.6097, -74.0817)           └─ Busca domiciliario más cercano

                                                        🗺️ PostGIS
                                                            │
                                                            │ ORDER BY location <->
                                                            │ ST_MakePoint(lng, lat)
                                                            ↓
                                                    ┌───────────────┐
                                                    │  Cálculo de   │
                                                    │  distancias   │
                                                    └───────────────┘
                                                            │
                   Mapa de la ciudad                        │
                                                            ↓
    ┌────────────────────────────────────────────────────────────┐
    │                                                            │
    │                       🏪 Restaurante                       │
    │                          (origen)                          │
    │                            ↑                               │
    │                            │                               │
    │                      Pedido listo                          │
    │                            │                               │
    │            Domiciliario 3  │  Domiciliario 1              │
    │                🚴 (2.1km) │    🚴 (5.3km)                 │
    │                  ✅        │      ❌                        │
    │               disponible   │    ocupado                    │
    │                            │                               │
    │                            │                               │
    │                            ↓                               │
    │                       📍 Cliente                           │
    │                     (4.6097, -74.0817)                     │
    │                            ↑                               │
    │                            │                               │
    │                     3.8km (ocupado)                        │
    │                            │                               │
    │                    Domiciliario 2                          │
    │                         🚴 (3.8km)                         │
    │                           ❌                                │
    │                        ocupado                             │
    │                                                            │
    └────────────────────────────────────────────────────────────┘


  3. Resultado de la consulta:

     SELECT id, name,
            ST_Distance(location, ST_SetSRID(ST_MakePoint(-74.0817, 4.6097), 4326)) as distance
     FROM drivers
     WHERE status = 'available'
     ORDER BY distance
     LIMIT 1
     FOR UPDATE SKIP LOCKED;

     ┌────┬──────────────────┬───────────┬──────────────┐
     │ id │      name        │  status   │  distance(m) │
     ├────┼──────────────────┼───────────┼──────────────┤
     │ 3  │ Juan Pérez       │ available │   2100       │  ← SELECCIONADO ✅
     └────┴──────────────────┴───────────┴──────────────┘


  4. Asignación:
     - Driver 3 asignado al pedido
     - Status cambiado a 'busy'
     - Pedido asociado en orders.driver_id = 3


  5. Beneficios:
     ✅ Menor tiempo de entrega
     ✅ Menor distancia recorrida
     ✅ Optimización de recursos
     ✅ Mejor experiencia del cliente
```

---

## 🔐 Sistema de Roles y Permisos

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     ROLES Y PERMISOS DEL SISTEMA                             │
└─────────────────────────────────────────────────────────────────────────────┘

                              user_admin
                                  │
                                  │ role_id
                                  ↓
                              ┌──────┐
                              │ roles│
                              └──────┘
                                  │
                                  │
        ┌────────────────────┬────┴────┬────────────────────┐
        │                    │         │                    │
        ↓                    ↓         ↓                    ↓
    ┌────────┐          ┌────────┐ ┌────────┐        ┌──────────┐
    │ CAJERO │          │COCINERO│ │ ADMIN  │        │DOMICILIARIO│
    └────────┘          └────────┘ └────────┘        └──────────┘
        │                    │         │                    │
        │                    │         │                    │
        ↓                    ↓         ↓                    ↓

┌────────────────┐  ┌────────────────┐  ┌─────────────────┐  ┌──────────────────┐
│   PERMISOS     │  │   PERMISOS     │  │    PERMISOS     │  │    PERMISOS      │
├────────────────┤  ├────────────────┤  ├─────────────────┤  ├──────────────────┤
│✅ Ver pedidos  │  │✅ Ver pedidos  │  │✅ Todo acceso   │  │✅ Ver pedidos    │
│  pendientes    │  │  pagados       │  │                 │  │  asignados       │
│                │  │                │  │✅ CRUD productos│  │                  │
│✅ Confirmar    │  │✅ Marcar       │  │                 │  │✅ Actualizar GPS │
│  pagos         │  │  preparando    │  │✅ CRUD usuarios │  │                  │
│                │  │                │  │                 │  │✅ Marcar estados │
│✅ Ver reportes │  │✅ Marcar listo │  │✅ Ver reportes  │  │  picked-up       │
│  de ventas     │  │                │  │  completos      │  │  on-route        │
│                │  │✅ Recibir      │  │                 │  │  delivered       │
│✅ Ver          │  │  notificaciones│  │✅ Gestión de    │  │                  │
│  estadísticas  │  │  sonoras       │  │  roles          │  │✅ Ver historial  │
│                │  │                │  │                 │  │                  │
│✅ Historial de │  │✅ Ver historial│  │✅ Configuración │  │✅ Cambiar estado │
│  transacciones │  │                │  │  del sistema    │  │  (disponible/    │
│                │  │                │  │                 │  │   offline)       │
│                │  │                │  │                 │  │                  │
│❌ Preparar     │  │❌ Confirmar    │  │✅ Todo lo demás │  │❌ Ver reportes   │
│  pedidos       │  │  pagos         │  │                 │  │                  │
│                │  │                │  │                 │  │❌ Confirmar pagos│
│❌ Entregar     │  │❌ Entregar     │  │                 │  │                  │
│  pedidos       │  │  pedidos       │  │                 │  │❌ Preparar       │
│                │  │                │  │                 │  │  pedidos         │
└────────────────┘  └────────────────┘  └─────────────────┘  └──────────────────┘


FLUJO DE AUTENTICACIÓN:

  Usuario → LoginAdminPage → POST /loginAdmin
                                    │
                                    ↓
                              Valida credenciales
                                    │
                                    ↓
                            Devuelve role
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
                ↓                   ↓                   ↓
         /cajero            /cocinero           /domiciliario
    (PedidosCajeroPage)(PedidosCocineroPage)(DomiciliarioPage)
```

---

## 💾 Arquitectura de Almacenamiento

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ESTRATEGIA DE ALMACENAMIENTO                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                          DATOS TRANSACCIONALES                              │
│                           (PostgreSQL Tables)                               │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📦 orders, order_items                                                     │
│     ├─ Datos de pedidos actuales                                           │
│     ├─ Relaciones con usuarios y productos                                 │
│     └─ Claves foráneas con CASCADE                                         │
│                                                                             │
│  👥 users, user_admin                                                       │
│     ├─ Información de clientes                                             │
│     ├─ Credenciales de administradores                                     │
│     └─ Datos de contacto                                                   │
│                                                                             │
│  🛍️  products, categories, vendors                                          │
│     ├─ Catálogo de productos                                               │
│     ├─ Precios actuales                                                    │
│     └─ Clasificación y origen                                              │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                           DATOS HISTÓRICOS                                  │
│                       (Auditoría y Análisis)                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📜 status_history                                                          │
│     ├─ Registro completo de cambios de estado                              │
│     ├─ Quién hizo el cambio (changed_by)                                   │
│     ├─ Cuándo se hizo (changed_at)                                         │
│     └─ Permite auditoría y análisis de tiempos                             │
│                                                                             │
│  💰 order_items (con precio histórico)                                     │
│     ├─ Precio al momento de la venta                                       │
│     └─ Inmutable después de creación                                       │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                         DATOS GEOESPACIALES                                 │
│                         (PostGIS Geography)                                 │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📍 users.location                                                          │
│     └─ Ubicación GPS del cliente para entrega                              │
│                                                                             │
│  🚴 drivers.location                                                        │
│     ├─ Ubicación en tiempo real del domiciliario                           │
│     └─ Actualizada periódicamente                                          │
│                                                                             │
│  🏪 vendors.location                                                        │
│     └─ Ubicación fija del restaurante/proveedor                            │
│                                                                             │
│  Índices: GIST indexes para búsquedas espaciales eficientes                │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────┐
│                         DATOS MULTIMEDIA                                    │
│                      (Base64 y URLs externas)                               │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  🖼️  products.image_url                                                     │
│     ├─ URL externa (recomendado para producción)                           │
│     └─ Base64 (para desarrollo/demo)                                       │
│                                                                             │
│  📸 product_media                                                           │
│     ├─ Múltiples imágenes por producto                                     │
│     ├─ Soporte para videos (media_type)                                    │
│     └─ Almacenamiento flexible (URL o base64)                              │
│                                                                             │
│  Nota: Para producción se recomienda usar CDN o S3                          │
│                                                                             │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Patrones de Diseño Implementados

### 1. Repository Pattern (Implícito)
```
Controllers → Pool (pg) → PostgreSQL
(Lógica)     (Acceso)    (Persistencia)
```

### 2. MVC Pattern
```
Models      → Definidos implícitamente en esquema SQL
Views       → Flutter UI Components
Controllers → Express Controllers
```

### 3. Transaction Script
```javascript
// Operaciones complejas envueltas en transacciones
BEGIN
  INSERT user
  SELECT available driver
  UPDATE driver status
  INSERT order
  INSERT order_items
  INSERT status_history
COMMIT
```

### 4. Optimistic Locking (con PostGIS)
```sql
-- FOR UPDATE SKIP LOCKED evita bloqueos
SELECT id FROM drivers
WHERE status='available'
FOR UPDATE SKIP LOCKED
```

---

## 📈 Escalabilidad y Performance

### Optimizaciones Actuales

1. **Connection Pooling**
   - Pool de conexiones PostgreSQL
   - Reutilización de conexiones
   - Manejo eficiente de concurrencia

2. **Índices Espaciales**
   - GIST indexes en campos de geografía
   - Búsquedas O(log n) en lugar de O(n)

3. **Consultas Agregadas**
   - JSON_AGG para productos en pedidos
   - Reduce número de queries

4. **Transacciones Atómicas**
   - Previene estados inconsistentes
   - Garantiza integridad de datos

### Recomendaciones para Escalar

1. **Cache Layer**
   - Redis para productos frecuentes
   - Cache de ubicaciones de drivers

2. **Load Balancing**
   - Múltiples instancias de backend
   - Nginx como reverse proxy

3. **Read Replicas**
   - PostgreSQL read replicas para reportes
   - Separar lectura de escritura

4. **CDN para Imágenes**
   - S3 + CloudFront
   - Reduce carga en backend

---

**Fin de Diagramas de Arquitectura**
