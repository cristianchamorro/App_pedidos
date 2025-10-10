# SQL Query Changes

## Driver Assignment Query

### Before (Non-Atomic)
```sql
-- Simple SELECT - no locking, no status update
SELECT id
FROM drivers
WHERE status='available'
ORDER BY location <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
LIMIT 1
```

**Problem**: 
- Race condition: Multiple concurrent requests could SELECT the same driver
- Driver status remains 'available' until order is fully created
- No atomicity between selection and assignment

### After (Atomic)
```sql
-- CTE with row-level locking and immediate status update
WITH candidato AS (
  SELECT id
  FROM drivers
  WHERE status='available'
  ORDER BY location <-> ST_SetSRID(ST_MakePoint($1, $2), 4326)
  LIMIT 1
  FOR UPDATE SKIP LOCKED  -- Row-level lock, skip if already locked
)
UPDATE drivers d
SET status='busy', updated_at=NOW()
FROM candidato c
WHERE d.id=c.id
RETURNING d.id
```

**Benefits**:
- ✅ Atomic operation: SELECT + UPDATE in one query
- ✅ Row-level locking prevents concurrent access to same driver
- ✅ `SKIP LOCKED` makes concurrent transactions skip locked rows
- ✅ Status changes immediately within transaction
- ✅ Returns driver_id or empty result if none available

## Driver Release Query

### New Query (Automatic Release)
```sql
-- Release driver when order is completed/canceled
UPDATE drivers 
SET status='available', updated_at=NOW() 
WHERE id=(SELECT driver_id FROM orders WHERE id=$1)
```

**Usage**:
- Called automatically after order status changes to 'entregado'
- Called automatically after order status changes to 'cancelado'
- Uses subquery to find driver_id from order_id

## Concurrency Scenario Example

### Scenario: 2 Requests Arrive Simultaneously, 1 Driver Available

#### With Old Code (Race Condition):
```
Time  | Transaction A              | Transaction B              | Driver Status
------|----------------------------|----------------------------|---------------
t0    | BEGIN                      | BEGIN                      | available
t1    | SELECT id (gets driver 1)  | SELECT id (gets driver 1)  | available
t2    | INSERT order with driver 1 | INSERT order with driver 1 | available
t3    | COMMIT                     | COMMIT                     | available
      | ❌ Both orders assigned    | ❌ to same driver!         | ❌ Still available!
```

#### With New Code (Atomic):
```
Time  | Transaction A              | Transaction B              | Driver Status
------|----------------------------|----------------------------|---------------
t0    | BEGIN                      | BEGIN                      | available
t1    | WITH + FOR UPDATE (lock)   | WITH + FOR UPDATE (wait)   | available
t2    | UPDATE status='busy'       | (waiting for lock...)      | available → busy
t3    | RETURNING driver 1         | (still waiting...)         | busy
t4    | INSERT order with driver 1 | (still waiting...)         | busy
t5    | COMMIT (releases lock)     | (lock released, retry)     | busy
t6    |                            | WITH + FOR UPDATE SKIP     | busy
t7    |                            | (no available drivers!)    | busy
t8    |                            | ROLLBACK                   | busy
      | ✅ Order A succeeds        | ✅ Order B fails safely    | ✅ Correct status
```

## Transaction Flow

### Order Creation Flow
```
BEGIN TRANSACTION
  ├─ Find/Create User
  ├─ Atomic Driver Selection + Update to 'busy'  ← NEW: Atomic operation
  │  └─ If no driver available: ROLLBACK
  ├─ Insert Order with driver_id
  ├─ Insert Order Items
  └─ Insert Status History
COMMIT TRANSACTION

If transaction fails → All changes rollback (including driver status)
```

### Order Completion Flow
```
BEGIN TRANSACTION (status change)
  ├─ UPDATE orders SET status='entregado'
  └─ INSERT status_history
COMMIT TRANSACTION

After successful commit:
  ├─ NEW: UPDATE drivers SET status='available'  ← Separate transaction
  └─ (Logged if fails, doesn't affect order status)
```

## Performance Considerations

### Row-Level Locking Impact
- `FOR UPDATE SKIP LOCKED` is efficient - no waiting for locked rows
- Contention is minimal: each transaction processes different drivers
- Failed requests return immediately with clear error message

### Index Requirements
For optimal performance, ensure indexes exist on:
```sql
-- Spatial index on location (should already exist for PostGIS)
CREATE INDEX idx_drivers_location ON drivers USING GIST(location);

-- Composite index for available driver lookups
CREATE INDEX idx_drivers_status_location ON drivers(status, location) 
WHERE status='available';

-- Index for driver status updates
CREATE INDEX idx_drivers_status ON drivers(status);

-- Index for order-driver relationship
CREATE INDEX idx_orders_driver_id ON orders(driver_id);
```

## Database Requirements

- PostgreSQL 9.5+ (for `FOR UPDATE SKIP LOCKED`)
- PostGIS extension (for spatial queries)
- Tables must have columns:
  - `drivers.status` (text/varchar)
  - `drivers.updated_at` (timestamp)
  - `drivers.location` (geometry/geography)
  - `orders.driver_id` (integer/bigint)
