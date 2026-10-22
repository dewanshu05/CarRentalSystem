<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.carrental.model.Car" %>
<%@ page import="com.carrental.model.Customer" %>

<%
    request.setAttribute("pageTitle", "Book a Car");
    List<Car> availableCars = (List<Car>) request.getAttribute("availableCars");
    List<Customer> customerList = (List<Customer>) request.getAttribute("customerList");
    String selectedCarId = (String) request.getAttribute("selectedCarId");

    String today = LocalDate.now().toString();
    String tomorrow = LocalDate.now().plusDays(2).toString();

    if (availableCars == null || customerList == null) {
        response.sendRedirect(request.getContextPath() + "/rentals?action=new");
        return;
    }
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header">
    <div class="page-title">
        <h1>Book a Car for Rental</h1>
        <p>Assign an available vehicle to a customer and calculate charges</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/rentals" class="btn btn-outline">&larr; Back to Rentals</a>
    </div>
</div>

<div class="card form-container">
    <div class="card-header">
        <h2>New Reservation Form</h2>
        <span class="badge badge-available">
            <%= availableCars.size() %> Vehicles Available
        </span>
    </div>
    <div class="card-body">
        <% if (availableCars.isEmpty()) { %>
            <div class="alert alert-danger" style="margin-bottom: 1.5rem;">
                <strong>No cars available!</strong> All vehicles are currently rented or in maintenance. 
                Please return a vehicle or add new cars to the inventory.
            </div>
        <% } %>

        <% if (customerList.isEmpty()) { %>
            <div class="alert alert-danger" style="margin-bottom: 1.5rem;">
                <strong>No registered customers!</strong> You must 
                <a href="<%= request.getContextPath() %>/customers?action=new" style="text-decoration: underline; font-weight: bold;">
                    register at least one customer
                </a> 
                before creating a booking.
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/rentals" method="post">
            <input type="hidden" name="action" value="book">

            <div class="form-grid">
                <!-- Select Customer -->
                <div class="form-group col-span-2">
                    <label for="customerId">Select Customer *</label>
                    <select id="customerId" name="customerId" class="form-control" required <%= customerList.isEmpty() ? "disabled" : "" %>>
                        <option value="">-- Choose a Registered Customer --</option>
                        <% for (Customer cust : customerList) { %>
                            <option value="<%= cust.getCustomerId() %>">
                                <%= cust.getFullName() %> (📞 <%= cust.getPhone() %> | DL: <%= cust.getLicenseNumber() %>)
                            </option>
                        <% } %>
                    </select>
                    <div style="margin-top:0.3rem;">
                        <small>Customer not in list? <a href="<%= request.getContextPath() %>/customers?action=new" style="color:var(--primary); font-weight:600;">+ Register New Customer</a></small>
                    </div>
                </div>

                <!-- Select Available Car -->
                <div class="form-group col-span-2">
                    <label for="carSelect">Select Available Vehicle *</label>
                    <select id="carSelect" name="carId" class="form-control" required <%= availableCars.isEmpty() ? "disabled" : "" %>>
                        <option value="" data-rate="0">-- Choose Available Vehicle --</option>
                        <% for (Car car : availableCars) { 
                            boolean isSelected = (selectedCarId != null && selectedCarId.equals(String.valueOf(car.getCarId())));
                        %>
                            <option value="<%= car.getCarId() %>" 
                                    data-rate="<%= car.getDailyRate() %>"
                                    <%= isSelected ? "selected" : "" %>>
                                <%= car.getBrand() %> <%= car.getCarModel() %> [<%= car.getRegistrationNumber() %>] &bull; <%= car.getCategory() %> &bull; ₹<%= String.format("%.2f", car.getDailyRate()) %>/day
                            </option>
                        <% } %>
                    </select>
                </div>

                <!-- Rental Pickup Date -->
                <div class="form-group">
                    <label for="rentalDate">Pickup Date *</label>
                    <input type="date" id="rentalDate" name="rentalDate" class="form-control" 
                           value="<%= today %>" required>
                </div>

                <!-- Expected Return Date -->
                <div class="form-group">
                    <label for="expectedReturnDate">Expected Return Date *</label>
                    <input type="date" id="expectedReturnDate" name="expectedReturnDate" class="form-control" 
                           value="<%= tomorrow %>" required>
                </div>

                <!-- Rental Notes -->
                <div class="form-group col-span-2">
                    <label for="notes">Booking Purpose / Destination Notes</label>
                    <textarea id="notes" name="notes" class="form-control" 
                              placeholder="e.g. Outstation family trip to Jaipur, includes GPS navigation kit."></textarea>
                </div>
            </div>

            <!-- Dynamic Live Pricing Box -->
            <div class="price-calculation-card">
                <h3 style="font-size:0.95rem; font-weight:700; color:var(--dark); margin-bottom: 0.5rem;">
                    Automatic Rental Charge Summary
                </h3>
                <div class="price-row">
                    <span>Daily Vehicle Rate:</span>
                    <span id="calcDailyRate" style="font-weight:600;">₹0.00</span>
                </div>
                <div class="price-row">
                    <span>Duration:</span>
                    <span id="calcDays" style="font-weight:600;">0 Days</span>
                </div>
                <div class="price-row total-row">
                    <span>Estimated Total Cost:</span>
                    <span id="calcTotalCost" style="color:var(--primary);">₹0.00</span>
                </div>
                <small style="color:var(--slate-600); display:block; margin-top:0.4rem;">
                    * Charges calculated automatically as (Days × Daily Rate). Late returns incur 1.5x penalty per extra day.
                </small>
            </div>

            <div class="form-actions">
                <a href="<%= request.getContextPath() %>/rentals" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary" <%= (availableCars.isEmpty() || customerList.isEmpty()) ? "disabled" : "" %>>
                    Confirm & Book Vehicle
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
