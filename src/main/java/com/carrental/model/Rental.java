package com.carrental.model;

import java.io.Serializable;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model: Rental (Java Bean / POJO)
 * Represents a car booking transaction from the 'rentals' table.
 * Includes join fields (carModel, registrationNumber, customerName, customerPhone)
 * to simplify rendering in JSP without doing multiple round-trips.
 */
public class Rental implements Serializable {
    private static final long serialVersionUID = 1L;

    private int rentalId;
    private int carId;
    private int customerId;
    private Date rentalDate;
    private Date expectedReturnDate;
    private Date actualReturnDate;
    private int totalDays;
    private double dailyRateApplied;
    private double baseCost;
    private double lateFee;
    private double totalCost;
    private String status; // 'ACTIVE', 'COMPLETED', 'CANCELLED'
    private String notes;
    private Timestamp createdAt;

    // Additional fields populated via SQL JOIN for display purposes
    private String carModel;
    private String registrationNumber;
    private String customerName;
    private String customerPhone;

    // Default Constructor
    public Rental() {
        this.status = "ACTIVE";
        this.lateFee = 0.00;
    }

    // Constructor for Booking a New Rental
    public Rental(int carId, int customerId, Date rentalDate, Date expectedReturnDate,
                  int totalDays, double dailyRateApplied, double baseCost, double totalCost,
                  String notes) {
        this.carId = carId;
        this.customerId = customerId;
        this.rentalDate = rentalDate;
        this.expectedReturnDate = expectedReturnDate;
        this.totalDays = totalDays;
        this.dailyRateApplied = dailyRateApplied;
        this.baseCost = baseCost;
        this.lateFee = 0.00;
        this.totalCost = totalCost;
        this.status = "ACTIVE";
        this.notes = notes;
    }

    // Full Parameterized Constructor
    public Rental(int rentalId, int carId, int customerId, Date rentalDate,
                  Date expectedReturnDate, Date actualReturnDate, int totalDays,
                  double dailyRateApplied, double baseCost, double lateFee, double totalCost,
                  String status, String notes, Timestamp createdAt) {
        this.rentalId = rentalId;
        this.carId = carId;
        this.customerId = customerId;
        this.rentalDate = rentalDate;
        this.expectedReturnDate = expectedReturnDate;
        this.actualReturnDate = actualReturnDate;
        this.totalDays = totalDays;
        this.dailyRateApplied = dailyRateApplied;
        this.baseCost = baseCost;
        this.lateFee = lateFee;
        this.totalCost = totalCost;
        this.status = status;
        this.notes = notes;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public int getRentalId() {
        return rentalId;
    }

    public void setRentalId(int rentalId) {
        this.rentalId = rentalId;
    }

    public int getCarId() {
        return carId;
    }

    public void setCarId(int carId) {
        this.carId = carId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Date getRentalDate() {
        return rentalDate;
    }

    public void setRentalDate(Date rentalDate) {
        this.rentalDate = rentalDate;
    }

    public Date getExpectedReturnDate() {
        return expectedReturnDate;
    }

    public void setExpectedReturnDate(Date expectedReturnDate) {
        this.expectedReturnDate = expectedReturnDate;
    }

    public Date getActualReturnDate() {
        return actualReturnDate;
    }

    public void setActualReturnDate(Date actualReturnDate) {
        this.actualReturnDate = actualReturnDate;
    }

    public int getTotalDays() {
        return totalDays;
    }

    public void setTotalDays(int totalDays) {
        this.totalDays = totalDays;
    }

    public double getDailyRateApplied() {
        return dailyRateApplied;
    }

    public void setDailyRateApplied(double dailyRateApplied) {
        this.dailyRateApplied = dailyRateApplied;
    }

    public double getBaseCost() {
        return baseCost;
    }

    public void setBaseCost(double baseCost) {
        this.baseCost = baseCost;
    }

    public double getLateFee() {
        return lateFee;
    }

    public void setLateFee(double lateFee) {
        this.lateFee = lateFee;
    }

    public double getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(double totalCost) {
        this.totalCost = totalCost;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getCarModel() {
        return carModel;
    }

    public void setCarModel(String carModel) {
        this.carModel = carModel;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.status);
    }
}
