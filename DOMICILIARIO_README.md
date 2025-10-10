# Pantalla del Domiciliario

## Descripción
La pantalla del domiciliario muestra todos los pedidos que están listos para ser entregados (estado: "listo"). Los domiciliarios pueden ver la información del cliente y marcar los pedidos como entregados.

## Características

### 1. Auto-refresh
- La lista de pedidos se actualiza automáticamente cada 5 segundos
- Esto permite ver nuevos pedidos listos sin necesidad de refrescar manualmente

### 2. Información del pedido
Para cada pedido se muestra:
- **Número de pedido**: ID único del pedido
- **Cliente**: Nombre del cliente
- **Teléfono**: Número de contacto
- **Dirección**: Dirección de entrega (destacada en naranja)
- **Total**: Monto total del pedido (en verde)
- **Productos**: Lista detallada de productos con cantidades

### 3. Marcar como entregado
- Botón verde "Marcar como Entregado" para cada pedido
- Al presionar, el pedido cambia de estado a "entregado"
- Se actualiza automáticamente la lista de pedidos

## Flujo de uso

1. **Login**: El domiciliario ingresa con sus credenciales en la pantalla de login de administrador
2. **Acceso**: Si las credenciales tienen rol "domiciliario", se redirige a esta pantalla
3. **Ver pedidos**: Se muestran todos los pedidos con estado "listo"
4. **Entregar**: Al entregar un pedido, se marca como entregado desde la app
5. **Actualización**: La lista se refresca automáticamente

## Integración con backend

### Endpoint utilizado para obtener pedidos
```
GET /pedidos?estado=listo
```

### Endpoint utilizado para marcar como entregado
```
PUT /pedidos/:id/entregado-cliente
Body: { "changed_by": "domiciliario" }
```

## Rutas de navegación

- Ruta principal: `/domiciliario`
- Declarada en: `app_frontend/lib/main.dart`
- Archivo de la página: `app_frontend/lib/pages/pedidos_domiciliario_page.dart`

## Roles requeridos

Para acceder a esta pantalla, el usuario debe tener el rol **"domiciliario"** en el sistema de autenticación del backend.
