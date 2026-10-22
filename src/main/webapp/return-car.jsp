<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.carrental.model.Rental" %>

<%
    request.setAttribute("pageTitle", "Process Car Return");
    Rental rental = (Rental) request.getAttribute("rental");

    if (rental == null) {
        response.sendRedirect(request.getContextPath() + "/rentals");
        return;
    }

    String today = LocalDate.now().toString();
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header">
    <div class="page-title">
        <h1>Vehicle Return & Billing Settlement</h1>
        <p>Inspect returned vehicle, verify return date, calculate late fee, and close booking</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/rentals" class="btn btn-outline">&larr; Back to Rentals</a>
    </div>
</div>

<div class="card form-container">
    <div class="card-header">
        <h2>Return Process for Booking #RN-<%= rental.getRentalId() %></h2>
        <span class="badge badge-active">Active Rental</span>
    </div>
    <div class="card-body">
        
        <!-- Summary of Original Booking -->
        <div style="background:var(--slate-100); border-radius:var(--radius-sm); padding:1rem; margin-bottom:1.5rem;">
            <div class="form-grid" style="row-gap: 0.6rem;">
                <div>
                    <small style="color:var(--slate-600);">Vehicle Rented:</small><br>
                    <strong><%= rental.getCarModel() %></strong> (<code><%= rental.getRegistrationNumber() %></code>)
                </div>
                <div>
                    <small style="color:var(--slate-600);">Customer:</small><br>
                    <strong><%= rental.getCustomerName() %></strong> (📞 <%= rental.getCustomerPhone() %>)
                </div>
                <div>
                    <small style="color:var(--slate-600);">Pickup Date:</small><br>
                    <strong><%= rental.getRentalDate() %></strong>
                </div>
                <div>
                    <small style="color:var(--slate-600);">Scheduled Return Date:</small><br>
                    <strong style="color:var(--primary);"><%= rental.getExpectedReturnDate() %></strong>
                </div>
                <div>
                    <small style="color:var(--slate-600);">Daily Rate Locked:</small><br>
                    <strong>₹<%= String.format("%.2f", rental.getDailyRateApplied()) %></strong> / day
                </div>
                <div>
                    <small style="color:var(--slate-600);">Initial Base Cost (<%= rental.getTotalDays() %> days):</small><br>
                    <strong>₹<%= String.format("%.2f", rental.getBaseCost()) %></strong>
                </div>
            </div>
        </div>

        <form action="<%= request.getContextPath() %>/rentals" method="post">
            <input type="hidden" name="action" value="returnCar">
            <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
            <input type="hidden" name="carId" value="<%= rental.getCarId() %>">

            <!-- Hidden fields for JavaScript Real-Time Calculator -->
            <input type="hidden" id="expectedReturnDateHidden" value="<%= rental.getExpectedReturnDate() %>">
            <input type="hidden" id="dailyRateHidden" value="<%= rental.getDailyRateApplied() %>">
            <input type="hidden" id="baseCostHidden" value="<%= rental.getBaseCost() %>">

            <div class="form-grid">
                <!-- Actual Return Date -->
                <div class="form-group col-span-2">
                    <label for="actualReturnDate">Actual Return Date *</label>
                    <input type="date" id="actualReturnDate" name="actualReturnDate" class="form-control" 
                           value="<%= today %>" required>
                    <span class="form-hint">
                        If return is later than <%= rental.getExpectedReturnDate() %>, a late penalty is automatically applied.
                    </span>
                </div>

                <!-- Inspection Notes -->
                <div class="form-group col-span-2">
                    <label for="returnNotes">Return Vehicle Inspection Notes</label>
                    <textarea id="returnNotes" name="returnNotes" class="form-control" 
                              placeholder="e.g. Fuel tank full, vehicle inspected, odometer reading 45,210 km, no scratches."></textarea>
                </div>
            </div>

            <!-- Real-Time Return Calculation Breakdown -->
            <div class="price-calculation-card">
                <h3 style="font-size:0.95rem; font-weight:700; color:var(--dark); margin-bottom: 0.5rem;">
                    Final Invoice & Settlement Breakdown
                </h3>
                <div class="price-row">
                    <span>Base Rental Charges (<%= rental.getTotalDays() %> days):</span>
                    <span>₹<%= String.format("%.2f", rental.getBaseCost()) %></span>
                </div>
                <div class="price-row">
                    <span>Return Schedule Status:</span>
                    <span id="calcDelayDays" style="font-weight:600; color:var(--success);">On Time (0 Days)</span>
                </div>
                <div class="price-row">
                    <span>Late Penalty Fee (1.5x daily rate):</span>
                    <span id="calcLateFee" style="font-weight:600; color:var(--danger);">₹0.00</span>
                </div>
                <div class="price-row total-row">
                    <span>Final Total Payable:</span>
                    <span id="calcFinalTotal" style="color:var(--dark);">₹<%= String.format("%.2f", rental.getBaseCost()) %></span>
                </div>
            </div>

            <div class="form-actions">
                <a href="<%= request.getContextPath() %>/rentals" class="btn btn-outline">Cancel</a>
                <button type="submit" class="btn btn-success">
                    ✓ Confirm Return & Release Car
                </button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
