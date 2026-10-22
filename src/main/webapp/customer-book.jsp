<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="com.carrental.model.Car" %>
<%@ page import="com.carrental.model.User" %>

<%
    request.setAttribute("pageTitle", "Reserve Vehicle");
    User currentUser = (User) session.getAttribute("currentUser");
    List<Car> availableCars = (List<Car>) request.getAttribute("availableCars");
    String selectedCarId = (String) request.getAttribute("selectedCarId");
    String errorMsg = request.getParameter("error");

    String today = LocalDate.now().toString();
    String tomorrow = LocalDate.now().plusDays(2).toString();

    if (currentUser == null || availableCars == null) {
        response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        return;
    }
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header" style="margin-bottom: 1.5rem;">
    <div class="page-title">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--slate-500); margin-bottom:0.25rem;">Vehicle Reservation</div>
        <h1 style="font-size:1.85rem; font-weight:800; letter-spacing:-0.03em; color:var(--dark); margin:0;">Confirm Vehicle Booking</h1>
        <p style="color:var(--slate-600); font-size:0.93rem; margin-top:0.25rem;">Select pickup and return dates with automatic real-time rate calculation</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/customer/dashboard" class="btn btn-outline">&larr; Back to Fleet</a>
    </div>
</div>

<% if (errorMsg != null && !errorMsg.isEmpty()) { %>
<div class="alert alert-error" style="display:flex;align-items:center;gap:0.75rem;background:#fef2f2;border:1px solid #fecaca;color:#991b1b;padding:1rem 1.25rem;border-radius:var(--radius-sm);margin-bottom:1.5rem;font-weight:500;">
    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= errorMsg %>
</div>
<% } %>

<div style="display:grid; grid-template-columns:1fr 380px; gap:1.75rem; align-items:start;">

    <!-- Left Column: Form -->
    <div class="card">
        <div class="card-header" style="padding:1.25rem 1.5rem; border-bottom:1px solid var(--border);">
            <div style="display:flex; justify-content:space-between; align-items:center; width:100%;">
                <h2 style="font-size:1.15rem; font-weight:700; color:var(--dark); margin:0;">Reservation Specifications</h2>
                <span class="badge badge-available"><%= availableCars.size() %> Vehicles Ready</span>
            </div>
        </div>
        <div class="card-body" style="padding:1.5rem;">
            
            <% if (availableCars.isEmpty()) { %>
                <div class="alert alert-danger" style="margin-bottom: 1.5rem;">
                    <strong>No vehicles currently available!</strong> All vehicles are out on hire. Please check back soon.
                </div>
            <% } %>

            <form action="<%= request.getContextPath() %>/customer/book" method="post" id="customerBookingForm">
                <div class="form-grid">
                    <!-- Vehicle Dropdown -->
                    <div class="form-group col-span-2">
                        <label for="carSelect" style="font-weight:600; color:var(--dark);">Select Vehicle from Fleet *</label>
                        <select id="carSelect" name="carId" class="form-control" required style="font-size:0.95rem; padding:0.7rem 0.85rem;">
                            <option value="" data-rate="0">-- Select an available vehicle --</option>
                            <% for (Car car : availableCars) { 
                                boolean isSelected = (selectedCarId != null && selectedCarId.equals(String.valueOf(car.getCarId())));
                            %>
                                <option value="<%= car.getCarId() %>" 
                                        data-rate="<%= car.getDailyRate() %>"
                                        data-model="<%= car.getBrand() %> <%= car.getCarModel() %>"
                                        data-cat="<%= car.getCategory() %>"
                                        <%= isSelected ? "selected" : "" %>>
                                    <%= car.getBrand() %> <%= car.getCarModel() %> (<%= car.getCategory() %> &bull; <%= car.getRegistrationNumber() %>) — ₹<%= String.format("%.2f", car.getDailyRate()) %>/day
                                </option>
                            <% } %>
                        </select>
                    </div>

                    <!-- Pickup Date -->
                    <div class="form-group">
                        <label for="rentalDate" style="font-weight:600; color:var(--dark);">Pickup Date *</label>
                        <input type="date" id="rentalDate" name="rentalDate" class="form-control" 
                               value="<%= today %>" min="<%= today %>" required>
                    </div>

                    <!-- Return Date -->
                    <div class="form-group">
                        <label for="expectedReturnDate" style="font-weight:600; color:var(--dark);">Scheduled Return Date *</label>
                        <input type="date" id="expectedReturnDate" name="expectedReturnDate" class="form-control" 
                               value="<%= tomorrow %>" min="<%= today %>" required>
                    </div>

                    <!-- Notes -->
                    <div class="form-group col-span-2">
                        <label for="notes" style="font-weight:600; color:var(--dark);">Trip Destination / Special Requests (Optional)</label>
                        <textarea id="notes" name="notes" class="form-control" 
                                  placeholder="e.g. Weekend road trip, outstation travel to Mysore, GPS preferred..."></textarea>
                    </div>
                </div>

                <!-- Form Action Buttons -->
                <div class="form-actions" style="margin-top:2rem; padding-top:1.25rem; border-top:1px solid var(--border); display:flex; justify-content:flex-end; gap:0.75rem;">
                    <a href="<%= request.getContextPath() %>/customer/dashboard" class="btn btn-outline">Cancel</a>
                    <button type="submit" class="btn btn-primary" style="padding:0.65rem 1.5rem; font-weight:700;" <%= availableCars.isEmpty() ? "disabled" : "" %>>
                        Confirm &amp; Reserve Vehicle &rarr;
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Right Column: Live Fare Preview & Guarantees -->
    <div style="display:flex; flex-direction:column; gap:1.25rem;">
        
        <!-- Live Trip Fare Breakdown Card -->
        <div class="card" style="border:1px solid #bfdbfe; background:linear-gradient(180deg, #ffffff, #f8fafc);">
            <div class="card-header" style="background:#eff6ff; border-bottom:1px solid #bfdbfe; padding:1rem 1.25rem;">
                <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:#1e40af;">Live Fare Calculator</div>
                <h3 style="font-size:1.1rem; font-weight:800; color:var(--dark); margin:0.2rem 0 0;">Trip Charge Summary</h3>
            </div>
            <div class="card-body" style="padding:1.25rem;">
                <div style="display:flex; justify-content:space-between; font-size:0.9rem; padding:0.4rem 0; color:var(--slate-600);">
                    <span>Vehicle Selected:</span>
                    <strong id="summaryCarModel" style="color:var(--dark); text-align:right;">—</strong>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:0.9rem; padding:0.4rem 0; color:var(--slate-600);">
                    <span>Daily Rental Rate:</span>
                    <strong id="summaryDailyRate" style="color:var(--dark);">₹0.00</strong>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:0.9rem; padding:0.4rem 0; color:var(--slate-600);">
                    <span>Duration:</span>
                    <strong id="summaryDays" style="color:var(--dark);">0 Days</strong>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:0.9rem; padding:0.4rem 0; color:var(--slate-600);">
                    <span>Base Fare:</span>
                    <strong id="summaryBase" style="color:var(--dark);">₹0.00</strong>
                </div>
                <div style="display:flex; justify-content:space-between; font-size:0.9rem; padding:0.4rem 0; color:var(--slate-600);">
                    <span>Insurance &amp; Roadside:</span>
                    <strong style="color:#059669;">Included (Free)</strong>
                </div>
                
                <div style="border-top:1px solid #bfdbfe; margin-top:0.75rem; padding-top:0.85rem; display:flex; justify-content:space-between; align-items:baseline;">
                    <div>
                        <span style="font-size:0.82rem; font-weight:700; text-transform:uppercase; color:var(--slate-500); display:block;">Total Estimated</span>
                        <small style="color:var(--slate-500);">(Taxes included)</small>
                    </div>
                    <div style="font-size:1.6rem; font-weight:800; color:var(--primary);" id="summaryTotal">₹0.00</div>
                </div>
            </div>
        </div>

        <!-- Verified Driver Card -->
        <div class="card" style="border-left:4px solid #10b981;">
            <div class="card-body" style="padding:1.25rem;">
                <div style="display:flex; align-items:center; gap:0.5rem; margin-bottom:0.6rem;">
                    <span style="width:8px; height:8px; border-radius:50%; background:#10b981;"></span>
                    <strong style="font-size:0.88rem; color:#065f46; text-transform:uppercase; letter-spacing:0.04em;">Verified Driver Account</strong>
                </div>
                <div style="font-size:0.9rem; color:var(--dark); line-height:1.6;">
                    <strong><%= currentUser.getFullName() %></strong><br>
                    <span style="color:var(--slate-600);"><%= currentUser.getEmail() %></span>
                </div>
            </div>
        </div>

        <!-- Trust Badges -->
        <div style="background:var(--bg-light); border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem; font-size:0.85rem; color:var(--slate-600); line-height:1.8;">
            <div style="display:flex; align-items:center; gap:0.5rem;">
                <span style="color:#10b981;">✓</span> Full Comprehensive Insurance Included
            </div>
            <div style="display:flex; align-items:center; gap:0.5rem;">
                <span style="color:#10b981;">✓</span> 100% Sanitized &amp; Safety Inspected
            </div>
            <div style="display:flex; align-items:center; gap:0.5rem;">
                <span style="color:#10b981;">✓</span> Free Cancellation &amp; Flexible Edits
            </div>
        </div>

    </div>
</div>

<script>
(function() {
    const carSelect = document.getElementById('carSelect');
    const pickupInput = document.getElementById('rentalDate');
    const returnInput = document.getElementById('expectedReturnDate');

    const summaryCar = document.getElementById('summaryCarModel');
    const summaryRate = document.getElementById('summaryDailyRate');
    const summaryDays = document.getElementById('summaryDays');
    const summaryBase = document.getElementById('summaryBase');
    const summaryTotal = document.getElementById('summaryTotal');

    function recalculate() {
        const selectedOpt = carSelect.options[carSelect.selectedIndex];
        const dailyRate = selectedOpt ? parseFloat(selectedOpt.dataset.rate || 0) : 0;
        const carModel = selectedOpt && selectedOpt.dataset.model ? selectedOpt.dataset.model : '—';

        const pDate = new Date(pickupInput.value);
        const rDate = new Date(returnInput.value);

        let days = 1;
        if (!isNaN(pDate) && !isNaN(rDate)) {
            const diff = rDate - pDate;
            days = Math.round(diff / (1000 * 60 * 60 * 24));
            if (days <= 0) days = 1;
        }

        const total = days * dailyRate;

        summaryCar.textContent = carModel;
        summaryRate.textContent = '₹' + dailyRate.toFixed(2) + '/day';
        summaryDays.textContent = days + (days === 1 ? ' Day' : ' Days');
        summaryBase.textContent = '₹' + total.toFixed(2);
        summaryTotal.textContent = '₹' + total.toFixed(2);
    }

    carSelect.addEventListener('change', recalculate);
    pickupInput.addEventListener('change', recalculate);
    returnInput.addEventListener('change', recalculate);

    recalculate();
})();
</script>

<jsp:include page="/includes/footer.jsp" />
