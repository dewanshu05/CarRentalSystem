package com.carrental.controller;

import java.io.IOException;
import java.util.List;

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
import com.carrental.model.Rental;

/**
 * Controller: DashboardServlet
 * Endpoint: /dashboard (and mapped as root welcome endpoint)
 * Prepares summary KPIs and real-time operational feeds for the admin dashboard.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard", ""})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CarDAO carDAO;
    private CustomerDAO customerDAO;
    private RentalDAO rentalDAO;

    @Override
    public void init() {
        carDAO = new CarDAO();
        customerDAO = new CustomerDAO();
        rentalDAO = new RentalDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Security Check: Verify user is logged in as an ADMIN / OWNER
        javax.servlet.http.HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login?error=" + 
                    java.net.URLEncoder.encode("Please log in to access the Owner / Admin dashboard.", "UTF-8"));
            return;
        }

        com.carrental.model.User user = (com.carrental.model.User) session.getAttribute("currentUser");
        if (user.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard?error=" + 
                    java.net.URLEncoder.encode("Access Denied! You do not have Owner / Administrator privileges.", "UTF-8"));
            return;
        }

        // Fetch Key Metrics
        int totalCars = carDAO.getTotalCarCount();
        int availableCars = carDAO.getAvailableCarCount();
        int totalCustomers = customerDAO.getTotalCustomerCount();
        int activeRentals = rentalDAO.getActiveRentalsCount();
        double totalRevenue = rentalDAO.getTotalRevenue();

        // Fetch recent active rentals & sample available cars
        List<Rental> activeRentalList = rentalDAO.getActiveRentals();
        List<Car> availableCarList = carDAO.getAvailableCars();

        // Pass data to View (dashboard.jsp)
        request.setAttribute("totalCars", totalCars);
        request.setAttribute("availableCars", availableCars);
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("activeRentals", activeRentals);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("activeRentalList", activeRentalList);
        request.setAttribute("availableCarList", availableCarList);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/dashboard.jsp");
        dispatcher.forward(request, response);
    }
}
