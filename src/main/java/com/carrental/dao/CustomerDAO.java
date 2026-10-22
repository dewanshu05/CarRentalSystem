package com.carrental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.carrental.config.DBConnection;
import com.carrental.model.Customer;

/**
 * Data Access Object (DAO) for Customer entity.
 * Handles customer registration, profile lookups, updates, and metrics.
 */
public class CustomerDAO {

    private static final String INSERT_CUSTOMER = 
        "INSERT INTO customers (full_name, email, phone, license_number, address) " +
        "VALUES (?, ?, ?, ?, ?)";
    
    private static final String SELECT_ALL_CUSTOMERS = 
        "SELECT * FROM customers ORDER BY customer_id DESC";
    
    private static final String SELECT_CUSTOMER_BY_ID = 
        "SELECT * FROM customers WHERE customer_id = ?";
    
    private static final String UPDATE_CUSTOMER = 
        "UPDATE customers SET full_name = ?, email = ?, phone = ?, license_number = ?, address = ? " +
        "WHERE customer_id = ?";
    
    private static final String DELETE_CUSTOMER = 
        "DELETE FROM customers WHERE customer_id = ?";

    private static final String COUNT_TOTAL_CUSTOMERS = 
        "SELECT COUNT(*) FROM customers";

    /**
     * Register a new customer
     */
    public boolean addCustomer(Customer customer) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(INSERT_CUSTOMER);
            ps.setString(1, customer.getFullName());
            ps.setString(2, customer.getEmail());
            ps.setString(3, customer.getPhone());
            ps.setString(4, customer.getLicenseNumber());
            ps.setString(5, customer.getAddress());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(conn, ps, null);
        }
    }

    /**
     * Retrieve all customers
     */
    public List<Customer> getAllCustomers() {
        List<Customer> customerList = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SELECT_ALL_CUSTOMERS);

            while (rs.next()) {
                Customer c = mapRowToCustomer(rs);
                customerList.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return customerList;
    }

    /**
     * Find customer by ID
     */
    public Customer getCustomerById(int customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Customer customer = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_CUSTOMER_BY_ID);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();

            if (rs.next()) {
                customer = mapRowToCustomer(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return customer;
    }

    /**
     * Update customer profile
     */
    public boolean updateCustomer(Customer customer) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_CUSTOMER);
            ps.setString(1, customer.getFullName());
            ps.setString(2, customer.getEmail());
            ps.setString(3, customer.getPhone());
            ps.setString(4, customer.getLicenseNumber());
            ps.setString(5, customer.getAddress());
            ps.setInt(6, customer.getCustomerId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(conn, ps, null);
        }
    }

    /**
     * Delete customer by ID
     */
    public boolean deleteCustomer(int customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(DELETE_CUSTOMER);
            ps.setInt(1, customerId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Cannot delete customer with ID " + customerId + " because rental records exist.");
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(conn, ps, null);
        }
    }

    /**
     * Total number of customers
     */
    public int getTotalCustomerCount() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(COUNT_TOTAL_CUSTOMERS);
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return 0;
    }

    private Customer mapRowToCustomer(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setCustomerId(rs.getInt("customer_id"));
        c.setFullName(rs.getString("full_name"));
        c.setEmail(rs.getString("email"));
        c.setPhone(rs.getString("phone"));
        c.setLicenseNumber(rs.getString("license_number"));
        c.setAddress(rs.getString("address"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        return c;
    }
}
