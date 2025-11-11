# Configuración de Red - Guía Rápida

## ¿Qué problema resuelve esto?

Antes, cuando cambiabas de red (por ejemplo, de tu casa a la oficina), la aplicación dejaba de funcionar porque la dirección IP del backend estaba fija en el código. Ahora puedes cambiar fácilmente la configuración sin tocar el código.

## Solución en 3 Pasos

### 1. Crear tu archivo de configuración

Ve a la carpeta `app_frontend/` y ejecuta:

```bash
cp .env.example .env
```

### 2. Encontrar la IP de tu servidor backend

**En Windows:**
```bash
ipconfig
```
Busca "Dirección IPv4" - algo como `192.168.1.100`

**En Mac/Linux:**
```bash
ifconfig
```
o
```bash
ip addr
```
Busca la dirección "inet" - algo como `192.168.1.100`

### 3. Actualizar el archivo .env

Abre el archivo `app_frontend/.env` con cualquier editor de texto y cambia:

```
BACKEND_URL=http://192.168.101.6:3000
```

Por tu IP:

```
BACKEND_URL=http://192.168.1.100:3000
```

¡Listo! Reinicia la aplicación.

## Ejemplos según tu caso

### Desarrollo con emulador Android
```
BACKEND_URL=http://10.0.2.2:3000
```

### Desarrollo con dispositivo físico (celular/tablet)
```
BACKEND_URL=http://192.168.X.X:3000
```
Reemplaza X.X con tu IP local

### Desarrollo con iOS Simulator o Web
```
BACKEND_URL=http://localhost:3000
```

## ¿No funciona?

### Checklist:

- [ ] ¿El backend está corriendo? Ejecuta `npm start` en `app_backend/`
- [ ] ¿Tu dispositivo y el servidor están en la misma red WiFi?
- [ ] ¿La IP en el archivo .env es correcta?
- [ ] ¿Reiniciaste la aplicación completamente después de cambiar el .env?
- [ ] ¿El firewall permite conexiones en el puerto 3000?

## Más información

Para una guía completa, ve a [NETWORK_CONFIGURATION_GUIDE.md](NETWORK_CONFIGURATION_GUIDE.md)
