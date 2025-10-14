-- Migration: Create Financial and Reporting Tables
-- Description: Add payment methods, daily sales tracking, expenses, and reporting
-- Date: 2025-10-14

-- ============================================
-- 1. PAYMENT METHODS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS payment_methods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL UNIQUE,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default payment methods
INSERT INTO payment_methods (name, active) VALUES
  ('efectivo', true),
  ('tarjeta', true),
  ('transferencia', true),
  ('datafono', true)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- 2. ORDER PAYMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS order_payments (
  id SERIAL PRIMARY KEY,
  order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  payment_method_id INTEGER NOT NULL REFERENCES payment_methods(id),
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  payment_date TIMESTAMP DEFAULT NOW(),
  reference VARCHAR(100),
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_payments_order_id ON order_payments(order_id);
CREATE INDEX IF NOT EXISTS idx_order_payments_payment_date ON order_payments(payment_date);
CREATE INDEX IF NOT EXISTS idx_order_payments_method ON order_payments(payment_method_id);

-- ============================================
-- 3. DAILY SALES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS daily_sales (
  id SERIAL PRIMARY KEY,
  sale_date DATE NOT NULL UNIQUE,
  total_orders INTEGER NOT NULL DEFAULT 0,
  completed_orders INTEGER DEFAULT 0,
  canceled_orders INTEGER DEFAULT 0,
  total_sales DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_cash DECIMAL(10,2) DEFAULT 0,
  total_card DECIMAL(10,2) DEFAULT 0,
  total_transfer DECIMAL(10,2) DEFAULT 0,
  total_costs DECIMAL(10,2) DEFAULT 0,
  gross_profit DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_daily_sales_date ON daily_sales(sale_date);

-- ============================================
-- 4. EXPENSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  category VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  payment_method VARCHAR(50),
  receipt_number VARCHAR(50),
  created_by INTEGER REFERENCES user_admin(id),
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(expense_date);
CREATE INDEX IF NOT EXISTS idx_expenses_category ON expenses(category);

-- ============================================
-- 5. EXPENSE CATEGORIES (for reference)
-- ============================================
COMMENT ON COLUMN expenses.category IS 'Categorías sugeridas: servicios, sueldos, mantenimiento, suministros, transporte, marketing, otros';

-- ============================================
-- 6. ALTER EXISTING ORDERS TABLE
-- ============================================
-- Add financial fields to orders table if they don't exist
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'pendiente';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method_id INTEGER REFERENCES payment_methods(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax DECIMAL(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal DECIMAL(10,2);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS notes TEXT;

-- ============================================
-- 7. COMMENTS
-- ============================================
COMMENT ON TABLE payment_methods IS 'Métodos de pago disponibles en el sistema';
COMMENT ON TABLE order_payments IS 'Pagos realizados para cada pedido';
COMMENT ON TABLE daily_sales IS 'Consolidado de ventas diarias para reportes';
COMMENT ON TABLE expenses IS 'Gastos operativos del negocio';
COMMENT ON COLUMN orders.payment_status IS 'Estado de pago: pendiente, pagado, parcial';
