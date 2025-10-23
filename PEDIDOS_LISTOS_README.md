# Pantalla de Pedidos Listos - Documentación

## Descripción General

Se ha implementado una nueva pantalla que muestra los pedidos que han sido marcados como "listos" (preparados) desde la pantalla de cocina (`pedidos_cocinero_page`). Además, incluye una sección para mostrar videos educativos o informativos.

## Características Implementadas

### 1. Visualización de Pedidos Listos

La nueva pantalla `PedidosListosPage` muestra:

- **Lista de pedidos con estado "listo"**: Pedidos que han sido preparados en la cocina
- **Información del cliente**: Nombre, teléfono y dirección de entrega
- **Detalles del pedido**: Número de pedido, fecha/hora, productos con cantidades
- **Total del pedido**: Monto total a pagar
- **Actualización automática**: La lista se refresca cada 5 segundos

### 2. Sección de Videos

Incluye una sección para mostrar videos que pueden ser:
- Tutoriales de preparación
- Recetas especiales
- Material educativo
- Cualquier contenido multimedia

Los videos se pueden abrir haciendo clic en ellos (usando url_launcher).

## Arquitectura de la Solución

### Archivos Modificados/Creados

1. **`app_frontend/lib/pages/pedidos_listos_page.dart`** (NUEVO)
   - Página principal para mostrar pedidos listos
   - Implementa auto-refresh cada 5 segundos
   - Incluye sección de videos configurable

2. **`app_frontend/lib/main.dart`**
   - Agregada ruta `/pedidos-listos`
   - Importación de la nueva página

3. **`app_frontend/lib/pages/pedidos_cocinero_page.dart`**
   - Agregado botón en el AppBar para navegar a pedidos listos
   - Ícono de check_circle para indicar pedidos completados

## Flujo de Trabajo

```
[Pedidos Cocinero] 
    ↓ (Marcar como Preparado)
[Estado: "listo"]
    ↓ (Clic en botón de check_circle)
[Pedidos Listos Page]
    → Muestra todos los pedidos listos
    → Muestra videos/recursos
```

## Acceso a la Pantalla

### Desde la Cocina (Cocinero)

1. Iniciar sesión como cocinero
2. Ver la pantalla de "Pedidos en preparación"
3. Hacer clic en el ícono de ✓ (check_circle) en el AppBar
4. Se abre la pantalla de "Pedidos Listos para Entrega"

### Navegación Programática

```dart
Navigator.pushNamed(
  context,
  '/pedidos-listos',
  arguments: {'userId': userId},
);
```

## Configuración de Videos

### Método Actual (Estático)

Los videos están definidos como una lista estática en el código:

```dart
final List<Map<String, String>> videos = [
  {
    'title': 'Tutorial de Preparación',
    'url': 'https://www.youtube.com/watch?v=example1',
    'thumbnail': 'https://via.placeholder.com/300x200?text=Video+1',
  },
  // ... más videos
];
```

### Configuración Dinámica (Recomendado para Producción)

Para configurar videos dinámicamente desde el backend, sigue estos pasos:

#### 1. Crear Tabla de Videos en la Base de Datos

```sql
CREATE TABLE videos (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  category VARCHAR(100),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Insertar videos de ejemplo
INSERT INTO videos (title, url, thumbnail_url, category) VALUES
('Tutorial de Preparación', 'https://youtube.com/watch?v=xxx', 'https://img.youtube.com/vi/xxx/0.jpg', 'tutorial'),
('Recetas Especiales', 'https://youtube.com/watch?v=yyy', 'https://img.youtube.com/vi/yyy/0.jpg', 'receta');
```

#### 2. Crear Endpoint en el Backend

En `app_backend/controllers/videosController.js`:

```javascript
const pool = require('../db');

const obtenerVideos = async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id, title, url, thumbnail_url, category FROM videos WHERE is_active = true ORDER BY created_at DESC'
    );
    res.json({ success: true, videos: result.rows });
  } catch (error) {
    console.error('Error al obtener videos:', error);
    res.status(500).json({ error: 'Error al obtener videos' });
  }
};

module.exports = { obtenerVideos };
```

En `app_backend/routes/videos.js`:

```javascript
const express = require('express');
const router = express.Router();
const videosController = require('../controllers/videosController');

router.get('/', videosController.obtenerVideos);

module.exports = router;
```

En `app_backend/server.js`:

```javascript
const videosRoutes = require('./routes/videos');
app.use('/videos', videosRoutes);
```

#### 3. Agregar Método en ApiService

En `app_frontend/lib/api_service.dart`:

```dart
Future<List<Map<String, dynamic>>> fetchVideos() async {
  try {
    final url = Uri.parse('$baseUrl/videos');
    final response = await http.get(url, headers: {"Content-Type": "application/json"});
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['videos']);
      } else {
        throw Exception('Error al obtener videos');
      }
    } else {
      throw Exception('Error del servidor: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception("No se pudo conectar al backend: $e");
  }
}
```

#### 4. Actualizar PedidosListosPage

Modificar el código en `pedidos_listos_page.dart`:

```dart
// Cambiar de lista estática a dinámica
List<Map<String, dynamic>> videos = [];

// En initState, cargar videos
@override
void initState() {
  super.initState();
  _cargarPedidos();
  _cargarVideos();  // Agregar esta línea
  
  _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    _cargarPedidos();
  });
}

// Agregar método para cargar videos
Future<void> _cargarVideos() async {
  try {
    final data = await api.fetchVideos();
    if (mounted) {
      setState(() {
        videos = data;
      });
    }
  } catch (e) {
    print('Error al cargar videos: $e');
  }
}
```

### Cómo Subir Videos (Opciones)

#### Opción 1: URLs de YouTube/Vimeo
- Simplemente guarda la URL del video en la base de datos
- Ejemplo: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
- El thumbnail se puede obtener automáticamente de YouTube

#### Opción 2: Subir Videos a un Servidor
- Usa servicios como AWS S3, Google Cloud Storage, o Cloudinary
- Guarda la URL del video alojado
- Similar a cómo actualmente se manejan las imágenes de productos

#### Opción 3: Servidor Propio
- Configura un endpoint para subir archivos de video
- Almacena los videos en el servidor
- Sirve los videos desde una URL pública

## Interfaz de Usuario

### Pantalla Principal

```
┌─────────────────────────────────────┐
│ ← Pedidos Listos para Entrega  🔄  │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │  ✓  3 Pedidos Listos        │   │
│  │     Esperando entrega       │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ ✓ Pedido #123       [LISTO] │   │
│  │ Listo: 23/10/2025 15:30     │   │
│  ├─────────────────────────────┤   │
│  │ 👤 Juan Pérez               │   │
│  │ 📞 555-1234                 │   │
│  │ 📍 Calle Principal 123      │   │
│  ├─────────────────────────────┤   │
│  │ 🍴 Productos del pedido:    │   │
│  │   [2x] Hamburguesa ✓        │   │
│  │   [1x] Papas Fritas ✓       │   │
│  ├─────────────────────────────┤   │
│  │ Total: $25.00               │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 🎥 Videos y Recursos        │   │
│  ├─────────────────────────────┤   │
│  │ ▶ [Thumbnail] Tutorial...   │   │
│  │ ▶ [Thumbnail] Recetas...    │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

## Estados de Pedidos

| Estado | Descripción | Pantalla |
|--------|-------------|----------|
| `pendiente` | Pedido creado, esperando pago | Cajero |
| `pagado` | Pagado, listo para preparar | Cocinero |
| `listo` | Preparado, esperando entrega | **Pedidos Listos** |
| `entregado` | Entregado al cliente | Historial |

## API Endpoints Utilizados

### Existentes
- `GET /pedidos?estado=listo` - Obtener pedidos con estado "listo"

### Sugeridos para Videos
- `GET /videos` - Obtener lista de videos activos
- `POST /admin/videos` - Agregar nuevo video (admin)
- `PUT /admin/videos/:id` - Actualizar video (admin)
- `DELETE /admin/videos/:id` - Desactivar video (admin)

## Dependencias

Las siguientes dependencias ya están incluidas en `pubspec.yaml`:
- `http: ^1.2.2` - Para llamadas API
- `url_launcher: ^6.1.10` - Para abrir URLs de videos
- `intl: ^0.19.0` - Para formateo de fechas

## Testing

### Pruebas Manuales

1. **Verificar visualización de pedidos listos**
   - Marcar un pedido como preparado en la pantalla de cocina
   - Navegar a "Pedidos Listos"
   - Verificar que el pedido aparece correctamente

2. **Verificar auto-refresh**
   - Abrir la pantalla de pedidos listos
   - Marcar otro pedido como preparado desde otra sesión
   - Esperar 5 segundos
   - Verificar que el nuevo pedido aparece automáticamente

3. **Verificar sección de videos**
   - Hacer clic en un video
   - Verificar que se abre el navegador/app de YouTube

### Casos de Prueba

```dart
// Test: Cargar pedidos listos
test('Debe cargar pedidos con estado listo', () async {
  final api = ApiService();
  final pedidos = await api.obtenerPedidosPorEstado('listo');
  expect(pedidos, isA<List<Map<String, dynamic>>>());
});

// Test: Navegación a pantalla de pedidos listos
testWidgets('Debe navegar a pedidos listos desde cocina', (tester) async {
  await tester.pumpWidget(MyApp());
  // ... implementar test
});
```

## Mejoras Futuras

1. **Filtros y Búsqueda**
   - Filtrar por fecha
   - Buscar por número de pedido o cliente

2. **Notificaciones Push**
   - Notificar al domiciliario cuando hay pedidos listos

3. **Integración con Domiciliarios**
   - Asignar pedidos listos a domiciliarios
   - Mostrar estado de entrega

4. **Gestión de Videos**
   - Panel de administración para agregar/editar videos
   - Categorías de videos
   - Estadísticas de visualización

5. **Soporte para más Tipos de Medios**
   - PDFs de menús
   - Imágenes de productos
   - Links a redes sociales

## Soporte y Mantenimiento

Para cualquier duda o problema:
1. Revisar los logs del servidor backend
2. Verificar la conectividad con la API
3. Asegurar que los datos en la base de datos son correctos
4. Verificar que url_launcher tiene permisos en Android/iOS

## Conclusión

Esta implementación proporciona una solución completa para:
- ✅ Visualizar pedidos que han sido marcados como listos en la cocina
- ✅ Incluir una sección de videos configurable
- ✅ Mantener la arquitectura existente de la aplicación
- ✅ Permitir fácil expansión futura

La solución es minimalista, mantiene el estilo visual de la app, y está lista para producción con capacidad de configuración dinámica de videos.
