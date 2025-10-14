-- Migration: Create Inventory Management Tables
-- Description: Add inventory control, movements tracking, and alerts
-- Date: 2025-10-14

-- ============================================
-- 1. INVENTORY TABLE
-- ============================================
-- Control de stock de productos
CREATE TABLE IF NOT EXISTS inventory (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  min_quantity INTEGER DEFAULT 10 CHECK (min_quantity >= 0),
  max_quantity INTEGER DEFAULT 100 CHECK (max_quantity >= min_quantity),
  unit_cost DECIMAL(10,2) CHECK (unit_cost >= 0),
  last_purchase_date TIMESTAMP,
  last_updated TIMESTAMP DEFAULT NOW(),
  UNIQUE(product_id)
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_inventory_product_id ON inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_quantity ON inventory(quantity);

-- ============================================
-- 2. INVENTORY MOVEMENTS TABLE
-- ============================================
-- Registro de todos los movimientos de inventario
CREATE TABLE IF NOT EXISTS inventory_movements (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  movement_type VARCHAR(20) NOT NULL CHECK (movement_type IN ('entrada', 'salida', 'ajuste', 'merma', 'devolucion')),
  quantity INTEGER NOT NULL CHECK (quantity != 0),
  previous_quantity INTEGER NOT NULL CHECK (previous_quantity >= 0),
  new_quantity INTEGER NOT NULL CHECK (new_quantity >= 0),
  reason VARCHAR(200),
  cost DECIMAL(10,2) CHECK (cost >= 0),
  order_id INTEGER REFERENCES orders(id),
  user_id INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for reporting and tracking
CREATE INDEX IF NOT EXISTS idx_inv_movements_product_id ON inventory_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_inv_movements_created_at ON inventory_movements(created_at);
CREATE INDEX IF NOT EXISTS idx_inv_movements_type ON inventory_movements(movement_type);
CREATE INDEX IF NOT EXISTS idx_inv_movements_order_id ON inventory_movements(order_id);

-- ============================================
-- 3. INVENTORY ALERTS TABLE
-- ============================================
-- Alertas de stock bajo, agotado o exceso
CREATE TABLE IF NOT EXISTS inventory_alerts (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  alert_type VARCHAR(20) NOT NULL CHECK (alert_type IN ('low_stock', 'out_of_stock', 'excess_stock')),
  alert_date TIMESTAMP DEFAULT NOW(),
  resolved BOOLEAN DEFAULT FALSE,
  resolved_date TIMESTAMP,
  resolved_by INTEGER REFERENCES user_admin(id)
);

-- Index for active alerts
CREATE INDEX IF NOT EXISTS idx_inv_alerts_product_id ON inventory_alerts(product_id);
CREATE INDEX IF NOT EXISTS idx_inv_alerts_resolved ON inventory_alerts(resolved) WHERE resolved = FALSE;
CREATE INDEX IF NOT EXISTS idx_inv_alerts_type ON inventory_alerts(alert_type);

-- ============================================
-- 4. FUNCTION: Generate Alerts
-- ============================================
-- Función para generar alertas automáticas cuando el stock cambia
CREATE OR REPLACE FUNCTION check_inventory_alerts()
RETURNS TRIGGER AS $$
BEGIN
  -- Check for low stock
  IF NEW.quantity <= NEW.min_quantity AND NEW.quantity > 0 THEN
    INSERT INTO inventory_alerts (product_id, alert_type)
    VALUES (NEW.product_id, 'low_stock')
    ON CONFLICT DO NOTHING;
  END IF;

  -- Check for out of stock
  IF NEW.quantity = 0 THEN
    INSERT INTO inventory_alerts (product_id, alert_type)
    VALUES (NEW.product_id, 'out_of_stock')
    ON CONFLICT DO NOTHING;
  END IF;

  -- Check for excess stock
  IF NEW.quantity > NEW.max_quantity THEN
    INSERT INTO inventory_alerts (product_id, alert_type)
    VALUES (NEW.product_id, 'excess_stock')
    ON CONFLICT DO NOTHING;
  END IF;

  -- Auto-resolve alerts if stock is now normal
  IF NEW.quantity > NEW.min_quantity AND NEW.quantity <= NEW.max_quantity THEN
    UPDATE inventory_alerts
    SET resolved = TRUE, resolved_date = NOW()
    WHERE product_id = NEW.product_id
      AND resolved = FALSE
      AND alert_type IN ('low_stock', 'out_of_stock', 'excess_stock');
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. TRIGGER: Auto-generate Alerts
-- ============================================
DROP TRIGGER IF EXISTS trigger_inventory_alerts ON inventory;
CREATE TRIGGER trigger_inventory_alerts
AFTER INSERT OR UPDATE OF quantity ON inventory
FOR EACH ROW
EXECUTE FUNCTION check_inventory_alerts();

-- ============================================
-- 6. INITIAL DATA: Create inventory for existing products
-- ============================================
-- Crear registros de inventario para productos existentes (si no existen)
INSERT INTO inventory (product_id, quantity, min_quantity, max_quantity, unit_cost)
SELECT 
  id,
  0,  -- cantidad inicial en 0
  10, -- stock mínimo por defecto
  100, -- stock máximo por defecto
  COALESCE(price * 0.6, 0) -- costo estimado (60% del precio de venta)
FROM products
WHERE id NOT IN (SELECT product_id FROM inventory)
ON CONFLICT (product_id) DO NOTHING;

-- ============================================
-- 7. COMMENTS
-- ============================================
COMMENT ON TABLE inventory IS 'Control de stock de productos';
COMMENT ON TABLE inventory_movements IS 'Historial de movimientos de inventario';
COMMENT ON TABLE inventory_alerts IS 'Alertas de stock bajo/agotado/exceso';
COMMENT ON COLUMN inventory.quantity IS 'Cantidad actual en stock';
COMMENT ON COLUMN inventory.min_quantity IS 'Stock mínimo antes de generar alerta';
COMMENT ON COLUMN inventory.max_quantity IS 'Stock máximo recomendado';
COMMENT ON COLUMN inventory.unit_cost IS 'Costo unitario del producto';
