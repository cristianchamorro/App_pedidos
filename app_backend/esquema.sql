-- =====================================
-- ESQUEMA DE BASE DE DATOS: Bd_App
-- Sistema de gestión de pedidos
-- =====================================

-- Habilitar extensión PostGIS para geolocalización
CREATE EXTENSION IF NOT EXISTS postgis;

-- =====================================
-- TABLA: roles
-- Roles de usuarios administrativos
-- =====================================
CREATE TABLE IF NOT EXISTS roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- =====================================
-- TABLA: user_admin
-- Usuarios administrativos del sistema
-- =====================================
CREATE TABLE IF NOT EXISTS user_admin (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

-- =====================================
-- TABLA: categories
-- Categorías de productos
-- =====================================
CREATE TABLE IF NOT EXISTS categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- =====================================
-- TABLA: vendors
-- Proveedores de productos
-- =====================================
CREATE TABLE IF NOT EXISTS vendors (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- =====================================
-- TABLA: products
-- Productos disponibles para pedido
-- =====================================
CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    image_url TEXT,
    category_id INTEGER NOT NULL,
    vendor_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (vendor_id) REFERENCES vendors(id) ON DELETE CASCADE
);

-- =====================================
-- TABLA: users
-- Clientes del sistema
-- =====================================
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================
-- TABLA: drivers
-- Conductores de entregas con geolocalización
-- =====================================
CREATE TABLE IF NOT EXISTS drivers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    status VARCHAR(20) DEFAULT 'available' CHECK (status IN ('available', 'busy', 'offline')),
    location GEOMETRY(Point, 4326), -- Coordenadas geográficas (longitud, latitud)
    created_at TIMESTAMP DEFAULT NOW()
);

-- =====================================
-- TABLA: orders
-- Pedidos de clientes
-- =====================================
CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    driver_id INTEGER,
    total NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pendiente' CHECK (status IN ('pendiente', 'preparando', 'listo', 'entregado', 'cancelado', 'pagado')),
    order_channel VARCHAR(50) DEFAULT 'APP',
    nota TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL
);

-- =====================================
-- TABLA: order_items
-- Productos dentro de cada pedido
-- =====================================
CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price NUMERIC(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- =====================================
-- TABLA: status_history
-- Historial de cambios de estado de pedidos
-- =====================================
CREATE TABLE IF NOT EXISTS status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL,
    changed_by INTEGER,
    changed_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES user_admin(id) ON DELETE SET NULL
);

-- =====================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- =====================================
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_products_category_id ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_vendor_id ON products(vendor_id);
CREATE INDEX IF NOT EXISTS idx_drivers_location ON drivers USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_drivers_status ON drivers(status);
CREATE INDEX IF NOT EXISTS idx_status_history_order_id ON status_history(order_id);

-- =====================================
-- DATOS INICIALES: roles
-- =====================================
INSERT INTO roles (name) VALUES 
    ('admin'),
    ('cajero'),
    ('cocinero')
ON CONFLICT (name) DO NOTHING;

-- =====================================
-- DATOS INICIALES: user_admin
-- Contraseñas en texto plano (en producción usar hash)
-- =====================================
INSERT INTO user_admin (username, password, name, role_id) VALUES 
    ('admin', 'admin123', 'Administrador', (SELECT id FROM roles WHERE name = 'admin')),
    ('cajero', 'cajero123', 'Cajero Principal', (SELECT id FROM roles WHERE name = 'cajero')),
    ('cocinero', 'cocinero123', 'Cocinero Principal', (SELECT id FROM roles WHERE name = 'cocinero'))
ON CONFLICT (username) DO NOTHING;

-- =====================================
-- DATOS INICIALES: categories
-- =====================================
INSERT INTO categories (name) VALUES 
    ('Bebidas'),
    ('Comida Rápida'),
    ('Postres'),
    ('Platos Principales'),
    ('Ensaladas')
ON CONFLICT (name) DO NOTHING;

-- =====================================
-- DATOS INICIALES: vendors
-- =====================================
INSERT INTO vendors (name) VALUES 
    ('Restaurante Central'),
    ('Cafetería Express'),
    ('Panadería Dulce'),
    ('Food Truck #1')
ON CONFLICT DO NOTHING;

-- =====================================
-- DATOS INICIALES: products
-- =====================================
INSERT INTO products (name, description, price, image_url, category_id, vendor_id) VALUES 
    ('Hamburguesa Clásica', 'Hamburguesa con carne, lechuga, tomate y queso', 8.50, 'https://via.placeholder.com/150', 
        (SELECT id FROM categories WHERE name = 'Comida Rápida'), 
        (SELECT id FROM vendors WHERE name = 'Restaurante Central')),
    ('Coca Cola', 'Bebida gaseosa 500ml', 2.00, 'https://via.placeholder.com/150', 
        (SELECT id FROM categories WHERE name = 'Bebidas'), 
        (SELECT id FROM vendors WHERE name = 'Cafetería Express')),
    ('Pizza Pepperoni', 'Pizza grande con pepperoni', 12.00, 'https://via.placeholder.com/150', 
        (SELECT id FROM categories WHERE name = 'Comida Rápida'), 
        (SELECT id FROM vendors WHERE name = 'Restaurante Central')),
    ('Ensalada César', 'Ensalada con pollo, lechuga romana y aderezo césar', 7.50, 'https://via.placeholder.com/150', 
        (SELECT id FROM categories WHERE name = 'Ensaladas'), 
        (SELECT id FROM vendors WHERE name = 'Restaurante Central')),
    ('Helado de Chocolate', 'Helado artesanal de chocolate', 4.00, 'https://via.placeholder.com/150', 
        (SELECT id FROM categories WHERE name = 'Postres'), 
        (SELECT id FROM vendors WHERE name = 'Panadería Dulce'))
ON CONFLICT DO NOTHING;

-- =====================================
-- DATOS INICIALES: drivers
-- =====================================
INSERT INTO drivers (name, phone, status, location) VALUES 
    ('Juan Pérez', '555-0101', 'available', ST_SetSRID(ST_MakePoint(-74.0060, 40.7128), 4326)),
    ('María García', '555-0102', 'available', ST_SetSRID(ST_MakePoint(-74.0070, 40.7138), 4326)),
    ('Carlos Rodríguez', '555-0103', 'busy', ST_SetSRID(ST_MakePoint(-74.0080, 40.7148), 4326))
ON CONFLICT DO NOTHING;

-- =====================================
-- DATOS DE EJEMPLO: users
-- =====================================
INSERT INTO users (name, phone, address) VALUES 
    ('Cliente Demo', '555-1234', 'Calle Principal 123, Ciudad')
ON CONFLICT DO NOTHING;
