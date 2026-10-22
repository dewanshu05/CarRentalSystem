package com.carrental.controller;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.carrental.dao.CustomerDAO;
import com.carrental.model.Customer;

/**
 * Controller: CustomerServlet
 * Endpoint: /customers
 * Handles Customer CRUD operations and driver profile management.
 */
@WebServlet(name = "CustomerServlet", urlPatterns = {"/customers"})
public class CustomerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private CustomerDAO customerDAO;

    @Override
    public void init() {
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
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteCustomer(request, response);
                break;
            case "list":
            default:
                listCustomers(request, response);
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
            case "insert":
                insertCustomer(request, response);
                break;
            case "update":
                updateCustomer(request, response);
                break;
            default:
                listCustomers(request, response);
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
                    URLEncoder.encode("Access Denied! Customer accounts cannot view customer records.", "UTF-8"));
            return false;
        }
        return true;
    }

    private void listCustomers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Customer> customerList = customerDAO.getAllCustomers();
        request.setAttribute("customerList", customerList);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/customers.jsp");
        dispatcher.forward(request, response);
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-form.jsp");
        dispatcher.forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer != null) {
                request.setAttribute("customer", customer);
                RequestDispatcher dispatcher = request.getRequestDispatcher("/customer-form.jsp");
                dispatcher.forward(request, response);
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Customer not found", "UTF-8"));
            }
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Invalid customer ID", "UTF-8"));
        }
    }

    private void insertCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String licenseNumber = request.getParameter("licenseNumber");
            String address = request.getParameter("address");

            Customer customer = new Customer(fullName, email, phone, licenseNumber, address);
            boolean success = customerDAO.addCustomer(customer);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers?msg=" + URLEncoder.encode("Customer registered successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Failed to register customer. Email or License number might already be registered.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }

    private void updateCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String licenseNumber = request.getParameter("licenseNumber");
            String address = request.getParameter("address");

            Customer customer = new Customer();
            customer.setCustomerId(customerId);
            customer.setFullName(fullName);
            customer.setEmail(email);
            customer.setPhone(phone);
            customer.setLicenseNumber(licenseNumber);
            customer.setAddress(address);

            boolean success = customerDAO.updateCustomer(customer);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers?msg=" + URLEncoder.encode("Customer profile updated!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Failed to update customer.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }

    private void deleteCustomer(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int customerId = Integer.parseInt(request.getParameter("id"));
            boolean success = customerDAO.deleteCustomer(customerId);

            if (success) {
                response.sendRedirect(request.getContextPath() + "/customers?msg=" + URLEncoder.encode("Customer deleted successfully!", "UTF-8"));
            } else {
                response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Cannot delete customer! Existing rental history depends on this record.", "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/customers?error=" + URLEncoder.encode("Invalid customer ID for deletion.", "UTF-8"));
        }
    }
}
