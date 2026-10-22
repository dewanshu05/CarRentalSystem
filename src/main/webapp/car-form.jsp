<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrental.model.Car" %>

<%
    Car car = (Car) request.getAttribute("car");
    boolean isEdit = (car != null);
    request.setAttribute("pageTitle", isEdit ? "Edit Car" : "Add New Car");
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header">
    <div class="page-title">
        <h1><%= isEdit ? "Edit Vehicle Details" : "Add New Vehicle to Fleet" %></h1>
        <p><%= isEdit ? "Update specifications, rates, or status for this car" : "Register a new vehicle into the car rental system" %></p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/cars" class="btn btn-outline">&larr; Back to Cars</a>
    </div>
</div>

<div class="card form-container">
    <div class="card-header">
        <h2><%= isEdit ? "Edit Car #" + car.getCarId() : "Vehicle Information Form" %></h2>
    </div>
    <div class="card-body">
        <form action="<%= request.getContextPath() %>/cars" method="post">
            <input type="hidden" name="action" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
                <input type="hidden" name="carId" value="<%= car.getCarId() %>">
            <% } %>

            <div class="form-grid">
                <!-- Car Model -->
                <div class="form-group">
                    <label for="carModel">Car Model Name *</label>
                    <input type="text" id="carModel" name="carModel" class="form-control" 
                           placeholder="e.g. City 1.5L ZX, Creta SX, Swift ZXi" 
                           value="<%= isEdit ? car.getCarModel() : "" %>" required>
                </div>

                <!-- Brand / Manufacturer -->
                <div class="form-group">
                    <label for="brand">Brand / Manufacturer *</label>
                    <input type="text" id="brand" name="brand" class="form-control" 
                           placeholder="e.g. Honda, Hyundai, Toyota, Tata" 
                           value="<%= isEdit ? car.getBrand() : "" %>" required>
                </div>

                <!-- Category -->
                <div class="form-group">
                    <label for="category">Category *</label>
                    <select id="category" name="category" class="form-control" required>
                        <option value="">-- Select Category --</option>
                        <option value="Sedan" <%= (isEdit && "Sedan".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>Sedan</option>
                        <option value="SUV" <%= (isEdit && "SUV".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>SUV</option>
                        <option value="Hatchback" <%= (isEdit && "Hatchback".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>Hatchback</option>
                        <option value="Luxury SUV" <%= (isEdit && "Luxury SUV".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>Luxury SUV</option>
                        <option value="Electric SUV" <%= (isEdit && "Electric SUV".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>Electric SUV</option>
                        <option value="Off-Road SUV" <%= (isEdit && "Off-Road SUV".equalsIgnoreCase(car.getCategory())) ? "selected" : "" %>>Off-Road SUV</option>
                    </select>
                </div>

                <!-- Registration Number -->
                <div class="form-group">
                    <label for="registrationNumber">License Plate / Registration No *</label>
                    <input type="text" id="registrationNumber" name="registrationNumber" class="form-control" 
                           placeholder="e.g. DL-01-AB-1234" 
                           value="<%= isEdit ? car.getRegistrationNumber() : "" %>" required>
                </div>

                <!-- Daily Rental Rate -->
                <div class="form-group">
                    <label for="dailyRate">Daily Rental Rate (₹) *</label>
                    <input type="number" step="0.01" min="100" id="dailyRate" name="dailyRate" class="form-control" 
                           placeholder="e.g. 2500.00" 
                           value="<%= isEdit ? car.getDailyRate() : "2000.00" %>" required>
                </div>

                <!-- Seating Capacity -->
                <div class="form-group">
                    <label for="seatingCapacity">Seating Capacity *</label>
                    <input type="number" min="2" max="12" id="seatingCapacity" name="seatingCapacity" class="form-control" 
                           value="<%= isEdit ? car.getSeatingCapacity() : "5" %>" required>
                </div>

                <!-- Fuel Type -->
                <div class="form-group">
                    <label for="fuelType">Fuel Type *</label>
                    <select id="fuelType" name="fuelType" class="form-control" required>
                        <option value="Petrol" <%= (isEdit && "Petrol".equalsIgnoreCase(car.getFuelType())) ? "selected" : "" %>>Petrol</option>
                        <option value="Diesel" <%= (isEdit && "Diesel".equalsIgnoreCase(car.getFuelType())) ? "selected" : "" %>>Diesel</option>
                        <option value="Electric" <%= (isEdit && "Electric".equalsIgnoreCase(car.getFuelType())) ? "selected" : "" %>>Electric</option>
                        <option value="CNG" <%= (isEdit && "CNG".equalsIgnoreCase(car.getFuelType())) ? "selected" : "" %>>CNG</option>
                        <option value="Hybrid" <%= (isEdit && "Hybrid".equalsIgnoreCase(car.getFuelType())) ? "selected" : "" %>>Hybrid</option>
                    </select>
                </div>

                <!-- Status -->
                <div class="form-group">
                    <label for="status">Vehicle Status *</label>
                    <select id="status" name="status" class="form-control" required>
                        <option value="AVAILABLE" <%= (isEdit && "AVAILABLE".equalsIgnoreCase(car.getStatus())) ? "selected" : "" %>>AVAILABLE (Ready to rent)</option>
                        <option value="RENTED" <%= (isEdit && "RENTED".equalsIgnoreCase(car.getStatus())) ? "selected" : "" %>>RENTED (Currently out)</option>
                        <option value="MAINTENANCE" <%= (isEdit && "MAINTENANCE".equalsIgnoreCase(car.getStatus())) ? "selected" : "" %>>MAINTENANCE (Servicing/Repair)</option>
                    </select>
                </div>
            </div>

            <div class="form-actions">
                <a href="<%= request.getContextPath() %>/cars" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-primary">
                    <%= isEdit ? "Update Vehicle" : "Save & Add Vehicle" %>
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
