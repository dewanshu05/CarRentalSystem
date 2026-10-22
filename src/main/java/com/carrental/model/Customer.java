package com.carrental.model;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * Model: Customer (Java Bean / POJO)
 * Represents the 'customers' table in the MySQL database.
 */
public class Customer implements Serializable {
    private static final long serialVersionUID = 1L;

    private int customerId;
    private String fullName;
    private String email;
    private String phone;
    private String licenseNumber;
    private String address;
    private Timestamp createdAt;

    // Default Constructor
    public Customer() {
    }

    // Constructor for creating a new Customer (without customerId)
    public Customer(String fullName, String email, String phone, String licenseNumber, String address) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.licenseNumber = licenseNumber;
        this.address = address;
    }

    // Full Parameterized Constructor
    public Customer(int customerId, String fullName, String email, String phone,
                    String licenseNumber, String address, Timestamp createdAt) {
        this.customerId = customerId;
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.licenseNumber = licenseNumber;
        this.address = address;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
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

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getLicenseNumber() {
        return licenseNumber;
    }

    public void setLicenseNumber(String licenseNumber) {
        this.licenseNumber = licenseNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Customer [customerId=" + customerId + ", name=" + fullName
                + ", email=" + email + ", phone=" + phone
                + ", license=" + licenseNumber + "]";
    }
}
