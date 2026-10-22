package com.carrental.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.carrental.config.DBConnection;
import com.carrental.model.Rental;

/**
 * Data Access Object (DAO) for Rental entity.
 * Handles booking transactions, returns, automatic charge updates, and metrics.
 * 
 * College Viva Tip:
 * Notice bookCar() and returnCar() use Database Transactions (conn.setAutoCommit(false),
 * conn.commit(), conn.rollback()). This ensures ACID properties: a rental is NEVER recorded
 * without also updating the car's availability status!
 */
public class RentalDAO {

    private static final String INSERT_RENTAL = 
        "INSERT INTO rentals (car_id, customer_id, rental_date, expected_return_date, total_days, " +
        "daily_rate_applied, base_cost, late_fee, total_cost, status, notes) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?)";

    private static final String SELECT_ALL_RENTALS = 
        "SELECT r.*, c.car_model, c.registration_number, cust.full_name AS customer_name, cust.phone AS customer_phone " +
        "FROM rentals r " +
        "JOIN cars c ON r.car_id = c.car_id " +
        "JOIN customers cust ON r.customer_id = cust.customer_id " +
        "ORDER BY r.rental_id DESC";

    private static final String SELECT_ACTIVE_RENTALS = 
        "SELECT r.*, c.car_model, c.registration_number, cust.full_name AS customer_name, cust.phone AS customer_phone " +
        "FROM rentals r " +
        "JOIN cars c ON r.car_id = c.car_id " +
        "JOIN customers cust ON r.customer_id = cust.customer_id " +
        "WHERE r.status = 'ACTIVE' " +
        "ORDER BY r.rental_id DESC";

    private static final String SELECT_RENTAL_BY_ID = 
        "SELECT r.*, c.car_model, c.registration_number, cust.full_name AS customer_name, cust.phone AS customer_phone " +
        "FROM rentals r " +
        "JOIN cars c ON r.car_id = c.car_id " +
        "JOIN customers cust ON r.customer_id = cust.customer_id " +
        "WHERE r.rental_id = ?";

    private static final String SELECT_RENTALS_BY_CUSTOMER_ID = 
        "SELECT r.*, c.car_model, c.registration_number, cust.full_name AS customer_name, cust.phone AS customer_phone " +
        "FROM rentals r " +
        "JOIN cars c ON r.car_id = c.car_id " +
        "JOIN customers cust ON r.customer_id = cust.customer_id " +
        "WHERE r.customer_id = ? " +
        "ORDER BY r.rental_id DESC";

    private static final String COUNT_CUSTOMER_ACTIVE_RENTALS = 
        "SELECT COUNT(*) FROM rentals WHERE customer_id = ? AND status = 'ACTIVE'";

    private static final String SUM_CUSTOMER_TOTAL_SPENT = 
        "SELECT COALESCE(SUM(total_cost), 0) FROM rentals WHERE customer_id = ?";

    private static final String UPDATE_RENTAL_RETURN = 
        "UPDATE rentals SET actual_return_date = ?, late_fee = ?, total_cost = ?, status = 'COMPLETED', notes = ? " +
        "WHERE rental_id = ?";

    private static final String COUNT_ACTIVE_RENTALS = 
        "SELECT COUNT(*) FROM rentals WHERE status = 'ACTIVE'";

    private static final String SUM_TOTAL_REVENUE = 
        "SELECT COALESCE(SUM(total_cost), 0) FROM rentals WHERE status = 'COMPLETED'";

    /**
     * Books a car in an ACID transaction:
     * 1. Inserts a new row in 'rentals' table.
     * 2. Updates the 'cars' table setting status = 'RENTED'.
     */
    public boolean bookCar(Rental rental) {
        Connection conn = null;
        PreparedStatement psRental = null;
        PreparedStatement psCar = null;

        try {
            conn = DBConnection.getConnection();
            // Start transaction
            conn.setAutoCommit(false);

            // 1. Insert into rentals
            psRental = conn.prepareStatement(INSERT_RENTAL);
            psRental.setInt(1, rental.getCarId());
            psRental.setInt(2, rental.getCustomerId());
            psRental.setDate(3, rental.getRentalDate());
            psRental.setDate(4, rental.getExpectedReturnDate());
            psRental.setInt(5, rental.getTotalDays());
            psRental.setDouble(6, rental.getDailyRateApplied());
            psRental.setDouble(7, rental.getBaseCost());
            psRental.setDouble(8, rental.getLateFee());
            psRental.setDouble(9, rental.getTotalCost());
            psRental.setString(10, rental.getNotes());
            psRental.executeUpdate();

            // 2. Mark car as RENTED
            String updateCarSql = "UPDATE cars SET status = 'RENTED' WHERE car_id = ?";
            psCar = conn.prepareStatement(updateCarSql);
            psCar.setInt(1, rental.getCarId());
            psCar.executeUpdate();

            // Commit transaction
            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            DBConnection.closeResources(null, psRental, null);
            DBConnection.closeResources(conn, psCar, null);
        }
    }

    /**
     * Processes car return in an ACID transaction:
     * 1. Updates rental row with actual return date, calculated late fee, total cost, and status = 'COMPLETED'.
     * 2. Updates car row back to status = 'AVAILABLE'.
     */
    public boolean returnCar(int rentalId, int carId, Date actualReturnDate, double lateFee, double totalCost, String notes) {
        Connection conn = null;
        PreparedStatement psRental = null;
        PreparedStatement psCar = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update Rental record
            psRental = conn.prepareStatement(UPDATE_RENTAL_RETURN);
            psRental.setDate(1, actualReturnDate);
            psRental.setDouble(2, lateFee);
            psRental.setDouble(3, totalCost);
            psRental.setString(4, notes);
            psRental.setInt(5, rentalId);
            psRental.executeUpdate();

            // 2. Mark car back as AVAILABLE
            String updateCarSql = "UPDATE cars SET status = 'AVAILABLE' WHERE car_id = ?";
            psCar = conn.prepareStatement(updateCarSql);
            psCar.setInt(1, carId);
            psCar.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            return false;
        } finally {
            try {
                if (conn != null) conn.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            DBConnection.closeResources(null, psRental, null);
            DBConnection.closeResources(conn, psCar, null);
        }
    }

    /**
     * Get all rentals with car and customer names
     */
    public List<Rental> getAllRentals() {
        List<Rental> list = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SELECT_ALL_RENTALS);

            while (rs.next()) {
                list.add(mapRowToRental(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return list;
    }

    /**
     * Get only active rentals
     */
    public List<Rental> getActiveRentals() {
        List<Rental> list = new ArrayList<>();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SELECT_ACTIVE_RENTALS);

            while (rs.next()) {
                list.add(mapRowToRental(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return list;
    }

    /**
     * Find single rental by ID
     */
    public Rental getRentalById(int rentalId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Rental rental = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_RENTAL_BY_ID);
            ps.setInt(1, rentalId);
            rs = ps.executeQuery();

            if (rs.next()) {
                rental = mapRowToRental(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return rental;
    }

    /**
     * Get rental history for a specific customer (for Customer Portal)
     */
    public List<Rental> getRentalsByCustomerId(int customerId) {
        List<Rental> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SELECT_RENTALS_BY_CUSTOMER_ID);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRowToRental(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return list;
    }

    /**
     * Count active rentals for a specific customer
     */
    public int getCustomerActiveRentalsCount(int customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(COUNT_CUSTOMER_ACTIVE_RENTALS);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return 0;
    }

    /**
     * Calculate total spent by a specific customer
     */
    public double getCustomerTotalSpent(int customerId) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(SUM_CUSTOMER_TOTAL_SPENT);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, ps, rs);
        }
        return 0.0;
    }

    /**
     * Count active rentals
     */
    public int getActiveRentalsCount() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(COUNT_ACTIVE_RENTALS);
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
     * Calculate total revenue from completed rentals
     */
    public double getTotalRevenue() {
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(SUM_TOTAL_REVENUE);
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.closeResources(conn, stmt, rs);
        }
        return 0.0;
    }

    private Rental mapRowToRental(ResultSet rs) throws SQLException {
        Rental r = new Rental();
        r.setRentalId(rs.getInt("rental_id"));
        r.setCarId(rs.getInt("car_id"));
        r.setCustomerId(rs.getInt("customer_id"));
        r.setRentalDate(rs.getDate("rental_date"));
        r.setExpectedReturnDate(rs.getDate("expected_return_date"));
        r.setActualReturnDate(rs.getDate("actual_return_date"));
        r.setTotalDays(rs.getInt("total_days"));
        r.setDailyRateApplied(rs.getDouble("daily_rate_applied"));
        r.setBaseCost(rs.getDouble("base_cost"));
        r.setLateFee(rs.getDouble("late_fee"));
        r.setTotalCost(rs.getDouble("total_cost"));
        r.setStatus(rs.getString("status"));
        r.setNotes(rs.getString("notes"));
        r.setCreatedAt(rs.getTimestamp("created_at"));

        // Join values
        r.setCarModel(rs.getString("car_model"));
        r.setRegistrationNumber(rs.getString("registration_number"));
        r.setCustomerName(rs.getString("customer_name"));
        r.setCustomerPhone(rs.getString("customer_phone"));

        return r;
    }

    /**
     * Cancel an ACTIVE rental (by customer): sets status = 'CANCELLED' and marks car AVAILABLE again.
     * Only allowed if rental belongs to the given customerId (security check in DAO).
     */
    public boolean cancelBooking(int rentalId, int customerId) {
        Connection conn = null;
        PreparedStatement psRental = null;
        PreparedStatement psCar = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Get car_id for this rental (and verify ownership + active status)
            PreparedStatement psCheck = conn.prepareStatement(
                "SELECT car_id FROM rentals WHERE rental_id = ? AND customer_id = ? AND status = 'ACTIVE'");
            psCheck.setInt(1, rentalId);
            psCheck.setInt(2, customerId);
            ResultSet rs = psCheck.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                DBConnection.closeResources(null, psCheck, rs);
                return false;
            }
            int carId = rs.getInt("car_id");
            DBConnection.closeResources(null, psCheck, rs);

            // 2. Update rental status to CANCELLED
            psRental = conn.prepareStatement(
                "UPDATE rentals SET status = 'CANCELLED' WHERE rental_id = ? AND customer_id = ?");
            psRental.setInt(1, rentalId);
            psRental.setInt(2, customerId);
            psRental.executeUpdate();

            // 3. Mark car back as AVAILABLE
            psCar = conn.prepareStatement("UPDATE cars SET status = 'AVAILABLE' WHERE car_id = ?");
            psCar.setInt(1, carId);
            psCar.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
            DBConnection.closeResources(null, psRental, null);
            DBConnection.closeResources(conn, psCar, null);
        }
    }

    /**
     * Update the expected return date (and recalculate costs) for an ACTIVE rental.
     * Only allowed if rental belongs to the given customerId.
     */
    public boolean updateBooking(int rentalId, int customerId, Date newExpectedReturnDate, String notes) {
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psUpdate = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Fetch original rental to recalculate cost
            psCheck = conn.prepareStatement(
                "SELECT rental_date, daily_rate_applied FROM rentals WHERE rental_id = ? AND customer_id = ? AND status = 'ACTIVE'");
            psCheck.setInt(1, rentalId);
            psCheck.setInt(2, customerId);
            rs = psCheck.executeQuery();
            if (!rs.next()) {
                conn.rollback();
                return false;
            }
            Date rentalDate = rs.getDate("rental_date");
            double dailyRate = rs.getDouble("daily_rate_applied");
            DBConnection.closeResources(null, psCheck, rs);

            // 2. Recalculate days & cost
            long diffMillis = newExpectedReturnDate.getTime() - rentalDate.getTime();
            int days = (int) java.util.concurrent.TimeUnit.DAYS.convert(diffMillis, java.util.concurrent.TimeUnit.MILLISECONDS);
            if (days <= 0) days = 1;
            double baseCost = days * dailyRate;

            // 3. Update rental
            psUpdate = conn.prepareStatement(
                "UPDATE rentals SET expected_return_date = ?, total_days = ?, base_cost = ?, total_cost = ?, notes = ? " +
                "WHERE rental_id = ? AND customer_id = ? AND status = 'ACTIVE'");
            psUpdate.setDate(1, newExpectedReturnDate);
            psUpdate.setInt(2, days);
            psUpdate.setDouble(3, baseCost);
            psUpdate.setDouble(4, baseCost);
            psUpdate.setString(5, notes);
            psUpdate.setInt(6, rentalId);
            psUpdate.setInt(7, customerId);
            psUpdate.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            return false;
        } finally {
            try { if (conn != null) conn.setAutoCommit(true); } catch (SQLException e) { e.printStackTrace(); }
            DBConnection.closeResources(null, psUpdate, null);
            DBConnection.closeResources(conn, psCheck, rs);
        }
    }
}

