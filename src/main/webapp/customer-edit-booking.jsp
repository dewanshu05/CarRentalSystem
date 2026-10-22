<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrental.model.Rental" %>
<%@ page import="com.carrental.model.User" %>
<%@ page import="java.time.LocalDate" %>

<%
    request.setAttribute("pageTitle", "Edit Booking");
    User currentUser = (User) session.getAttribute("currentUser");
    Rental rental = (Rental) request.getAttribute("rental");
    String errorMsg = request.getParameter("error");

    if (currentUser == null || rental == null) {
        response.sendRedirect(request.getContextPath() + "/customer/bookings");
        return;
    }
    String minDate = rental.getRentalDate().toLocalDate().plusDays(1).toString();
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header">
    <div class="page-title">
        <h1>Edit Booking <span style="color:var(--primary);">#RN-<%= rental.getRentalId() %></span></h1>
        <p>Update your return date or trip notes for this active booking</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/customer/bookings" class="btn btn-outline">&larr; Back to Bookings</a>
    </div>
</div>

<% if (errorMsg != null && !errorMsg.isEmpty()) { %>
<div class="alert alert-error" style="display:flex;align-items:center;gap:0.75rem;background:#fef2f2;border:1px solid #fecaca;color:#991b1b;padding:1rem 1.25rem;border-radius:var(--radius-sm);margin-bottom:1.5rem;">
    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <strong><%= errorMsg %></strong>
</div>
<% } %>

<div style="display:grid;grid-template-columns:1fr 380px;gap:1.5rem;align-items:start;">

    <!-- Edit Form -->
    <div class="card">
        <div class="card-header">
            <h2>Update Booking Details</h2>
            <span class="badge badge-active">Active Booking</span>
        </div>
        <div class="card-body">

            <!-- Current Booking Summary -->
            <div style="background:linear-gradient(135deg,#1e293b,#0f172a);border-radius:var(--radius-sm);padding:1.25rem 1.5rem;margin-bottom:1.75rem;color:#fff;">
                <div style="font-size:0.75rem;font-weight:700;text-transform:uppercase;letter-spacing:0.08em;color:#94a3b8;margin-bottom:0.75rem;">Current Booking Summary</div>
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:0.85rem;font-size:0.93rem;">
                    <div>
                        <div style="color:#94a3b8;font-size:0.78rem;margin-bottom:0.2rem;">Vehicle</div>
                        <div style="font-weight:700;"><%= rental.getCarModel() %></div>
                        <div style="font-size:0.8rem;color:#64748b;"><code style="background:rgba(255,255,255,0.1);padding:0.1rem 0.4rem;border-radius:3px;"><%= rental.getRegistrationNumber() %></code></div>
                    </div>
                    <div>
                        <div style="color:#94a3b8;font-size:0.78rem;margin-bottom:0.2rem;">Daily Rate</div>
                        <div style="font-weight:700;font-size:1.1rem;color:#38bdf8;">₹<%= String.format("%.2f", rental.getDailyRateApplied()) %><span style="font-size:0.8rem;color:#64748b;font-weight:400;">/day</span></div>
                    </div>
                    <div>
                        <div style="color:#94a3b8;font-size:0.78rem;margin-bottom:0.2rem;">Pickup Date</div>
                        <div style="font-weight:600;"><%= rental.getRentalDate() %></div>
                    </div>
                    <div>
                        <div style="color:#94a3b8;font-size:0.78rem;margin-bottom:0.2rem;">Current Return Date</div>
                        <div style="font-weight:600;color:#f97316;"><%= rental.getExpectedReturnDate() %></div>
                    </div>
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/customer/edit-booking" method="post" id="editBookingForm">
                <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">

                <div class="form-grid">
                    <!-- New Return Date -->
                    <div class="form-group col-span-2">
                        <label for="expectedReturnDate">New Return Date *</label>
                        <input type="date" id="expectedReturnDate" name="expectedReturnDate"
                               class="form-control"
                               value="<%= rental.getExpectedReturnDate() %>"
                               min="<%= minDate %>"
                               required>
                        <small style="color:var(--slate-600);margin-top:0.3rem;display:block;">
                            Must be after your pickup date (<%= rental.getRentalDate() %>). Costs will be recalculated automatically.
                        </small>
                    </div>

                    <!-- Notes -->
                    <div class="form-group col-span-2">
                        <label for="notes">Trip Notes (Optional)</label>
                        <textarea id="notes" name="notes" class="form-control"
                                  placeholder="e.g. Extended trip to Mysore..."><%= rental.getNotes() != null ? rental.getNotes() : "" %></textarea>
                    </div>
                </div>

                <!-- Live Recalculation -->
                <div class="price-calculation-card" style="margin-top:0.5rem;">
                    <h3 style="font-size:0.95rem;font-weight:700;color:var(--dark);margin-bottom:0.5rem;">
                        Updated Charge Preview
                    </h3>
                    <div class="price-row">
                        <span>Daily Rate:</span>
                        <span style="font-weight:600;">₹<%= String.format("%.2f", rental.getDailyRateApplied()) %></span>
                    </div>
                    <div class="price-row">
                        <span>New Duration:</span>
                        <span id="newDays" style="font-weight:600;">— Days</span>
                    </div>
                    <div class="price-row total-row">
                        <span>New Estimated Total:</span>
                        <span id="newTotal" style="color:var(--primary);">₹0.00</span>
                    </div>
                </div>

                <div class="form-actions" style="margin-top:1.5rem;">
                    <a href="<%= request.getContextPath() %>/customer/bookings" class="btn btn-outline">Discard Changes</a>
                    <button type="submit" class="btn btn-primary">
                        ✓ Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Info Panel -->
    <div style="display:flex;flex-direction:column;gap:1rem;">
        <div class="card" style="border-left:4px solid var(--warning);">
            <div class="card-body" style="padding:1.25rem;">
                <div style="display:flex;align-items:center;gap:0.5rem;margin-bottom:0.75rem;font-weight:700;color:#92400e;">
                    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                    Late Return Policy
                </div>
                <p style="font-size:0.88rem;color:var(--slate-700);margin:0;line-height:1.6;">
                    Returning the vehicle after your scheduled return date will incur a <strong>1.5× penalty</strong> per extra day. Please plan accordingly and update your return date in advance if needed.
                </p>
            </div>
        </div>

        <div class="card">
            <div class="card-body" style="padding:1.25rem;">
                <div style="font-weight:700;color:var(--dark);margin-bottom:0.75rem;">📋 Edit Restrictions</div>
                <ul style="font-size:0.87rem;color:var(--slate-600);line-height:1.8;margin:0;padding-left:1.2rem;">
                    <li>Only the <strong>return date</strong> and notes can be changed.</li>
                    <li>The <strong>vehicle</strong> and <strong>pickup date</strong> are fixed.</li>
                    <li>Cost is automatically recalculated based on days.</li>
                    <li>You can <strong>cancel</strong> this booking instead if needed.</li>
                </ul>
            </div>
        </div>

        <!-- Cancel Danger Zone -->
        <div class="card" style="border:1px solid #fecaca;">
            <div class="card-body" style="padding:1.25rem;">
                <div style="font-weight:700;color:#991b1b;margin-bottom:0.5rem;">⚠️ Cancel This Booking?</div>
                <p style="font-size:0.87rem;color:var(--slate-600);margin:0 0 1rem;">
                    This will permanently cancel booking <strong>#RN-<%= rental.getRentalId() %></strong> and mark the vehicle as available again.
                </p>
                <form action="<%= request.getContextPath() %>/customer/cancel-booking" method="post"
                      onsubmit="return confirm('Are you sure you want to cancel Booking #RN-<%= rental.getRentalId() %>? This cannot be undone.');">
                    <input type="hidden" name="rentalId" value="<%= rental.getRentalId() %>">
                    <button type="submit" class="btn" style="background:#fef2f2;color:#991b1b;border:1px solid #fecaca;width:100%;font-weight:600;">
                        Cancel This Booking
                    </button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
(function() {
    const returnDateInput = document.getElementById('expectedReturnDate');
    const pickupDate = new Date('<%= rental.getRentalDate() %>');
    const dailyRate = <%= rental.getDailyRateApplied() %>;

    function recalculate() {
        const returnDate = new Date(returnDateInput.value);
        if (!returnDateInput.value || isNaN(returnDate)) {
            document.getElementById('newDays').textContent = '— Days';
            document.getElementById('newTotal').textContent = '₹0.00';
            return;
        }
        const diffMs = returnDate - pickupDate;
        let days = Math.round(diffMs / (1000 * 60 * 60 * 24));
        if (days <= 0) days = 1;
        const total = days * dailyRate;
        document.getElementById('newDays').textContent = days + ' Day' + (days !== 1 ? 's' : '');
        document.getElementById('newTotal').textContent = '₹' + total.toFixed(2);
    }

    returnDateInput.addEventListener('change', recalculate);
    recalculate();
})();
</script>

<jsp:include page="/includes/footer.jsp" />
