# Guía Rápida: Cómo Agregar tu Logo

Esta guía te ayudará a reemplazar el logo temporal por el logo real de tu restaurante.

## 📋 Requisitos

Tu imagen de logo debe cumplir con:
- ✅ Formato PNG (preferiblemente con fondo transparente)
- ✅ Tamaño mínimo de 512x512 píxeles
- ✅ Buena calidad (se mostrará en diferentes tamaños)

## 🚀 Pasos Rápidos (5 minutos)

### Paso 1: Preparar tu Logo
1. Abre tu archivo de logo en un editor de imágenes
2. Asegúrate de que tenga fondo transparente (no blanco)
3. Guárdalo como `logo.png`

### Paso 2: Copiar el Archivo
Copia tu archivo `logo.png` a esta ubicación:
```
app_frontend/
  └── assets/
      └── images/
          └── logo.png    ← Tu archivo aquí
```

**En Windows:**
```cmd
copy C:\ruta\a\tu\logo.png app_frontend\assets\images\logo.png
```

**En Mac/Linux:**
```bash
cp /ruta/a/tu/logo.png app_frontend/assets/images/logo.png
```

### Paso 3: Editar el Código
Abre el archivo: `app_frontend/lib/widgets/app_logo.dart`

**Encuentra estas líneas (alrededor de la línea 21-27):**
```dart
  @override
  Widget build(BuildContext context) {
    // If you have a custom logo image, uncomment this and comment out the CustomPaint:
    // return Image.asset(
    //   'assets/images/logo.png',
    //   width: size,
    //   height: size,
    // );

    // For now, we use a custom-drawn logo
    return Container(
```

**Cámbialo por esto:**
```dart
  @override
  Widget build(BuildContext context) {
    // Using custom logo image
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );

    // Old custom-drawn logo (commented out)
    /*
    return Container(
```

**Y comenta el resto del CustomPaint** añadiendo `*/` al final del método, antes del último `}`.

### Paso 4: Reconstruir la App
```bash
cd app_frontend
flutter clean
flutter pub get
flutter run
```

## ✅ Verificación

Tu logo debería aparecer en:
- ✅ Pantalla de bienvenido/selección de tipo de usuario
- ✅ Pantalla de login de administrador

## 🎨 Recomendaciones de Diseño

### Colores del Logo
Para que tu logo se vea mejor con el tema, considera usar estos colores:
- **Rojo principal:** `#D32F2F`
- **Naranja cálido:** `#FFA726`
- **Dorado:** `#FFB300`

### Tamaños Recomendados
| Uso | Tamaño |
|-----|---------|
| Pantalla principal | 512x512 o más |
| Versión pequeña | 256x256 |
| Ícono de app | 1024x1024 (para publicar) |

## 🔧 Solución de Problemas

### ❌ Error: "Unable to load asset"
**Causa:** El archivo no está en la ubicación correcta.
**Solución:** 
1. Verifica que el archivo esté en `app_frontend/assets/images/logo.png`
2. Verifica que `pubspec.yaml` tenga las líneas:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
3. Ejecuta `flutter clean` y `flutter pub get`

### ❌ El logo se ve pixelado
**Causa:** La imagen es muy pequeña.
**Solución:** Usa una imagen de al menos 512x512 píxeles.

### ❌ El logo tiene fondo blanco
**Causa:** La imagen PNG no tiene transparencia.
**Solución:** 
1. Abre tu logo en un editor como GIMP, Photoshop, o Photopea
2. Elimina el fondo blanco
3. Guarda como PNG con transparencia

### ❌ El logo se ve cortado
**Causa:** El logo tiene proporciones muy diferentes a un cuadrado.
**Solución:** 
1. Ajusta tu logo a proporciones 1:1 (cuadrado)
2. O modifica el código para usar `BoxFit.cover` en lugar de `BoxFit.contain`

## 📐 Ajustar Tamaño del Logo

Si quieres que el logo se vea más grande o más pequeño en las pantallas, edita estos archivos:

**Login Choice Page** (`lib/pages/login_choice_page.dart`, línea ~50):
```dart
const AppLogo(
  size: 120,  // Cambia este número
  backgroundColor: Colors.white,
  showCircleBackground: true,
),
```

**Login Admin Page** (`lib/pages/login_admin_page.dart`, línea ~145):
```dart
const AppLogo(
  size: 100,  // Cambia este número
  showCircleBackground: false,
),
```

## 🎯 Ejemplo Completo

Aquí está el código completo para `app_logo.dart` con tu logo personalizado:

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final bool showCircleBackground;

  const AppLogo({
    super.key,
    this.size = 120,
    this.backgroundColor,
    this.showCircleBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: showCircleBackground ? EdgeInsets.all(size * 0.15) : null,
      decoration: showCircleBackground
          ? BoxDecoration(
              color: backgroundColor ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            )
          : null,
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
```

## 📞 Ayuda

Si tienes problemas:
1. Verifica que Flutter esté instalado: `flutter doctor`
2. Verifica que el archivo existe: `ls app_frontend/assets/images/logo.png`
3. Revisa los mensajes de error en la consola
4. Ejecuta `flutter clean` antes de `flutter run`

## ✨ Resultado Final

Después de seguir estos pasos, tu logo personalizado aparecerá en:
- ✅ Pantalla de bienvenido con círculo blanco de fondo
- ✅ Pantalla de login sin fondo
- ✅ Con los colores y estilo de tu marca

---

**¿Necesitas más ayuda?** Consulta `THEME_LOGO_GUIDE.md` para documentación completa.
