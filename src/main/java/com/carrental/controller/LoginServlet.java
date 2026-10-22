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
import com.carrental.model.User;

/**
 * Controller: LoginServlet
 * Handles user authentication, session creation, role-based redirection, and logout.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/logout"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();

        // Handle Logout
        if ("/logout".equals(path)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login?msg=" + 
                    URLEncoder.encode("You have been safely logged out.", "UTF-8"));
            return;
        }

        // Check if already logged in
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/dashboard");
                return;
            } else if (user.isCustomer()) {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard");
                return;
            }
        }

        RequestDispatcher dispatcher = request.getRequestDispatcher("/login.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login?error=" + 
                    URLEncoder.encode("Please enter both username and password.", "UTF-8"));
            return;
        }

        User user = userDAO.authenticate(username.trim(), password.trim());

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);

            if (user.isAdmin()) {
                response.sendRedirect(request.getContextPath() + "/dashboard?msg=" + 
                        URLEncoder.encode("Welcome back, Owner / Administrator!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customer/dashboard?msg=" + 
                        URLEncoder.encode("Welcome, " + user.getFullName() + "!", "UTF-8"));
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/login?error=" + 
                    URLEncoder.encode("Invalid username/email or password.", "UTF-8"));
        }
    }
}
