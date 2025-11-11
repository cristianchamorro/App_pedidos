# Tema y Logo - Guía de Implementación

## Resumen de Cambios

Se ha implementado un nuevo tema con colores cálidos representativos de un restaurante/local de comida, y se ha agregado un logo personalizado en las pantallas de inicio de sesión.

## 🎨 Paleta de Colores

### Colores Principales (Rojo Cálido)
El tema utiliza tonos rojos cálidos, típicos de restaurantes y negocios de comida:

- **Primary (Rojo Principal):** `#D32F2F`
  - Uso: Botones principales, encabezados, elementos destacados
  
- **Primary Light (Rojo Claro):** `#EF5350`
  - Uso: Hover states, fondos suaves
  
- **Primary Dark (Rojo Oscuro):** `#C62828`
  - Uso: Sombras, estados activos
  
- **Primary Very Light (Rojo Muy Claro):** `#FFEBEE`
  - Uso: Fondos de página, áreas desactivadas

### Colores Secundarios (Naranja Cálido)
- **Secondary (Naranja):** `#FFA726`
- **Secondary Light:** `#FFB74D`
- **Secondary Dark:** `#F57C00`
- Uso: Botones flotantes, acciones secundarias, elementos de comida

### Colores de Acento (Dorado/Ámbar)
- **Accent (Dorado):** `#FFB300`
- **Accent Light:** `#FFCA28`
- Uso: Highlights, elementos premium, estrellas de calificación

### Colores de Estado
- **Success (Verde):** `#4CAF50` - Pedidos completados, acciones exitosas
- **Warning (Naranja):** `#FFA726` - Advertencias, pendientes
- **Error (Rojo):** `#D32F2F` - Errores, cancelaciones
- **Info (Dorado):** `#FFB300` - Información, tips

## 🖼️ Logo del Restaurante

### Implementación Actual
Se ha creado un logo personalizado dibujado con Flutter CustomPainter que muestra:
- Un plato/círculo en los colores del tema
- Tenedor y cuchillo estilizados
- Punto de acento dorado

**Ubicación del código:** `lib/widgets/app_logo.dart`

### Reemplazar con Logo Personalizado

Para usar el logo real del restaurante:

1. **Preparar la imagen:**
   - Formato: PNG con fondo transparente
   - Tamaño recomendado: 512x512px o mayor
   - Nombre del archivo: `logo.png`

2. **Colocar la imagen:**
   ```
   app_frontend/
   └── assets/
       └── images/
           └── logo.png
   ```

3. **Actualizar el widget (en `lib/widgets/app_logo.dart`):**
   ```dart
   @override
   Widget build(BuildContext context) {
     // Descomentar estas líneas:
     return Image.asset(
       'assets/images/logo.png',
       width: size,
       height: size,
     );
     
     // Y comentar o eliminar el CustomPaint actual
   }
   ```

4. **Reconstruir la app:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### Variante del Logo
Si deseas un logo en blanco para fondos oscuros, crea también:
- `logo_white.png` - Versión en blanco del logo

## 📱 Pantallas Actualizadas

### 1. Login Choice Page (`lib/pages/login_choice_page.dart`)
- Muestra el logo grande con sombra
- Usa los nuevos colores del tema
- Botones con el esquema de colores rojo/naranja

### 2. Login Admin Page (`lib/pages/login_admin_page.dart`)
- Logo más pequeño en la parte superior del formulario
- Gradiente de fondo usando los nuevos colores
- Inputs y botones con el tema actualizado

## 🎨 Uso del Tema en el Código

### Acceder a los Colores del Tema

```dart
import 'package:app_pedidos/theme/app_theme.dart';

// Usar colores directamente
Container(
  color: AppTheme.primary,
  child: Text(
    'Texto',
    style: TextStyle(color: AppTheme.textOnPrimary),
  ),
)

// Usar gradientes predefinidos
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.primaryGradient,
  ),
)

// Usar estilos de texto predefinidos
Text(
  'Título',
  style: AppTheme.heading1,
)
```

### Widget del Logo

```dart
import 'package:app_pedidos/widgets/app_logo.dart';

// Logo con fondo circular blanco y sombra
AppLogo(
  size: 120,
  backgroundColor: Colors.white,
  showCircleBackground: true,
)

// Logo sin fondo
AppLogo(
  size: 80,
  showCircleBackground: false,
)
```

## 🔄 Migración de Pantallas Existentes

Para actualizar otras pantallas al nuevo tema:

1. **Botones principales:** Cambiarán automáticamente al rojo (#D32F2F)
2. **Botones flotantes (FAB):** Cambiarán al naranja (#FFA726)
3. **AppBars:** Mantienen el gradiente pero ahora en rojo
4. **Cards y superficies:** Sin cambios, siguen siendo blancas

### Ejemplo de Actualización Manual

```dart
// Antes (azul)
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF2196F3), // Azul
  ),
  child: Text('Botón'),
)

// Después (rojo - automático con el tema)
ElevatedButton(
  child: Text('Botón'), // Ya usa AppTheme.primary
)
```

## 📸 Screenshots Recomendados

Se recomienda tomar screenshots de:
1. Pantalla de elección de login (login_choice_page)
2. Pantalla de login de administrador (login_admin_page)
3. Cualquier otra pantalla principal para verificar la coherencia del tema

## 🧪 Testing

Para verificar que el tema funciona correctamente:

```bash
cd app_frontend
flutter clean
flutter pub get
flutter run
```

Verificar:
- ✅ Los colores rojos y naranjas aparecen correctamente
- ✅ El logo se muestra en las pantallas de login
- ✅ Los botones usan los nuevos colores
- ✅ Las transiciones y sombras funcionan bien

## 📝 Notas Adicionales

### Psicología del Color en Restaurantes
Los colores elegidos (rojo, naranja, dorado) son ideales para aplicaciones de comida porque:
- **Rojo:** Estimula el apetito, energía, urgencia
- **Naranja:** Amigable, accesible, apetitoso
- **Dorado:** Premium, calidad, lujo

### Accesibilidad
- Todos los colores tienen suficiente contraste con el texto blanco
- Los elementos interactivos son claramente distinguibles
- El tema sigue las guías de Material Design 3

### Personalización Futura
El archivo `app_theme.dart` está estructurado para facilitar cambios futuros:
- Todos los colores están definidos como constantes nombradas
- Los gradientes son reutilizables
- Los estilos de texto están predefinidos

## 🔗 Archivos Relacionados

- `lib/theme/app_theme.dart` - Definición del tema
- `lib/widgets/app_logo.dart` - Widget del logo
- `lib/pages/login_choice_page.dart` - Pantalla de elección
- `lib/pages/login_admin_page.dart` - Pantalla de login admin
- `assets/images/README.md` - Guía para agregar logo personalizado
- `pubspec.yaml` - Configuración de assets

---

**Versión:** 1.0  
**Fecha:** 2024  
**Autor:** Sistema de App Pedidos
