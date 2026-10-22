package com.carrental.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * DBConnection
 * -------------------------------------------------------------------------
 * Robust, intelligent Database Connection Manager for College Projects.
 * 
 * 1. Automatically tests MySQL connection with standard default credentials
 *    (root/root, root/"", root/password).
 * 2. Automatically initializes the schema & sample data if tables don't exist.
 * 3. Graceful In-Memory fallback: If local MySQL service is stopped or not
 *    yet configured, automatically boots an embedded MySQL-compatible database
 *    so the web application opens and functions immediately in the browser!
 * -------------------------------------------------------------------------
 */
public class DBConnection {

    private static String activeJdbcUrl = null;
    private static String activeUser = null;
    private static String activePass = null;
    private static String activeDriver = null;
    private static boolean isInitialized = false;

    // Default MySQL configuration
    private static final String MYSQL_DB_URL = "jdbc:mysql://localhost:3306/car_rental_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String MYSQL_SERVER_URL = "jdbc:mysql://localhost:3306/?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String MYSQL_DRIVER = "com.mysql.cj.jdbc.Driver";

    // Embedded Fallback configuration (MySQL compatibility mode)
    private static final String H2_URL = "jdbc:h2:file:./car_rental_h2_db;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DEFAULT_NULL_ORDERING=HIGH;AUTO_SERVER=TRUE";
    private static final String H2_DRIVER = "org.h2.Driver";

    static {
        determineDatabaseSource();
    }

    private static synchronized void determineDatabaseSource() {
        if (isInitialized) return;

        // 1. Check for Cloud MySQL Environment Variables (Render, Railway, Aiven, etc.)
        String envDbUrl = System.getenv("DB_URL");
        if (envDbUrl == null) envDbUrl = System.getenv("MYSQL_URL");
        if (envDbUrl == null) envDbUrl = System.getenv("DATABASE_URL");
        String envDbUser = System.getenv("DB_USER");
        if (envDbUser == null) envDbUser = System.getenv("MYSQL_USER");
        String envDbPass = System.getenv("DB_PASSWORD");
        if (envDbPass == null) envDbPass = System.getenv("MYSQL_PASSWORD");

        if (envDbUrl != null && !envDbUrl.trim().isEmpty()) {
            try {
                Class.forName(MYSQL_DRIVER);
                if (envDbUrl.startsWith("mysql://")) {
                    envDbUrl = "jdbc:" + envDbUrl;
                }
                Connection conn = DriverManager.getConnection(envDbUrl, envDbUser != null ? envDbUser : "root", envDbPass != null ? envDbPass : "");
                conn.close();
                activeJdbcUrl = envDbUrl;
                activeUser = envDbUser != null ? envDbUser : "root";
                activePass = envDbPass != null ? envDbPass : "";
                activeDriver = MYSQL_DRIVER;
                mysqlConnected = true;
                System.out.println("✅ Connected to Cloud MySQL Database successfully!");
            } catch (Exception e) {
                System.err.println("⚠️ Notice: Cloud Database URL connection test: " + e.getMessage());
            }
        }

        // 2. Try Local MySQL next
        String[] candidatePasswords = {"root", "", "password", "admin", "123456"};

        if (!mysqlConnected) {
            try {
                Class.forName(MYSQL_DRIVER);
            for (String pass : candidatePasswords) {
                try {
                    // Try to connect to MySQL server root
                    Connection conn = DriverManager.getConnection(MYSQL_SERVER_URL, "root", pass);
                    Statement stmt = conn.createStatement();
                    stmt.executeUpdate("CREATE DATABASE IF NOT EXISTS car_rental_db;");
                    stmt.close();
                    conn.close();

                    // Successfully reached MySQL and created database!
                    activeJdbcUrl = MYSQL_DB_URL;
                    activeUser = "root";
                    activePass = pass;
                    activeDriver = MYSQL_DRIVER;
                    mysqlConnected = true;
                    System.out.println("✅ Connected to MySQL Database Server successfully using user 'root'!");
                    break;
                } catch (Exception ignored) {
                    // Try next password
                }
            }
        } catch (Exception e) {
            // MySQL driver not found or general error
        }

        if (!mysqlConnected) {
            // Fallback to Embedded Database in MySQL mode
            try {
                Class.forName(H2_DRIVER);
                activeJdbcUrl = H2_URL;
                activeUser = "sa";
                activePass = "";
                activeDriver = H2_DRIVER;
                System.out.println("💡 Note: Local MySQL service was not accessible on port 3306.");
                System.out.println("🚀 Starting embedded database (MySQL Mode) so you can test the application immediately!");
            } catch (Exception e) {
                System.err.println("Database driver error: " + e.getMessage());
            }
        }

        // Initialize schema and sample data
        initializeDatabaseTables();
        isInitialized = true;
    }

    /**
     * Creates tables and populates sample data if they do not exist.
     */
    private static void initializeDatabaseTables() {
        Connection conn = null;
        Statement stmt = null;
        try {
            conn = DriverManager.getConnection(activeJdbcUrl, activeUser, activePass);
            stmt = conn.createStatement();

            // 1. Create Cars table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS cars (" +
                "  car_id INT AUTO_INCREMENT PRIMARY KEY," +
                "  car_model VARCHAR(100) NOT NULL," +
                "  brand VARCHAR(50) NOT NULL," +
                "  category VARCHAR(50) NOT NULL," +
                "  registration_number VARCHAR(30) NOT NULL UNIQUE," +
                "  daily_rate DECIMAL(10,2) NOT NULL," +
                "  status VARCHAR(20) NOT NULL DEFAULT 'AVAILABLE'," +
                "  seating_capacity INT NOT NULL DEFAULT 5," +
                "  fuel_type VARCHAR(20) NOT NULL DEFAULT 'Petrol'," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ");"
            );

            // 2. Create Customers table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS customers (" +
                "  customer_id INT AUTO_INCREMENT PRIMARY KEY," +
                "  full_name VARCHAR(100) NOT NULL," +
                "  email VARCHAR(100) NOT NULL UNIQUE," +
                "  phone VARCHAR(20) NOT NULL," +
                "  license_number VARCHAR(50) NOT NULL UNIQUE," +
                "  address TEXT," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ");"
            );

            // 3. Create Rentals table
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS rentals (" +
                "  rental_id INT AUTO_INCREMENT PRIMARY KEY," +
                "  car_id INT NOT NULL," +
                "  customer_id INT NOT NULL," +
                "  rental_date DATE NOT NULL," +
                "  expected_return_date DATE NOT NULL," +
                "  actual_return_date DATE DEFAULT NULL," +
                "  total_days INT NOT NULL," +
                "  daily_rate_applied DECIMAL(10,2) NOT NULL," +
                "  base_cost DECIMAL(10,2) NOT NULL," +
                "  late_fee DECIMAL(10,2) DEFAULT 0.00," +
                "  total_cost DECIMAL(10,2) NOT NULL," +
                "  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'," +
                "  notes TEXT," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ");"
            );

            // 4. Create Users table (Role-Based Authentication: ADMIN vs CUSTOMER)
            stmt.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "  user_id INT AUTO_INCREMENT PRIMARY KEY," +
                "  username VARCHAR(50) NOT NULL UNIQUE," +
                "  password VARCHAR(100) NOT NULL," +
                "  full_name VARCHAR(100) NOT NULL," +
                "  email VARCHAR(100) NOT NULL UNIQUE," +
                "  role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER'," +
                "  customer_id INT NULL," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ");"
            );

            // Seed Cars if empty
            ResultSet rsCars = stmt.executeQuery("SELECT COUNT(*) FROM cars");
            if (rsCars.next() && rsCars.getInt(1) == 0) {
                stmt.executeUpdate(
                    "INSERT INTO cars (car_model, brand, category, registration_number, daily_rate, status, seating_capacity, fuel_type) VALUES " +
                    "('City 1.5L ZX', 'Honda', 'Sedan', 'DL-01-AB-1001', 2500.00, 'AVAILABLE', 5, 'Petrol')," +
                    "('Creta SX(O)', 'Hyundai', 'SUV', 'MH-02-CD-2002', 3200.00, 'RENTED', 5, 'Diesel')," +
                    "('Swift ZXi', 'Maruti Suzuki', 'Hatchback', 'KA-03-EF-3003', 1800.00, 'AVAILABLE', 5, 'Petrol')," +
                    "('Fortuner 4x4', 'Toyota', 'Luxury SUV', 'KA-05-GH-4004', 6500.00, 'AVAILABLE', 7, 'Diesel')," +
                    "('Nexon EV Max', 'Tata Motors', 'Electric SUV', 'TN-07-JK-5005', 3000.00, 'MAINTENANCE', 5, 'Electric')," +
                    "('Thar LX 4-Seater', 'Mahindra', 'Off-Road SUV', 'HR-26-LM-6006', 3800.00, 'RENTED', 4, 'Diesel');"
                );
            }
            rsCars.close();

            // Seed Customers if empty
            ResultSet rsCust = stmt.executeQuery("SELECT COUNT(*) FROM customers");
            if (rsCust.next() && rsCust.getInt(1) == 0) {
                stmt.executeUpdate(
                    "INSERT INTO customers (full_name, email, phone, license_number, address) VALUES " +
                    "('Aarav Sharma', 'aarav.sharma@example.com', '9876543210', 'DL-2018-0098765', '42 MG Road, Bengaluru')," +
                    "('Priya Patel', 'priya.patel@example.com', '9812345678', 'MH-2019-0012345', '15 Link Road, Mumbai')," +
                    "('Rohan Verma', 'rohan.verma@example.com', '9823456789', 'DL-2020-0045678', '88 Sector 14, Gurugram')," +
                    "('Sneha Reddy', 'sneha.reddy@example.com', '9834567890', 'KA-2021-0078901', '21 Jubilee Hills, Hyderabad');"
                );
            }
            rsCust.close();

            // Seed Rentals if empty
            ResultSet rsRentals = stmt.executeQuery("SELECT COUNT(*) FROM rentals");
            if (rsRentals.next() && rsRentals.getInt(1) == 0) {
                stmt.executeUpdate(
                    "INSERT INTO rentals (car_id, customer_id, rental_date, expected_return_date, actual_return_date, total_days, daily_rate_applied, base_cost, late_fee, total_cost, status, notes) VALUES " +
                    "(2, 1, '2026-10-18', '2026-10-23', NULL, 5, 3200.00, 16000.00, 0.00, 16000.00, 'ACTIVE', 'Family weekend trip to Coorg.')," +
                    "(6, 3, '2026-10-19', '2026-10-22', NULL, 3, 3800.00, 11400.00, 0.00, 11400.00, 'ACTIVE', 'Road trip to Shimla.')," +
                    "(1, 2, '2026-10-10', '2026-10-14', '2026-10-14', 4, 2500.00, 10000.00, 0.00, 10000.00, 'COMPLETED', 'Returned on time.');"
                );
            }
            rsRentals.close();

            // Seed Users if empty
            ResultSet rsUsers = stmt.executeQuery("SELECT COUNT(*) FROM users");
            if (rsUsers.next() && rsUsers.getInt(1) == 0) {
                stmt.executeUpdate(
                    "INSERT INTO users (username, password, full_name, email, role, customer_id) VALUES " +
                    "('admin', 'admin123', 'Fleet Owner / Admin', 'admin@carrental.com', 'ADMIN', NULL)," +
                    "('aarav', 'customer123', 'Aarav Sharma', 'aarav.sharma@example.com', 'CUSTOMER', 1)," +
                    "('priya', 'customer123', 'Priya Patel', 'priya.patel@example.com', 'CUSTOMER', 2)," +
                    "('rohan', 'customer123', 'Rohan Verma', 'rohan.verma@example.com', 'CUSTOMER', 3);"
                );
            }
            rsUsers.close();

            System.out.println("✅ Database schema and sample data verified & ready!");
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, stmt, null);
        }
    }

    /**
     * Obtains an active connection to the database.
     */
    public static Connection getConnection() throws SQLException {
        if (!isInitialized) {
            determineDatabaseSource();
        }
        return DriverManager.getConnection(activeJdbcUrl, activeUser, activePass);
    }

    /**
     * Utility method to close JDBC resources.
     */
    public static void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException ignored) {}
        try {
            if (stmt != null) stmt.close();
        } catch (SQLException ignored) {}
        try {
            if (conn != null) conn.close();
        } catch (SQLException ignored) {}
    }
}
