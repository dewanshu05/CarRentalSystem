package com.carrental.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.sql.Date;
import java.util.List;
import java.util.concurrent.TimeUnit;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.carrental.dao.CarDAO;
import com.carrental.dao.RentalDAO;
import com.carrental.model.Car;
import com.carrental.model.Rental;
import com.carrental.model.User;

/**
 * Controller: CustomerPortalServlet
 * Handles the dedicated Customer Portal:
 *  - /customer/dashboard      : browse available cars, view personal summary stats
 *  - /customer/bookings       : view personal booking history & invoice details
 *  - /customer/book           : book vehicle directly for the logged-in customer
 *  - /customer/edit-booking   : edit (update return date of) an active booking
 *  - /customer/cancel-booking : cancel an active booking
 */
@WebServlet(name = "CustomerPortalServlet", urlPatterns = {
    "/customer/dashboard", "/customer/bookings", "/customer/book",
    "/customer/edit-booking", "/customer/cancel-booking"
})
public class CustomerPortalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CarDAO carDAO;
    private RentalDAO rentalDAO;

    @Override
    public void init() {
        carDAO = new CarDAO();
        rentalDAO = new RentalDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getAuthenticatedCustomer(request, response);
        if (currentUser == null) return;

        String path = request.getServletPath();

        if ("/customer/bookings".equals(path)) {
            showMyBookings(request, response, currentUser);
        } else if ("/customer/book".equals(path)) {
            showBookingForm(request, response, currentUser);
        } else if ("/customer/edit-booking".equals(path)) {
            showEditBookingForm(request, response, currentUser);
        } else {
            showCustomerDashboard(request, response, currentUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User currentUser = getAuthenticatedCustomer(request, response);
        if (currentUser == null) return;

        String path = request.getServletPath();
        if ("/customer/book".equals(path)) {
            processCustomerBooking(request, response, currentUser);
        } else if ("/customer/edit-booking".equals(path)) {
            processEditBooking(request, response, currentUser);
        } else if ("/customer/cancel-booking".equals(path)) {
            processCancelBooking(request, response, currentUser);
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        }
    }

    // -------------------------------------------------------------------------
    // GET handlers
    // -------------------------------------------------------------------------

    private void showCustomerDashboard(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Car> availableCars = carDAO.getAvailableCars();
        List<Rental> myRentals = rentalDAO.getRentalsByCustomerId(user.getCustomerId());
        int activeCount = rentalDAO.getCustomerActiveRentalsCount(user.getCustomerId());
        double totalSpent = rentalDAO.getCustomerTotalSpent(user.getCustomerId());

        request.setAttribute("availableCars", availableCars);
        request.setAttribute("myRentals", myRentals);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("totalSpent", totalSpent);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-dashboard.jsp");
        dispatcher.forward(request, response);
    }

    private void showMyBookings(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Rental> myRentals = rentalDAO.getRentalsByCustomerId(user.getCustomerId());
        int activeCount = rentalDAO.getCustomerActiveRentalsCount(user.getCustomerId());
        double totalSpent = rentalDAO.getCustomerTotalSpent(user.getCustomerId());

        request.setAttribute("myRentals", myRentals);
        request.setAttribute("activeCount", activeCount);
        request.setAttribute("totalSpent", totalSpent);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-bookings.jsp");
        dispatcher.forward(request, response);
    }

    private void showBookingForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        List<Car> availableCars = carDAO.getAvailableCars();
        String carIdParam = request.getParameter("carId");

        request.setAttribute("availableCars", availableCars);
        request.setAttribute("selectedCarId", carIdParam);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-book.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditBookingForm(HttpServletRequest request, HttpServletResponse response, User user)
            throws ServletException, IOException {
        String rentalIdParam = request.getParameter("rentalId");
        if (rentalIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
            return;
        }
        try {
            int rentalId = Integer.parseInt(rentalIdParam);
            Rental rental = rentalDAO.getRentalById(rentalId);
            // Security: must belong to this customer and be ACTIVE
            if (rental == null || rental.getCustomerId() != user.getCustomerId() || !rental.isActive()) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" +
                        URLEncoder.encode("Booking not found or cannot be edited.", "UTF-8"));
                return;
            }
            request.setAttribute("rental", rental);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-edit-booking.jsp");
            dispatcher.forward(request, response);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/bookings");
        }
    }

    // -------------------------------------------------------------------------
    // POST handlers
    // -------------------------------------------------------------------------

    private void processCustomerBooking(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            int carId = Integer.parseInt(request.getParameter("carId"));
            Date rentalDate = Date.valueOf(request.getParameter("rentalDate"));
            Date expectedReturnDate = Date.valueOf(request.getParameter("expectedReturnDate"));
            String notes = request.getParameter("notes");

            if (expectedReturnDate.before(rentalDate)) {
                response.sendRedirect(request.getContextPath() + "/customer/book?carId=" + carId + "&error=" +
                        URLEncoder.encode("Return date cannot be earlier than pickup date!", "UTF-8"));
                return;
            }

            long diffInMillis = expectedReturnDate.getTime() - rentalDate.getTime();
            int days = (int) TimeUnit.DAYS.convert(diffInMillis, TimeUnit.MILLISECONDS);
            if (days <= 0) days = 1;

            Car car = carDAO.getCarById(carId);
            if (car == null || !car.isAvailable()) {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=" +
                        URLEncoder.encode("Selected car is no longer available. Please choose another.", "UTF-8"));
                return;
            }

            double dailyRate = car.getDailyRate();
            double baseCost = days * dailyRate;

            Rental rental = new Rental(carId, user.getCustomerId(), rentalDate, expectedReturnDate,
                    days, dailyRate, baseCost, baseCost, notes);

            boolean success = rentalDAO.bookCar(rental);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?msg=" +
                        URLEncoder.encode("🎉 Booking confirmed! Your car is reserved.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/book?carId=" + carId + "&error=" +
                        URLEncoder.encode("Database error booking car. Please try again.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=" +
                    URLEncoder.encode("Error processing booking: " + e.getMessage(), "UTF-8"));
        }
    }

    private void processEditBooking(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            int rentalId = Integer.parseInt(request.getParameter("rentalId"));
            Date newReturnDate = Date.valueOf(request.getParameter("expectedReturnDate"));
            String notes = request.getParameter("notes");

            // Fetch rental to validate pickup date
            Rental rental = rentalDAO.getRentalById(rentalId);
            if (rental == null || rental.getCustomerId() != user.getCustomerId() || !rental.isActive()) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" +
                        URLEncoder.encode("Booking not found or cannot be edited.", "UTF-8"));
                return;
            }

            if (newReturnDate.before(rental.getRentalDate()) || newReturnDate.equals(rental.getRentalDate())) {
                response.sendRedirect(request.getContextPath() + "/customer/edit-booking?rentalId=" + rentalId + "&error=" +
                        URLEncoder.encode("Return date must be after the pickup date.", "UTF-8"));
                return;
            }

            boolean success = rentalDAO.updateBooking(rentalId, user.getCustomerId(), newReturnDate, notes);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?msg=" +
                        URLEncoder.encode("✅ Booking #RN-" + rentalId + " updated successfully.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/edit-booking?rentalId=" + rentalId + "&error=" +
                        URLEncoder.encode("Could not update booking. Please try again.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" +
                    URLEncoder.encode("Error updating booking: " + e.getMessage(), "UTF-8"));
        }
    }

    private void processCancelBooking(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {
        try {
            int rentalId = Integer.parseInt(request.getParameter("rentalId"));
            boolean success = rentalDAO.cancelBooking(rentalId, user.getCustomerId());
            if (success) {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?msg=" +
                        URLEncoder.encode("Booking #RN-" + rentalId + " has been cancelled. The car is now available again.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" +
                        URLEncoder.encode("Could not cancel booking. It may already be completed or cancelled.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customer/bookings?error=" +
                    URLEncoder.encode("Error cancelling booking: " + e.getMessage(), "UTF-8"));
        }
    }

    /**
     * Security check: Ensures user is logged in as a CUSTOMER.
     */
    private User getAuthenticatedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" +
                    URLEncoder.encode("Please log in to access your customer account.", "UTF-8"));
            return null;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return null;
        }

        if (user.getCustomerId() == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" +
                    URLEncoder.encode("Customer account profile not linked.", "UTF-8"));
            return null;
        }

        return user;
    }
}
