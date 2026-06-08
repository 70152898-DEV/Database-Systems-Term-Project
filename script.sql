-- ============================================================================
-- UNIVERSITY OF LAHORE - DEPARTMENT OF COMPUTER SCIENCE & IT
-- COURSE: DATABASE SYSTEMS (SPRING 2026)
-- LAB PROJECT: VEHICLE DEALERSHIP MANAGEMENT SYSTEM (POSTGRESQL DIALECT)
-- SECTION: BSCS-5B
-- MEMBERS:
--         1. Akhnas Furqan 70152898
--         2. Hassan Khalid 70153477
--         3. M. Saad Tahir 70147067
-- ============================================================================

-- ==========================================
-- 1: DATA DEFINITION LANGUAGE (DDL)
-- ==========================================

-- Drop tables in reverse order of dependencies to avoid constraint violations
DROP TABLE IF EXISTS PAYMENTS CASCADE;
DROP TABLE IF EXISTS SALES CASCADE;
DROP TABLE IF EXISTS VEHICLES_INVENTORY CASCADE;
DROP TABLE IF EXISTS VEHICLE_MODELS CASCADE;
DROP TABLE IF EXISTS VEHICLE_BRANDS CASCADE;
DROP TABLE IF EXISTS EMPLOYEES CASCADE;
DROP TABLE IF EXISTS EMPLOYEE_ROLE CASCADE;
DROP TABLE IF EXISTS DEPARTMENTS CASCADE;
DROP TABLE IF EXISTS CUSTOMERS CASCADE;

-- 1.1 Customer Information Table
CREATE TABLE CUSTOMERS (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE,
    address TEXT NOT NULL,
    customer_since DATE NOT NULL DEFAULT CURRENT_DATE
);

-- 1.2 Dealership Structure Tables
CREATE TABLE DEPARTMENTS (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE EMPLOYEE_ROLE (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE EMPLOYEES (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    salary NUMERIC(12, 2) NOT NULL CHECK (salary > 0),
    department_id INT NOT NULL,
    employee_role_id INT NOT NULL,
    FOREIGN KEY (department_id) REFERENCES DEPARTMENTS(department_id) ON DELETE RESTRICT,
    FOREIGN KEY (employee_role_id) REFERENCES EMPLOYEE_ROLE(role_id) ON DELETE RESTRICT
);

-- 1.3 Inventory & Vehicle Tables
CREATE TABLE VEHICLE_BRANDS (
    brand_id SERIAL PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE VEHICLE_MODELS (
    model_id SERIAL PRIMARY KEY,
    brand_id INT NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES VEHICLE_BRANDS(brand_id) ON DELETE CASCADE,
    CONSTRAINT unique_brand_model UNIQUE (brand_id, model_name)
);

CREATE TABLE VEHICLES_INVENTORY (
    vehicle_id SERIAL PRIMARY KEY,
    chassis_no VARCHAR(50) NOT NULL UNIQUE,
    registration_number VARCHAR(30) UNIQUE, 
    model_id INT NOT NULL,
    manufacture_year INT NOT NULL,
    color VARCHAR(30) NOT NULL,
    mileage INT NOT NULL DEFAULT 0 CHECK (mileage >= 0),
    fuel_type VARCHAR(30) NOT NULL,
    transmission VARCHAR(30) NOT NULL,
    purchase_price NUMERIC(14, 2) NOT NULL CHECK (purchase_price > 0), 
    sale_price NUMERIC(14, 2) NOT NULL CHECK (sale_price > 0),     
    status VARCHAR(30) NOT NULL DEFAULT 'In Stock' CHECK (status IN ('In Stock', 'Sold', 'Reserved')),
    FOREIGN KEY (model_id) REFERENCES VEHICLE_MODELS(model_id) ON DELETE RESTRICT
);

-- 1.4 Sales & Transactions Tables
CREATE TABLE SALES (
    sale_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    vehicle_id INT NOT NULL UNIQUE, -- Enforces 1:1 physical unit sale logic
    salesperson_id INT NOT NULL,
    sale_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount NUMERIC(14, 2) NOT NULL CHECK (total_amount > 0),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'Pending' CHECK (payment_status IN ('Pending', 'Partial', 'Completed')),
    FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (vehicle_id) REFERENCES VEHICLES_INVENTORY(vehicle_id) ON DELETE RESTRICT,
    FOREIGN KEY (salesperson_id) REFERENCES EMPLOYEES(employee_id) ON DELETE RESTRICT
);

CREATE TABLE PAYMENTS (
    payment_id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    amount NUMERIC(14, 2) NOT NULL CHECK (amount > 0),
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    method VARCHAR(50) NOT NULL CHECK (method IN ('Bank Transfer', 'Pay Order', 'Cash', 'Cheque')),
    FOREIGN KEY (sale_id) REFERENCES SALES(sale_id) ON DELETE CASCADE
);


-- ==========================================
-- 2: DATA MANIPULATION LANGUAGE (DML)
-- ==========================================

-- 2.1 Brands & Models
INSERT INTO VEHICLE_BRANDS (brand_name) VALUES 
('Toyota'), ('Honda'), ('Suzuki'), ('Kia'), ('Hyundai');

INSERT INTO VEHICLE_MODELS (brand_id, model_name) VALUES 
(1, 'Corolla Altis X'), (1, 'Yaris ATIV X'),
(2, 'Civic Oriel'), (2, 'City Aspire'),
(3, 'Swift GLX'),
(4, 'Sportage AWD'), 
(5, 'Tucson AWD');

-- 2.2 Showroom Departments & Roles
INSERT INTO DEPARTMENTS (department_id, department_name) VALUES 
(1, 'Executive Management'), 
(2, 'Showroom Sales'), 
(3, 'Finance & Accounts'), 
(4, 'Post-Sale Workshop');

INSERT INTO EMPLOYEE_ROLE (role_id, role_name) VALUES 
(1, 'General Manager'), 
(2, 'Sales Relationship Manager'), 
(3, 'Senior Accountant'), 
(4, 'Showroom Consultant');

-- Adjust the internal sequence numbers so PostgreSQL SERIAL behaves properly after manual ID inserts
SELECT setval(pg_get_serial_sequence('DEPARTMENTS', 'department_id'), COALESCE(MAX(department_id), 1)) FROM DEPARTMENTS;
SELECT setval(pg_get_serial_sequence('EMPLOYEE_ROLE', 'role_id'), COALESCE(MAX(role_id), 1)) FROM EMPLOYEE_ROLE;

-- 2.3 Corporate Employees
INSERT INTO EMPLOYEES (employee_id, first_name, last_name, phone, email, hire_date, salary, department_id, employee_role_id) VALUES 
(1, 'Muhammad', 'Ali', '+923001112233', 'm.ali@dealership.pk', '2022-01-15', 250000.00, 1, 1),
(2, 'Zainab', 'Fatima', '+923214445566', 'z.fatima@dealership.pk', '2023-03-10', 95000.00, 2, 2),
(3, 'Asif', 'Raza', '+923337778899', 'a.raza@dealership.pk', '2024-05-20', 120000.00, 3, 3),
(4, 'Bilal', 'Khan', '+923459990011', 'b.khan@dealership.pk', '2025-02-01', 75000.00, 2, 4),
(5, 'Sana', 'Malik', '+923032223344', 'sana.malik@dealership.pk', '2026-06-01', 75000.00, 2, 4),
(6, 'Hamza', 'Shahzad', '+923156667788', 'h.shahzad@dealership.pk', '2023-08-14', 110000.00, 2, 2),
(7, 'Ayesha', 'Rehman', '+923223334455', 'a.rehman@dealership.pk', '2024-01-10', 130000.00, 3, 3),
(8, 'Osman', 'Dawood', '+923008889900', 'o.dawood@dealership.pk', '2021-11-05', 280000.00, 1, 1),
(9, 'Mariam', 'Javed', '+923345556677', 'm.javed@dealership.pk', '2025-05-12', 72000.00, 2, 4),
(10, 'Faisal', 'Iqbal', '+923451119922', 'f.iqbal@dealership.pk', '2025-09-18', 70000.00, 2, 4),
(11, 'Khadija', 'Mansoor', '+923218881144', 'k.mansoor@dealership.pk', '2024-07-22', 85000.00, 2, 4),
(12, 'Umer', 'Siddiqui', '+923014443322', 'u.siddiqui@dealership.pk', '2023-11-30', 105000.00, 3, 3),
(13, 'Nida', 'Farooq', '+923332228899', 'n.farooq@dealership.pk', '2025-03-15', 73000.00, 2, 4),
(14, 'Haris', 'Rauf', '+923127774411', 'h.rauf@dealership.pk', '2026-02-10', 90000.00, 2, 2),
(15, 'Tayyaba', 'Bano', '+923456665544', 't.bano@dealership.pk', '2024-09-05', 78000.00, 2, 4);

SELECT setval(pg_get_serial_sequence('EMPLOYEES', 'employee_id'), COALESCE(MAX(employee_id), 1)) FROM EMPLOYEES;

-- 2.4 Customer Entities
INSERT INTO CUSTOMERS (first_name, last_name, phone, email, address, customer_since) VALUES
('Hamza', 'Ahmed', '+923015556677', 'hamza.ahmed@gmail.com', 'House 142, Block Y, DHA Phase 3, Lahore', '2025-01-10'),
('Ayesha', 'Siddiqui', '+923126667788', 'ayesha.sid@yahoo.com', 'Apartment 4B, Creek Vista, Phase 8, DHA, Karachi', '2025-01-12'),
('Umer', 'Farooq', '+923227778899', 'umer.farooq@outlook.com', 'House 19-B, Main Nazimuddin Road, F-10/2, Islamabad', '2025-02-01'),
('Bilal', 'Mansoor', '+923004445511', 'bilal.mansoor@gmail.com', 'House 88, Sector C, Bahria Town, Lahore', '2025-02-14'),
('Sana', 'Javed', '+923332221100', 'sana.j@hotmail.com', 'Street 5, Askari 11, Bedian Road, Lahore', '2025-03-01'),
('Zain', 'Mehmood', '+923456663322', 'zain.mehmood@gmail.com', 'House 250, Block G3, Johar Town, Lahore', '2025-03-15'),
('Fatima', 'Ali', '+923219998877', 'fatima.ali@live.com', 'Khayaban-e-Shahbaz, Phase 6, DHA, Karachi', '2025-04-02'),
('Mustafa', 'Kamal', '+923028884433', 'mustafa.k@gmail.com', 'Main Auto Bhan Road, Latifabad Unit 2, Hyderabad', '2025-04-18'),
('Mariam', 'Khan', '+923157776655', 'mariam.khan@gmail.com', 'House 12, Street 44, F-7/1, Islamabad', '2025-05-05'),
('Usman', 'Ghani', '+923341112233', 'usman.ghani@yahoo.com', 'Sector G, Phase 2, Hayatabad, Peshawar', '2025-05-20'),
('Amna', 'Sheikh', '+923005559911', 'amna.s@gmail.com', 'Block 3, Gulshan-e-Iqbal, Karachi', '2025-06-01'),
('Asad', 'Raza', '+923214449988', 'asad.raza@outlook.com', 'House 99, Main Boulevard, Gulberg 3, Lahore', '2025-06-11'),
('Khadija', 'Bibi', '+923451117766', 'khadija.b@gmail.com', 'Street 2, Saddar Bazaar, Rawalpindi', '2025-07-04'),
('Faisal', 'Iqbal', '+923338883344', 'faisal.iqbal@gmail.com', 'House 14, Civil Lines, Gujranwala', '2025-07-22'),
('Hira', 'Shah', '+923013334455', 'hira.shah@gmail.com', 'Block B, North Nazimabad, Karachi', '2025-08-01'),
('Saad', 'Malik', '+923122229900', 'saad.malik@live.com', 'House 412, Sector E, DHA Phase 1, Islamabad', '2025-08-15'),
('Nida', 'Yasir', '+923225551122', 'nida.yasir@yahoo.com', 'House 67, Garden Town, Multan', '2025-09-02'),
('Ali', 'Hassan', '+923007772211', 'ali.hassan@gmail.com', 'Street 9, Peoples Colony No 1, Faisalabad', '2025-09-19'),
('Zoya', 'Rehman', '+923348885566', 'zoya.r@gmail.com', 'Apartment 12-C, Navy Housing Scheme, Kalma Chowk, Lahore', '2025-10-05'),
('Waqas', 'Jameel', '+923454448899', 'waqas.j@gmail.com', 'House 31, Sector B, Askari 14, Rawalpindi', '2025-10-25'),
('Tayyaba', 'Bano', '+923211110099', 'tayyaba.b@gmail.com', 'House 102, Main Road, Samanabad, Lahore', '2025-11-01'),
('Raza', 'Naqvi', '+923023337766', 'raza.naqvi@gmail.com', 'Street 4, Sector G-9/3, Islamabad', '2025-11-12'),
('Maham', 'Tariq', '+923136662211', 'maham.t@yahoo.com', 'Khayaban-e-Seher, Phase 6, DHA, Karachi', '2025-12-03'),
('Daniyal', 'Aziz', '+923335550011', 'daniyal.aziz@gmail.com', 'House 56, Block H, Valencia Town, Lahore', '2025-12-18'),
('Saba', 'Parveen', '+923458881122', 'saba.p@live.com', 'Street 11, Model Town, Sialkot', '2026-01-02'),
('Adnan', 'Siddique', '+923019994433', 'adnan.sid@gmail.com', 'House 73, Cavalry Ground, Lahore Cantt, Lahore', '2026-01-15'),
('Mehak', 'Lodhi', '+923124440099', 'mehak.l@gmail.com', 'Apartment A7, Maymar Towers, Gulshan-e-Iqbal, Karachi', '2026-02-01'),
('Haris', 'Rauf', '+923221115566', 'haris.rauf@outlook.com', 'House 19, Sector F, Bahria Town, Islamabad', '2026-02-14'),
('Rimsha', 'Ijaz', '+923002228877', 'rimsha.i@gmail.com', 'Street 3, New Town, Sargodha', '2026-03-01'),
('Arsalan', 'Baig', '+923347771122', 'arsalan.b@yahoo.com', 'House 82, Block D, WAPDA Town, Lahore', '2026-03-10'),
('Kiran', 'Abid', '+923453336677', 'kiran.abid@gmail.com', 'Khayaban-e-Rahat, Phase 6, DHA, Karachi', '2026-04-02'),
('Shahid', 'Afridi', '+923025553311', 'shahid.a@gmail.com', 'House 10, Sector E-7, Islamabad', '2026-04-15'),
('Javerya', 'Khan', '+923152229988', 'javerya.k@live.com', 'House 22, Shami Road, Peshawar Cantt, Peshawar', '2026-05-01'),
('Nabeel', 'Qureshi', '+923334449900', 'nabeel.q@gmail.com', 'Apartment 9, Paragon City, Barki Road, Lahore', '2026-05-18'),
('Iqra', 'Aziz', '+923017770022', 'iqra.aziz@gmail.com', 'Block 13-D, Gulshan-e-Iqbal, Karachi', '2026-06-01'),
('Adeel', 'Chaudhry', '+923218885544', 'adeel.c@outlook.com', 'House 115, Sector A, Askari 10, Lahore', '2026-06-12'),
('Fareeha', 'Anjum', '+923452224411', 'fareeha.a@gmail.com', 'Street 7, Lalazar Colony, Rawalpindi', '2026-07-02'),
('Zeeshan', 'Ashraf', '+923349993355', 'zeeshan.a@yahoo.com', 'House 44, Muslim Town, Faisalabad', '2026-07-20'),
('Sehrish', 'Munir', '+923021117788', 'sehrish.m@gmail.com', 'House 204, Block J, Sector 2, Bahria Orchard, Lahore', '2026-08-01'),
('Taimoor', 'Salahuddin', '+923135554433', 'taimoor.s@gmail.com', 'Khayaban-e-Tanzeem, Phase 5, DHA, Karachi', '2026-08-16'),
('Amina', 'Haq', '+923224448811', 'amina.haq@live.com', 'House 3, Street 18, F-8/2, Islamabad', '2026-09-02'),
('Waseem', 'Akram', '+923008881122', 'waseem.a@gmail.com', 'House 77, Main Boulevard, DHA Phase 6, Lahore', '2026-09-18'),
('Bushra', 'Ansari', '+923336660099', 'bushra.a@yahoo.com', 'Block 4, PECHS, Karachi', '2026-10-01'),
('Kamran', 'Akmal', '+923451112288', 'kamran.a@gmail.com', 'House 90, Block C, Model Town, Lahore', '2026-10-12'),
('Sadia', 'Imam', '+923012225544', 'sadia.imam@gmail.com', 'Street 15, Sector H-11, Islamabad', '2026-11-01'),
('Fahad', 'Mustafa', '+923129994455', 'fahad.m@gmail.com', 'Apartment 301, Regency Apartments, Clifton, Karachi', '2026-11-15'),
('Momina', 'Mustehsan', '+923226663300', 'momina.m@outlook.com', 'House 142, Sector C, DHA Phase 2, Islamabad', '2026-12-02'),
('Bilal', 'Ashraf', '+923004441199', 'bilal.ashraf@gmail.com', 'House 5, Street 2, Cantt View Colony, Multan', '2026-12-19'),
('Sajal', 'Aly', '+923345558877', 'sajal.aly@gmail.com', 'House 88, Block K, Gulberg 2, Lahore', '2027-01-05'),
('Ahad', 'Raza', '+923457770011', 'ahad.raza@yahoo.com', 'Khayaban-e-Badban, Phase 7, DHA, Karachi', '2027-01-20');

-- 2.5 Showroom Fleet Inventory
INSERT INTO VEHICLES_INVENTORY (chassis_no, registration_number, model_id, manufacture_year, color, mileage, fuel_type, transmission, purchase_price, sale_price, status) VALUES
('PAKSHOWROOM000001', 'LEC-24-1001', 1, 2024, 'Super White', 15000, 'Petrol', 'Automatic', 6200000.00, 6650000.00, 'In Stock'),
('PAKSHOWROOM000002', 'ICT-25-2002', 2, 2025, 'Attitude Black', 4500, 'Petrol', 'Automatic', 4400000.00, 4750000.00, 'In Stock'),
('PAKSHOWROOM000003', 'KHI-23-3003', 3, 2023, 'Meteoroid Gray', 32000, 'Petrol', 'Automatic', 7100000.00, 7450000.00, 'In Stock'),
('PAKSHOWROOM000004', NULL, 4, 2026, 'Silver Metallic', 0, 'Petrol', 'Automatic', 4600000.00, 4950000.00, 'In Stock'),
('PAKSHOWROOM000005', 'LEC-22-1005', 5, 2022, 'Graphite Gray', 48000, 'Petrol', 'Manual', 3800000.00, 4100000.00, 'Sold'),
('PAKSHOWROOM000006', 'ICT-25-2006', 6, 2025, 'Mercury Blue', 8200, 'Petrol', 'Automatic', 7800000.00, 8300000.00, 'In Stock'),
('PAKSHOWROOM000007', 'KHI-24-3007', 7, 2024, 'Super White', 19000, 'Hybrid', 'Automatic', 8100000.00, 8650000.00, 'Reserved'),
('PAKSHOWROOM000008', NULL, 1, 2026, 'Attitude Black', 0, 'Petrol', 'Automatic', 6800000.00, 7250000.00, 'In Stock'),
('PAKSHOWROOM000009', 'LEC-23-1009', 2, 2023, 'Silver Metallic', 27000, 'Petrol', 'Automatic', 4100000.00, 4400000.00, 'Sold'),
('PAKSHOWROOM000010', 'ICT-24-2010', 3, 2024, 'Meteoroid Gray', 14000, 'Petrol', 'Automatic', 7400000.00, 7850000.00, 'In Stock'),
('PAKSHOWROOM000011', 'KHI-25-3011', 4, 2025, 'Graphite Gray', 6100, 'Petrol', 'Manual', 4500000.00, 4850000.00, 'In Stock'),
('PAKSHOWROOM000012', NULL, 5, 2026, 'Super White', 0, 'Petrol', 'Automatic', 4750000.00, 5100000.00, 'In Stock'),
('PAKSHOWROOM000013', 'LEC-25-1013', 6, 2025, 'Attitude Black', 3200, 'Petrol', 'Automatic', 7950000.00, 8450000.00, 'In Stock'),
('PAKSHOWROOM000014', 'ICT-23-2014', 7, 2023, 'Mercury Blue', 39000, 'Hybrid', 'Automatic', 7500000.00, 7950000.00, 'Sold'),
('PAKSHOWROOM000015', 'KHI-22-3015', 1, 2022, 'Silver Metallic', 55000, 'Petrol', 'Automatic', 5400000.00, 5750000.00, 'Sold'),
('PAKSHOWROOM000016', NULL, 2, 2026, 'Super White', 0, 'Petrol', 'Manual', 4300000.00, 4650000.00, 'In Stock'),
('PAKSHOWROOM000017', 'LEC-24-1017', 3, 2024, 'Graphite Gray', 22000, 'Petrol', 'Automatic', 7200000.00, 7600000.00, 'In Stock'),
('PAKSHOWROOM000018', 'ICT-25-2018', 4, 2025, 'Meteoroid Gray', 9000, 'Petrol', 'Automatic', 4650000.00, 5000000.00, 'In Stock'),
('PAKSHOWROOM000019', 'KHI-24-3019', 5, 2024, 'Attitude Black', 11000, 'Petrol', 'Automatic', 4400000.00, 4750000.00, 'Reserved'),
('PAKSHOWROOM000020', NULL, 6, 2026, 'Mercury Blue', 0, 'Petrol', 'Automatic', 8400000.00, 8950000.00, 'In Stock'),
('PAKSHOWROOM000021', 'LEC-23-1021', 7, 2023, 'Super White', 34000, 'Hybrid', 'Automatic', 7600000.00, 8100000.00, 'Sold'),
('PAKSHOWROOM000022', 'ICT-22-2022', 1, 2022, 'Silver Metallic', 62000, 'Petrol', 'Automatic', 5200000.00, 5500000.00, 'Sold'),
('PAKSHOWROOM000023', 'KHI-25-3023', 2, 2025, 'Graphite Gray', 4100, 'Petrol', 'Automatic', 4550000.00, 4900000.00, 'In Stock'),
('PAKSHOWROOM000024', NULL, 3, 2026, 'Attitude Black', 0, 'Petrol', 'Automatic', 8200000.00, 8750000.00, 'In Stock'),
('PAKSHOWROOM000025', 'LEC-25-1025', 4, 2025, 'Super White', 5200, 'Petrol', 'Automatic', 4700000.00, 5050000.00, 'In Stock'),
('PAKSHOWROOM000026', 'ICT-24-2026', 5, 2024, 'Meteoroid Gray', 18500, 'Petrol', 'Manual', 4150000.00, 4450000.00, 'In Stock'),
('PAKSHOWROOM000027', 'KHI-23-3027', 6, 2023, 'Silver Metallic', 29000, 'Petrol', 'Automatic', 7100000.00, 7550000.00, 'Sold'),
('PAKSHOWROOM000028', NULL, 7, 2026, 'Graphite Gray', 0, 'Hybrid', 'Automatic', 8500000.00, 9100000.00, 'In Stock'),
('PAKSHOWROOM000029', 'LEC-22-1029', 1, 2022, 'Mercury Blue', 59000, 'Petrol', 'Manual', 4900000.00, 5200000.00, 'Sold'),
('PAKSHOWROOM000030', 'ICT-25-2030', 2, 2025, 'Super White', 7300, 'Petrol', 'Automatic', 4500000.00, 4850000.00, 'In Stock'),
('PAKSHOWROOM000031', 'KHI-24-3031', 3, 2024, 'Attitude Black', 21000, 'Petrol', 'Automatic', 7350000.00, 7750000.00, 'In Stock'),
('PAKSHOWROOM000032', NULL, 4, 2026, 'Meteoroid Gray', 0, 'Petrol', 'Automatic', 4850000.00, 5200000.00, 'In Stock'),
('PAKSHOWROOM000033', 'LEC-23-1033', 5, 2023, 'Silver Metallic', 31000, 'Petrol', 'Automatic', 4000000.00, 4300000.00, 'Sold'),
('PAKSHOWROOM000034', 'ICT-24-2034', 6, 2024, 'Graphite Gray', 16000, 'Petrol', 'Automatic', 7500000.00, 7950000.00, 'In Stock'),
('PAKSHOWROOM000035', 'KHI-25-3035', 7, 2025, 'Super White', 2400, 'Hybrid', 'Automatic', 8350000.00, 8900000.00, 'Reserved'),
('PAKSHOWROOM000036', NULL, 1, 2026, 'Mercury Blue', 0, 'Petrol', 'Automatic', 6850000.00, 7300000.00, 'In Stock'),
('PAKSHOWROOM000037', 'LEC-25-1037', 2, 2025, 'Attitude Black', 1100, 'Petrol', 'Manual', 4450000.00, 4800000.00, 'In Stock'),
('PAKSHOWROOM000038', 'ICT-23-2038', 3, 2023, 'Super White', 42000, 'Petrol', 'Automatic', 6800000.00, 7200000.00, 'Sold'),
('PAKSHOWROOM000039', 'KHI-22-3039', 4, 2022, 'Silver Metallic', 67000, 'Petrol', 'Manual', 3700000.00, 3950000.00, 'Sold'),
('PAKSHOWROOM000040', NULL, 5, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 4800000.00, 5150000.00, 'In Stock'),
('PAKSHOWROOM000041', 'LEC-24-1041', 6, 2024, 'Meteoroid Gray', 24000, 'Petrol', 'Automatic', 7300000.00, 7750000.00, 'In Stock'),
('PAKSHOWROOM000042', 'ICT-25-2042', 7, 2025, 'Mercury Blue', 6800, 'Hybrid', 'Automatic', 8250000.00, 8800000.00, 'In Stock'),
('PAKSHOWROOM000043', 'KHI-24-3043', 1, 2024, 'Super White', 13500, 'Petrol', 'Automatic', 6300000.00, 6700000.00, 'In Stock'),
('PAKSHOWROOM000044', NULL, 2, 2026, 'Attitude Black', 0, 'Petrol', 'Automatic', 4650000.00, 4950000.00, 'In Stock'),
('PAKSHOWROOM000045', 'LEC-23-1045', 3, 2023, 'Silver Metallic', 35000, 'Petrol', 'Automatic', 6950000.00, 7350000.00, 'Sold'),
('PAKSHOWROOM000046', 'ICT-22-2046', 4, 2022, 'Graphite Gray', 71000, 'Petrol', 'Automatic', 3600000.00, 3850000.00, 'Sold'),
('PAKSHOWROOM000047', 'KHI-25-3047', 5, 2025, 'Meteoroid Gray', 8900, 'Petrol', 'Manual', 4450000.00, 4800000.00, 'In Stock'),
('PAKSHOWROOM000048', NULL, 6, 2026, 'Super White', 0, 'Petrol', 'Automatic', 8450000.00, 9000000.00, 'In Stock'),
('PAKSHOWROOM000049', 'LEC-25-1049', 7, 2025, 'Attitude Black', 4300, 'Hybrid', 'Automatic', 8400000.00, 8950000.00, 'In Stock'),
('PAKSHOWROOM000050', 'ICT-24-2050', 1, 2024, 'Mercury Blue', 21500, 'Petrol', 'Automatic', 6250000.00, 6650000.00, 'In Stock'),
('PAKSHOWROOM000051', 'KHI-23-3051', 2, 2023, 'Silver Metallic', 33000, 'Petrol', 'Automatic', 4050000.00, 4350000.00, 'Sold'),
('PAKSHOWROOM000052', NULL, 3, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 8250000.00, 8800000.00, 'In Stock'),
('PAKSHOWROOM000053', 'LEC-22-1053', 4, 2022, 'Meteoroid Gray', 64000, 'Petrol', 'Manual', 3650000.00, 3900000.00, 'Sold'),
('PAKSHOWROOM000054', 'ICT-25-2054', 5, 2025, 'Super White', 5100, 'Petrol', 'Automatic', 4600000.00, 4950000.00, 'In Stock'),
('PAKSHOWROOM000055', 'KHI-24-3055', 6, 2024, 'Attitude Black', 17000, 'Petrol', 'Automatic', 7400000.00, 7850000.00, 'In Stock'),
('PAKSHOWROOM000056', NULL, 7, 2026, 'Mercury Blue', 0, 'Hybrid', 'Automatic', 8550000.00, 9150000.00, 'In Stock'),
('PAKSHOWROOM000057', 'LEC-23-1057', 1, 2023, 'Silver Metallic', 29500, 'Petrol', 'Automatic', 5800000.00, 6150000.00, 'Sold'),
('PAKSHOWROOM000058', 'ICT-24-2058', 2, 2024, 'Graphite Gray', 19000, 'Petrol', 'Manual', 4200000.00, 4500000.00, 'In Stock'),
('PAKSHOWROOM000059', 'KHI-25-3059', 3, 2025, 'Meteoroid Gray', 3800, 'Petrol', 'Automatic', 7850000.00, 8350000.00, 'In Stock'),
('PAKSHOWROOM000060', NULL, 4, 2026, 'Super White', 0, 'Petrol', 'Automatic', 4900000.00, 5250000.00, 'In Stock'),
('PAKSHOWROOM000061', 'LEC-25-1061', 5, 2025, 'Attitude Black', 2900, 'Petrol', 'Automatic', 4650000.00, 5000000.00, 'In Stock'),
('PAKSHOWROOM000062', 'ICT-23-2062', 6, 2023, 'Mercury Blue', 41000, 'Petrol', 'Automatic', 6950000.00, 7400000.00, 'Sold'),
('PAKSHOWROOM000063', 'KHI-22-3063', 7, 2022, 'Silver Metallic', 73000, 'Hybrid', 'Automatic', 6700000.00, 7100000.00, 'Sold'),
('PAKSHOWROOM000064', NULL, 1, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 6900000.00, 7350000.00, 'In Stock'),
('PAKSHOWROOM000065', 'LEC-24-1065', 2, 2024, 'Meteoroid Gray', 25000, 'Petrol', 'Automatic', 4300000.00, 4600000.00, 'In Stock'),
('PAKSHOWROOM000066', 'ICT-25-2066', 3, 2025, 'Super White', 9300, 'Petrol', 'Automatic', 7750000.00, 8250000.00, 'Reserved'),
('PAKSHOWROOM000067', 'KHI-24-3067', 4, 2024, 'Attitude Black', 14200, 'Petrol', 'Manual', 4400000.00, 4700000.00, 'In Stock'),
('PAKSHOWROOM000068', NULL, 5, 2026, 'Mercury Blue', 0, 'Petrol', 'Automatic', 4950000.00, 5300000.00, 'In Stock'),
('PAKSHOWROOM000069', 'LEC-23-1069', 6, 2023, 'Silver Metallic', 37000, 'Petrol', 'Automatic', 7050000.00, 7500000.00, 'Sold'),
('PAKSHOWROOM000070', 'ICT-22-2070', 7, 2022, 'Graphite Gray', 69000, 'Hybrid', 'Automatic', 6800000.00, 7200000.00, 'Sold'),
('PAKSHOWROOM000071', 'KHI-25-3071', 1, 2025, 'Meteoroid Gray', 6000, 'Petrol', 'Automatic', 6550000.00, 6950000.00, 'In Stock'),
('PAKSHOWROOM000072', NULL, 2, 2026, 'Super White', 0, 'Petrol', 'Automatic', 4700000.00, 5000000.00, 'In Stock'),
('PAKSHOWROOM000073', 'LEC-25-1073', 3, 2025, 'Attitude Black', 4900, 'Petrol', 'Automatic', 7900000.00, 8400000.00, 'In Stock'),
('PAKSHOWROOM000074', 'ICT-24-2074', 4, 2024, 'Mercury Blue', 22000, 'Petrol', 'Automatic', 4450000.00, 4750000.00, 'In Stock'),
('PAKSHOWROOM000075', 'KHI-23-3075', 5, 2023, 'Silver Metallic', 36500, 'Petrol', 'Manual', 3950000.00, 4250000.00, 'Sold'),
('PAKSHOWROOM000076', NULL, 6, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 8500000.00, 9050000.00, 'In Stock'),
('PAKSHOWROOM000077', 'LEC-22-1077', 7, 2022, 'Meteoroid Gray', 81000, 'Hybrid', 'Automatic', 6500000.00, 6900000.00, 'Sold'),
('PAKSHOWROOM000078', 'ICT-25-2078', 1, 2025, 'Super White', 2100, 'Petrol', 'Automatic', 6600000.00, 7050000.00, 'In Stock'),
('PAKSHOWROOM000079', 'KHI-24-3079', 2, 2024, 'Attitude Black', 18000, 'Petrol', 'Automatic', 4350000.00, 4650000.00, 'In Stock'),
('PAKSHOWROOM000080', NULL, 3, 2026, 'Mercury Blue', 0, 'Petrol', 'Automatic', 8300000.00, 8850000.00, 'In Stock'),
('PAKSHOWROOM000081', 'LEC-23-1081', 4, 2023, 'Silver Metallic', 34000, 'Petrol', 'Manual', 3900000.00, 4150000.00, 'Sold'),
('PAKSHOWROOM000082', 'ICT-25-2082', 5, 2025, 'Graphite Gray', 3100, 'Petrol', 'Automatic', 4700000.00, 5050000.00, 'In Stock'),
('PAKSHOWROOM000083', 'KHI-23-3083', 6, 2023, 'Meteoroid Gray', 45000, 'Petrol', 'Automatic', 6850000.00, 7300000.00, 'Sold'),
('PAKSHOWROOM000084', NULL, 7, 2026, 'Super White', 0, 'Hybrid', 'Automatic', 8600000.00, 9200000.00, 'In Stock'),
('PAKSHOWROOM000085', 'LEC-24-1085', 1, 2024, 'Attitude Black', 16500, 'Petrol', 'Automatic', 6350000.00, 6750000.00, 'In Stock'),
('PAKSHOWROOM000086', 'ICT-24-2086', 2, 2024, 'Mercury Blue', 26000, 'Petrol', 'Automatic', 4250000.00, 4550000.00, 'In Stock'),
('PAKSHOWROOM000087', 'KHI-25-3087', 3, 2025, 'Silver Metallic', 7200, 'Petrol', 'Automatic', 7800000.00, 8300000.00, 'In Stock'),
('PAKSHOWROOM000088', NULL, 4, 2026, 'Graphite Gray', 0, 'Petrol', 'Manual', 4750000.00, 5100000.00, 'In Stock'),
('PAKSHOWROOM000089', 'LEC-25-1089', 5, 2025, 'Meteoroid Gray', 5400, 'Petrol', 'Automatic', 4680000.00, 5050000.00, 'In Stock'),
('PAKSHOWROOM000090', 'ICT-23-2090', 6, 2023, 'Super White', 39500, 'Petrol', 'Automatic', 7000000.00, 7450000.00, 'Sold'),
('PAKSHOWROOM000091', 'KHI-22-3091', 7, 2022, 'Attitude Black', 78000, 'Hybrid', 'Automatic', 6600000.00, 7000000.00, 'Sold'),
('PAKSHOWROOM000092', NULL, 1, 2026, 'Mercury Blue', 0, 'Petrol', 'Automatic', 6950000.00, 7400000.00, 'In Stock'),
('PAKSHOWROOM000093', 'LEC-24-1093', 2, 2024, 'Silver Metallic', 20500, 'Petrol', 'Manual', 4300000.00, 4600000.00, 'In Stock'),
('PAKSHOWROOM000094', 'ICT-25-2094', 3, 2025, 'Graphite Gray', 1500, 'Petrol', 'Automatic', 7950000.00, 8450000.00, 'In Stock'),
('PAKSHOWROOM000095', 'KHI-24-3095', 4, 2024, 'Meteoroid Gray', 15500, 'Petrol', 'Automatic', 4500000.00, 4800000.00, 'In Stock'),
('PAKSHOWROOM000096', NULL, 5, 2026, 'Super White', 0, 'Petrol', 'Automatic', 5000000.00, 5350000.00, 'In Stock'),
('PAKSHOWROOM000097', 'LEC-23-1097', 6, 2023, 'Attitude Black', 43000, 'Petrol', 'Automatic', 6900000.00, 7350000.00, 'Sold'),
('PAKSHOWROOM000098', 'ICT-25-2098', 7, 2025, 'Mercury Blue', 8700, 'Hybrid', 'Automatic', 8300000.00, 8850000.00, 'In Stock'),
('PAKSHOWROOM000099', 'KHI-24-3099', 1, 2024, 'Silver Metallic', 12000, 'Petrol', 'Automatic', 6400000.00, 6800000.00, 'In Stock'),
('PAKSHOWROOM000100', NULL, 2, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 4750000.00, 5050000.00, 'In Stock');


-- ============================================================================
-- 3: EXHIBITION OF THE 10 FEATURES
-- ============================================================================

-- FEATURE 1: Vehicle Stock Intake (Add new car into inventory)
INSERT INTO VEHICLES_INVENTORY (chassis_no, registration_number, model_id, manufacture_year, color, mileage, fuel_type, transmission, purchase_price, sale_price, status) 
VALUES ('HYTU6000998877665', NULL, 7, 2026, 'Graphite Gray', 0, 'Petrol', 'Automatic', 8100000.00, 8650000.00, 'In Stock');


-- FEATURE 2: Onboard New Personnel (Add new employee)
INSERT INTO EMPLOYEES (first_name, last_name, phone, email, hire_date, salary, department_id, employee_role_id) 
VALUES ('Daniyal', 'Malik', '+923035553344', 'daniyal.malik@dealership.pk', '2026-06-01', 75000.00, 2, 4);


-- FEATURE 3: Process Customer Sale (Insert a new sales entry)
INSERT INTO SALES (customer_id, vehicle_id, salesperson_id, sale_date, total_amount, payment_status) 
VALUES (1, 1, 2, '2026-06-05', 6600000.00, 'Partial');


-- FEATURE 4: Log Transaction Payment (Record payment amount)
INSERT INTO PAYMENTS (sale_id, amount, payment_date, method) 
VALUES (1, 4000000.00, '2026-06-05', 'Bank Transfer');


-- FEATURE 5: Update Vehicle Availability Status (Change status to Sold)
UPDATE VEHICLES_INVENTORY 
SET status = 'Sold' 
WHERE vehicle_id = 1;


-- FEATURE 6: Adjust Employee Compensation (Update employee salary)
UPDATE EMPLOYEES 
SET salary = 85000.00 
WHERE employee_id = 4;


-- FEATURE 7: Remove Misentered Ledger Records (Delete wrong entry using chassis code)
INSERT INTO VEHICLES_INVENTORY (chassis_no, registration_number, model_id, manufacture_year, color, mileage, fuel_type, transmission, purchase_price, sale_price, status) 
VALUES ('ERR_CHASSIS_99999', 'BAD-REG', 1, 2020, 'Red', 999, 'Petrol', 'Manual', 1000.00, 1200.00, 'In Stock');

DELETE FROM VEHICLES_INVENTORY 
WHERE chassis_no = 'ERR_CHASSIS_99999';


-- FEATURE 8: Real-Time Active Inventory Search (Show all vehicles currently available in stock)
SELECT 
    v.vehicle_id AS "ID",
    b.brand_name AS "Brand",
    m.model_name AS "Model Spec",
    v.manufacture_year AS "Year",
    COALESCE(v.registration_number, 'Unregistered / Ready for First Owner') AS "Registration State",
    v.color AS "Color",
    v.sale_price AS "Asking Retail (PKR)"
FROM VEHICLES_INVENTORY v
INNER JOIN VEHICLE_MODELS m ON v.model_id = m.model_id
INNER JOIN VEHICLE_BRANDS b ON m.brand_id = b.brand_id
WHERE v.status = 'In Stock';


-- FEATURE 9: Salesperson Performance Leaderboard (Rank staff by total sales revenue generated)
SELECT 
    e.employee_id AS "Staff ID",
    CONCAT(e.first_name, ' ', e.last_name) AS "Salesperson Name",
    COUNT(s.sale_id) AS "Units Cleared",
    SUM(s.total_amount) AS "Gross Revenue Handled (PKR)"
FROM EMPLOYEES e
INNER JOIN SALES s ON e.employee_id = s.salesperson_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY "Gross Revenue Handled (PKR)" DESC;


-- FEATURE 10: Comprehensive Customer Purchase History (Track historical purchases and payment balances)
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS "Client Profile",
    c.phone AS "Contact Number",
    s.sale_date AS "Deal Closed On",
    CONCAT(b.brand_name, ' ', m.model_name) AS "Purchased Asset",
    s.total_amount AS "Agreed Contract Price (PKR)",
    COALESCE(SUM(p.amount), 0.00) AS "Total Capital Paid (PKR)",
    (s.total_amount - COALESCE(SUM(p.amount), 0.00)) AS "Outstanding Dues (PKR)",
    s.payment_status AS "Contract Status"
FROM CUSTOMERS c
INNER JOIN SALES s ON c.customer_id = s.customer_id
INNER JOIN VEHICLES_INVENTORY v ON s.vehicle_id = v.vehicle_id
INNER JOIN VEHICLE_MODELS m ON v.model_id = m.model_id
INNER JOIN VEHICLE_BRANDS b ON m.brand_id = b.brand_id
LEFT JOIN PAYMENTS p ON s.sale_id = p.sale_id
WHERE c.customer_id = 1
GROUP BY c.first_name, c.last_name, c.phone, s.sale_date, b.brand_name, m.model_name, s.total_amount, s.payment_status;