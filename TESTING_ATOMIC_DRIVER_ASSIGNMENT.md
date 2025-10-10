# Testing Atomic Driver Assignment

This document describes how to test the atomic driver assignment and automatic release functionality.

## Changes Made

1. **Atomic Driver Reservation** - In `crearPedido`, drivers are now atomically reserved using:
   - CTE (Common Table Expression) with `FOR UPDATE SKIP LOCKED`
   - Immediate status change to 'busy' within the transaction
   - Prevents concurrent orders from assigning the same driver

2. **Automatic Driver Release** - Drivers are automatically released (status -> 'available') when:
   - An order is marked as delivered (`marcarEntregado`, `marcarEntregadoCliente`)
   - An order is canceled (`cancelarPedido`)

## Prerequisites

- PostgreSQL running with the `Bd_App` database
- At least one driver with:
  - `status='available'`
  - Valid `location` (PostGIS geometry point)
- Database should have PostGIS extension enabled

## Test Cases

### Test 1: Single Order - Driver Assignment and Release

1. **Setup**: Ensure you have at least one available driver:
   ```sql
   SELECT id, status FROM drivers WHERE status='available';
   ```

2. **Create Order**: POST to `/pedidos`
   ```json
   {
     "nombre": "Test User",
     "telefono": "1234567890",
     "direccion_entrega": "Test Address",
     "productos": [{"id": 1, "price": 10.00, "cantidad": 1}],
     "ubicacion": {"lng": -74.0060, "lat": 40.7128}
   }
   ```

3. **Verify Driver is Busy**:
   ```sql
   SELECT d.id, d.status, o.id as order_id
   FROM drivers d
   JOIN orders o ON o.driver_id = d.id
   WHERE o.id = <order_id>;
   -- Expected: status='busy'
   ```

4. **Mark Order as Delivered**: PUT to `/pedidos/<order_id>/entregar`
   ```json
   {
     "changed_by": "driver"
   }
   ```

5. **Verify Driver is Available Again**:
   ```sql
   SELECT id, status FROM drivers WHERE id = <driver_id>;
   -- Expected: status='available'
   ```

### Test 2: Concurrent Orders - No Double Assignment

This test verifies that under concurrent load, the same driver is NOT assigned to multiple orders.

1. **Setup**: Ensure you have exactly one available driver

2. **Send Multiple Concurrent Requests**: Use a tool like Apache Bench or custom script:
   ```bash
   # Example with curl (run simultaneously in different terminals)
   for i in {1..5}; do
     curl -X POST http://localhost:3000/pedidos \
       -H "Content-Type: application/json" \
       -d '{"nombre":"User'$i'","telefono":"123456789'$i'","direccion_entrega":"Addr","productos":[{"id":1,"price":10,"cantidad":1}],"ubicacion":{"lng":-74.006,"lat":40.7128}}' &
   done
   wait
   ```

3. **Verify**: Only one order should succeed with driver assignment, others should fail with "No hay drivers disponibles"
   ```sql
   SELECT COUNT(*) FROM orders WHERE driver_id = <driver_id> AND status='pendiente';
   -- Expected: 1
   ```

### Test 3: Cancel Order - Driver Release

1. **Create Order** (as in Test 1)

2. **Verify Driver is Busy** (as in Test 1, step 3)

3. **Cancel Order**: PUT to `/pedidos/<order_id>/cancelar`
   ```json
   {
     "changed_by": "admin"
   }
   ```

4. **Verify Driver is Available Again**:
   ```sql
   SELECT id, status FROM drivers WHERE id = <driver_id>;
   -- Expected: status='available'
   ```

### Test 4: Client Delivery Endpoint

1. **Create Order** (as in Test 1)

2. **Mark as Delivered via Client Endpoint**: PUT to `/pedidos/<order_id>/entregado-cliente`
   ```json
   {
     "changed_by": "client"
   }
   ```

3. **Verify Driver is Available Again**:
   ```sql
   SELECT id, status FROM drivers WHERE id = <driver_id>;
   -- Expected: status='available'
   ```

## SQL Queries for Verification

### Check Driver Status History
```sql
SELECT 
  o.id as order_id,
  o.status as order_status,
  o.driver_id,
  d.status as driver_status,
  o.created_at
FROM orders o
LEFT JOIN drivers d ON d.id = o.driver_id
ORDER BY o.created_at DESC
LIMIT 10;
```

### Check for Double Assignments (should return empty)
```sql
SELECT driver_id, COUNT(*) as order_count
FROM orders
WHERE status IN ('pendiente', 'preparando', 'listo')
GROUP BY driver_id
HAVING COUNT(*) > 1;
```

## Expected Behavior

### Atomic Reservation (crearPedido)
- ✅ Driver status changes to 'busy' immediately in the same transaction
- ✅ If transaction rolls back, driver status change also rolls back
- ✅ `FOR UPDATE SKIP LOCKED` ensures no two transactions lock the same driver
- ✅ Returns "No hay drivers disponibles" if no driver is available

### Automatic Release
- ✅ Driver status changes to 'available' after order is delivered
- ✅ Driver status changes to 'available' after order is canceled
- ✅ If driver release fails, the order status change still succeeds (logged error)
- ✅ Works for both `marcarEntregado` and `marcarEntregadoCliente` endpoints

## Troubleshooting

### Issue: "No hay drivers disponibles" but drivers exist
- Check if drivers have valid locations: `SELECT id, location FROM drivers WHERE location IS NOT NULL;`
- Check PostGIS is installed: `SELECT PostGIS_version();`
- Verify driver status: `SELECT id, status FROM drivers;`

### Issue: Driver not released after delivery
- Check logs for "Error al liberar driver" messages
- Verify `updated_at` column exists on drivers table
- Check if order has a valid `driver_id`: `SELECT id, driver_id FROM orders WHERE id = <order_id>;`
