-- =====================================================================
--  NovaGear Technologies  |  Product-Based Company Database (MySQL 8.0+)
--  Brand : NovaGear - consumer electronics & accessories sold online (India)
--  Tables: categories, suppliers, employees, products, customers,
--          orders, order_items, reviews   (every table has 50 rows or fewer)
--  Note  : All people, emails, phone numbers and suppliers are FICTIONAL.
-- =====================================================================

DROP DATABASE IF EXISTS novagear_db;
CREATE DATABASE novagear_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE novagear_db;

-- ---------------------------------------------------------------------
-- 1. SCHEMA
-- ---------------------------------------------------------------------
CREATE TABLE categories (
  category_id    INT           NOT NULL AUTO_INCREMENT,
  category_name  VARCHAR(50)   NOT NULL,
  description    VARCHAR(150),
  PRIMARY KEY (category_id),
  UNIQUE KEY uq_category_name (category_name)
);

CREATE TABLE suppliers (
  supplier_id    INT           NOT NULL AUTO_INCREMENT,
  supplier_name  VARCHAR(80)   NOT NULL,
  city           VARCHAR(50)   NOT NULL,
  country        VARCHAR(50)   NOT NULL,
  contact_email  VARCHAR(100),
  lead_time_days INT           NOT NULL,
  PRIMARY KEY (supplier_id),
  CONSTRAINT chk_lead_time CHECK (lead_time_days > 0)
);

CREATE TABLE employees (
  employee_id    INT           NOT NULL AUTO_INCREMENT,
  full_name      VARCHAR(60)   NOT NULL,
  job_title      VARCHAR(60)   NOT NULL,
  department     VARCHAR(40)   NOT NULL,
  manager_id     INT           NULL,
  salary         DECIMAL(12,2) NOT NULL COMMENT 'Annual salary in INR',
  hire_date      DATE          NOT NULL,
  PRIMARY KEY (employee_id),
  CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) REFERENCES employees (employee_id),
  CONSTRAINT chk_salary CHECK (salary > 0)
);

CREATE TABLE products (
  product_id     INT           NOT NULL AUTO_INCREMENT,
  product_name   VARCHAR(80)   NOT NULL,
  category_id    INT           NOT NULL,
  supplier_id    INT           NOT NULL,
  cost_price     DECIMAL(10,2) NOT NULL COMMENT 'What NovaGear pays (INR)',
  unit_price     DECIMAL(10,2) NOT NULL COMMENT 'Selling price (INR)',
  stock_qty      INT           NOT NULL,
  reorder_level  INT           NOT NULL,
  launch_date    DATE          NOT NULL,
  is_active      TINYINT(1)    NOT NULL DEFAULT 1 COMMENT '1 = on sale, 0 = discontinued',
  PRIMARY KEY (product_id),
  UNIQUE KEY uq_product_name (product_name),
  CONSTRAINT fk_prod_category FOREIGN KEY (category_id) REFERENCES categories (category_id),
  CONSTRAINT fk_prod_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id),
  CONSTRAINT chk_prices CHECK (cost_price > 0 AND unit_price > cost_price),
  CONSTRAINT chk_stock  CHECK (stock_qty >= 0 AND reorder_level >= 0)
);

CREATE TABLE customers (
  customer_id    INT           NOT NULL AUTO_INCREMENT,
  full_name      VARCHAR(60)   NOT NULL,
  email          VARCHAR(100)  NOT NULL,
  phone          VARCHAR(20)   NULL,
  city           VARCHAR(50)   NOT NULL,
  state          VARCHAR(50)   NOT NULL,
  signup_date    DATE          NOT NULL,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customer_email (email)
);

CREATE TABLE orders (
  order_id       INT           NOT NULL AUTO_INCREMENT,
  customer_id    INT           NOT NULL,
  employee_id    INT           NOT NULL COMMENT 'Sales executive who handled the order',
  order_date     DATE          NOT NULL,
  status         VARCHAR(15)   NOT NULL,
  payment_method VARCHAR(20)   NOT NULL,
  delivery_date  DATE          NULL,
  PRIMARY KEY (order_id),
  CONSTRAINT fk_ord_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  CONSTRAINT fk_ord_employee FOREIGN KEY (employee_id) REFERENCES employees (employee_id),
  CONSTRAINT chk_status CHECK (status IN ('Delivered','Shipped','Processing','Cancelled')),
  CONSTRAINT chk_payment CHECK (payment_method IN ('UPI','Credit Card','Debit Card','Net Banking','Cash on Delivery')),
  CONSTRAINT chk_delivery CHECK (
    (status = 'Delivered' AND delivery_date IS NOT NULL AND delivery_date >= order_date)
    OR (status <> 'Delivered' AND delivery_date IS NULL))
);

CREATE TABLE order_items (
  order_item_id    INT           NOT NULL AUTO_INCREMENT,
  order_id         INT           NOT NULL,
  product_id       INT           NOT NULL,
  quantity         INT           NOT NULL,
  unit_price       DECIMAL(10,2) NOT NULL COMMENT 'Price charged per unit (INR)',
  discount_percent DECIMAL(5,2)  NOT NULL DEFAULT 0,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uq_order_product (order_id, product_id),
  CONSTRAINT fk_item_order   FOREIGN KEY (order_id)   REFERENCES orders (order_id),
  CONSTRAINT fk_item_product FOREIGN KEY (product_id) REFERENCES products (product_id),
  CONSTRAINT chk_qty  CHECK (quantity > 0),
  CONSTRAINT chk_disc CHECK (discount_percent BETWEEN 0 AND 50)
);

CREATE TABLE reviews (
  review_id         INT           NOT NULL AUTO_INCREMENT,
  product_id        INT           NOT NULL,
  customer_id       INT           NOT NULL,
  rating            TINYINT       NOT NULL,
  review_text       VARCHAR(200),
  review_date       DATE          NOT NULL,
  verified_purchase TINYINT(1)    NOT NULL COMMENT '1 = bought on NovaGear store, 0 = bought elsewhere',
  PRIMARY KEY (review_id),
  UNIQUE KEY uq_review (customer_id, product_id),
  CONSTRAINT fk_rev_product  FOREIGN KEY (product_id)  REFERENCES products (product_id),
  CONSTRAINT fk_rev_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
  CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5)
);

-- ---------------------------------------------------------------------
-- 2. DATA
-- ---------------------------------------------------------------------
INSERT INTO categories (category_id, category_name, description) VALUES
  (1, 'Smart Wearables', 'Smartwatches, fitness bands and health trackers'),
  (2, 'Audio', 'Earbuds, headphones and speakers'),
  (3, 'Mobile Accessories', 'Cases, screen guards, mounts and tripods'),
  (4, 'Laptop Accessories', 'Stands, keyboards, mice, hubs and sleeves'),
  (5, 'Smart Home', 'Smart bulbs, plugs, locks and air purifiers'),
  (6, 'Power & Charging', 'Power banks, chargers, cables and power stations'),
  (7, 'Gaming Gear', 'Gaming mice, keyboards, headsets and controllers'),
  (8, 'Cameras & Surveillance', 'Home cameras, dash cams and video doorbells'),
  (9, 'Networking', 'Routers, mesh systems, extenders and cables'),
  (10, 'Storage', 'SSDs, hard drives, pendrives and memory cards');

INSERT INTO suppliers (supplier_id, supplier_name, city, country, contact_email, lead_time_days) VALUES
  (1, 'Shenzhen BrightTech Components', 'Shenzhen', 'China', 'sales@brighttech.example.com', 21),
  (2, 'Guangzhou SoundWave Industries', 'Guangzhou', 'China', 'orders@soundwave.example.com', 18),
  (3, 'Dongguan PowerCell Co.', 'Dongguan', 'China', 'export@powercell.example.com', 25),
  (4, 'Taipei NetCore Systems', 'Taipei', 'Taiwan', 'sales@netcore.example.com', 20),
  (5, 'Noida Circuitry Works', 'Noida', 'India', 'supply@circuitry.example.com', 7),
  (6, 'Pune PrecisionMolds', 'Pune', 'India', 'care@precisionmolds.example.com', 6),
  (7, 'Chennai Smart Devices Pvt Ltd', 'Chennai', 'India', 'b2b@smartdevices.example.com', 8),
  (8, 'Hanoi Digital Manufacturing', 'Hanoi', 'Vietnam', 'sales@hanoidigital.example.com', 24),
  (9, 'Bengaluru OptiLens Technologies', 'Bengaluru', 'India', 'orders@optilens.example.com', 9),
  (10, 'Seoul MemoryTech Ltd', 'Seoul', 'South Korea', 'global@memorytech.example.com', 22),
  (11, 'Hyderabad HomeAuto Solutions', 'Hyderabad', 'India', 'sales@homeauto.example.com', 10),
  (12, 'Ahmedabad Packaging & Cables Pvt Ltd', 'Ahmedabad', 'India', 'care@packcables.example.com', 5);

INSERT INTO employees (employee_id, full_name, job_title, department, manager_id, salary, hire_date) VALUES
  (1, 'Vivek Anand', 'Chief Executive Officer', 'Management', NULL, 6500000, '2019-04-01'),
  (2, 'Meenal Joshi', 'Head of Sales', 'Sales', 1, 2800000, '2019-07-15'),
  (3, 'Rohit Bhandari', 'Head of Operations', 'Operations', 1, 2600000, '2019-09-02'),
  (4, 'Anita Fernandes', 'Finance Manager', 'Finance', 1, 2400000, '2020-01-10'),
  (5, 'Sanjay Pillai', 'Head of Product', 'Product', 1, 3000000, '2019-06-03'),
  (6, 'Pallavi Ghosh', 'Marketing Manager', 'Marketing', 1, 2200000, '2020-03-02'),
  (7, 'Deepak Rawat', 'Sales Executive', 'Sales', 2, 650000, '2021-02-15'),
  (8, 'Farhan Qureshi', 'Sales Executive', 'Sales', 2, 700000, '2021-08-23'),
  (9, 'Kritika Sood', 'Senior Sales Executive', 'Sales', 2, 950000, '2020-11-09'),
  (10, 'Tushar Naik', 'Sales Executive', 'Sales', 2, 620000, '2023-01-16'),
  (11, 'Lavanya Reddy', 'Senior Sales Executive', 'Sales', 2, 1050000, '2020-06-22'),
  (12, 'Imran Sheikh', 'Product Manager', 'Product', 5, 1800000, '2021-04-05'),
  (13, 'Nisha Varghese', 'Senior Hardware Engineer', 'Product', 12, 2000000, '2020-09-14'),
  (14, 'Arvind Menon', 'QA Engineer', 'Product', 12, 880000, '2022-05-30'),
  (15, 'Gopal Yadav', 'Warehouse Supervisor', 'Operations', 3, 720000, '2020-10-12'),
  (16, 'Salman Ansari', 'Warehouse Associate', 'Operations', 15, 360000, '2022-07-04'),
  (17, 'Rekha Pandey', 'Support Lead', 'Customer Support', 3, 780000, '2021-01-18'),
  (18, 'Mohan Das', 'Support Executive', 'Customer Support', 17, 420000, '2023-03-27'),
  (19, 'Sunita Rao', 'Senior Support Specialist', 'Customer Support', 17, 820000, '2020-02-17'),
  (20, 'Harpreet Bedi', 'Accounts Executive', 'Finance', 4, 540000, '2022-11-21');

INSERT INTO products (product_id, product_name, category_id, supplier_id, cost_price, unit_price, stock_qty, reorder_level, launch_date, is_active) VALUES
  (1, 'NovaGear Pulse Smartwatch S1', 1, 1, 2900, 4999, 110, 30, '2022-07-14', 1),
  (2, 'NovaGear Pulse Smartwatch Pro', 1, 1, 5600, 8999, 6, 10, '2023-01-21', 1),
  (3, 'NovaGear FitBand 5', 1, 7, 1350, 2499, 53, 30, '2024-06-27', 1),
  (4, 'NovaGear Kids Tracker Watch', 1, 1, 1900, 3299, 1, 30, '2023-04-20', 0),
  (5, 'NovaGear Sleep Ring Lite', 1, 1, 4100, 6999, 42, 10, '2024-06-07', 1),
  (6, 'NovaGear AirBuds Neo', 2, 2, 950, 1999, 104, 30, '2024-10-12', 1),
  (7, 'NovaGear AirBuds Pro ANC', 2, 2, 2400, 4499, 6, 30, '2023-03-17', 1),
  (8, 'NovaGear BassBoom Bluetooth Speaker', 2, 2, 1600, 2999, 128, 30, '2025-04-19', 1),
  (9, 'NovaGear Studio Over-Ear Headphones', 2, 2, 3000, 5499, 31, 10, '2025-05-01', 1),
  (10, 'NovaGear Neckband Swift', 2, 7, 600, 1299, 140, 30, '2024-08-23', 1),
  (11, 'NovaGear ShieldFlex Phone Case', 3, 12, 150, 499, 219, 60, '2023-12-24', 1),
  (12, 'NovaGear TempGlass Screen Guard', 3, 12, 70, 299, 273, 60, '2023-04-13', 1),
  (13, 'NovaGear MagGrip Car Mount', 3, 6, 300, 799, 34, 60, '2024-12-21', 0),
  (14, 'NovaGear Selfie Tripod 3-in-1', 3, 6, 520, 1199, 45, 30, '2022-08-24', 1),
  (15, 'NovaGear Ring Light 10-inch', 3, 1, 700, 1499, 51, 30, '2022-07-29', 1),
  (16, 'NovaGear ErgoLift Laptop Stand', 4, 6, 800, 1799, 105, 30, '2025-03-16', 1),
  (17, 'NovaGear SilentType Wireless Keyboard', 4, 5, 750, 1599, 38, 30, '2022-04-10', 1),
  (18, 'NovaGear Glide Wireless Mouse', 4, 5, 380, 899, 184, 60, '2024-03-05', 1),
  (19, 'NovaGear USB-C Hub 7-in-1', 4, 5, 1250, 2499, 110, 30, '2025-03-21', 1),
  (20, 'NovaGear Laptop Sleeve 15.6', 4, 12, 380, 999, 85, 60, '2024-07-28', 1),
  (21, 'NovaGear SmartBulb Color 9W', 5, 11, 280, 699, 284, 60, '2022-10-31', 1),
  (22, 'NovaGear Smart Plug Wi-Fi', 5, 11, 350, 899, 237, 60, '2023-06-01', 1),
  (23, 'NovaGear VoiceHub Mini Speaker', 5, 11, 1900, 3499, 124, 30, '2024-12-23', 1),
  (24, 'NovaGear Smart Door Lock', 5, 11, 7400, 11999, 9, 10, '2022-09-19', 1),
  (25, 'NovaGear Air Purifier Home 300', 5, 8, 5800, 9499, 27, 10, '2025-04-27', 1),
  (26, 'NovaGear 20000mAh Power Bank', 6, 3, 1000, 1999, 104, 30, '2025-02-23', 1),
  (27, 'NovaGear 65W GaN Fast Charger', 6, 3, 1050, 2299, 93, 30, '2022-11-10', 1),
  (28, 'NovaGear Braided Type-C Cable 1.5m', 6, 12, 140, 499, 141, 60, '2025-05-09', 1),
  (29, 'NovaGear Wireless Charging Pad 15W', 6, 3, 580, 1299, 58, 30, '2023-09-07', 1),
  (30, 'NovaGear Solar Power Station 300W', 6, 3, 16500, 24999, 5, 10, '2022-10-31', 1),
  (31, 'NovaGear Raptor Gaming Mouse', 7, 5, 800, 1799, 99, 30, '2022-04-17', 1),
  (32, 'NovaGear Blaze Mechanical Keyboard', 7, 5, 2100, 3999, 100, 30, '2023-01-28', 1),
  (33, 'NovaGear Phantom Gaming Headset', 7, 2, 1800, 3499, 124, 30, '2024-02-12', 1),
  (34, 'NovaGear XL Gaming Mousepad', 7, 6, 300, 899, 155, 60, '2025-02-14', 0),
  (35, 'NovaGear Pro Controller Wireless', 7, 8, 1500, 2799, 93, 30, '2022-12-07', 1),
  (36, 'NovaGear HomeCam 2K Indoor', 8, 9, 1250, 2499, 89, 30, '2022-08-26', 1),
  (37, 'NovaGear OutdoorCam Weatherproof', 8, 9, 2800, 4999, 67, 30, '2024-08-21', 1),
  (38, 'NovaGear Dash Cam Drive 4K', 8, 9, 3300, 5999, 6, 10, '2023-09-10', 1),
  (39, 'NovaGear Video Doorbell', 8, 11, 3700, 6499, 26, 10, '2022-03-08', 1),
  (40, 'NovaGear Action Cam Trek 4K', 8, 9, 4700, 7999, 26, 10, '2023-11-06', 1),
  (41, 'NovaGear WiFi 6 Router AX1800', 9, 4, 2200, 3999, 49, 30, '2023-01-28', 1),
  (42, 'NovaGear Mesh WiFi 2-Pack', 9, 4, 5300, 8999, 4, 10, '2022-12-28', 1),
  (43, 'NovaGear WiFi Range Extender', 9, 4, 700, 1499, 136, 30, '2023-08-08', 1),
  (44, 'NovaGear USB WiFi Adapter AC600', 9, 4, 320, 799, 185, 60, '2024-12-14', 0),
  (45, 'NovaGear Ethernet Cable Cat6 10m', 9, 12, 120, 399, 196, 60, '2024-12-13', 1),
  (46, 'NovaGear Pocket SSD 500GB', 10, 10, 2900, 4499, 46, 30, '2022-09-05', 1),
  (47, 'NovaGear Pocket SSD 1TB', 10, 10, 5000, 7499, 1, 10, '2022-12-10', 1),
  (48, 'NovaGear Pendrive 64GB USB 3.0', 10, 10, 280, 599, 281, 60, '2023-06-02', 1),
  (49, 'NovaGear MicroSD Card 128GB', 10, 10, 450, 899, 11, 60, '2023-02-25', 1),
  (50, 'NovaGear Portable HDD 2TB', 10, 10, 3800, 5499, 28, 10, '2023-03-16', 1);

INSERT INTO customers (customer_id, full_name, email, phone, city, state, signup_date) VALUES
  (1, 'Aarav Sharma', 'aarav.sharma@example.org', NULL, 'Mumbai', 'Maharashtra', '2025-08-30'),
  (2, 'Priya Nair', 'priya.nair@example.org', NULL, 'Kolkata', 'West Bengal', '2025-04-09'),
  (3, 'Rohan Gupta', 'rohan.gupta@example.com', NULL, 'Chandigarh', 'Chandigarh', '2024-04-16'),
  (4, 'Ananya Iyer', 'ananya.iyer@example.com', NULL, 'Delhi', 'Delhi', '2025-11-25'),
  (5, 'Vikram Singh', 'vikram.singh@example.net', NULL, 'Mumbai', 'Maharashtra', '2025-12-04'),
  (6, 'Sneha Reddy', 'sneha.reddy@example.org', '+91-8414253317', 'Ahmedabad', 'Gujarat', '2024-01-13'),
  (7, 'Arjun Mehta', 'arjun.mehta@example.org', NULL, 'Delhi', 'Delhi', '2023-06-04'),
  (8, 'Kavya Menon', 'kavya.menon@example.net', '+91-8282289557', 'Lucknow', 'Uttar Pradesh', '2023-11-02'),
  (9, 'Rahul Verma', 'rahul.verma@example.org', NULL, 'Bengaluru', 'Karnataka', '2023-06-11'),
  (10, 'Isha Kapoor', 'isha.kapoor@example.com', NULL, 'Bengaluru', 'Karnataka', '2026-06-22'),
  (11, 'Siddharth Joshi', 'siddharth.joshi@example.org', '+91-7054496635', 'Lucknow', 'Uttar Pradesh', '2024-09-28'),
  (12, 'Neha Agarwal', 'neha.agarwal@example.net', '+91-7385953039', 'Pune', 'Maharashtra', '2025-02-02'),
  (13, 'Karan Malhotra', 'karan.malhotra@example.com', '+91-6737951920', 'Lucknow', 'Uttar Pradesh', '2025-08-16'),
  (14, 'Pooja Patel', 'pooja.patel@example.org', '+91-9028231061', 'Pune', 'Maharashtra', '2025-04-11'),
  (15, 'Aditya Rao', 'aditya.rao@example.net', '+91-7797092044', 'Delhi', 'Delhi', '2024-02-09'),
  (16, 'Meera Krishnan', 'meera.krishnan@example.org', '+91-9237013792', 'Chandigarh', 'Chandigarh', '2025-07-02'),
  (17, 'Imran Khan', 'imran.khan@example.net', '+91-7143996862', 'Mumbai', 'Maharashtra', '2024-04-19'),
  (18, 'Shreya Banerjee', 'shreya.banerjee@example.net', '+91-9835865784', 'Mumbai', 'Maharashtra', '2023-05-20'),
  (19, 'Nikhil Desai', 'nikhil.desai@example.com', '+91-6433183786', 'Bengaluru', 'Karnataka', '2025-01-29'),
  (20, 'Divya Pillai', 'divya.pillai@example.net', '+91-9262536106', 'Lucknow', 'Uttar Pradesh', '2024-08-20'),
  (21, 'Manish Tiwari', 'manish.tiwari@example.org', '+91-7548343199', 'Chennai', 'Tamil Nadu', '2024-01-18'),
  (22, 'Ritika Chopra', 'ritika.chopra@example.com', '+91-7523835888', 'Kochi', 'Kerala', '2025-09-05'),
  (23, 'Harsh Vardhan', 'harsh.vardhan@example.net', '+91-9901056822', 'Kochi', 'Kerala', '2023-06-30'),
  (24, 'Simran Kaur', 'simran.kaur@example.com', '+91-7827091967', 'Bengaluru', 'Karnataka', '2025-09-13'),
  (25, 'Gaurav Saxena', 'gaurav.saxena@example.com', '+91-6628678779', 'Mumbai', 'Maharashtra', '2026-01-07'),
  (26, 'Tanvi Kulkarni', 'tanvi.kulkarni@example.net', '+91-9576359385', 'Mumbai', 'Maharashtra', '2024-05-31'),
  (27, 'Abhishek Mishra', 'abhishek.mishra@example.org', '+91-9237009444', 'Mumbai', 'Maharashtra', '2023-11-04'),
  (28, 'Lakshmi Narayanan', 'lakshmi.narayanan@example.com', '+91-7710746871', 'Ahmedabad', 'Gujarat', '2025-03-19'),
  (29, 'Faizan Ahmed', 'faizan.ahmed@example.org', '+91-6293666407', 'Hyderabad', 'Telangana', '2023-06-07'),
  (30, 'Debjani Sen', 'debjani.sen@example.com', '+91-6621696661', 'Mumbai', 'Maharashtra', '2023-07-17'),
  (31, 'Yash Thakur', 'yash.thakur@example.org', '+91-6082845195', 'Bengaluru', 'Karnataka', '2025-10-12'),
  (32, 'Nandini Bose', 'nandini.bose@example.net', '+91-8728277086', 'Delhi', 'Delhi', '2026-03-15'),
  (33, 'Varun Bhatia', 'varun.bhatia@example.com', '+91-9023957379', 'Delhi', 'Delhi', '2023-08-26'),
  (34, 'Aisha Siddiqui', 'aisha.siddiqui@example.com', '+91-8141908641', 'Hyderabad', 'Telangana', '2025-11-05'),
  (35, 'Pranav Deshmukh', 'pranav.deshmukh@example.net', '+91-8546288192', 'Chennai', 'Tamil Nadu', '2023-04-17'),
  (36, 'Sakshi Jain', 'sakshi.jain@example.net', '+91-8042739571', 'Ahmedabad', 'Gujarat', '2025-08-29'),
  (37, 'Omkar Patil', 'omkar.patil@example.net', '+91-6478751844', 'Lucknow', 'Uttar Pradesh', '2025-02-21'),
  (38, 'Jasleen Gill', 'jasleen.gill@example.org', '+91-8123217035', 'Delhi', 'Delhi', '2023-08-22'),
  (39, 'Mohit Chauhan', 'mohit.chauhan@example.com', '+91-9886560662', 'Kolkata', 'West Bengal', '2025-03-18'),
  (40, 'Radhika Shetty', 'radhika.shetty@example.org', '+91-6442035752', 'Hyderabad', 'Telangana', '2023-06-28'),
  (41, 'Tarun Yadav', 'tarun.yadav@example.com', '+91-8491237546', 'Mumbai', 'Maharashtra', '2024-07-08'),
  (42, 'Ishita Ghosh', 'ishita.ghosh@example.org', '+91-8490716068', 'Bengaluru', 'Karnataka', '2026-03-02'),
  (43, 'Kunal Shah', 'kunal.shah@example.com', '+91-9049875231', 'Hyderabad', 'Telangana', '2026-06-30'),
  (44, 'Anjali Dubey', 'anjali.dubey@example.com', '+91-9388035026', 'Ahmedabad', 'Gujarat', '2026-02-28'),
  (45, 'Dev Pandey', 'dev.pandey@example.org', '+91-6254881866', 'Chennai', 'Tamil Nadu', '2026-02-23'),
  (46, 'Sana Sheikh', 'sana.sheikh@example.com', '+91-7353981263', 'Bengaluru', 'Karnataka', '2025-07-18'),
  (47, 'Rajat Bansal', 'rajat.bansal@example.com', '+91-7764845187', 'Delhi', 'Delhi', '2026-01-27'),
  (48, 'Bhavna Rathore', 'bhavna.rathore@example.com', '+91-8766251038', 'Chennai', 'Tamil Nadu', '2025-09-23'),
  (49, 'Suresh Babu', 'suresh.babu@example.com', '+91-7215015610', 'Chennai', 'Tamil Nadu', '2023-05-26'),
  (50, 'Zoya Mirza', 'zoya.mirza@example.org', '+91-7062510842', 'Chennai', 'Tamil Nadu', '2025-02-13');

INSERT INTO orders (order_id, customer_id, employee_id, order_date, status, payment_method, delivery_date) VALUES
  (1, 18, 8, '2025-06-28', 'Delivered', 'Credit Card', '2025-07-01'),
  (2, 37, 8, '2025-07-30', 'Cancelled', 'Net Banking', NULL),
  (3, 35, 9, '2025-09-03', 'Delivered', 'Debit Card', '2025-09-10'),
  (4, 8, 8, '2025-09-09', 'Delivered', 'Credit Card', '2025-09-18'),
  (5, 49, 7, '2025-09-16', 'Delivered', 'Debit Card', '2025-09-24'),
  (6, 24, 7, '2025-09-17', 'Delivered', 'Debit Card', '2025-09-25'),
  (7, 28, 7, '2025-09-21', 'Delivered', 'Debit Card', '2025-09-26'),
  (8, 13, 8, '2025-10-05', 'Delivered', 'Credit Card', '2025-10-13'),
  (9, 41, 9, '2025-11-19', 'Delivered', 'Credit Card', '2025-11-23'),
  (10, 6, 10, '2025-11-21', 'Cancelled', 'Credit Card', NULL),
  (11, 21, 11, '2025-11-24', 'Delivered', 'UPI', '2025-11-27'),
  (12, 2, 10, '2025-11-29', 'Cancelled', 'UPI', NULL),
  (13, 28, 11, '2025-12-02', 'Cancelled', 'UPI', NULL),
  (14, 37, 7, '2026-01-11', 'Cancelled', 'Cash on Delivery', NULL),
  (15, 24, 9, '2026-01-15', 'Delivered', 'Credit Card', '2026-01-20'),
  (16, 48, 9, '2026-01-16', 'Delivered', 'UPI', '2026-01-21'),
  (17, 5, 9, '2026-02-11', 'Cancelled', 'Debit Card', NULL),
  (18, 18, 11, '2026-02-12', 'Delivered', 'Credit Card', '2026-02-17'),
  (19, 9, 7, '2026-02-19', 'Delivered', 'Credit Card', '2026-02-24'),
  (20, 44, 11, '2026-03-10', 'Delivered', 'Debit Card', '2026-03-18'),
  (21, 14, 11, '2026-03-11', 'Delivered', 'Credit Card', '2026-03-15'),
  (22, 47, 8, '2026-03-24', 'Delivered', 'UPI', '2026-03-28'),
  (23, 17, 9, '2026-04-17', 'Delivered', 'Credit Card', '2026-04-23'),
  (24, 18, 11, '2026-04-17', 'Delivered', 'Net Banking', '2026-04-21'),
  (25, 3, 9, '2026-05-07', 'Cancelled', 'Credit Card', NULL),
  (26, 29, 7, '2026-05-07', 'Delivered', 'UPI', '2026-05-11'),
  (27, 28, 9, '2026-05-13', 'Delivered', 'Credit Card', '2026-05-18'),
  (28, 39, 10, '2026-05-24', 'Cancelled', 'Credit Card', NULL),
  (29, 44, 7, '2026-06-02', 'Delivered', 'Debit Card', '2026-06-09'),
  (30, 21, 11, '2026-06-04', 'Delivered', 'Debit Card', '2026-06-07'),
  (31, 13, 7, '2026-06-06', 'Delivered', 'Net Banking', '2026-06-12'),
  (32, 34, 11, '2026-06-10', 'Delivered', 'UPI', '2026-06-15'),
  (33, 28, 9, '2026-06-12', 'Delivered', 'UPI', '2026-06-15'),
  (34, 44, 11, '2026-06-20', 'Delivered', 'Cash on Delivery', '2026-06-29'),
  (35, 46, 8, '2026-07-06', 'Cancelled', 'UPI', NULL),
  (36, 6, 11, '2026-07-08', 'Delivered', 'Credit Card', '2026-07-11'),
  (37, 4, 11, '2026-07-15', 'Delivered', 'UPI', '2026-07-19'),
  (38, 44, 9, '2026-08-15', 'Delivered', 'Net Banking', '2026-08-19'),
  (39, 32, 11, '2026-08-22', 'Delivered', 'Debit Card', '2026-08-31'),
  (40, 45, 8, '2026-08-27', 'Delivered', 'Debit Card', '2026-08-29'),
  (41, 48, 8, '2026-09-02', 'Delivered', 'UPI', '2026-09-06'),
  (42, 23, 7, '2026-09-27', 'Delivered', 'UPI', '2026-10-01'),
  (43, 12, 9, '2026-09-29', 'Delivered', 'Credit Card', '2026-10-03'),
  (44, 21, 7, '2026-10-17', 'Cancelled', 'Net Banking', NULL),
  (45, 9, 7, '2026-10-22', 'Shipped', 'UPI', NULL),
  (46, 43, 11, '2026-10-24', 'Shipped', 'Net Banking', NULL),
  (47, 24, 9, '2026-10-27', 'Shipped', 'Credit Card', NULL),
  (48, 22, 11, '2026-10-29', 'Processing', 'Cash on Delivery', NULL),
  (49, 11, 9, '2026-10-31', 'Processing', 'Debit Card', NULL),
  (50, 24, 11, '2026-10-31', 'Processing', 'Net Banking', NULL);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price, discount_percent) VALUES
  (1, 1, 22, 3, 899, 0),
  (2, 3, 41, 1, 3999, 5),
  (3, 3, 11, 1, 499, 0),
  (4, 4, 17, 1, 1599, 0),
  (5, 5, 17, 1, 1599, 0),
  (6, 6, 27, 1, 2299, 10),
  (7, 7, 12, 2, 299, 0),
  (8, 8, 28, 3, 499, 0),
  (9, 9, 35, 1, 2799, 0),
  (10, 9, 31, 1, 1799, 10),
  (11, 11, 32, 1, 3999, 10),
  (12, 15, 37, 2, 4999, 5),
  (13, 16, 45, 3, 399, 0),
  (14, 18, 38, 1, 5999, 0),
  (15, 19, 49, 1, 899, 5),
  (16, 20, 48, 3, 599, 5),
  (17, 21, 39, 1, 6499, 5),
  (18, 21, 1, 3, 4999, 0),
  (19, 22, 29, 3, 1299, 0),
  (20, 23, 3, 1, 2499, 0),
  (21, 24, 9, 1, 5499, 15),
  (22, 26, 18, 2, 899, 10),
  (23, 26, 23, 3, 3499, 10),
  (24, 27, 16, 1, 1799, 5),
  (25, 29, 26, 1, 1999, 5),
  (26, 30, 8, 1, 2999, 5),
  (27, 30, 21, 1, 699, 10),
  (28, 31, 19, 2, 2499, 5),
  (29, 31, 42, 1, 8999, 0),
  (30, 32, 7, 1, 4499, 0),
  (31, 32, 15, 1, 1499, 0),
  (32, 33, 6, 2, 1999, 0),
  (33, 33, 11, 2, 499, 5),
  (34, 34, 47, 1, 7499, 5),
  (35, 36, 29, 3, 1299, 0),
  (36, 37, 14, 2, 1199, 0),
  (37, 38, 21, 1, 699, 5),
  (38, 39, 14, 2, 1199, 10),
  (39, 40, 47, 1, 7499, 15),
  (40, 41, 10, 2, 1299, 5),
  (41, 42, 45, 1, 399, 0),
  (42, 43, 2, 1, 8999, 0),
  (43, 45, 39, 1, 6499, 10),
  (44, 46, 3, 3, 2499, 0),
  (45, 47, 19, 3, 2499, 0),
  (46, 47, 36, 1, 2499, 10),
  (47, 48, 33, 3, 3499, 5),
  (48, 49, 2, 1, 8999, 10),
  (49, 50, 35, 3, 2799, 0),
  (50, 50, 24, 1, 11999, 0);

INSERT INTO reviews (review_id, product_id, customer_id, rating, review_text, review_date, verified_purchase) VALUES
  (1, 47, 35, 4, 'Good value for money.', '2023-08-06', 0),
  (2, 6, 19, 4, 'Very good product, minor room for improvement.', '2025-03-13', 0),
  (3, 11, 35, 4, 'Solid build and reliable so far.', '2025-09-18', 1),
  (4, 41, 35, 2, 'Not worth the price, disappointed.', '2025-09-24', 1),
  (5, 45, 20, 2, 'Quality is below expectations.', '2025-09-28', 0),
  (6, 17, 49, 3, 'Okay for the price, nothing special.', '2025-10-03', 1),
  (7, 27, 24, 5, 'Superb performance and quick delivery.', '2025-10-07', 1),
  (8, 12, 28, 4, 'Very good product, minor room for improvement.', '2025-10-07', 1),
  (9, 28, 13, 4, 'Happy with it, battery could be better.', '2025-11-02', 1),
  (10, 35, 41, 5, 'Excellent quality, totally worth the price.', '2025-11-29', 1),
  (11, 32, 21, 3, 'Average product, does the job.', '2025-12-18', 1),
  (12, 31, 41, 3, 'Okay for the price, nothing special.', '2025-12-18', 1),
  (13, 46, 37, 3, 'Decent but expected a bit more.', '2026-01-13', 0),
  (14, 45, 48, 5, 'Superb performance and quick delivery.', '2026-02-06', 1),
  (15, 21, 28, 5, 'Excellent quality, totally worth the price.', '2026-02-11', 0),
  (16, 15, 9, 5, 'Superb performance and quick delivery.', '2026-03-02', 0),
  (17, 49, 9, 4, 'Good value for money.', '2026-03-17', 1),
  (18, 19, 27, 4, 'Very good product, minor room for improvement.', '2026-03-17', 0),
  (19, 48, 44, 4, 'Good value for money.', '2026-03-20', 1),
  (20, 39, 14, 4, 'Good value for money.', '2026-03-21', 1),
  (21, 1, 14, 5, 'Superb performance and quick delivery.', '2026-04-07', 1),
  (22, 29, 47, 2, 'Stopped working properly after a few weeks.', '2026-04-11', 1),
  (23, 3, 17, 5, 'Works flawlessly. Highly recommended!', '2026-05-03', 1),
  (24, 23, 29, 4, 'Very good product, minor room for improvement.', '2026-06-02', 1),
  (25, 18, 29, 5, 'Superb performance and quick delivery.', '2026-06-05', 1),
  (26, 16, 28, 4, 'Good value for money.', '2026-06-08', 1),
  (27, 8, 21, 2, 'Not worth the price, disappointed.', '2026-06-20', 1),
  (28, 11, 28, 5, 'Excellent quality, totally worth the price.', '2026-06-20', 1),
  (29, 19, 13, 4, 'Good value for money.', '2026-06-26', 1),
  (30, 46, 24, 3, 'Works fine but packaging was poor.', '2026-06-27', 0),
  (31, 7, 34, 5, 'Best purchase this year, great build quality.', '2026-06-27', 1),
  (32, 6, 28, 3, 'Average product, does the job.', '2026-06-28', 1),
  (33, 26, 44, 4, 'Very good product, minor room for improvement.', '2026-06-28', 1),
  (34, 21, 21, 3, 'Okay for the price, nothing special.', '2026-07-01', 1),
  (35, 42, 13, 4, 'Happy with it, battery could be better.', '2026-07-05', 1),
  (36, 15, 34, 4, 'Good value for money.', '2026-07-08', 1),
  (37, 49, 4, 5, 'Works flawlessly. Highly recommended!', '2026-07-14', 0),
  (38, 47, 44, 4, 'Happy with it, battery could be better.', '2026-07-17', 1),
  (39, 29, 6, 3, 'Okay for the price, nothing special.', '2026-07-22', 1),
  (40, 34, 1, 4, 'Good value for money.', '2026-07-30', 0),
  (41, 32, 46, 4, 'Happy with it, battery could be better.', '2026-07-31', 0),
  (42, 2, 36, 4, 'Happy with it, battery could be better.', '2026-08-06', 0),
  (43, 5, 1, 5, 'Best purchase this year, great build quality.', '2026-08-19', 0),
  (44, 19, 29, 4, 'Solid build and reliable so far.', '2026-09-05', 0),
  (45, 21, 44, 5, 'Best purchase this year, great build quality.', '2026-09-12', 1),
  (46, 10, 48, 4, 'Good value for money.', '2026-09-19', 1),
  (47, 47, 45, 4, 'Solid build and reliable so far.', '2026-09-23', 1),
  (48, 14, 32, 5, 'Excellent quality, totally worth the price.', '2026-09-25', 1),
  (49, 2, 12, 4, 'Solid build and reliable so far.', '2026-10-06', 1),
  (50, 45, 23, 4, 'Happy with it, battery could be better.', '2026-10-14', 1);

-- ---------------------------------------------------------------------
-- 3. QUICK CHECK  (run this after loading - row counts should match)
-- ---------------------------------------------------------------------
SELECT 'categories' AS table_name, COUNT(*) AS total_rows FROM categories
UNION ALL SELECT 'suppliers',   COUNT(*) FROM suppliers
UNION ALL SELECT 'employees',   COUNT(*) FROM employees
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'customers',   COUNT(*) FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'reviews',     COUNT(*) FROM reviews;


-- Marketing is planning a premium-gadgets campaign and only wants products we are still selling that cost more
-- than ₹3,000. Pull that list so the designers can start on banners. Most expensive first, please.

SELECT
	product_name,
    unit_price,
    stock_qty
FROM products
WHERE is_active = 1 AND cost_price > 3000
ORDER BY cost_price DESC;


-- “Last week we ran out of a bestseller because nobody noticed it was running low. The warehouse wants a daily alert
-- list: every active product whose stock has dropped to or below its reorder level, and by how many units it is short.
-- Biggest shortage on top.”


SELECT 
	product_name,
    stock_qty,
    reorder_level,
    reorder_level - stock_qty AS shortfall
FROM products
ORDER BY shortfall DESC;


-- “Our support agents cannot call customers about delivery problems when the phone number is blank. Pull the
-- customers from Delhi, Mumbai and Bengaluru who have no phone number on file, so the team can ask for it by
-- email.”


SELECT 
	full_name,
    email,
    city
FROM customers
WHERE city IN ('Delhi','Mumbai','Bengaluru') and phone IS NULL
ORDER BY city,full_name;


-- “The CEO walks into a board meeting in an hour and wants a single-line snapshot of our active catalogue: how
-- many products, the average price, the highest and lowest price, total units sitting in stock, and what that stock is
-- worth at cost price. One row, please.”

SELECT 
	COUNT(product_name) AS total_product,
    ROUND(AVG(unit_price),2) AS avg_price,
    MAX(unit_price) AS max_price,
    MIN(unit_price) AS min_price,
    SUM(unit_price) AS total_units,
    SUM(cost_price*stock_qty) AS inventory_value_at_cost
FROM products;


-- “Finance is renegotiating fees with paymen-- t gateways. Before that call they need to know how many orders each
-- payment method handled. Cancelled orders never completed, so leave them out. Most-used method first.”


SELECT 
	payment_method,
    COUNT(payment_method) AS total_orders
FROM orders
WHERE status != 'Cancelled'
GROUP BY payment_method;


-- “HR is preparing the annual compensation review. For every department that has more than 2 employees, show the
-- headcount, average salary and highest salary. Averages of one or two people are not meaningful, so skip tiny
-- departments. Best-paying departments first.”

SELECT * FROM employees;

SELECT
	department,
    COUNT(department) AS headcount,
    ROUND(AVG(salary),2) AS avg_salary,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department
HAVING headcount > 2
ORDER BY headcount DESC;


-- “Product wants to double down on high-margin items. Build a Top 10 ranked by profit margin percentage (profit
-- divided by selling price). Show the category name and supplier name, not IDs. Nobody reads IDs in a meeting.”


SELECT 
	p.product_name,
    c.category_name,
    s.supplier_name,
    p.unit_price - p.cost_price AS margin,
    ROUND(((unit_price - cost_price) * 100 / unit_price),1) AS margin_pct
FROM products p
INNER JOIN categories c
ON p.category_id = c.category_id
INNER JOIN suppliers s
ON p.supplier_id = s.supplier_id
ORDER BY margin_pct DESC
LIMIT 10;


-- “The quarterly review is coming up. Show the total units sold and total revenue for every product category, best
-- category first. Remember we give discounts, so revenue is not just price times quantity. Use: quantity * unit_price
-- * (1 - discount_percent/100) from order_items.”


SELECT 
	c.category_name,
    SUM(p.unit_price) AS total_units,
    ROUND(SUM((o.quantity * o.unit_price) * (1 - o.discount_percent/100)),2) AS discount_revenue
FROM categories c
INNER JOIN products p
ON c.category_id = p.category_id
INNER JOIN order_items o
ON o.product_id = p.product_id
GROUP BY c.category_name;

-- “Some people registered on our website but never placed an order, not even one that was later cancelled. Marketing
-- wants to send them a first-order coupon. List them with the oldest sign-ups first, because those are the coldest
-- leads.”

SELECT * FROM customers;
SELECT * FROM orders;

SELECT 
	c.full_name,
    c.email,
    c.signup_date
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL
ORDER BY c.signup_date ASC;


-- “Time for the quarterly sales-team review. For each Sales Executive (any job title containing 'Sales Executive',
-- including Senior), show how many orders they handled and the total revenue from them. Include reps with zero
-- revenue and show 0, not NULL. Careful: an order with 2 items will be counted twice if you are not careful.”








 

    