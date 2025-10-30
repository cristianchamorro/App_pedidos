# Guía de Configuración de Red - App Pedidos

## Problema Resuelto

Anteriormente, la aplicación tenía las direcciones IP del backend codificadas de forma fija, lo que causaba problemas cuando se cambiaba de red (por ejemplo, de casa a la oficina). Ahora la configuración del backend es flexible y fácil de cambiar.

## Solución Implementada

La aplicación ahora utiliza un archivo de configuración `.env` que permite cambiar la dirección del backend sin necesidad de modificar el código fuente.

## Cómo Configurar la Aplicación para una Nueva Red

### Paso 1: Localizar el archivo .env

El archivo de configuración se encuentra en:
```
app_frontend/.env
```

### Paso 2: Encontrar la dirección IP de tu servidor backend

Dependiendo de tu sistema operativo:

**Windows:**
1. Abre el CMD (Command Prompt)
2. Escribe: `ipconfig`
3. Busca la línea "IPv4 Address" o "Dirección IPv4"
4. Anota la dirección IP (ejemplo: 192.168.1.100)

**Mac/Linux:**
1. Abre la Terminal
2. Escribe: `ifconfig` o `ip addr`
3. Busca la dirección "inet" (ejemplo: 192.168.1.100)

**Importante:** Asegúrate de que tu dispositivo móvil/emulador y el servidor backend estén en la misma red.

### Paso 3: Actualizar el archivo .env

Abre el archivo `app_frontend/.env` y modifica la línea:

```bash
BACKEND_URL=http://192.168.101.6:3000
```

Reemplaza `192.168.101.6` con la IP de tu servidor backend que encontraste en el Paso 2.

**Ejemplos de configuración:**

```bash
# Para desarrollo local en emulador Android
BACKEND_URL=http://10.0.2.2:3000

# Para dispositivo físico en la misma red
BACKEND_URL=http://192.168.1.100:3000

# Para iOS simulator o desarrollo web
BACKEND_URL=http://localhost:3000

# Para usar un puerto diferente
BACKEND_URL=http://192.168.1.100:8080
```

### Paso 4: Reiniciar la aplicación

Después de modificar el archivo `.env`:
1. Cierra la aplicación completamente si está en ejecución
2. Vuelve a ejecutar la aplicación con:
   ```bash
   flutter run
   ```

## Casos de Uso Comunes

### Trabajando desde Casa
```bash
BACKEND_URL=http://192.168.1.50:3000
```

### Trabajando desde la Oficina
```bash
BACKEND_URL=http://192.168.10.25:3000
```

### Desarrollo Local con Emulador Android
```bash
BACKEND_URL=http://10.0.2.2:3000
```

### Desarrollo con Dispositivo Físico
1. Encuentra la IP de tu computadora donde corre el backend
2. Configura esa IP en el archivo .env
3. Asegúrate de que el dispositivo esté conectado a la misma red WiFi

## Solución de Problemas

### Error: "No se pudo conectar al backend"

1. **Verifica que el backend esté corriendo:**
   ```bash
   cd app_backend
   npm start
   ```
   Deberías ver: `🚀 Servidor corriendo en http://127.0.0.1:3000`

2. **Verifica la conexión de red:**
   - Asegúrate de que tu dispositivo y el servidor estén en la misma red
   - Intenta hacer ping a la IP del servidor desde tu dispositivo

3. **Verifica el archivo .env:**
   - Confirma que la IP en el archivo .env sea correcta
   - Verifica que el puerto sea el correcto (normalmente 3000)
   - No olvides reiniciar la aplicación después de cambiar el .env

4. **Firewall:**
   - Asegúrate de que el firewall de tu computadora permita conexiones en el puerto 3000

### La aplicación no detecta los cambios en .env

1. Detén completamente la aplicación (no solo recarga en caliente)
2. Ejecuta `flutter clean`
3. Vuelve a ejecutar `flutter run`

## Notas Técnicas

### Archivos Modificados

- `app_frontend/.env` - Archivo de configuración (no se incluye en git)
- `app_frontend/.env.example` - Plantilla de ejemplo
- `app_frontend/lib/api_service.dart` - Actualizado para leer de .env
- `app_frontend/lib/main.dart` - Inicializa dotenv al inicio
- `app_frontend/lib/pages/confirmar_pedido_page.dart` - Usa ApiService en lugar de URL hardcoded
- `app_frontend/pubspec.yaml` - Incluye .env en assets

### Seguridad

El archivo `.env` está excluido del control de versiones (git) por seguridad. Cada desarrollador debe crear su propio archivo `.env` basado en `.env.example`.

## Configuración del Backend

El backend está configurado para aceptar conexiones desde cualquier IP:

```javascript
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor corriendo en http://127.0.0.1:${PORT}`);
});
```

Esto permite que dispositivos en la red local se conecten al servidor.

## Soporte

Si tienes problemas con la configuración de red:
1. Verifica que el backend esté corriendo
2. Confirma que estés en la misma red
3. Revisa que la IP en el archivo .env sea correcta
4. Reinicia la aplicación completamente después de cambios en .env
