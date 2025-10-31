# ✅ Inicio Rápido - Configuración de Red

## 🎯 Problema Resuelto

Ya no tendrás problemas al cambiar de red (casa ↔ oficina). Solo necesitas actualizar un archivo.

## 📋 Checklist de Configuración (5 minutos)

### ✅ Paso 1: Crear archivo de configuración
```bash
cd app_frontend
cp .env.example .env
```

### ✅ Paso 2: Encontrar la IP de tu servidor backend

**Windows:**
```cmd
ipconfig
```
Busca: **Dirección IPv4** → Ejemplo: `192.168.1.100`

**Mac/Linux:**
```bash
ifconfig
# o
ip addr
```
Busca: **inet** → Ejemplo: `192.168.1.100`

### ✅ Paso 3: Editar el archivo .env

Abre `app_frontend/.env` con cualquier editor de texto y cambia:

```bash
# Antes
BACKEND_URL=http://192.168.101.6:3000

# Después (usa TU IP)
BACKEND_URL=http://192.168.1.100:3000
```

### ✅ Paso 4: Reiniciar la aplicación

1. Cierra completamente la app
2. Vuelve a ejecutar:
   ```bash
   flutter run
   ```

## 🔧 Configuraciones Comunes

### 📱 Emulador Android
```bash
BACKEND_URL=http://10.0.2.2:3000
```

### 📱 Dispositivo Físico (celular/tablet)
```bash
BACKEND_URL=http://TU_IP_LOCAL:3000
```
⚠️ **Importante:** Tu dispositivo y computadora deben estar en la misma red WiFi

### 💻 Web o iOS Simulator
```bash
BACKEND_URL=http://localhost:3000
```

## 🏢 Cambiar de Red (Casa → Oficina)

1. En la oficina, encuentra la nueva IP del servidor
2. Edita `app_frontend/.env`
3. Cambia el `BACKEND_URL` con la nueva IP
4. Reinicia la app

¡Listo! 🎉

## ❌ Solución de Problemas

### Error: "No se pudo conectar al backend"

**Checklist de diagnóstico:**
- [ ] ¿El backend está corriendo? (`cd app_backend && npm start`)
- [ ] ¿Ves el mensaje `🚀 Servidor corriendo...`?
- [ ] ¿Tu dispositivo y servidor están en la misma red?
- [ ] ¿La IP en `.env` es correcta?
- [ ] ¿Reiniciaste la app COMPLETAMENTE?
- [ ] ¿El firewall permite conexiones en puerto 3000?

### La app no detecta cambios en .env

```bash
flutter clean
flutter pub get
flutter run
```

### No tengo archivo .env

```bash
cd app_frontend
cp .env.example .env
# Ahora edita el .env con tu IP
```

### Error: "No file or variants found for asset: .env"

Este error ocurre si el archivo `.env` no existe. **Importante:** El archivo `.env` debe estar en `app_frontend/`, no en assets. `flutter_dotenv` lo carga directamente del sistema de archivos.

**Solución:**
```bash
cd app_frontend
cp .env.example .env
# Edita .env con tu IP
flutter clean
flutter run
```

**Nota:** El archivo `.env` NO debe estar listado en `pubspec.yaml` bajo `assets:`. Solo debe existir físicamente en la carpeta `app_frontend/`.

## 📚 Más Información

- **Guía rápida en español:** [CONFIGURACION_RED.md](CONFIGURACION_RED.md)
- **Guía completa en inglés:** [NETWORK_CONFIGURATION_GUIDE.md](NETWORK_CONFIGURATION_GUIDE.md)
- **Detalles técnicos:** [IMPLEMENTATION_SUMMARY_NETWORK_CONFIG.md](IMPLEMENTATION_SUMMARY_NETWORK_CONFIG.md)

## 🎓 Tips Útiles

1. **Guarda diferentes versiones del .env:**
   - `.env.casa` con la IP de tu casa
   - `.env.oficina` con la IP de la oficina
   - Copia el que necesites a `.env`

2. **Para desarrollo:**
   - Si usas emulador, deja `http://10.0.2.2:3000`
   - Si usas dispositivo real, usa tu IP local

3. **El archivo .env no se sube a git**
   - Es seguro poner IPs locales
   - Cada desarrollador tiene su propia configuración

## ✨ Beneficios

- ✅ Cambio de red en segundos
- ✅ No tocas código
- ✅ Funciona en cualquier red
- ✅ Configuración segura
- ✅ Fácil de usar

## 🆘 ¿Necesitas Ayuda?

1. Lee [CONFIGURACION_RED.md](CONFIGURACION_RED.md) para más detalles
2. Revisa [NETWORK_CONFIGURATION_GUIDE.md](NETWORK_CONFIGURATION_GUIDE.md) para troubleshooting avanzado
3. Verifica que el backend esté configurado correctamente (puerto 3000, acepta conexiones externas)
