# Flujo de la Pantalla del Domiciliario

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────────────┐
│                      INICIO DE LA APP                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                   RoleSelectionScreen                            │
│  [Ingresar como Usuario]  [Ingresar como Administrador]        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ clic en Administrador
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      LoginAdminPage                              │
│  Usuario: [_________]                                           │
│  Password: [_________]                                          │
│                    [Ingresar]                                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Autenticación exitosa
                           │ con rol="domiciliario"
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│               PedidosDomiciliarioPage                            │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  "Pedidos listos para entregar"                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Pedido #123                [Marcar como Entregado]    │   │
│  │  Cliente: Juan Pérez                                    │   │
│  │  Teléfono: 3001234567                                  │   │
│  │  Dirección: Calle 123 #45-67  ← DESTACADA             │   │
│  │  Total: $25,000                                         │   │
│  │                                                          │   │
│  │  Productos:                                             │   │
│  │  2x Pizza                                               │   │
│  │  1x Gaseosa                                             │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Pedido #124                [Marcar como Entregado]    │   │
│  │  ...                                                     │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  🔄 Auto-refresh cada 5 segundos                               │
└─────────────────────────┬────────────────────────────────────────┘
                          │ Al presionar "Marcar como Entregado"
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  API Call: PUT /pedidos/:id/entregado-cliente                   │
│  Body: { "changed_by": "domiciliario" }                         │
└──────────────────────────┬──────────────────────────────────────┘
                           │ Respuesta exitosa
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│  ✅ SnackBar: "Pedido marcado como entregado"                  │
│  🔄 Lista se refresca automáticamente                           │
│  📦 El pedido desaparece de la lista (ya no está "listo")      │
└─────────────────────────────────────────────────────────────────┘
```

## Estados del Pedido

```
CLIENTE              CAJERO              COCINERO            DOMICILIARIO
   │                   │                    │                     │
   ▼                   │                    │                     │
┌──────────┐          │                    │                     │
│pendiente │          │                    │                     │
└────┬─────┘          │                    │                     │
     │                ▼                    │                     │
     │         ┌──────────┐               │                     │
     │         │  pagado  │               │                     │
     │         └────┬─────┘               │                     │
     │              │                     ▼                     │
     │              │              ┌──────────┐                │
     │              │              │  listo   │◄───────────────┼─ VE AQUÍ
     │              │              └────┬─────┘                │
     │              │                   │                      ▼
     │              │                   │              ┌──────────────┐
     │              │                   │              │ Marca como   │
     │              │                   │              │ ENTREGADO    │
     │              │                   │              └──────┬───────┘
     │              │                   │                     ▼
     │              │                   │              ┌──────────┐
     │              │                   │              │entregado │
     │              │                   │              └──────────┘
     │              │                   │                     │
     └──────────────┴───────────────────┴─────────────────────┘
```

## Comparación con Otros Roles

| Aspecto            | Cajero              | Cocinero           | Domiciliario       |
|--------------------|---------------------|--------------------|--------------------|
| **Estado visible** | pendiente           | pagado             | listo              |
| **Acción**         | Realizar pago       | Marcar preparado   | Marcar entregado   |
| **Estado final**   | pagado              | listo              | entregado          |
| **Info destacada** | Total a cobrar      | Productos grandes  | Dirección de entrega|
| **Auto-refresh**   | ❌ No               | ✅ 5 segundos      | ✅ 5 segundos      |
| **Endpoint usado** | /pago               | /listo-cocina      | /entregado-cliente |

## Diferencias Clave de la Pantalla del Domiciliario

1. **Dirección destacada en naranja**: Para que sea fácilmente visible
2. **Total en verde y grande**: Para confirmar el monto antes de entregar
3. **Lista de productos**: Para verificar qué va en la entrega
4. **Auto-refresh**: Para ver nuevos pedidos sin intervención manual

## Ejemplo de Datos Mostrados

```dart
{
  "order_id": 123,
  "cliente_nombre": "Juan Pérez",
  "cliente_telefono": "3001234567",
  "direccion_entrega": "Calle 123 #45-67, Apartamento 501",  // ← DESTACADO
  "total": "25000",
  "productos": [
    {
      "nombre": "Pizza Hawaiana",
      "cantidad": 2,
      "price": "12500"
    },
    {
      "nombre": "Gaseosa 1.5L",
      "cantidad": 1,
      "price": "5000"
    }
  ]
}
```

## Interacción del Usuario

```
1. ABRIR APP
   └─> Seleccionar "Ingresar como Administrador"
       └─> Ingresar credenciales (rol: domiciliario)
           └─> Sistema redirige a /domiciliario

2. VER PEDIDOS
   └─> Lista se carga automáticamente (estado: listo)
       └─> Cada 5 segundos se actualiza
           └─> Nuevos pedidos aparecen automáticamente

3. ENTREGAR PEDIDO
   └─> Ver dirección de entrega (destacada)
       └─> Verificar productos
           └─> Confirmar total
               └─> Presionar "Marcar como Entregado"
                   └─> Ver confirmación
                       └─> Pedido desaparece de la lista

4. CONTINUAR
   └─> Esperar nuevos pedidos (auto-refresh)
       └─> Repetir proceso para siguiente pedido
```

## Ventajas del Auto-refresh

- ✅ No necesita refrescar manualmente
- ✅ Ve pedidos nuevos inmediatamente
- ✅ Puede planificar rutas con anticipación
- ✅ Reduce tiempo de espera
- ✅ Mejora eficiencia operativa
