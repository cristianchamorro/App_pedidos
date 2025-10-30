# App Pedidos

Aplicación multiplataforma para realización de pedidos.

## Configuración de Red

La aplicación ahora soporta configuración flexible del backend para trabajar en diferentes redes (casa, oficina, etc.).

### Configuración Rápida

1. Ve a `app_frontend/` y copia el archivo de ejemplo:
   ```bash
   cp .env.example .env
   ```

2. Edita el archivo `.env` y actualiza la dirección IP con la de tu servidor backend:
   ```bash
   BACKEND_URL=http://TU_IP_AQUI:3000
   ```

3. Para encontrar tu IP:
   - **Windows**: Abre CMD y ejecuta `ipconfig`
   - **Mac/Linux**: Abre Terminal y ejecuta `ifconfig` o `ip addr`

4. Reinicia la aplicación

### Documentación Completa

Para más detalles sobre la configuración de red, consulta [NETWORK_CONFIGURATION_GUIDE.md](NETWORK_CONFIGURATION_GUIDE.md)

## Estructura del Proyecto

```
App_pedidos/
├── app_backend/     # Backend Node.js con Express
└── app_frontend/    # Frontend Flutter
    └── .env         # Configuración de red (crear desde .env.example)
```
