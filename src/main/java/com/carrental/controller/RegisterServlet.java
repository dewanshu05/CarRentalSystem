package com.carrental.controller;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.carrental.dao.UserDAO;
import com.carrental.model.Customer;
import com.carrental.model.User;

/**
 * Controller: RegisterServlet
 * Allows self-registration for new customers to browse and book vehicles.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard");
            }
            return;
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/register.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String fullName = request.getParameter("fullName");
            String username = request.getParameter("username");
            String email = request.getParameter("email");
            String password = request.getParameter("password");
            String phone = request.getParameter("phone");
            String licenseNumber = request.getParameter("licenseNumber");
            String address = request.getParameter("address");

            // Check if username or email is already registered
            if (userDAO.isUsernameOrEmailTaken(username, email)) {
                response.sendRedirect(request.getContextPath() + "/register?error=" + 
                        URLEncoder.encode("Username or Email already registered. Please choose another or login.", "UTF-8"));
                return;
            }

            Customer customer = new Customer(fullName, email, phone, licenseNumber, address);
            User newUser = userDAO.registerCustomer(customer, username, password);

            if (newUser != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("currentUser", newUser);
                response.sendRedirect(request.getContextPath() + "/customer/dashboard?msg=" + 
                        URLEncoder.encode("Welcome to DriveEase! Your customer account was created.", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/register?error=" + 
                        URLEncoder.encode("Failed to register. Driving license number might already be in use.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register?error=" + 
                    URLEncoder.encode("Registration error: " + e.getMessage(), "UTF-8"));
        }
    }
}
