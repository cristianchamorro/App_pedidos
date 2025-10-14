-- Migration: Enhance Vendors/Suppliers Management
-- Description: Add more fields to vendors and create purchase orders
-- Date: 2025-10-14

-- ============================================
-- 1. ENHANCE VENDORS TABLE
-- ============================================
-- Add more information to vendors
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS contact_person VARCHAR(100);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS phone VARCHAR(20);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS email VARCHAR(100);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50);
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(50) DEFAULT 'contado';
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT NOW();
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS notes TEXT;

-- Index for active vendors
CREATE INDEX IF NOT EXISTS idx_vendors_active ON vendors(active);

-- ============================================
-- 2. PURCHASE ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS purchase_orders (
  id SERIAL PRIMARY KEY,
  vendor_id INTEGER NOT NULL REFERENCES vendors(id),
  order_number VARCHAR(50) UNIQUE,
  order_date DATE NOT NULL DEFAULT CURRENT_DATE,
  expected_date DATE,
  received_date DATE,
  status VARCHAR(20) DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'recibido', 'parcial', 'cancelado')),
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  tax DECIMAL(10,2) DEFAULT 0 CHECK (tax >= 0),
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  notes TEXT,
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_po_vendor ON purchase_orders(vendor_id);
CREATE INDEX IF NOT EXISTS idx_po_status ON purchase_orders(status);
CREATE INDEX IF NOT EXISTS idx_po_order_date ON purchase_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_po_order_number ON purchase_orders(order_number);

-- ============================================
-- 3. PURCHASE ORDER ITEMS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS purchase_order_items (
  id SERIAL PRIMARY KEY,
  purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
  product_id INTEGER NOT NULL REFERENCES products(id),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  received_quantity INTEGER DEFAULT 0 CHECK (received_quantity >= 0),
  unit_cost DECIMAL(10,2) NOT NULL CHECK (unit_cost >= 0),
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_po_items_po_id ON purchase_order_items(purchase_order_id);
CREATE INDEX IF NOT EXISTS idx_po_items_product_id ON purchase_order_items(product_id);

-- ============================================
-- 4. FUNCTION: Generate PO Number
-- ============================================
CREATE OR REPLACE FUNCTION generate_po_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL THEN
    NEW.order_number := 'PO-' || TO_CHAR(NEW.order_date, 'YYYYMMDD') || '-' || LPAD(NEW.id::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 5. TRIGGER: Auto-generate PO Number
-- ============================================
DROP TRIGGER IF EXISTS trigger_generate_po_number ON purchase_orders;
CREATE TRIGGER trigger_generate_po_number
BEFORE INSERT ON purchase_orders
FOR EACH ROW
EXECUTE FUNCTION generate_po_number();

-- ============================================
-- 6. COMMENTS
-- ============================================
COMMENT ON TABLE vendors IS 'Proveedores/Suppliers del sistema';
COMMENT ON TABLE purchase_orders IS 'Órdenes de compra a proveedores';
COMMENT ON TABLE purchase_order_items IS 'Ítems de las órdenes de compra';
COMMENT ON COLUMN vendors.payment_terms IS 'Términos de pago: contado, 15 días, 30 días, etc';
COMMENT ON COLUMN purchase_orders.status IS 'Estados: pendiente, recibido, parcial, cancelado';
