# Guía Visual - Pantalla de Pedidos Listos

## Flujo de Navegación

```
┌──────────────────────────────────────────────────────────────────┐
│                      FLUJO DE PEDIDOS                             │
└──────────────────────────────────────────────────────────────────┘

1️⃣ CAJERO
┌─────────────────┐
│ Pedidos Cajero  │  → Confirma pago
│   (pendiente)   │     Estado: "pagado"
└────────┬────────┘
         │
         ↓
2️⃣ COCINERO
┌─────────────────┐
│ Pedidos Cocina  │  → Marca como preparado
│    (pagado)     │     Estado: "listo"
└────────┬────────┘
         │
         ↓
3️⃣ NUEVA PANTALLA ⭐
┌─────────────────┐
│ Pedidos Listos  │  → Visualiza pedidos preparados
│    (listo)      │     + Videos/Recursos
└─────────────────┘
```

## Acceso a la Nueva Pantalla

### Desde Pantalla de Cocina

```
┌────────────────────────────────────────────────┐
│ ← Cocina - Pedidos en preparación  [✓] [⋮] [⋯]│  ← Nuevo botón ✓
└────────────────────────────────────────────────┘
                                         ↑
                                         │
                            Clic aquí para ver pedidos listos
```

## Mockup de la Pantalla Principal

```
┌──────────────────────────────────────────────────────────────┐
│  ← Pedidos Listos para Entrega                          🔄   │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │                                                        │  │
│  │        ✓         3 Pedidos Listos                     │  │
│  │              Esperando entrega                        │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                               │
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║  ✓  Pedido #125                      [LISTO] ✓       ║  │
│  ║     Listo: 23/10/2025 16:45                          ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  👤  María González                                   ║  │
│  ║  📞  555-9876                                         ║  │
│  ║  📍  Av. Libertador 456, Apto 3B                      ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  🍴 Productos del pedido:                             ║  │
│  ║     ┌──────────────────────────────────────────┐     ║  │
│  ║     │  [2x]  Hamburguesa Especial        ✓    │     ║  │
│  ║     └──────────────────────────────────────────┘     ║  │
│  ║     ┌──────────────────────────────────────────┐     ║  │
│  ║     │  [1x]  Papas Fritas Grande         ✓    │     ║  │
│  ║     └──────────────────────────────────────────┘     ║  │
│  ║     ┌──────────────────────────────────────────┐     ║  │
│  ║     │  [2x]  Refresco Cola               ✓    │     ║  │
│  ║     └──────────────────────────────────────────┘     ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  Total:                              $42.50          ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│                                                               │
│  ╔═══════════════════════════════════════════════════════╗  │
│  ║  ✓  Pedido #126                      [LISTO] ✓       ║  │
│  ║     Listo: 23/10/2025 16:50                          ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  👤  Carlos Rodríguez                                 ║  │
│  ║  📞  555-3456                                         ║  │
│  ║  📍  Calle 5 #23-45                                   ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  🍴 Productos del pedido:                             ║  │
│  ║     ┌──────────────────────────────────────────┐     ║  │
│  ║     │  [1x]  Pizza Mediana Pepperoni     ✓    │     ║  │
│  ║     └──────────────────────────────────────────┘     ║  │
│  ║     ┌──────────────────────────────────────────┐     ║  │
│  ║     │  [1x]  Ensalada César              ✓    │     ║  │
│  ║     └──────────────────────────────────────────┘     ║  │
│  ║ ───────────────────────────────────────────────────── ║  │
│  ║  Total:                              $28.00          ║  │
│  ╚═══════════════════════════════════════════════════════╝  │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  🎥  Videos y Recursos                                │  │
│  ├────────────────────────────────────────────────────────┤  │
│  │  ┌──────────────────────────────────────────────────┐ │  │
│  │  │  ▶  [📺]  Tutorial de Preparación          →    │ │  │
│  │  │           youtube.com/watch?v=...                │ │  │
│  │  └──────────────────────────────────────────────────┘ │  │
│  │  ┌──────────────────────────────────────────────────┐ │  │
│  │  │  ▶  [📺]  Recetas Especiales               →    │ │  │
│  │  │           youtube.com/watch?v=...                │ │  │
│  │  └──────────────────────────────────────────────────┘ │  │
│  │                                                        │  │
│  │  Nota: Los videos se pueden configurar dinámicamente  │  │
│  │  cargando URLs similar a las imágenes de productos.   │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

## Elementos de la UI

### 1. Encabezado (AppBar)
```
┌──────────────────────────────────────────────┐
│ ← Pedidos Listos para Entrega          🔄   │
│   (Gradiente verde)                          │
└──────────────────────────────────────────────┘
```
- **Color**: Gradiente verde claro
- **Botón izquierdo**: Volver atrás
- **Botón derecho**: Actualizar manualmente

### 2. Tarjeta de Estadísticas
```
┌──────────────────────────────────────────┐
│                                          │
│    ✓      3 Pedidos Listos              │
│         Esperando entrega                │
│                                          │
└──────────────────────────────────────────┘
```
- **Color de fondo**: Gradiente verde suave
- **Ícono**: Check circle verde
- **Actualización**: Automática cada 5 segundos

### 3. Tarjeta de Pedido
```
╔═══════════════════════════════════════╗
║  ✓  Pedido #123        [LISTO] ✓     ║  ← Header con estado
║     Listo: DD/MM/YYYY HH:MM          ║
║ ───────────────────────────────────── ║
║  👤 Cliente                           ║  ← Información del cliente
║  📞 Teléfono                          ║     (fondo azul claro)
║  📍 Dirección                         ║
║ ───────────────────────────────────── ║
║  🍴 Productos del pedido:             ║  ← Lista de productos
║     [Cx] Producto 1            ✓     ║     (fondo verde claro)
║     [Cx] Producto 2            ✓     ║
║ ───────────────────────────────────── ║
║  Total:                    $XX.XX     ║  ← Total
╚═══════════════════════════════════════╝     (fondo amarillo claro)
```

**Detalles:**
- **Borde**: Verde con opacidad 0.5, ancho 2px
- **Header**: Badge verde con texto "LISTO"
- **Secciones**: Cada sección tiene color de fondo distintivo
- **Productos**: Check verde para indicar preparado

### 4. Sección de Videos
```
┌─────────────────────────────────────────┐
│  🎥  Videos y Recursos                  │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │  ▶  [📺]  Título del Video    →  │  │  ← Clickeable
│  │           URL del video...        │  │
│  └───────────────────────────────────┘  │
│                                         │
│  Nota: Configuración dinámica similar  │
│  a las imágenes de productos           │
└─────────────────────────────────────────┘
```
- **Color**: Gradiente morado suave
- **Videos**: Cards clickeables que abren URL
- **Ícono**: Play circle morado

## Paleta de Colores

```
┌──────────────────────────────────────────────────┐
│  Pantalla Principal                               │
├──────────────────────────────────────────────────┤
│  Background:        green[50]                     │
│  AppBar:            green → lightGreen (gradient) │
│  Stats Card:        green.shade100 → white        │
│  Order Card Border: green.withOpacity(0.5)        │
│  Ready Badge:       green (solid)                 │
│  Customer Info:     blue.withOpacity(0.05)        │
│  Products Section:  green.withOpacity(0.1)        │
│  Total Section:     amber.withOpacity(0.1)        │
│  Videos Section:    purple.shade100 → white       │
└──────────────────────────────────────────────────┘
```

## Comparación con Otras Pantallas

### Pantalla de Cocina (Actual)
```
┌─────────────────────────────┐
│ Cocina - En preparación     │
│ (Estado: pagado)            │
│ Color: Morado/Púrpura       │
└─────────────────────────────┘
        ↓
   [Marcar como Preparado]
        ↓
┌─────────────────────────────┐
│ Pedidos Listos (NUEVO)      │
│ (Estado: listo)             │
│ Color: Verde                │
└─────────────────────────────┘
```

## Funcionalidades Interactivas

### 1. Auto-refresh
```
Cada 5 segundos →  [API Call] → Actualiza lista
                                        ↓
                            [Sin parpadeo, smooth update]
```

### 2. Click en Video
```
[Video Card] → [Click] → [url_launcher] → [Navegador/YouTube App]
```

### 3. Navegación
```
[Cocina] → [Botón ✓] → [Pedidos Listos]
    ↑                          ↓
    └─────── [Botón ←] ────────┘
```

## Estados de la Pantalla

### Estado: Cargando
```
┌──────────────────────────┐
│                          │
│     ⌛ Cargando...       │
│   [Circular Progress]    │
│                          │
└──────────────────────────┘
```

### Estado: Sin Pedidos
```
┌──────────────────────────┐
│                          │
│      📥 [Icono]          │
│  No hay pedidos listos   │
│   en este momento        │
│                          │
└──────────────────────────┘
```

### Estado: Con Pedidos
```
┌──────────────────────────┐
│  [Estadísticas]          │
│  [Pedido 1]              │
│  [Pedido 2]              │
│  [Pedido 3]              │
│  [Videos]                │
└──────────────────────────┘
```

## Responsive Design

La interfaz se adapta a diferentes tamaños de pantalla:

### Móvil (Portrait)
- Cards ocupan ancho completo
- Videos en lista vertical
- Padding: 12px

### Tablet (Landscape)
- Cards mantienen ancho completo para legibilidad
- Scrolling suave
- Padding: 16px

## Animaciones

1. **Entrada de cards**: Fade in suave
2. **Actualización de lista**: Sin animación brusca
3. **Click en video**: Feedback visual (ripple effect)
4. **Badge de estado**: Pulse suave cada 2 segundos

## Accesibilidad

- ✅ Iconos con significado claro
- ✅ Colores con buen contraste
- ✅ Texto legible (14-20px)
- ✅ Tooltips en botones
- ✅ Areas clickeables grandes (48x48dp mínimo)

## Comparación Visual: Antes vs Después

### Antes ❌
```
Cocina → [Marcar listo] → ¿? (No se veía)
                           ↓
                    (Estado perdido)
```

### Después ✅
```
Cocina → [Marcar listo] → Pedidos Listos
                              ↓
                    (Visibles + Videos)
```

## Capturas de Pantalla Simuladas

### Pantalla Completa
```
█████████████████████████████████████
█ ← Pedidos Listos            🔄   █
█                                   █
█ ┌───────────────────────────────┐ █
█ │   ✓   3 Pedidos Listos       │ █
█ └───────────────────────────────┘ █
█                                   █
█ ┌───────────────────────────────┐ █
█ │ ✓ Pedido #125     [LISTO] ✓  │ █
█ │ María González                │ █
█ │ 2x Hamburguesa ✓              │ █
█ │ Total: $42.50                 │ █
█ └───────────────────────────────┘ █
█                                   █
█ ┌───────────────────────────────┐ █
█ │ 🎥 Videos y Recursos          │ █
█ │ ▶ Tutorial de Preparación  → │ █
█ └───────────────────────────────┘ █
█████████████████████████████████████
```

## Notas de Implementación

### ✅ Completado
- [x] Pantalla funcional con diseño responsive
- [x] Consumo de API para pedidos con estado "listo"
- [x] Auto-refresh cada 5 segundos
- [x] Sección de videos clickeables
- [x] Navegación desde pantalla de cocina
- [x] UI consistente con el resto de la app

### 📝 Configuración Recomendada
- [ ] Backend para gestión de videos (opcional)
- [ ] Panel de admin para agregar/editar videos
- [ ] Categorización de videos
- [ ] Thumbnails personalizados

### 🚀 Mejoras Futuras
- [ ] Notificaciones push para domiciliarios
- [ ] Asignación automática de pedidos
- [ ] Tracking en tiempo real
- [ ] Estadísticas de entrega
