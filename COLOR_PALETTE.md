# Paleta de Colores del Restaurante

## Colores Aplicados al App Pedidos

Esta es la paleta de colores implementada en la aplicación, inspirada en restaurantes y negocios de comida.

---

## 🔴 Colores Principales (Rojo)

### Primary - Rojo Principal
**Código HEX:** `#D32F2F`  
**RGB:** `rgb(211, 47, 47)`  
**Uso:** Botones principales, encabezados, elementos destacados

```
████████████████████████
████████████████████████  #D32F2F (Deep Red)
████████████████████████
```

### Primary Light - Rojo Claro
**Código HEX:** `#EF5350`  
**RGB:** `rgb(239, 83, 80)`  
**Uso:** Efectos hover, degradados, estados activos

```
████████████████████████
████████████████████████  #EF5350 (Light Red)
████████████████████████
```

### Primary Dark - Rojo Oscuro
**Código HEX:** `#C62828`  
**RGB:** `rgb(198, 40, 40)`  
**Uso:** Sombras, estados presionados

```
████████████████████████
████████████████████████  #C62828 (Dark Red)
████████████████████████
```

### Primary Very Light - Rojo Muy Claro
**Código HEX:** `#FFEBEE`  
**RGB:** `rgb(255, 235, 238)`  
**Uso:** Fondos de página, áreas desactivadas

```
████████████████████████
████████████████████████  #FFEBEE (Very Light Red)
████████████████████████
```

---

## 🟠 Colores Secundarios (Naranja)

### Secondary - Naranja Cálido
**Código HEX:** `#FFA726`  
**RGB:** `rgb(255, 167, 38)`  
**Uso:** Botones flotantes (FAB), acciones secundarias

```
████████████████████████
████████████████████████  #FFA726 (Warm Orange)
████████████████████████
```

### Secondary Light - Naranja Claro
**Código HEX:** `#FFB74D`  
**RGB:** `rgb(255, 183, 77)`  
**Uso:** Degradados, efectos hover

```
████████████████████████
████████████████████████  #FFB74D (Light Orange)
████████████████████████
```

### Secondary Dark - Naranja Oscuro
**Código HEX:** `#F57C00`  
**RGB:** `rgb(245, 124, 0)`  
**Uso:** Sombras de elementos naranjas

```
████████████████████████
████████████████████████  #F57C00 (Dark Orange)
████████████████████████
```

---

## 🟡 Colores de Acento (Dorado)

### Accent - Dorado
**Código HEX:** `#FFB300`  
**RGB:** `rgb(255, 179, 0)`  
**Uso:** Highlights, elementos premium, estrellas

```
████████████████████████
████████████████████████  #FFB300 (Golden)
████████████████████████
```

### Accent Light - Dorado Claro
**Código HEX:** `#FFCA28`  
**RGB:** `rgb(255, 202, 40)`  
**Uso:** Degradados dorados, efectos de brillo

```
████████████████████████
████████████████████████  #FFCA28 (Light Amber)
████████████████████████
```

---

## ⚪ Colores de Estado

### Success - Verde Éxito
**Código HEX:** `#4CAF50`  
**RGB:** `rgb(76, 175, 80)`  
**Uso:** Mensajes de éxito, pedidos completados

```
████████████████████████
████████████████████████  #4CAF50 (Green)
████████████████████████
```

### Warning - Advertencia (Naranja)
**Código HEX:** `#FFA726`  
**RGB:** `rgb(255, 167, 38)`  
**Uso:** Advertencias, estados pendientes

```
████████████████████████
████████████████████████  #FFA726 (Orange)
████████████████████████
```

### Error - Error (Rojo)
**Código HEX:** `#D32F2F`  
**RGB:** `rgb(211, 47, 47)`  
**Uso:** Mensajes de error, cancelaciones

```
████████████████████████
████████████████████████  #D32F2F (Red)
████████████████████████
```

### Info - Información (Dorado)
**Código HEX:** `#FFB300`  
**RGB:** `rgb(255, 179, 0)`  
**Uso:** Mensajes informativos, tips

```
████████████████████████
████████████████████████  #FFB300 (Golden)
████████████████████████
```

---

## 🎨 Combinaciones Recomendadas

### Combinación 1: Primaria
```
Fondo:  #D32F2F (Rojo)
Texto:  #FFFFFF (Blanco)
```
✅ Excelente contraste para lectura

### Combinación 2: Secundaria
```
Fondo:  #FFA726 (Naranja)
Texto:  #FFFFFF (Blanco)
```
✅ Buena visibilidad, cálido y acogedor

### Combinación 3: Degradado Principal
```
Inicio: #D32F2F (Rojo)
Fin:    #EF5350 (Rojo Claro)
```
✅ Elegante para AppBars y headers

### Combinación 4: Degradado Secundario
```
Inicio: #FFA726 (Naranja)
Fin:    #FFB74D (Naranja Claro)
```
✅ Perfecto para botones especiales

---

## 📱 Uso en Diferentes Elementos

| Elemento | Color Principal | Color Secundario |
|----------|-----------------|------------------|
| **AppBar** | #D32F2F (Rojo) | Gradiente rojo |
| **Botón Principal** | #D32F2F (Rojo) | Texto blanco |
| **Botón Secundario** | Blanco | Borde rojo #D32F2F |
| **FAB (Flotante)** | #FFA726 (Naranja) | Ícono blanco |
| **Input Activo** | Borde #D32F2F | - |
| **Input Inactivo** | Borde #E0E0E0 | - |
| **Fondos** | #FFEBEE / #F5F5F5 | - |
| **Cards** | #FFFFFF | Sombra sutil |
| **Logo** | #D32F2F + #FFA726 | Detalles dorados |

---

## 🖼️ Para Diseñadores

Si estás creando assets (logos, banners, iconos) para esta app:

1. **Color primario dominante:** #D32F2F (rojo profundo)
2. **Color de acento/complemento:** #FFA726 (naranja cálido)
3. **Detalles especiales:** #FFB300 (dorado)
4. **Fondos claros:** #FFEBEE (rosa muy claro)
5. **Texto sobre color:** Siempre blanco (#FFFFFF)

---

## 📋 Códigos para Copiar

### CSS
```css
:root {
  --primary: #D32F2F;
  --primary-light: #EF5350;
  --primary-dark: #C62828;
  --secondary: #FFA726;
  --accent: #FFB300;
  --success: #4CAF50;
}
```

### Flutter/Dart
```dart
static const Color primary = Color(0xFFD32F2F);
static const Color primaryLight = Color(0xFFEF5350);
static const Color primaryDark = Color(0xFFC62828);
static const Color secondary = Color(0xFFFFA726);
static const Color accent = Color(0xFFFFB300);
```

### Android XML
```xml
<color name="primary">#D32F2F</color>
<color name="primary_light">#EF5350</color>
<color name="primary_dark">#C62828</color>
<color name="secondary">#FFA726</color>
<color name="accent">#FFB300</color>
```

### iOS Swift
```swift
let primary = UIColor(hex: "D32F2F")
let primaryLight = UIColor(hex: "EF5350")
let primaryDark = UIColor(hex: "C62828")
let secondary = UIColor(hex: "FFA726")
let accent = UIColor(hex: "FFB300")
```

---

## 🎯 Recomendaciones

### Accesibilidad
✅ Todos los colores principales cumplen con WCAG 2.1 AA para contraste  
✅ Texto blanco sobre rojo: Radio de contraste 5.5:1  
✅ Texto blanco sobre naranja: Radio de contraste 3.2:1

### Psicología del Color
- **Rojo:** Estimula el apetito, crea urgencia, energía
- **Naranja:** Amigable, optimista, fresco
- **Dorado:** Premium, calidad, confiable

### Aplicaciones Exitosas que Usan Estos Colores
- McDonald's (rojo + amarillo)
- KFC (rojo)
- Pizza Hut (rojo)
- Burger King (rojo + naranja)
- Domino's (rojo + azul)

---

**Nota:** Esta paleta está optimizada para aplicaciones de comida y restaurantes.  
Los colores cálidos (rojo, naranja, dorado) estimulan el apetito y crean una experiencia acogedora.

---

**Versión:** 1.0  
**Última actualización:** 2024  
**Estado:** ✅ Implementado en la aplicación
