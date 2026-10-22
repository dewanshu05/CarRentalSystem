package com.carrental.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.carrental.config.DBConnection;
import com.carrental.model.Car;

/**
 * Data Access Object (DAO) for Car entity.
 * Implements CRUD operations and vehicle status queries using JDBC PreparedStatements.
 */
public class CarDAO {

    // SQL Queries
    private static final String INSERT_CAR = 
        "INSERT INTO cars (car_model, brand, category, registration_number, daily_rate, status, seating_capacity, fuel_type) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    
    private static final String SELECT_ALL_CARS = 
        "SELECT * FROM cars ORDER BY car_id DESC";
    
    private static final String SELECT_AVAILABLE_CARS = 
        "SELECT * FROM cars WHERE status = 'AVAILABLE' ORDER BY brand, car_model ASC";
    
    private static final String SELECT_CAR_BY_ID = 
        "SELECT * FROM cars WHERE car_id = ?";
    
    private static final String UPDATE_CAR = 
        "UPDATE cars SET car_model = ?, brand = ?, category = ?, registration_number = ?, daily_rate = ?, status = ?, seating_capacity = ?, fuel_type = ? " +
        "WHERE car_id = ?";
    
    private static final String UPDATE_CAR_STATUS = 
        "UPDATE cars SET status = ? WHERE car_id = ?";
    
    private static final String DELETE_CAR = 
        "DELETE FROM cars WHERE car_id = ?";

    private static final String COUNT_TOTAL_CARS = 
        "SELECT COUNT(*) FROM cars";

    private static final String COUNT_AVAILABLE_CARS = 
        "SELECT COUNT(*) FROM cars WHERE status = 'AVAILABLE'";

    /**
     * Add a new car to inventory
     */
    public boolean addCar(Car car) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(INSERT_CAR);
            ps.setString(1, car.getCarModel());
            ps.setString(2, car.getBrand());
            ps.setString(3, car.getCategory());
            ps.setString(4, car.getRegistrationNumber());
            ps.setDouble(5, car.getDailyRate());
            ps.setString(6, car.getStatus());
            ps.setInt(7, car.getSeatingCapacity());
            ps.setString(8, car.getFuelType());

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
     * Retrieve all cars
     */
    public List<Car> getAllCars() {
        List<Car> carList = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SELECT_ALL_CARS);

            while (rs.next()) {
                Car car = mapRowToCar(rs);
                carList.add(car);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return carList;
    }

    /**
     * Retrieve only available cars for booking
     */
    public List<Car> getAvailableCars() {
        List<Car> carList = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SELECT_AVAILABLE_CARS);

            while (rs.next()) {
                Car car = mapRowToCar(rs);
                carList.add(car);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return carList;
    }

    /**
     * Find a car by primary key ID
     */
    public Car getCarById(int carId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Car car = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_CAR_BY_ID);
            ps.setInt(1, carId);
            rs = ps.executeQuery();

            if (rs.next()) {
                car = mapRowToCar(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return car;
    }

    /**
     * Update car details
     */
    public boolean updateCar(Car car) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_CAR);
            ps.setString(1, car.getCarModel());
            ps.setString(2, car.getBrand());
            ps.setString(3, car.getCategory());
            ps.setString(4, car.getRegistrationNumber());
            ps.setDouble(5, car.getDailyRate());
            ps.setString(6, car.getStatus());
            ps.setInt(7, car.getSeatingCapacity());
            ps.setString(8, car.getFuelType());
            ps.setInt(9, car.getCarId());

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
     * Update car availability status (e.g., 'AVAILABLE', 'RENTED', 'MAINTENANCE')
     */
    public boolean updateCarStatus(int carId, String status) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(UPDATE_CAR_STATUS);
            ps.setString(1, status);
            ps.setInt(2, carId);

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
     * Delete car by ID
     */
    public boolean deleteCar(int carId) {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(DELETE_CAR);
            ps.setInt(1, carId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException e) {
            System.err.println("❌ Cannot delete car with ID " + carId + " because it has existing rental history.");
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.closeResources(conn, ps, null);
        }
    }

    /**
     * Get total count of cars
     */
    public int getTotalCarCount() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(COUNT_TOTAL_CARS);
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

    /**
     * Get count of currently available cars
     */
    public int getAvailableCarCount() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(COUNT_AVAILABLE_CARS);
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

    // Helper mapper
    private Car mapRowToCar(ResultSet rs) throws SQLException {
        Car car = new Car();
        car.setCarId(rs.getInt("car_id"));
        car.setCarModel(rs.getString("car_model"));
        car.setBrand(rs.getString("brand"));
        car.setCategory(rs.getString("category"));
        car.setRegistrationNumber(rs.getString("registration_number"));
        car.setDailyRate(rs.getDouble("daily_rate"));
        car.setStatus(rs.getString("status"));
        car.setSeatingCapacity(rs.getInt("seating_capacity"));
        car.setFuelType(rs.getString("fuel_type"));
        car.setCreatedAt(rs.getTimestamp("created_at"));
        return car;
    }
}
