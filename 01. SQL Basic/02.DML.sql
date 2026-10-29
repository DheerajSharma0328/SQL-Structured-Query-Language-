CREATE TABLE categories(
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE products(
    product_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES categories(category_id),
    product_name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price>0),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity>0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

ALTER TABLE products
DROP CONSTRAINT products_stock_quantity_check;

ALTER TABLE products
ADD CONSTRAINT products_stock_quantity_check
CHECK (stock_quantity >= 0);

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50) NOT NULL DEFAULT 'INDIA',
    signup_date DATE NOT NULL DEFAULT CURRENT_DATE,
    loyalty_points INT NOT NULL DEFAULT 0,
    referred_by INT REFERENCES customers(customer_id)
);

CREATE TABLE orders(
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id),
    employee_id INT REFERENCES employees(employee_id),
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK(
            status IN ('pending', 'processing', 'completed', 'cancelled', 'refunded')
        ),
    shipping_city VARCHAR(50),
    notes TEXT
);

CREATE TABLE order_items(
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0)
);

CREATE TABLE payments(
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_date DATE NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR NOT NULL
        CHECK (payment_method IN ('credit card', 'debit card', 'paypal' )),
    status VARCHAR(20) NOT NULL DEFAULT 'success'
            CHECK(status IN ('success', 'failed', 'refunded'))
);

INSERT INTO categories (category_name, description) VALUES
    ('Electronics',            'Gadgets, computer accessories and audio equipment'),
    ('Home & Kitchen',         'Appliances and tools for cooking and the home'),
    ('Books',                  'Programming, productivity and self-improvement books'),
    ('Clothing',               'Everyday apparel for men and women'),
    ('Sports & Outdoors',      'Fitness, camping and outdoor gear'),
    ('Beauty & Personal Care', 'Skincare, haircare and personal grooming products');

-- 30 products, 5 per category. Notes for later sections:
--   - product 3 (USB-C Hub) has 0 stock
--   - product 20 (Rain Jacket) is_active = FALSE (discontinued, still referenced by history)
--   - product 28 (Hair Dryer) is active but never ordered
INSERT INTO products (category_id, product_name, price, stock_quantity, is_active, created_at) VALUES
    (1, 'Wireless Mouse',                19.99, 120, TRUE,  '2023-01-10'),
    (1, 'Mechanical Keyboard',           79.99,  45, TRUE,  '2023-01-10'),
    (1, 'USB-C Hub',                     34.50,   1, TRUE,  '2023-02-01'),
    (1, '27-inch Monitor',              249.99,  15, TRUE,  '2023-02-15'),
    (1, 'Noise Cancelling Headphones',  129.00,  30, TRUE,  '2023-03-01'),
    (2, 'Stainless Steel Kettle',        39.99,  60, TRUE,  '2023-01-20'),
    (2, 'Non-stick Frying Pan',          24.99,  80, TRUE,  '2023-01-20'),
    (2, 'Air Fryer',                     89.99,  25, TRUE,  '2023-02-10'),
    (2, 'Coffee Maker',                  54.99,  40, TRUE,  '2023-02-10'),
    (2, 'Blender',                       44.50,  35, TRUE,  '2023-03-05'),
    (3, 'Learning SQL',                  42.00, 100, TRUE,  '2023-01-05'),
    (3, 'Clean Code',                    38.50,  70, TRUE,  '2023-01-05'),
    (3, 'The Pragmatic Programmer',      45.00,  55, TRUE,  '2023-01-05'),
    (3, 'Atomic Habits',                 16.99, 150, TRUE,  '2023-01-05'),
    (3, 'Deep Work',                     18.99,  90, TRUE,  '2023-01-05'),
    (4, 'Men''s Cotton T-Shirt',         14.99, 200, TRUE,  '2023-02-01'),
    (4, 'Women''s Denim Jacket',         59.99,  40, TRUE,  '2023-02-01'),
    (4, 'Running Shoes',                 89.00,  60, TRUE,  '2023-02-20'),
    (4, 'Wool Sweater',                  49.99,  35, TRUE,  '2023-03-10'),
    (4, 'Rain Jacket',                   69.99,  20, FALSE, '2023-02-20'),
    (5, 'Yoga Mat',                      22.00, 110, TRUE,  '2023-01-25'),
    (5, 'Dumbbell Set 20kg',             75.00,  25, TRUE,  '2023-01-25'),
    (5, 'Camping Tent 2-Person',        110.00,  18, TRUE,  '2023-03-15'),
    (5, 'Cycling Helmet',                39.99,  50, TRUE,  '2023-03-15'),
    (5, 'Water Bottle 1L',               12.99, 180, TRUE,  '2023-01-25'),
    (6, 'Moisturizing Cream',            18.50,  95, TRUE,  '2023-02-05'),
    (6, 'Electric Toothbrush',           49.99,  40, TRUE,  '2023-02-05'),
    (6, 'Hair Dryer',                    34.99,  30, TRUE,  '2023-02-05'),
    (6, 'Sunscreen SPF50',               15.99, 100, TRUE,  '2023-03-01'),
    (6, 'Perfume 50ml',                  65.00,  25, TRUE,  '2023-03-01');

-- 20 customers. Notes for later sections:
--   - phone/city are NULL for several rows on purpose
--   - referred_by chains a few customers back to an earlier customer
--   - customers 19 and 20 have NO orders at all
--   - customer 18 has exactly ONE order, and it's cancelled
INSERT INTO customers (first_name, last_name, email, phone, city, country, signup_date, loyalty_points, referred_by) VALUES
    ('Alice',    'Johnson',  'alice.johnson@email.com',  '212-555-0101', 'New York',      'USA',    '2023-01-15', 320, NULL),
    ('Brian',    'Kim',      'brian.kim@email.com',      NULL,           'Los Angeles',   'USA',    '2023-02-20', 150, 1),
    ('Carla',    'Mendes',   'carla.mendes@email.com',   '305-555-0103', 'Miami',         'USA',    '2023-03-05',  80, NULL),
    ('David',    'Okoro',    'david.okoro@email.com',    '312-555-0104', 'Chicago',       'USA',    '2023-03-22',   0, NULL),
    ('Elena',    'Petrova',  'elena.petrova@email.com',  NULL,           'Seattle',       'USA',    '2023-04-10', 210, 1),
    ('Farid',    'Haidari',  'farid.haidari@email.com',  '206-555-0106', 'Seattle',       'USA',    '2023-04-18',  45, NULL),
    ('Grace',    'Lin',      'grace.lin@email.com',      '415-555-0107', 'San Francisco', 'USA',    '2023-05-02', 500, NULL),
    ('Hassan',   'Ali',      'hassan.ali@email.com',     NULL,           'Houston',       'USA',    '2023-05-29',  60, 3),
    ('Isabella', 'Rossi',    'isabella.rossi@email.com', '617-555-0109', 'Boston',        'USA',    '2023-06-14',   0, NULL),
    ('Jamal',    'Carter',   'jamal.carter@email.com',   '404-555-0110', 'Atlanta',       'USA',    '2023-07-01',  90, NULL),
    ('Kavya',    'Reddy',    'kavya.reddy@email.com',    '512-555-0111', 'Austin',        'USA',    '2023-07-19', 130, 7),
    ('Liam',     'O''Brien', 'liam.obrien@email.com',    NULL,           'Denver',        'USA',    '2023-08-08',  20, NULL),
    ('Mei',      'Tanaka',   'mei.tanaka@email.com',     '602-555-0113', 'Phoenix',       'USA',    '2023-08-27',  75, NULL),
    ('Noah',     'Schmidt',  'noah.schmidt@email.com',   NULL,           NULL,            'USA',    '2023-09-10',   0, NULL),
    ('Olivia',   'Martin',   'olivia.martin@email.com',  '503-555-0115', 'Portland',      'USA',    '2023-09-30', 260, 7),
    ('Paulo',    'Souza',    'paulo.souza@email.com',    NULL,           'Sao Paulo',     'Brazil', '2023-10-12',  15, NULL),
    ('Queenie',  'Wu',       'queenie.wu@email.com',     NULL,           'Toronto',       'Canada', '2023-11-02',  40, NULL),
    ('Ravi',     'Kapoor',   'ravi.kapoor@email.com',    NULL,           'Mumbai',        'India',  '2023-11-25',   0, NULL),
    ('Sofia',    'Nowak',    'sofia.nowak@email.com',    NULL,           NULL,            'Poland', '2023-12-05',   0, NULL),
    ('Tomas',    'Vidal',    'tomas.vidal@email.com',    NULL,           'Madrid',        'Spain',  '2024-01-08',   0, NULL);

-- 45 orders, spread across Jan-Jun 2024. Statuses mixed on purpose:
-- 'pending' orders have no payment yet, 'cancelled' orders never got
-- paid, and customers 19/20 place none at all. employee_id values below
-- (1-4) point at Robert/Priya/Marcus/Elena, seeded back in PART 1.

INSERT INTO orders (customer_id, employee_id, order_date, status, shipping_city) VALUES
    (1,  2,    '2024-01-05', 'completed', 'New York'),
    (3,  NULL, '2024-01-07', 'completed', 'Miami'),
    (5,  4,    '2024-01-10', 'completed', 'Seattle'),
    (7,  NULL, '2024-01-12', 'cancelled', 'San Francisco'),
    (9,  3,    '2024-01-15', 'completed', 'Boston'),
    (2,  2,    '2024-01-18', 'completed', 'Los Angeles'),
    (11, NULL, '2024-01-22', 'completed', 'Austin'),
    (4,  4,    '2024-01-25', 'pending',   'Chicago'),
    (6,  3,    '2024-02-02', 'completed', 'Seattle'),
    (8,  NULL, '2024-02-05', 'completed', 'Houston'),
    (1,  2,    '2024-02-08', 'completed', 'New York'),
    (13, 4,    '2024-02-11', 'completed', 'Phoenix'),
    (10, NULL, '2024-02-14', 'refunded',  'Atlanta'),
    (15, 3,    '2024-02-18', 'completed', 'Portland'),
    (3,  NULL, '2024-02-21', 'completed', 'Miami'),
    (7,  2,    '2024-02-25', 'completed', 'San Francisco'),
    (12, 4,    '2024-03-01', 'completed', 'Denver'),
    (5,  NULL, '2024-03-04', 'completed', 'Seattle'),
    (9,  3,    '2024-03-08', 'cancelled', 'Boston'),
    (2,  2,    '2024-03-12', 'completed', 'Los Angeles'),
    (16, NULL, '2024-03-15', 'completed', 'Sao Paulo'),
    (1,  4,    '2024-03-19', 'completed', 'New York'),
    (14, NULL, '2024-03-23', 'completed', 'Chicago'),
    (11, 3,    '2024-03-27', 'completed', 'Austin'),
    (6,  2,    '2024-04-02', 'completed', 'Seattle'),
    (18, NULL, '2024-04-05', 'cancelled', 'Mumbai'),
    (8,  4,    '2024-04-09', 'completed', 'Houston'),
    (3,  NULL, '2024-04-12', 'completed', 'Miami'),
    (13, 3,    '2024-04-16', 'completed', 'Phoenix'),
    (7,  2,    '2024-04-20', 'completed', 'San Francisco'),
    (15, NULL, '2024-04-24', 'completed', 'Portland'),
    (10, 4,    '2024-04-28', 'completed', 'Atlanta'),
    (1,  2,    '2024-05-02', 'completed', 'New York'),
    (5,  3,    '2024-05-06', 'completed', 'Seattle'),
    (9,  NULL, '2024-05-10', 'completed', 'Boston'),
    (17, 4,    '2024-05-14', 'completed', 'Toronto'),
    (2,  2,    '2024-05-18', 'pending',   'Los Angeles'),
    (12, NULL, '2024-05-22', 'completed', 'Denver'),
    (11, 3,    '2024-05-26', 'completed', 'Austin'),
    (4,  4,    '2024-05-30', 'completed', 'Chicago'),
    (6,  2,    '2024-06-03', 'completed', 'Seattle'),
    (7,  NULL, '2024-06-07', 'completed', 'San Francisco'),
    (1,  3,    '2024-06-11', 'completed', 'New York'),
    (15, 4,    '2024-06-15', 'completed', 'Portland'),
    (9,  2,    '2024-06-20', 'completed', 'Boston');

CHECK (
    status IN ('pending', 'processing', 'completed', 'cancelled', 'refunded')
)

SELECT * FROM payments;
