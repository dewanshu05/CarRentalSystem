<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrental.model.Customer" %>

<%
    Customer customer = (Customer) request.getAttribute("customer");
    boolean isEdit = (customer != null);
    request.setAttribute("pageTitle", isEdit ? "Edit Customer" : "Add Customer");
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header">
    <div class="page-title">
        <h1><%= isEdit ? "Edit Customer Profile" : "Register New Customer" %></h1>
        <p><%= isEdit ? "Update personal details, phone number, or address" : "Create a customer account for renting vehicles" %></p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/customers" class="btn btn-outline">&larr; Back to Customers</a>
    </div>
</div>

<div class="card form-container">
    <div class="card-header">
        <h2><%= isEdit ? "Edit Customer #" + customer.getCustomerId() : "Customer Registration Form" %></h2>
    </div>
    <div class="card-body">
        <form action="<%= request.getContextPath() %>/customers" method="post">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
                <input type="hidden" name="customerId" value="<%= customer.getCustomerId() %>">
            <% } %>

            <div class="form-grid">
                <!-- Full Name -->
                <div class="form-group col-span-2">
                    <label for="fullName">Full Name *</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" 
                           placeholder="e.g. Rahul Sharma" 
                           value="<%= isEdit ? customer.getFullName() : "" %>" required>
                </div>

                <!-- Email Address -->
                <div class="form-group">
                    <label for="email">Email Address *</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="e.g. rahul@example.com" 
                           value="<%= isEdit ? customer.getEmail() : "" %>" required>
                </div>

                <!-- Phone Number -->
                <div class="form-group">
                    <label for="phone">Phone Number *</label>
                    <input type="tel" id="phone" name="phone" class="form-control" 
                           placeholder="e.g. 9876543210" 
                           value="<%= isEdit ? customer.getPhone() : "" %>" required>
                </div>

                <!-- License Number -->
                <div class="form-group col-span-2">
                    <label for="licenseNumber">Driving License Number *</label>
                    <input type="text" id="licenseNumber" name="licenseNumber" class="form-control" 
                           placeholder="e.g. DL-0420180012345" 
                           value="<%= isEdit ? customer.getLicenseNumber() : "" %>" required>
                    <span class="form-hint">Must be unique per customer. Verified at pickup.</span>
                </div>

                <!-- Residential Address -->
                <div class="form-group col-span-2">
                    <label for="address">Residential Address</label>
                    <textarea id="address" name="address" class="form-control" 
                              placeholder="e.g. Flat 302, Green Valley Apartments, Bengaluru"><%= isEdit && customer.getAddress() != null ? customer.getAddress() : "" %></textarea>
                </div>
            </div>

            <div class="form-actions">
                <a href="<%= request.getContextPath() %>/customers" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <%= isEdit ? "Update Customer" : "Register Customer" %>
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
