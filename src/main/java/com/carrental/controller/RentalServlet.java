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

import com.carrental.dao.CarDAO;
import com.carrental.dao.CustomerDAO;
import com.carrental.dao.RentalDAO;
import com.carrental.model.Car;
import com.carrental.model.Customer;
import com.carrental.model.Rental;

/**
 * Controller: RentalServlet
 * Endpoint: /rentals
 * Manages car bookings, checking car availability, return processing,
 * and automatic rental & late fee calculations.
 */
@WebServlet(name = "RentalServlet", urlPatterns = {"/rentals"})
public class RentalServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private RentalDAO rentalDAO;
    private CarDAO carDAO;
    private CustomerDAO customerDAO;

    @Override
    public void init() {
        rentalDAO = new RentalDAO();
        carDAO = new CarDAO();
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "new":
                showBookingForm(request, response);
                break;
            case "returnForm":
                showReturnForm(request, response);
                break;
            case "list":
            default:
                listRentals(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "book":
                processBooking(request, response);
                break;
            case "returnCar":
                processReturn(request, response);
                break;
            default:
                listRentals(request, response);
                break;
        }
    }

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" + 
                    URLEncoder.encode("Please log in with Owner credentials.", "UTF-8"));
            return false;
        }
        com.carrental.model.User user = (com.carrental.model.User) session.getAttribute("currentUser");
        if (!user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=" + 
                    URLEncoder.encode("Access Denied! You do not have permission to view all rentals or process returns.", "UTF-8"));
            return false;
        }
        return true;
    }

    // List all rentals with optional status filter
    private void listRentals(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String filter = request.getParameter("filter");
        List<Rental> rentalList;

        if ("active".equalsIgnoreCase(filter)) {
            rentalList = rentalDAO.getActiveRentals();
        } else {
            rentalList = rentalDAO.getAllRentals();
        }

        request.setAttribute("rentalList", rentalList);
        request.setAttribute("currentFilter", filter != null ? filter : "all");
        RequestDispatcher dispatcher = request.getRequestDispatcher("/rentals.jsp");
        dispatcher.forward(request, response);
    }

    // Show booking form with available cars and customers
    private void showBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Car> availableCars = carDAO.getAvailableCars();
        List<Customer> customerList = customerDAO.getAllCustomers();

        request.setAttribute("availableCars", availableCars);
        request.setAttribute("customerList", customerList);

        // Pre-select car if carId passed in query param
        String preSelectedCarId = request.getParameter("carId");
        if (preSelectedCarId != null) {
            request.setAttribute("selectedCarId", preSelectedCarId);
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/book-car.jsp");
        dispatcher.forward(request, response);
    }

    // Process new booking
    private void processBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int carId = Integer.parseInt(request.getParameter("carId"));
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            Date rentalDate = Date.valueOf(request.getParameter("rentalDate"));
            Date expectedReturnDate = Date.valueOf(request.getParameter("expectedReturnDate"));
            String notes = request.getParameter("notes");

            // Validate that expected return date is >= rental date
            if (expectedReturnDate.before(rentalDate)) {
                response.sendRedirect(request.getContextPath() + "/rentals?action=new&error=" + 
                        URLEncoder.encode("Return date cannot be earlier than pickup date!", "UTF-8"));
                return;
            }

            // Calculate rental days
            long diffInMillis = expectedReturnDate.getTime() - rentalDate.getTime();
            int days = (int) TimeUnit.DAYS.convert(diffInMillis, TimeUnit.MILLISECONDS);
            if (days <= 0) {
                days = 1; // Minimum charge is 1 day
            }

            // Fetch Car to lock in current daily rate
            Car car = carDAO.getCarById(carId);
            if (car == null || !car.isAvailable()) {
                response.sendRedirect(request.getContextPath() + "/rentals?action=new&error=" + 
                        URLEncoder.encode("Selected car is currently not available!", "UTF-8"));
                return;
            }

            double dailyRate = car.getDailyRate();
            double baseCost = days * dailyRate;
            double totalCost = baseCost; // Initially totalCost = baseCost (no late fee yet)

            Rental rental = new Rental(carId, customerId, rentalDate, expectedReturnDate,
                    days, dailyRate, baseCost, totalCost, notes);

            boolean success = rentalDAO.bookCar(rental);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/rentals?msg=" + 
                        URLEncoder.encode("Car booked successfully! Vehicle marked as RENTED.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/rentals?action=new&error=" + 
                        URLEncoder.encode("Booking failed due to a database error. Please try again.", "UTF-8"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rentals?action=new&error=" + 
                    URLEncoder.encode("Error processing booking: " + e.getMessage(), "UTF-8"));
        }
    }

    // Show return confirmation form with auto charge calculation preview
    private void showReturnForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int rentalId = Integer.parseInt(request.getParameter("id"));
            Rental rental = rentalDAO.getRentalById(rentalId);

            if (rental == null) {
                response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                        URLEncoder.encode("Rental record not found.", "UTF-8"));
                return;
            }

            if (!rental.isActive()) {
                response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                        URLEncoder.encode("This rental is already closed/completed.", "UTF-8"));
                return;
            }

            request.setAttribute("rental", rental);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/return-car.jsp");
            dispatcher.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                    URLEncoder.encode("Invalid rental ID.", "UTF-8"));
        }
    }

    // Process return of car and calculate late fees
    private void processReturn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int rentalId = Integer.parseInt(request.getParameter("rentalId"));
            int carId = Integer.parseInt(request.getParameter("carId"));
            Date actualReturnDate = Date.valueOf(request.getParameter("actualReturnDate"));
            String returnNotes = request.getParameter("returnNotes");

            Rental rental = rentalDAO.getRentalById(rentalId);
            if (rental == null) {
                response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                        URLEncoder.encode("Rental not found.", "UTF-8"));
                return;
            }

            // Automatic Late Fee Calculation:
            // If actual return date is after expected return date, charge penalty (1.5x daily rate per extra day)
            double lateFee = 0.0;
            if (actualReturnDate.after(rental.getExpectedReturnDate())) {
                long delayMillis = actualReturnDate.getTime() - rental.getExpectedReturnDate().getTime();
                int delayDays = (int) TimeUnit.DAYS.convert(delayMillis, TimeUnit.MILLISECONDS);
                if (delayDays > 0) {
                    // Penalty rate is 1.5 times the daily rate for each delayed day
                    lateFee = delayDays * (rental.getDailyRateApplied() * 1.5);
                }
            }

            double finalTotalCost = rental.getBaseCost() + lateFee;
            String updatedNotes = (rental.getNotes() != null ? rental.getNotes() + " | " : "") + 
                                  "Return: " + (returnNotes != null ? returnNotes : "Vehicle returned successfully.");

            boolean success = rentalDAO.returnCar(rentalId, carId, actualReturnDate, lateFee, finalTotalCost, updatedNotes);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/rentals?msg=" + 
                        URLEncoder.encode("Car returned successfully! Total charges: ₹" + finalTotalCost + 
                                (lateFee > 0 ? " (includes ₹" + lateFee + " late fee)" : ""), "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                        URLEncoder.encode("Failed to process return in database.", "UTF-8"));
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/rentals?error=" + 
                    URLEncoder.encode("Error processing car return: " + e.getMessage(), "UTF-8"));
        }
    }
}
