-- ================================================
-- BrewOrder Database Schema
-- ================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- USERS TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE,
    phone TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'customer' CHECK (role IN ('admin', 'submitter', 'customer')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- CATEGORIES TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- PRODUCTS TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    image_url TEXT,
    image_icon TEXT NOT NULL DEFAULT 'local_cafe',
    is_available BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- ORDERS TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled')),
    customer_name TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- ORDER ITEMS TABLE
-- ================================================
CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    subtotal DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- ROW LEVEL SECURITY (RLS)
-- ================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Public can read users" ON users FOR SELECT USING (true);
CREATE POLICY "Anyone can create users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (true);

-- Categories policies
CREATE POLICY "Public can read categories" ON categories FOR SELECT USING (true);

-- Products policies
CREATE POLICY "Public can read products" ON products FOR SELECT USING (true);

-- Orders policies
CREATE POLICY "Anyone can read own orders" ON orders FOR SELECT USING (true);
CREATE POLICY "Anyone can create orders" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Admins can update orders" ON orders FOR UPDATE USING (
    EXISTS (SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin')
);

-- Order items policies
CREATE POLICY "Anyone can read own order items" ON order_items FOR SELECT USING (true);
CREATE POLICY "Anyone can create order items" ON order_items FOR INSERT WITH CHECK (true);

-- ================================================
-- FUNCTIONS
-- ================================================

-- Auto-update updated_at for users
CREATE OR REPLACE FUNCTION update_users_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_users_updated_at();

-- Auto-update updated_at for orders
CREATE OR REPLACE FUNCTION update_orders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_orders_updated_at ON orders;
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_orders_updated_at();

-- ================================================
-- DUMMY DATA: USERS (Admin & Submitter)
-- ================================================
INSERT INTO users (id, name, phone, email, role) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Admin User', '+60123456789', 'admin@breworder.com', 'admin'),
    ('22222222-2222-2222-2222-222222222222', 'Submitter User', '+60123456788', 'submitter@breworder.com', 'submitter'),
    ('33333333-3333-3333-3333-333333333333', 'John Doe', '+60123456787', 'john@example.com', 'customer'),
    ('44444444-4444-4444-4444-444444444444', 'Jane Smith', '+60123456786', 'jane@example.com', 'customer')
ON CONFLICT (id) DO NOTHING;

-- ================================================
-- DUMMY DATA: CATEGORIES
-- ================================================
INSERT INTO categories (id, name, icon, display_order) VALUES
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Coffee', 'local_cafe', 1),
    ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Tea', 'spa', 2),
    ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Snacks', 'cookie', 3)
ON CONFLICT (id) DO NOTHING;

-- ================================================
-- DUMMY DATA: PRODUCTS
-- ================================================
INSERT INTO products (id, name, description, price, category_id, image_url, image_icon, display_order) VALUES
    -- Coffee
    ('ca111111-1111-1111-1111-111111111111', 'Cappuccino', 'Rich espresso with steamed milk foam', 3.50, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=80', 'local_cafe', 1),
    ('ca222222-2222-2222-2222-222222222222', 'Latte', 'Smooth espresso with creamy steamed milk', 4.00, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80', 'local_drink', 2),
    ('ca333333-3333-3333-3333-333333333333', 'Espresso', 'Pure concentrated coffee', 2.75, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1512568400610-62da28bc8a13?auto=format&fit=crop&w=800&q=80', 'whatshot', 3),
    ('ca444444-4444-4444-4444-444444444444', 'Americano', 'Espresso with hot water', 3.00, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1551030173-122aabc4489c?auto=format&fit=crop&w=800&q=80', 'coffee', 4),
    ('ca555555-5555-5555-5555-555555555555', 'Mocha', 'Chocolate espresso with steamed milk', 4.50, 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1578314675249-a6910f80cc4e?auto=format&fit=crop&w=800&q=80', 'local_cafe', 5),
    
    -- Tea
    ('cb111111-1111-1111-1111-111111111111', 'Green Tea', 'Light and refreshing Japanese green tea', 3.25, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1561336313-0bd5e0b27ec8?auto=format&fit=crop&w=800&q=80', 'spa', 1),
    ('cb222222-2222-2222-2222-222222222222', 'Oolong Tea', 'Partially oxidized tea with floral notes', 3.50, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?auto=format&fit=crop&w=800&q=80', 'grass', 2),
    ('cb333333-3333-3333-3333-333333333333', 'Lemon Tea', 'Hot tea with fresh lemon slices', 3.75, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80', 'thermostat', 3),
    ('cb444444-4444-4444-4444-444444444444', 'Chai Latte', 'Spiced tea with steamed milk', 4.00, 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?auto=format&fit=crop&w=800&q=80', 'local_drink', 4),
    
    -- Snacks
    ('cc111111-1111-1111-1111-111111111111', 'Croissant', 'Buttery flaky French pastry', 2.95, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80', 'cookie', 1),
    ('cc222222-2222-2222-2222-222222222222', 'Chocolate Cookie', 'Freshly baked chocolate chip cookie', 2.25, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?auto=format&fit=crop&w=800&q=80', 'emoji_food_beverage', 2),
    ('cc333333-3333-3333-3333-333333333333', 'Cheesecake', 'Creamy New York style cheesecake', 4.50, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1542826438-bd32f43d626f?auto=format&fit=crop&w=800&q=80', 'icecream', 3),
    ('cc444444-4444-4444-4444-444444444444', 'Blueberry Muffin', 'Soft muffin with fresh blueberries', 3.25, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1607958996333-41aef7caefaa?auto=format&fit=crop&w=800&q=80', 'bakery_dining', 4),
    ('cc555555-5555-5555-5555-555555555555', 'Brownie', 'Rich chocolate brownie', 3.00, 'cccccccc-cccc-cccc-cccc-cccccccccccc', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?auto=format&fit=crop&w=800&q=80', 'cake', 5)
ON CONFLICT (id) DO NOTHING;

-- ================================================
-- DUMMY DATA: SAMPLE ORDERS
-- ================================================
INSERT INTO orders (id, user_id, total_amount, status, customer_name, notes, created_at) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddd0001', '33333333-3333-3333-3333-333333333333', 7.50, 'completed', 'John Doe', 'Please add extra sugar', NOW() - INTERVAL '5 days'),
    ('dddddddd-dddd-dddd-dddd-dddddddd0002', '33333333-3333-3333-3333-333333333333', 12.25, 'ready', 'John Doe', NULL, NOW() - INTERVAL '1 day'),
    ('dddddddd-dddd-dddd-dddd-dddddddd0003', '44444444-4444-4444-4444-444444444444', 9.00, 'preparing', 'Jane Smith', 'Pick up at counter', NOW() - INTERVAL '2 hours')
ON CONFLICT (id) DO NOTHING;

-- Sample order items
INSERT INTO order_items (order_id, product_id, product_name, price, quantity, subtotal) VALUES
    ('dddddddd-dddd-dddd-dddd-dddddddd0001', 'ca111111-1111-1111-1111-111111111111', 'Cappuccino', 3.50, 1, 3.50),
    ('dddddddd-dddd-dddd-dddd-dddddddd0001', 'cc222222-2222-2222-2222-222222222222', 'Chocolate Cookie', 2.25, 2, 4.50),
    ('dddddddd-dddd-dddd-dddd-dddddddd0002', 'ca222222-2222-2222-2222-222222222222', 'Latte', 4.00, 2, 8.00),
    ('dddddddd-dddd-dddd-dddd-dddddddd0002', 'cc333333-3333-3333-3333-333333333333', 'Cheesecake', 4.50, 1, 4.50),
    ('dddddddd-dddd-dddd-dddd-dddddddd0003', 'cb111111-1111-1111-1111-111111111111', 'Green Tea', 3.25, 1, 3.25),
    ('dddddddd-dddd-dddd-dddd-dddddddd0003', 'ca333333-3333-3333-3333-333333333333', 'Espresso', 2.75, 1, 2.75),
    ('dddddddd-dddd-dddd-dddd-dddddddd0003', 'cc111111-1111-1111-1111-111111111111', 'Croissant', 2.95, 1, 2.95)
ON CONFLICT DO NOTHING;

-- for delete all tables incase u have db error  


-- DO $$ DECLARE
--     r RECORD;
-- BEGIN
--     -- Drop all tables
--     FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
--         EXECUTE 'DROP TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' CASCADE';
--     END LOOP;
-- END $$;