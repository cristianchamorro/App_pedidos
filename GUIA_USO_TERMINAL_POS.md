# 🖥️ Guía de Uso - Terminal POS Integrado

## 📋 Resumen

El **Terminal POS** está completamente integrado con el sistema existente de pedidos. Ahora crea pedidos reales que pasan por todo el flujo del sistema: desde la creación hasta la cocina y entrega.

---

## ✅ ¿Qué Hace el Terminal POS?

El Terminal POS es una **interfaz táctil para cajeros** que permite:

1. **Capturar pedidos presenciales** (cuando el cliente no usa la app)
2. **Tomar pedidos de mesas** (en restaurantes con servicio a mesa)
3. **Procesar pagos inmediatos**
4. **Enviar pedidos automáticamente a cocina**

---

## 🔄 Flujo Completo del Sistema

### Flujo 1: Pedido Directo en Terminal POS

**Caso de Uso:** Cliente llega al mostrador sin haber usado la app

```
┌────────────────────────────────────────┐
│ 1. CAJERO                              │
│    - Abre "Terminal POS" desde menú    │
│    - Busca/filtra productos            │
│    - Agrega al carrito                 │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 2. PROCESAR PAGO                       │
│    - Selecciona método (efectivo/card) │
│    - Ingresa monto (si es efectivo)    │
│    - Sistema calcula cambio            │
│    - Presiona "COBRAR"                 │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 3. SISTEMA CREA PEDIDO                 │
│    - POST /pedidos (estado: pendiente) │
│    - Retorna order_id                  │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 4. SISTEMA CONFIRMA PAGO               │
│    - PUT /pedidos/{id}/pago            │
│    - Estado: pendiente → preparando    │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 5. COCINA RECIBE PEDIDO                │
│    - Aparece en "Pedidos Cocinero"     │
│    - Cocinero ve productos y cantidad  │
│    - Cocinero prepara pedido           │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 6. PEDIDO LISTO                        │
│    - Cocinero marca "Listo"            │
│    - Aparece en "Pedidos Listos"       │
│    - Cajero entrega al cliente         │
└────────────────────────────────────────┘
```

### Flujo 2: Pedido con Gestión de Mesas

**Caso de Uso:** Cliente se sienta en una mesa del restaurante

```
┌────────────────────────────────────────┐
│ 1. CAJERO - GESTIÓN DE MESAS          │
│    - Abre "Gestión de Mesas"           │
│    - Ve mesas con estado:              │
│      🟢 Libre                          │
│      🟠 Ocupada                        │
│      🔴 Por Pagar                      │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 2. ABRIR MESA                          │
│    - Toca mesa LIBRE (verde)           │
│    - Presiona "Abrir Mesa"             │
│    - Se abre Terminal POS              │
│    - Título: "Pedido - Mesa X"         │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 3. TOMAR PEDIDO                        │
│    - Agrega productos al carrito       │
│    - Procesa pago                      │
│    - Sistema crea pedido con:          │
│      * nombre: "Mesa X"                │
│      * dirección: "Para consumir..."   │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 4. MESA CAMBIA A OCUPADA               │
│    - Mesa: 🟢 Libre → 🟠 Ocupada       │
│    - Muestra # de orden                │
│    - Muestra total acumulado           │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 5. COCINA PREPARA                      │
│    - Pedido en pantalla de cocina      │
│    - Cocinero prepara                  │
│    - Marca "Listo"                     │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 6. ENTREGA                             │
│    - Mesero entrega a mesa             │
│    - Cliente consume                   │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 7. SOLICITAR CUENTA                    │
│    - Cajero: toca mesa OCUPADA         │
│    - Presiona "Solicitar Cuenta"       │
│    - Mesa: 🟠 Ocupada → 🔴 Por Pagar   │
└────────────────┬───────────────────────┘
                 │
                 ↓
┌────────────────────────────────────────┐
│ 8. COBRAR                              │
│    - Cajero: toca mesa POR PAGAR       │
│    - Presiona "Cobrar"                 │
│    - Procesa pago final                │
│    - Mesa: 🔴 Por Pagar → 🟢 Libre     │
└────────────────────────────────────────┘
```

---

## 🎯 Casos de Uso

### Caso 1: Comida Rápida (Sin Mesas)

**Cliente llega al mostrador:**

1. Cajero abre **Terminal POS** (botón 🖥️)
2. Agrega productos al carrito
3. Cliente paga
4. Cajero procesa pago en POS
5. Sistema crea pedido y lo envía a cocina
6. Cocinero prepara
7. Cajero entrega cuando está listo

**Ventajas:**
- ✅ Rápido y eficiente
- ✅ Sin usar mesas
- ✅ Pedido va directo a cocina

### Caso 2: Restaurante con Mesas

**Cliente se sienta en mesa:**

1. Cajero abre **Gestión de Mesas** (botón 🍽️)
2. Selecciona mesa LIBRE
3. Presiona "Abrir Mesa"
4. Se abre Terminal POS con nombre de mesa
5. Toma pedido del cliente
6. Procesa pago
7. Mesa cambia a OCUPADA
8. Pedido va a cocina
9. Mesero entrega cuando está listo
10. Cliente pide cuenta
11. Cajero marca "Solicitar Cuenta"
12. Cajero cobra y libera mesa

**Ventajas:**
- ✅ Control visual de mesas
- ✅ Seguimiento de pedidos por mesa
- ✅ No se pierden órdenes
- ✅ Flujo organizado

### Caso 3: Pedido desde App (Existente)

**Cliente usa la app móvil:**

1. Cliente abre app
2. Selecciona productos
3. Confirma pedido
4. Pedido llega como "Pendiente"
5. Cajero ve en "Pedidos Pendientes"
6. Cajero procesa pago
7. Pedido va a cocina
8. Flujo normal continúa

**Ventajas:**
- ✅ Cliente ordena desde casa
- ✅ Menos tiempo en local
- ✅ Mismo flujo después del pago

---

## 🔍 Detalles Técnicos

### Estados del Pedido

```
pendiente → pagado → preparando → listo → entregado
   (app)    (cajero)  (automático) (cocina) (domicilio)
```

**Explicación:**
- `pendiente`: Pedido creado, esperando pago
- `pagado`: Pago confirmado por cajero
- `preparando`: Enviado automáticamente a cocina
- `listo`: Cocinero terminó de preparar
- `entregado`: Entregado al cliente

### API Endpoints Usados

**1. Crear Pedido:**
```http
POST /pedidos
Content-Type: application/json

{
  "nombre": "Mesa 5" | "Pedido POS",
  "telefono": "0000000000",
  "direccion_entrega": "Para consumir en Mesa 5",
  "ubicacion": {"lat": 0.0, "lng": 0.0},
  "productos": [
    {"id": 1, "nombre": "Hamburguesa", "cantidad": 2, "price": 15000, ...}
  ]
}

Response: {"success": true, "order_id": 42}
```

**2. Confirmar Pago:**
```http
PUT /pedidos/42/pago
Content-Type: application/json

{
  "efectivo": 30000,
  "changed_by": 1
}

Response: {"success": true}
```

**Efecto:** El pedido pasa de `pendiente` → `pagado` → `preparando` automáticamente

### Datos del Pedido

**Para pedidos de Terminal POS sin mesa:**
- `nombre`: "Pedido POS"
- `telefono`: "0000000000"
- `direccion_entrega`: "Pedido en local"

**Para pedidos de mesa:**
- `nombre`: "Mesa 5"
- `telefono`: "0000000000"
- `direccion_entrega`: "Para consumir en Mesa 5"

Esto permite diferenciar pedidos en reportes y estadísticas.

---

## 🎨 Interfaz del Terminal POS

### Layout Split-Screen

```
┌─────────────────────────────────────────────────────┐
│                Terminal POS                         │
├──────────────────────────────┬──────────────────────┤
│  PRODUCTOS (70%)             │  CARRITO (30%)       │
│                              │                      │
│  🔍 [Buscar productos...]    │  🛒 Carrito         │
│                              │                      │
│  [Todos] [Comida] [Bebida]  │  - Hamburguesa  x2   │
│                              │    $30,000           │
│  ┌──────┐ ┌──────┐ ┌──────┐ │                      │
│  │ 🍔   │ │ 🍕   │ │ 🌮   │ │  - Coca Cola    x1   │
│  │$15k  │ │$20k  │ │$10k  │ │    $5,000            │
│  └──────┘ └──────┘ └──────┘ │                      │
│                              │  ──────────────────  │
│  ┌──────┐ ┌──────┐ ┌──────┐ │  TOTAL: $35,000     │
│  │ 🥤   │ │ 🍟   │ │ 🧃   │ │                      │
│  │$5k   │ │$8k   │ │$3k   │ │  💵 [Efectivo]      │
│  └──────┘ └──────┘ └──────┘ │  💳 [Tarjeta]       │
│                              │  📱 [QR]            │
│  (más productos...)          │                      │
│                              │  [    COBRAR    ]   │
└──────────────────────────────┴──────────────────────┘
```

### Métodos de Pago

**1. Efectivo:**
- Botón abre teclado numérico
- Cajero ingresa monto recibido
- Sistema calcula cambio automáticamente
- Muestra cambio en grande y verde

**2. Tarjeta:**
- Selecciona con un clic
- Monto = Total (sin ingreso manual)
- Procesa directamente

**3. QR Code:**
- Preparado para integración futura
- Interface lista

### Teclado Numérico (Efectivo)

```
┌─────────────────────────┐
│  Monto: $35,000         │
├─────────────────────────┤
│  [7]  [8]  [9]          │
│  [4]  [5]  [6]          │
│  [1]  [2]  [3]          │
│  [C]  [0]  [⌫]          │
│  [      OK      ]       │
└─────────────────────────┘
```

**Controles:**
- `0-9`: Ingresar dígitos
- `C`: Limpiar todo
- `⌫`: Borrar último dígito
- `OK`: Confirmar monto

---

## 📱 Navegación

### Desde "Pedidos Pendientes" (Cajero)

```
┌─────────────────────────────────────────────┐
│  [←] Pedidos Pendientes  [🍽️][🖥️][📊][📋]  │
└─────────────────────────────────────────────┘
```

**Botones:**
- 🍽️ **Gestión de Mesas** → Ver/gestionar mesas del restaurante
- 🖥️ **Terminal POS** → Tomar pedido directo (sin mesa)
- 📊 **Dashboard Mejorado** → Gráficos y análisis
- 📋 **Dashboard Original** → Vista estándar

### Flujo de Navegación

```
Pedidos Cajero
    │
    ├─→ Gestión Mesas
    │     └─→ Abrir Mesa → Terminal POS (con mesa)
    │
    └─→ Terminal POS (sin mesa)
```

---

## ✅ Validación del Flujo

### Checklist para Cajero

**Al usar Terminal POS:**
- [ ] ¿Se agregaron productos al carrito?
- [ ] ¿Se seleccionó método de pago?
- [ ] ¿Se ingresó monto correcto (efectivo)?
- [ ] ¿Aparece el cambio (si aplica)?
- [ ] ¿Se presionó "COBRAR"?
- [ ] ¿Apareció mensaje "Pedido #X creado y enviado a cocina"?

**Después de crear pedido:**
- [ ] ¿El pedido tiene un número de orden?
- [ ] ¿El pedido aparece en pantalla de cocina?
- [ ] ¿El cocinero puede ver los productos?
- [ ] ¿La mesa cambió a "Ocupada" (si aplica)?

### Checklist para Cocinero

**Al recibir pedido:**
- [ ] ¿Aparece el pedido en "Pedidos Cocinero"?
- [ ] ¿Se ven todos los productos correctos?
- [ ] ¿Se ven las cantidades correctas?
- [ ] ¿Puedo marcar como "Listo" después de preparar?

---

## 🐛 Solución de Problemas

### Problema: "No aparece el pedido en cocina"

**Causa:** El pedido no pasó a estado "preparando"

**Solución:**
1. Verificar que se completó el pago
2. Verificar que no hubo error de red
3. Revisar en "Pedidos Pendientes" si quedó atorado

### Problema: "Mesa no cambia de estado"

**Causa:** Error al crear pedido desde mesa

**Solución:**
1. Verificar conexión a internet
2. Intentar nuevamente "Abrir Mesa"
3. Verificar que Terminal POS se abrió correctamente

### Problema: "No se puede procesar pago"

**Causa:** Monto insuficiente o carrito vacío

**Solución:**
1. Verificar que el carrito tenga productos
2. Si es efectivo, verificar que monto >= total
3. Verificar que se seleccionó método de pago

---

## 📊 Reportes y Estadísticas

### Dashboard de Cajero

Los pedidos creados desde Terminal POS se incluyen en:

- ✅ Total de ventas del día
- ✅ Número de pedidos
- ✅ Ticket promedio
- ✅ Gráfico de tendencias
- ✅ Distribución por estado

### Identificación en Reportes

**Pedidos POS sin mesa:**
- Nombre: "Pedido POS"
- Dirección: "Pedido en local"

**Pedidos POS con mesa:**
- Nombre: "Mesa X"
- Dirección: "Para consumir en Mesa X"

Esto permite filtrar y analizar:
- Ventas en local vs domicilio
- Ventas por mesa
- Productos más pedidos en local

---

## 🎓 Tips y Mejores Prácticas

### Para Cajeros

1. **Usa búsqueda:** Es más rápido que scrollear
2. **Usa filtros de categoría:** Agrupa productos similares
3. **Verifica el cambio:** Antes de confirmar
4. **Mesas ocupadas:** Siempre solicita cuenta antes de cobrar
5. **Pedidos grandes:** Revisa el carrito antes de cobrar

### Para Gerentes

1. **Revisa el dashboard:** Identifica horarios pico
2. **Analiza por mesa:** Ve qué mesas son más rentables
3. **Compara local vs domicilio:** Optimiza recursos
4. **Capacita al personal:** En uso de Terminal POS
5. **Monitorea cocina:** Asegura que no se atoren pedidos

---

## 🚀 Próximas Mejoras

### En Desarrollo

- [ ] Impresión de tickets (biblioteca ya instalada)
- [ ] Códigos QR para pago (biblioteca ya instalada)
- [ ] División de cuenta entre comensales
- [ ] Integración con hardware POS
- [ ] Modo offline con sincronización

### Sugerencias Bienvenidas

Si tienes ideas para mejorar el Terminal POS, contáctanos.

---

## 📞 Soporte

**Documentación Relacionada:**
- [SISTEMA_POS_COMPLETO.md](./SISTEMA_POS_COMPLETO.md) - Documentación técnica completa
- [DOCUMENTACION_COMPLETA_SISTEMA.md](./DOCUMENTACION_COMPLETA_SISTEMA.md) - Sistema completo
- [GUIA_RAPIDA_API.md](./GUIA_RAPIDA_API.md) - API Reference

**Repositorio:** https://github.com/cristianchamorro/App_pedidos

---

**Última actualización:** 2024  
**Versión:** 2.1.0-POS-Integrado  
**Estado:** 🟢 Operacional y Probado
