package com.carrental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.carrental.config.DBConnection;
import com.carrental.model.Customer;
import com.carrental.model.User;

/**
 * Data Access Object (DAO) for User entity.
 * Handles authentication, user profile lookups, and customer self-registration.
 */
public class UserDAO {

    private static final String AUTH_QUERY = 
        "SELECT * FROM users WHERE (username = ? OR email = ?) AND password = ?";

    private static final String FIND_BY_ID = 
        "SELECT * FROM users WHERE user_id = ?";

    private static final String CHECK_USERNAME = 
        "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";

    private static final String INSERT_CUSTOMER = 
        "INSERT INTO customers (full_name, email, phone, license_number, address) VALUES (?, ?, ?, ?, ?)";

    private static final String INSERT_USER = 
        "INSERT INTO users (username, password, full_name, email, role, customer_id) VALUES (?, ?, ?, ?, ?, ?)";

    /**
     * Authenticates a user with username/email and password.
     */
    public User authenticate(String usernameOrEmail, String password) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        User user = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(AUTH_QUERY);
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            ps.setString(3, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                user = mapRowToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return user;
    }

    /**
     * Finds user by primary key ID.
     */
    public User getUserById(int userId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        User user = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(FIND_BY_ID);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            if (rs.next()) {
                user = mapRowToUser(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return user;
    }

    /**
     * Checks if username or email is already registered.
     */
    public boolean isUsernameOrEmailTaken(String username, String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(CHECK_USERNAME);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return false;
    }

    /**
     * Registers a new Customer and User account in an ACID database transaction.
     */
    public User registerCustomer(Customer customer, String username, String password) {
        Connection conn = null;
        PreparedStatement psCust = null;
        PreparedStatement psUser = null;
        ResultSet rsKeys = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin transaction

            // 1. Insert Customer Profile
            psCust = conn.prepareStatement(INSERT_CUSTOMER, Statement.RETURN_GENERATED_KEYS);
            psCust.setString(1, customer.getFullName());
            psCust.setString(2, customer.getEmail());
            psCust.setString(3, customer.getPhone());
            psCust.setString(4, customer.getLicenseNumber());
            psCust.setString(5, customer.getAddress());
            psCust.executeUpdate();

            rsKeys = psCust.getGeneratedKeys();
            int newCustomerId = 0;
            if (rsKeys.next()) {
                newCustomerId = rsKeys.getInt(1);
            } else {
                throw new SQLException("Failed to obtain customer ID.");
            }

            // 2. Insert User Credentials with CUSTOMER role
            psUser = conn.prepareStatement(INSERT_USER, Statement.RETURN_GENERATED_KEYS);
            psUser.setString(1, username);
            psUser.setString(2, password);
            psUser.setString(3, customer.getFullName());
            psUser.setString(4, customer.getEmail());
            psUser.setString(5, "CUSTOMER");
            psUser.setInt(6, newCustomerId);
            psUser.executeUpdate();

            ResultSet rsUserKeys = psUser.getGeneratedKeys();
            int newUserId = 0;
            if (rsUserKeys.next()) {
                newUserId = rsUserKeys.getInt(1);
            }
            rsUserKeys.close();

            conn.commit(); // Commit transaction

            User newUser = new User();
            newUser.setUserId(newUserId);
            newUser.setUsername(username);
            newUser.setPassword(password);
            newUser.setFullName(customer.getFullName());
            newUser.setEmail(customer.getEmail());
            newUser.setRole("CUSTOMER");
            newUser.setCustomerId(newCustomerId);
            return newUser;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return null;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException ignored) {}
            DBConnection.closeResources(null, psCust, rsKeys);
            DBConnection.closeResources(conn, psUser, null);
        }
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setUsername(rs.getString("username"));
        u.setPassword(rs.getString("password"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setRole(rs.getString("role"));
        int custId = rs.getInt("customer_id");
        if (!rs.wasNull()) {
            u.setCustomerId(custId);
        }
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
