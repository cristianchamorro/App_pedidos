# 🚀 Setup Rápido - Mejoras Pedidos Listos

## ⏱️ 5 Minutos de Configuración

### Paso 1: Actualizar Dependencias (1 minuto)

```bash
cd app_frontend
flutter pub get
```

Esto instalará el nuevo paquete `audioplayers` necesario para el sonido.

### Paso 2: Agregar Archivo de Sonido (2 minutos)

**Opción A - Descarga rápida (Recomendada):**

1. Ve a https://freesound.org
2. Busca "notification bell" o "ding"
3. Descarga un sonido corto (1-2 segundos)
4. Guárdalo como `notification.mp3`
5. Cópialo a: `app_frontend/assets/sounds/notification.mp3`

**Opción B - Usar sonido del sistema:**

Si no agregas el archivo MP3, la app usará automáticamente el sonido del sistema (funciona pero menos personalizado).

### Paso 3: Compilar y Ejecutar (2 minutos)

```bash
# Para Android
flutter run

# Para Web
flutter run -d chrome

# Para producción
flutter build apk
# o
flutter build web
```

## ✅ Verificación Rápida

Después de ejecutar, verifica:

- [ ] La pantalla se divide en dos mitades (pedidos arriba, productos abajo)
- [ ] Las imágenes de productos son grandes y se ven bien
- [ ] Los números de pedido son muy grandes y visibles
- [ ] NO se ven precios ni descripciones en la publicidad
- [ ] Las transiciones entre imágenes son suaves

## 🔊 Probar Alerta de Sonido

Para probar la alerta:

1. Tener la pantalla de pedidos listos abierta
2. Desde el panel de cocinero, marcar un pedido como "Listo"
3. Deberías escuchar el sonido de notificación
4. Deberías ver la alerta visual en pantalla completa
5. La alerta se cierra sola después de 5 segundos

## 🖥️ Configuración para TV

### Conectar a TV:

**Opción 1 - HDMI directo:**
```
Tablet/Laptop → Cable HDMI → TV
```

**Opción 2 - Chromecast:**
```
1. Conectar Chromecast a TV
2. Desde la app, usar "Transmitir pantalla"
3. Seleccionar el Chromecast
```

**Opción 3 - Smart TV con Android:**
```
1. Instalar APK directamente en TV
2. Ejecutar la app
```

### Ajustes de TV Recomendados:

```
Brillo: ████████████ 100%
Contraste: ██████████ 80%
Nitidez: ████████ 70%
Modo de imagen: Estándar/Dinámico
Sonido: ██████ 50-60%
```

## 📱 Modo Pantalla Completa

La app automáticamente:
- ✅ Oculta la barra de navegación
- ✅ Oculta la barra de estado
- ✅ Se mantiene siempre encendida
- ✅ Usa orientación horizontal

**Si necesitas salir:**
- Desliza desde el borde inferior (Android)
- Presiona Esc (Web/Desktop)
- Usa el botón de retroceso (Android)

## 🎨 Personalización Rápida

### Cambiar Tiempos de Rotación

En `pedidos_listos_page.dart`, busca:

```dart
// Línea 39 - Actualizar pedidos
Timer.periodic(const Duration(seconds: 5), ...)

// Línea 44 - Rotar pedidos
Timer.periodic(const Duration(seconds: 7), ...)

// Línea 56 - Rotar publicidad
Timer.periodic(const Duration(seconds: 5), ...)
```

Cambia los números según prefieras:
- **Más rápido**: 3-4 segundos
- **Normal**: 5-7 segundos
- **Más lento**: 10-15 segundos

### Cambiar Duración de Alerta

En `pedidos_listos_page.dart`, línea ~164:

```dart
await Future.delayed(const Duration(seconds: 5));
```

Cambia `5` por el tiempo que desees (en segundos).

### Cambiar Colores

Busca en el código:

```dart
// Verde de pedidos
Colors.green.shade600

// Púrpura de publicidad
Colors.purple.shade100

// Naranja de productos
Colors.orange.shade50
```

Cámbialo por tu paleta de colores preferida.

## 🐛 Solución de Problemas Comunes

### "No escucho el sonido"

1. ✅ Verificar que `notification.mp3` existe en `assets/sounds/`
2. ✅ Verificar volumen del dispositivo
3. ✅ Verificar volumen de la TV (si aplica)
4. ✅ Probar con un archivo MP3 diferente

### "Las imágenes no se ven"

1. ✅ Verificar conexión a internet
2. ✅ Verificar que los productos tienen `image_url` en la base de datos
3. ✅ Verificar que las URLs de imágenes son válidas
4. ✅ Ver los logs de consola para errores

### "La pantalla no se ve en pantalla completa"

1. ✅ Verificar que el dispositivo soporta el modo inmersivo
2. ✅ En ajustes de TV, desactivar "Sobrescan" o "Zoom"
3. ✅ Usar resolución nativa de la TV

### "Los textos son muy grandes/pequeños"

Los tamaños están optimizados para TV de 40"+. Si tu pantalla es:
- **Más pequeña**: Reduce los valores de `fontSize` en un 20-30%
- **Más grande**: Aumenta los valores de `fontSize` en un 20-30%

## 📊 Métricas de Éxito

Después de implementar, monitorea:

- ✅ **Tiempo de espera de clientes**: ¿Se redujo?
- ✅ **Pedidos perdidos**: ¿Menos clientes preguntan por su pedido?
- ✅ **Ventas adicionales**: ¿Los clientes piden más productos que ven en pantalla?
- ✅ **Satisfacción**: ¿Los clientes comentan positivamente sobre la pantalla?

## 📞 Soporte

Si tienes problemas:

1. Revisa el archivo `PEDIDOS_LISTOS_MEJORAS_2024.md`
2. Revisa el archivo `GUIA_VISUAL_MEJORAS_PEDIDOS_LISTOS.md`
3. Revisa los logs de Flutter: `flutter logs`
4. Revisa los errores en la consola del navegador (si es web)

## 🎉 ¡Listo!

Tu pantalla de pedidos listos ahora está optimizada para:
- ✅ TV de 40+ pulgadas
- ✅ Publicidad efectiva
- ✅ Alertas claras con sonido
- ✅ Mejor experiencia de cliente

**¡Disfruta de tu pantalla mejorada!** 🚀

---

### Checklist Final

Antes de poner en producción:

- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Archivo de sonido agregado (o confirmado que funciona el fallback)
- [ ] Probado en dispositivo real
- [ ] Conectado a TV y probado desde distancia
- [ ] Volumen ajustado apropiadamente
- [ ] Imágenes de productos cargadas y visibles
- [ ] Transiciones funcionando suavemente
- [ ] Alerta de nuevo pedido probada
- [ ] Personal capacitado sobre la nueva pantalla
- [ ] Posicionamiento de TV optimizado en el local

¡Todo listo para empezar! 🎊
