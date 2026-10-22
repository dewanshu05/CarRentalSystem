package com.carrental.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model: User (POJO / Bean)
 * Represents system user authentication and role-based access control.
 * Roles:
 *  - 'ADMIN' / 'OWNER': Full access to fleet management, all customers, returns, metrics.
 *  - 'CUSTOMER': Access restricted to browsing cars, booking for self, and viewing personal history.
 */
public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private String username;
    private String password;
    private String fullName;
    private String email;
    private String role; // "ADMIN" or "CUSTOMER"
    private Integer customerId; // Linked customer profile ID for CUSTOMER role (null for ADMIN)
    private Timestamp createdAt;

    public User() {}

    public User(String username, String password, String fullName, String email, String role, Integer customerId) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.customerId = customerId;
    }

    public User(int userId, String username, String password, String fullName, String email, String role, Integer customerId, Timestamp createdAt) {
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.email = email;
        this.role = role;
        this.customerId = customerId;
        this.createdAt = createdAt;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public Integer getCustomerId() {
        return customerId;
    }

    public void setCustomerId(Integer customerId) {
        this.customerId = customerId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Role check helpers
    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(this.role);
    }

    public boolean isCustomer() {
        return "CUSTOMER".equalsIgnoreCase(this.role);
    }

    @Override
    public String toString() {
        return "User [userId=" + userId + ", username=" + username + ", role=" + role + ", customerId=" + customerId + "]";
    }
}
