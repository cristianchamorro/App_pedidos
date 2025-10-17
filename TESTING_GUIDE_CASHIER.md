# Guía de Pruebas - Módulo de Caja

## 🧪 Pruebas del Backend

### Pre-requisitos
1. Base de datos PostgreSQL ejecutándose
2. Datos de prueba en las tablas `orders`, `users`, `order_items`, `products`, `status_history`
3. Node.js instalado

### Iniciar el Backend
```bash
cd app_backend
npm install
node server.js
```

Deberías ver:
```
🚀 Servidor corriendo en http://127.0.0.1:3000
```

### Pruebas de Endpoints

#### 1. Estadísticas de Caja
```bash
curl http://localhost:3000/cajero/estadisticas
```

Respuesta esperada:
```json
{
  "success": true,
  "estadisticas": {
    "hoy": {
      "pedidos_hoy": "5",
      "total_hoy": "245.50"
    },
    "semana": {
      "pedidos_semana": "34",
      "total_semana": "1890.75"
    },
    "mes": {
      "pedidos_mes": "123",
      "total_mes": "7234.00"
    },
    "pendientes": {
      "pedidos_pendientes": "3",
      "total_pendiente": "87.50"
    }
  }
}
```

#### 2. Ventas del Día
```bash
curl http://localhost:3000/cajero/ventas/dia
```

Respuesta esperada:
```json
{
  "success": true,
  "resumen": {
    "total_pedidos": "5",
    "total_ventas": "245.50",
    "promedio_venta": "49.10"
  },
  "por_estado": [
    {
      "status": "pagado",
      "cantidad": "3",
      "total": "147.50"
    },
    {
      "status": "pendiente",
      "cantidad": "2",
      "total": "98.00"
    }
  ]
}
```

#### 3. Reporte de Ventas
```bash
curl "http://localhost:3000/cajero/ventas/reporte?fecha_inicio=2024-10-01&fecha_fin=2024-10-17"
```

Respuesta esperada:
```json
{
  "success": true,
  "periodo": {
    "fecha_inicio": "2024-10-01",
    "fecha_fin": "2024-10-17"
  },
  "resumen": {
    "total_pedidos": "67",
    "total_ventas": "2340.00",
    "promedio_venta": "34.93",
    "venta_minima": "12.00",
    "venta_maxima": "89.50"
  },
  "ventas_por_dia": [
    {
      "fecha": "2024-10-17",
      "pedidos": "12",
      "ventas": "450.00"
    },
    ...
  ],
  "productos_mas_vendidos": [
    {
      "id": 1,
      "name": "Pizza Margarita",
      "cantidad_vendida": "45",
      "total_ventas": "675.00"
    },
    ...
  ]
}
```

#### 4. Historial de Pagos
```bash
curl "http://localhost:3000/cajero/pagos/historial?limit=10&offset=0"
```

Respuesta esperada:
```json
{
  "success": true,
  "pagos": [
    {
      "pedido_id": 123,
      "total": "45.00",
      "fecha_pedido": "2024-10-17T14:30:00.000Z",
      "cliente": "Juan Pérez",
      "telefono": "3001234567",
      "fecha_pago": "2024-10-17T14:35:00.000Z",
      "cajero_id": 1
    },
    ...
  ],
  "total": 150,
  "limit": 10,
  "offset": 0
}
```

### Casos de Prueba Backend

| Test Case | Endpoint | Parámetros | Resultado Esperado | Status |
|-----------|----------|------------|-------------------|--------|
| TC-B01 | `/cajero/estadisticas` | Ninguno | Estadísticas de hoy/semana/mes | ⏳ |
| TC-B02 | `/cajero/ventas/dia` | Ninguno | Ventas del día actual | ⏳ |
| TC-B03 | `/cajero/ventas/reporte` | fecha_inicio, fecha_fin | Reporte completo | ⏳ |
| TC-B04 | `/cajero/ventas/reporte` | Fechas inválidas | Error 400 | ⏳ |
| TC-B05 | `/cajero/pagos/historial` | limit=50, offset=0 | Lista de 50 pagos | ⏳ |
| TC-B06 | `/cajero/pagos/historial` | limit=100 | Máximo 100 registros | ⏳ |

## 📱 Pruebas del Frontend

### Pre-requisitos
1. Backend ejecutándose en http://localhost:3000 o http://192.168.101.6:3000
2. Flutter SDK instalado
3. Emulador Android/iOS o dispositivo físico

### Configurar y Ejecutar
```bash
cd app_frontend
flutter pub get
flutter run
```

### Pruebas Manuales

#### A. Pantalla de Pago Mejorada

##### TC-F01: Pago en Efectivo
1. Navegar a "Pedidos Pendientes"
2. Seleccionar un pedido
3. Presionar "Realizar Pago"
4. Verificar que se muestra el total correcto
5. Seleccionar "Efectivo"
6. Ingresar monto menor al total
   - ✅ Debe mostrar error "El monto ingresado es menor al total"
7. Ingresar monto igual o mayor al total
   - ✅ Debe calcular vuelto automáticamente
8. Presionar "Confirmar Pago"
   - ✅ Debe mostrar recibo digital con todos los datos
   - ✅ Debe incluir: pedido, total, método, efectivo, vuelto
9. Cerrar recibo
   - ✅ Debe regresar a lista de pedidos
   - ✅ El pedido debe desaparecer de pendientes

##### TC-F02: Pago con Tarjeta
1. Navegar a "Pedidos Pendientes"
2. Seleccionar un pedido
3. Presionar "Realizar Pago"
4. Seleccionar "Tarjeta Débito" o "Tarjeta Crédito"
   - ✅ Campo de efectivo debe ocultarse
   - ✅ Vuelto debe ocultarse
5. Presionar "Confirmar Pago"
   - ✅ Debe mostrar recibo sin campos de efectivo/vuelto
   - ✅ Debe confirmar pago exitoso

##### TC-F03: Pago con Transferencia
1. Navegar a "Pedidos Pendientes"
2. Seleccionar un pedido
3. Presionar "Realizar Pago"
4. Seleccionar "Transferencia/QR"
   - ✅ Campo de efectivo debe ocultarse
5. Presionar "Confirmar Pago"
   - ✅ Debe procesar pago correctamente

#### B. Dashboard de Caja

##### TC-F04: Estadísticas Generales
1. Desde "Pedidos Pendientes", presionar ícono 📊
2. Verificar que se cargan las estadísticas
   - ✅ Card "Hoy" muestra pedidos y total del día
   - ✅ Card "Semana" muestra datos de la semana
   - ✅ Card "Mes" muestra datos del mes
   - ✅ Card "Pendientes" muestra pedidos por pagar
3. Presionar botón de refresh (🔄)
   - ✅ Debe recargar datos
   - ✅ Debe mostrar indicador de carga

##### TC-F05: Ventas del Día
1. En Dashboard, verificar pestaña "Ventas del Día" activa
2. Verificar información mostrada:
   - ✅ Total de pedidos del día
   - ✅ Total vendido
   - ✅ Promedio por venta
   - ✅ Desglose por estado con iconos
3. Verificar que los montos son consistentes con las cards superiores

##### TC-F06: Historial de Pagos
1. En Dashboard, presionar pestaña "Historial"
2. Presionar "Ver Historial Completo"
   - ✅ Debe abrir modal deslizable
   - ✅ Debe mostrar lista de pagos
   - ✅ Cada item debe mostrar: pedido, cliente, teléfono, fecha, total
3. Scroll en la lista
   - ✅ Debe permitir scroll suave
4. Presionar X para cerrar
   - ✅ Debe cerrar modal correctamente

##### TC-F07: Reporte Semanal
1. En Dashboard, presionar pestaña "Reportes"
2. Presionar "Reporte Semanal"
   - ✅ Debe mostrar indicador de carga
   - ✅ Debe abrir diálogo con reporte
3. Verificar contenido del reporte:
   - ✅ Período (últimos 7 días)
   - ✅ Resumen (pedidos, ventas, promedio, min, max)
   - ✅ Top 5 productos más vendidos
4. Presionar "Cerrar"
   - ✅ Debe cerrar diálogo

##### TC-F08: Reporte Mensual
1. En Dashboard, presionar "Reporte Mensual"
   - ✅ Debe generar reporte del mes actual
   - ✅ Formato similar a reporte semanal

##### TC-F09: Reporte Personalizado
1. En Dashboard, presionar "Reporte Personalizado"
2. Debe abrir selector de rango de fechas
   - ✅ Debe permitir seleccionar fecha inicio
   - ✅ Debe permitir seleccionar fecha fin
3. Seleccionar rango y confirmar
   - ✅ Debe generar reporte para ese período
4. Cancelar selección
   - ✅ No debe generar reporte

##### TC-F10: Manejo de Errores
1. Detener backend
2. Intentar cargar Dashboard
   - ✅ Debe mostrar mensaje de error
   - ✅ No debe crashear la app
3. Intentar generar reporte
   - ✅ Debe mostrar Snackbar con error de conexión
4. Reiniciar backend y presionar refresh
   - ✅ Debe recuperarse y cargar datos

#### C. Navegación e Integración

##### TC-F11: Navegación desde Pedidos Pendientes
1. Abrir "Pedidos Pendientes"
2. Verificar ícono 📊 en AppBar
   - ✅ Debe ser visible
   - ✅ Debe tener tooltip "Módulo de Caja"
3. Presionar ícono
   - ✅ Debe navegar al Dashboard
4. Presionar ← para volver
   - ✅ Debe regresar a Pedidos Pendientes

##### TC-F12: Flujo Completo de Pago
1. Iniciar en "Pedidos Pendientes"
2. Seleccionar pedido #123 (ejemplo)
3. Ver detalle del pedido
4. Presionar "Realizar Pago" desde detalle
5. Seleccionar método de pago
6. Confirmar pago
7. Verificar recibo
8. Cerrar y verificar que regresa a pedidos
9. Ir al Dashboard
10. Ver que el pedido aparece en historial
11. Verificar que estadísticas se actualizaron

## 📊 Matriz de Pruebas

### Pantalla de Pago
| ID | Descripción | Entrada | Salida Esperada | Status |
|----|-------------|---------|-----------------|--------|
| TC-F01.1 | Efectivo insuficiente | $40 para total $50 | Error | ⏳ |
| TC-F01.2 | Efectivo exacto | $50 para total $50 | Vuelto $0 | ⏳ |
| TC-F01.3 | Efectivo con vuelto | $60 para total $50 | Vuelto $10 | ⏳ |
| TC-F02.1 | Tarjeta débito | Seleccionar débito | Campo efectivo oculto | ⏳ |
| TC-F02.2 | Tarjeta crédito | Seleccionar crédito | Campo efectivo oculto | ⏳ |
| TC-F03.1 | Transferencia | Seleccionar transfer | Campo efectivo oculto | ⏳ |

### Dashboard
| ID | Descripción | Precondición | Resultado Esperado | Status |
|----|-------------|--------------|-------------------|--------|
| TC-F04.1 | Cargar estadísticas | Backend activo | 4 cards con datos | ⏳ |
| TC-F04.2 | Refresh estadísticas | Dashboard abierto | Datos actualizados | ⏳ |
| TC-F05.1 | Ver ventas día | Pestaña activa | Resumen completo | ⏳ |
| TC-F06.1 | Historial completo | Presionar botón | Modal con lista | ⏳ |
| TC-F07.1 | Reporte semanal | Seleccionar opción | Diálogo con datos | ⏳ |
| TC-F08.1 | Reporte mensual | Seleccionar opción | Diálogo con datos | ⏳ |
| TC-F09.1 | Reporte custom | Seleccionar fechas | Diálogo con datos | ⏳ |
| TC-F10.1 | Sin conexión | Backend apagado | Mensaje error | ⏳ |

## 🔍 Pruebas de Regresión

Verificar que las funcionalidades existentes siguen funcionando:

1. ✅ Confirmar pedido desde confirmar_pedido_page
2. ✅ Listar pedidos pendientes
3. ✅ Ver detalle de pedido
4. ✅ Estados de pedido (pendiente → pagado → preparando)
5. ✅ Otras pantallas (cocinero, domiciliario, admin)

## 📝 Checklist de Validación

### Funcional
- [ ] Todos los métodos de pago funcionan correctamente
- [ ] Cálculo de vuelto es preciso
- [ ] Estadísticas se calculan correctamente
- [ ] Reportes muestran datos correctos
- [ ] Historial pagina correctamente
- [ ] Filtros de fecha funcionan
- [ ] Navegación es fluida

### UI/UX
- [ ] Diseño es consistente con el resto de la app
- [ ] Botones tienen tamaño táctil adecuado
- [ ] Texto es legible en todos los tamaños de pantalla
- [ ] Colores siguen la paleta definida
- [ ] Iconos son descriptivos
- [ ] Loading states son claros
- [ ] Mensajes de error son informativos

### Performance
- [ ] Carga de estadísticas < 2s
- [ ] Generación de reportes < 3s
- [ ] Historial carga rápido (< 1s)
- [ ] No hay memory leaks
- [ ] Scroll es fluido

### Seguridad
- [ ] SQL injection protegido (prepared statements)
- [ ] Validación de entrada en frontend
- [ ] Validación de entrada en backend
- [ ] Manejo de errores no expone información sensible

## 🐛 Reporte de Bugs

Si encuentras bugs, reporta con el siguiente formato:

```
**ID**: BUG-XXX
**Título**: [Breve descripción]
**Severidad**: Alta / Media / Baja
**Pasos para Reproducir**:
1. Paso 1
2. Paso 2
3. ...

**Resultado Esperado**: [Qué debería pasar]
**Resultado Actual**: [Qué pasó]
**Capturas**: [Si aplica]
**Logs**: [Errores en consola]
**Ambiente**: 
- OS: 
- Dispositivo:
- Versión App:
```

## ✅ Criterios de Aceptación

Para considerar el módulo listo para producción:

1. ✅ Todos los tests funcionales pasan
2. ✅ UI cumple con mockups
3. ✅ Performance es aceptable
4. ✅ No hay bugs críticos
5. ✅ Documentación está completa
6. ✅ Backend endpoints funcionan correctamente
7. ✅ Manejo de errores es robusto
8. ✅ Datos se muestran correctamente formateados
