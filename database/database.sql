-- ====================================================================
-- Database Name: car_rental_db
-- Project: Car Rental Management System (Java, Servlets, JSP, JDBC, MySQL)
-- Author: 5th Semester B.Tech CSE Project
-- ====================================================================

-- 1. Create the database if it doesn't already exist
CREATE DATABASE IF NOT EXISTS car_rental_db;
USE car_rental_db;

-- 2. Drop existing tables if needed (in reverse order of dependencies)
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS cars;

-- ====================================================================
-- Table 1: cars
-- Stores vehicle inventory, specs, daily rental price, and availability
-- ====================================================================
CREATE TABLE cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    car_model VARCHAR(100) NOT NULL,
    brand VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL,                     -- e.g., 'Sedan', 'SUV', 'Hatchback', 'Luxury'
    registration_number VARCHAR(30) NOT NULL UNIQUE,   -- e.g., 'DL-01-AB-1234'
    daily_rate DECIMAL(10, 2) NOT NULL,                -- Rental rate per day in INR / Currency
    status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE',   -- 'AVAILABLE', 'RENTED', 'MAINTENANCE'
    seating_capacity INT NOT NULL DEFAULT 5,
    fuel_type VARCHAR(20) NOT NULL DEFAULT 'Petrol',    -- 'Petrol', 'Diesel', 'Electric', 'CNG'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Table 2: customers
-- Stores registered driver/customer personal and contact details
-- ====================================================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    license_number VARCHAR(50) NOT NULL UNIQUE,        -- Driving license ID
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Table 3: rentals
-- Stores booking transactions, rental duration, charges, and return status
-- ====================================================================
CREATE TABLE rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT NOT NULL,
    customer_id INT NOT NULL,
    rental_date DATE NOT NULL,
    expected_return_date DATE NOT NULL,
    actual_return_date DATE DEFAULT NULL,
    total_days INT NOT NULL,                           -- Number of rental days
    daily_rate_applied DECIMAL(10, 2) NOT NULL,        -- Locked daily rate at booking time
    base_cost DECIMAL(10, 2) NOT NULL,                 -- total_days * daily_rate_applied
    late_fee DECIMAL(10, 2) DEFAULT 0.00,              -- Extra penalty if returned after expected date
    total_cost DECIMAL(10, 2) NOT NULL,                -- base_cost + late_fee
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',      -- 'ACTIVE', 'COMPLETED', 'CANCELLED'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rental_car FOREIGN KEY (car_id) REFERENCES cars(car_id) ON DELETE RESTRICT,
    CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- Table 4: users
-- Stores authentication credentials and role permissions (ADMIN / CUSTOMER)
-- ====================================================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',     -- 'ADMIN' or 'CUSTOMER'
    customer_id INT NULL,                             -- Foreign key to customers for role 'CUSTOMER'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ====================================================================
-- SAMPLE DATA INSERTION
-- Populate initial data for quick testing and viva demonstration
-- ====================================================================

-- Insert sample cars
INSERT INTO cars (car_model, brand, category, registration_number, daily_rate, status, seating_capacity, fuel_type) VALUES
('City 1.5L ZX', 'Honda', 'Sedan', 'DL-01-AB-1001', 2500.00, 'AVAILABLE', 5, 'Petrol'),
('Creta SX(O)', 'Hyundai', 'SUV', 'MH-02-CD-2002', 3200.00, 'RENTED', 5, 'Diesel'),
('Swift ZXi', 'Maruti Suzuki', 'Hatchback', 'KA-03-EF-3003', 1800.00, 'AVAILABLE', 5, 'Petrol'),
('Fortuner 4x4 Legender', 'Toyota', 'Luxury SUV', 'KA-05-GH-4004', 6500.00, 'AVAILABLE', 7, 'Diesel'),
('Nexon EV Max', 'Tata Motors', 'Electric SUV', 'TN-07-JK-5005', 3000.00, 'MAINTENANCE', 5, 'Electric'),
('Thar LX 4-Seater', 'Mahindra', 'Off-Road SUV', 'HR-26-LM-6006', 3800.00, 'RENTED', 4, 'Diesel');

-- Insert sample customers
INSERT INTO customers (full_name, email, phone, license_number, address) VALUES
('Aarav Sharma', 'aarav.sharma@example.com', '9876543210', 'DL-2018-0098765', '42 MG Road, Bengaluru, Karnataka'),
('Priya Patel', 'priya.patel@example.com', '9812345678', 'MH-2019-0012345', '15 Link Road, Andheri West, Mumbai'),
('Rohan Verma', 'rohan.verma@example.com', '9823456789', 'DL-2020-0045678', '88 Sector 14, Gurugram, Haryana'),
('Sneha Reddy', 'sneha.reddy@example.com', '9834567890', 'KA-2021-0078901', '21 Jubilee Hills, Hyderabad, Telangana');

-- Insert sample rentals
-- 1. Active Rental for Hyundai Creta (car_id = 2) by Aarav Sharma (customer_id = 1)
INSERT INTO rentals (car_id, customer_id, rental_date, expected_return_date, actual_return_date, total_days, daily_rate_applied, base_cost, late_fee, total_cost, status, notes) VALUES
(2, 1, '2026-10-18', '2026-10-23', NULL, 5, 3200.00, 16000.00, 0.00, 16000.00, 'ACTIVE', 'Family weekend trip to Coorg.');

-- 2. Active Rental for Mahindra Thar (car_id = 6) by Rohan Verma (customer_id = 3)
INSERT INTO rentals (car_id, customer_id, rental_date, expected_return_date, actual_return_date, total_days, daily_rate_applied, base_cost, late_fee, total_cost, status, notes) VALUES
(6, 3, '2026-10-19', '2026-10-22', NULL, 3, 3800.00, 11400.00, 0.00, 11400.00, 'ACTIVE', 'Outstation road trip to Shimla.');

-- 3. Completed Past Rental for Honda City (car_id = 1) by Priya Patel (customer_id = 2)
INSERT INTO rentals (car_id, customer_id, rental_date, expected_return_date, actual_return_date, total_days, daily_rate_applied, base_cost, late_fee, total_cost, status, notes) VALUES
(1, 2, '2026-10-10', '2026-10-14', '2026-10-14', 4, 2500.00, 10000.00, 0.00, 10000.00, 'COMPLETED', 'Returned on time, vehicle in pristine condition.');

-- Insert sample users (Role-Based Authentication: 1 Admin / Owner + 3 Registered Customers)
INSERT INTO users (username, password, full_name, email, role, customer_id) VALUES
('admin', 'admin123', 'Fleet Owner / Administrator', 'admin@carrental.com', 'ADMIN', NULL),
('aarav', 'customer123', 'Aarav Sharma', 'aarav.sharma@example.com', 'CUSTOMER', 1),
('priya', 'customer123', 'Priya Patel', 'priya.patel@example.com', 'CUSTOMER', 2),
('rohan', 'customer123', 'Rohan Verma', 'rohan.verma@example.com', 'CUSTOMER', 3);

-- Verification Query: Check summary
SELECT 'Cars Total' AS Metric, COUNT(*) AS Value FROM cars
UNION ALL
SELECT 'Available Cars', COUNT(*) FROM cars WHERE status = 'AVAILABLE'
UNION ALL
SELECT 'Customers Total', COUNT(*) FROM customers
UNION ALL
SELECT 'Active Rentals', COUNT(*) FROM rentals WHERE status = 'ACTIVE';
