<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Rental" %>
<%@ page import="com.carrental.model.User" %>

<%
    request.setAttribute("pageTitle", "My Bookings");
    User currentUser = (User) session.getAttribute("currentUser");
    List<Rental> myRentals = (List<Rental>) request.getAttribute("myRentals");
    Integer activeCount = (Integer) request.getAttribute("activeCount");
    Double totalSpent  = (Double)  request.getAttribute("totalSpent");

    String successMsg = request.getParameter("msg");
    String errorMsg   = request.getParameter("error");

    if (currentUser == null || myRentals == null) {
        response.sendRedirect(request.getContextPath() + "/customer/bookings");
        return;
    }

    long completedCount  = myRentals.stream().filter(r -> "COMPLETED".equalsIgnoreCase(r.getStatus())).count();
    long cancelledCount  = myRentals.stream().filter(r -> "CANCELLED".equalsIgnoreCase(r.getStatus())).count();
%>

<jsp:include page="/includes/header.jsp" />

<style>
/* ===== Bookings Page – Premium Overrides ===== */
.bookings-hero {
    background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
    border-radius: var(--radius-md);
    padding: 2rem 2.25rem;
    color: #fff;
    margin-bottom: 2rem;
    position: relative;
    overflow: hidden;
}
.bookings-hero::before {
    content: '';
    position: absolute;
    top: -60px; right: -60px;
    width: 220px; height: 220px;
    border-radius: 50%;
    background: rgba(99,102,241,0.15);
    pointer-events: none;
}
.booking-card {
    background: #fff;
    border-radius: var(--radius-md);
    border: 1px solid var(--border);
    margin-bottom: 1rem;
    overflow: hidden;
    transition: box-shadow 0.2s ease, transform 0.2s ease;
}
.booking-card:hover {
    box-shadow: 0 8px 24px rgba(0,0,0,0.09);
    transform: translateY(-2px);
}
.booking-card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1rem 1.5rem;
    border-bottom: 1px solid var(--border);
    flex-wrap: wrap;
    gap: 0.75rem;
}
.booking-card-body {
    display: grid;
    grid-template-columns: 2fr 1.5fr 1.5fr 1fr;
    gap: 0;
    padding: 0;
}
.booking-col {
    padding: 1.1rem 1.5rem;
    border-right: 1px solid var(--border);
}
.booking-col:last-child { border-right: none; }
.booking-col-label {
    font-size: 0.72rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.07em;
    color: var(--slate-500);
    margin-bottom: 0.35rem;
}
.booking-card-footer {
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 0.5rem;
    padding: 0.75rem 1.5rem;
    background: var(--bg-light);
    border-top: 1px solid var(--border);
}
.badge-cancelled {
    background: #f1f5f9;
    color: #64748b;
}
.stat-mini {
    background: rgba(255,255,255,0.07);
    border-radius: var(--radius-sm);
    padding: 1rem 1.25rem;
    min-width: 130px;
}
.alert-banner {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 1rem 1.25rem;
    border-radius: var(--radius-sm);
    margin-bottom: 1.5rem;
    font-weight: 500;
}
.alert-success { background:#f0fdf4; border:1px solid #bbf7d0; color:#166534; }
.alert-error   { background:#fef2f2; border:1px solid #fecaca; color:#991b1b; }
.empty-state {
    text-align: center;
    padding: 4rem 2rem;
    color: var(--slate-600);
}
.empty-state svg { margin-bottom: 1rem; opacity: 0.3; }
@media (max-width: 900px) {
    .booking-card-body { grid-template-columns: 1fr 1fr; }
    .booking-col { border-right: none; border-bottom: 1px solid var(--border); }
    .booking-col:last-child { border-bottom: none; }
}
@media (max-width: 600px) {
    .booking-card-body { grid-template-columns: 1fr; }
}
</style>

<!-- Hero Banner -->
<div class="bookings-hero">
    <div style="display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:1rem;position:relative;z-index:1;">
        <div>
            <span class="badge" style="background:rgba(255,255,255,0.12);color:#cbd5e1;margin-bottom:0.5rem;">My Account</span>
            <h1 style="font-size:1.7rem;font-weight:800;margin:0.25rem 0;">My Bookings &amp; Invoices</h1>
            <p style="color:#94a3b8;font-size:0.93rem;margin:0;">Track, manage and modify all your rental reservations</p>
        </div>
        <a href="<%= request.getContextPath() %>/customer/book" class="btn btn-primary" style="white-space:nowrap;">
            + New Booking
        </a>
    </div>

    <!-- Mini KPI Strip -->
    <div style="display:flex;gap:0.75rem;margin-top:1.5rem;flex-wrap:wrap;position:relative;z-index:1;">
        <div class="stat-mini">
            <div style="font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:#94a3b8;margin-bottom:0.2rem;">Active</div>
            <div style="font-size:1.5rem;font-weight:800;color:#38bdf8;"><%= activeCount != null ? activeCount : 0 %></div>
        </div>
        <div class="stat-mini">
            <div style="font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:#94a3b8;margin-bottom:0.2rem;">Completed</div>
            <div style="font-size:1.5rem;font-weight:800;color:#34d399;"><%= completedCount %></div>
        </div>
        <div class="stat-mini">
            <div style="font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:#94a3b8;margin-bottom:0.2rem;">Cancelled</div>
            <div style="font-size:1.5rem;font-weight:800;color:#94a3b8;"><%= cancelledCount %></div>
        </div>
        <div class="stat-mini">
            <div style="font-size:0.72rem;font-weight:700;text-transform:uppercase;letter-spacing:0.07em;color:#94a3b8;margin-bottom:0.2rem;">Total Spent</div>
            <div style="font-size:1.5rem;font-weight:800;color:#f472b6;">₹<%= String.format("%.0f", totalSpent != null ? totalSpent : 0.0) %></div>
        </div>
    </div>
</div>

<!-- Alerts -->
<% if (successMsg != null && !successMsg.isEmpty()) { %>
<div class="alert-banner alert-success">
    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
    <%= successMsg %>
</div>
<% } %>
<% if (errorMsg != null && !errorMsg.isEmpty()) { %>
<div class="alert-banner alert-error">
    <svg width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= errorMsg %>
</div>
<% } %>

<!-- Search / Filter Bar -->
<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.25rem;flex-wrap:wrap;gap:0.75rem;">
    <h2 style="font-size:1.05rem;font-weight:700;color:var(--dark);">All Reservations (<%= myRentals.size() %>)</h2>
    <input type="text" id="searchInput" class="search-input" style="max-width:280px;" placeholder="🔍 Search bookings...">
</div>

<!-- Booking Cards List -->
<div id="bookingsList">
<% if (!myRentals.isEmpty()) {
    for (Rental r : myRentals) {
        boolean isActive    = r.isActive();
        boolean isCompleted = "COMPLETED".equalsIgnoreCase(r.getStatus());
        boolean isCancelled = "CANCELLED".equalsIgnoreCase(r.getStatus());
        String badgeClass   = isActive ? "badge-active" : (isCompleted ? "badge-completed" : "badge-cancelled");
%>
<div class="booking-card" data-search="<%= r.getCarModel().toLowerCase() %> rn-<%= r.getRentalId() %> <%= r.getStatus().toLowerCase() %> <%= r.getRegistrationNumber().toLowerCase() %>">
    <!-- Card Header -->
    <div class="booking-card-header">
        <div style="display:flex;align-items:center;gap:1rem;">
            <div style="background:var(--bg-light);border:1px solid var(--border);border-radius:8px;width:44px;height:44px;display:flex;align-items:center;justify-content:center;">
                <svg width="22" height="22" fill="none" stroke="<%= isActive ? "#6366f1" : (isCompleted ? "#10b981" : "#94a3b8") %>" stroke-width="2" viewBox="0 0 24 24">
                    <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                </svg>
            </div>
            <div>
                <div style="font-weight:800;font-size:1rem;color:var(--dark);"><%= r.getCarModel() %></div>
                <code style="font-size:0.78rem;color:var(--slate-600);background:var(--bg-light);padding:0.1rem 0.4rem;border-radius:3px;"><%= r.getRegistrationNumber() %></code>
            </div>
        </div>
        <div style="display:flex;align-items:center;gap:0.75rem;">
            <span style="font-size:0.78rem;color:var(--slate-500);">Booking ID:</span>
            <span style="font-weight:700;color:var(--dark);">#RN-<%= r.getRentalId() %></span>
            <span class="badge <%= badgeClass %>"><%= r.getStatus() %></span>
        </div>
    </div>

    <!-- Card Body: 4-column detail grid -->
    <div class="booking-card-body">
        <!-- Rental Period -->
        <div class="booking-col">
            <div class="booking-col-label">Rental Period</div>
            <div style="font-size:0.88rem;margin-bottom:0.3rem;">
                <span style="color:var(--slate-500);">Pickup:</span>
                <strong style="margin-left:0.3rem;"><%= r.getRentalDate() %></strong>
            </div>
            <div style="font-size:0.88rem;margin-bottom:0.3rem;">
                <span style="color:var(--slate-500);">Return:</span>
                <strong style="margin-left:0.3rem;color:<%= isActive ? "var(--primary)" : "var(--dark)" %>;">
                    <%= r.getExpectedReturnDate() %>
                </strong>
            </div>
            <% if (r.getActualReturnDate() != null) { %>
            <div style="font-size:0.88rem;">
                <span style="color:var(--success);">Returned:</span>
                <strong style="margin-left:0.3rem;color:var(--success);"><%= r.getActualReturnDate() %></strong>
            </div>
            <% } %>
        </div>

        <!-- Duration -->
        <div class="booking-col">
            <div class="booking-col-label">Duration &amp; Rate</div>
            <div style="font-size:1.3rem;font-weight:800;color:var(--dark);"><%= r.getTotalDays() %> <span style="font-size:0.9rem;font-weight:500;color:var(--slate-500);">days</span></div>
            <div style="font-size:0.85rem;color:var(--slate-600);margin-top:0.25rem;">@ ₹<%= String.format("%.2f", r.getDailyRateApplied()) %>/day</div>
        </div>

        <!-- Cost Breakdown -->
        <div class="booking-col">
            <div class="booking-col-label">Cost Breakdown</div>
            <div style="font-size:0.85rem;color:var(--slate-600);">Base: <strong style="color:var(--dark);">₹<%= String.format("%.2f", r.getBaseCost()) %></strong></div>
            <% if (r.getLateFee() > 0) { %>
            <div style="font-size:0.85rem;color:#ef4444;margin-top:0.2rem;">Late Fee: <strong>+₹<%= String.format("%.2f", r.getLateFee()) %></strong></div>
            <% } else { %>
            <div style="font-size:0.85rem;color:var(--slate-400);margin-top:0.2rem;">Late Fee: ₹0.00</div>
            <% } %>
        </div>

        <!-- Total -->
        <div class="booking-col" style="display:flex;flex-direction:column;justify-content:center;">
            <div class="booking-col-label">Total Invoiced</div>
            <div style="font-size:1.5rem;font-weight:800;color:<%= isActive ? "var(--primary)" : "var(--dark)" %>;">
                ₹<%= String.format("%.2f", r.getTotalCost()) %>
            </div>
        </div>
    </div>

    <!-- Card Footer: Actions -->
    <div class="booking-card-footer">
        <% if (isActive) { %>
            <a href="<%= request.getContextPath() %>/customer/edit-booking?rentalId=<%= r.getRentalId() %>"
               class="btn btn-outline btn-sm" style="display:inline-flex;align-items:center;gap:0.4rem;">
                <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/>
                </svg>
                Edit Booking
            </a>
            <form action="<%= request.getContextPath() %>/customer/cancel-booking" method="post" style="display:inline;"
                  onsubmit="return confirm('Cancel booking #RN-<%= r.getRentalId() %>? This cannot be undone.');">
                <input type="hidden" name="rentalId" value="<%= r.getRentalId() %>">
                <button type="submit" class="btn btn-sm" style="background:#fef2f2;color:#991b1b;border:1px solid #fecaca;display:inline-flex;align-items:center;gap:0.4rem;">
                    <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/>
                    </svg>
                    Cancel
                </button>
            </form>
        <% } else if (isCompleted) { %>
            <span style="font-size:0.82rem;color:var(--success);font-weight:600;">
                ✓ Trip Completed
            </span>
        <% } else if (isCancelled) { %>
            <span style="font-size:0.82rem;color:var(--slate-400);font-weight:500;">
                Booking Cancelled
            </span>
        <% } %>
    </div>
</div>
<%  }
   } else { %>
<div class="booking-card empty-state">
    <svg width="64" height="64" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24">
        <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
    </svg>
    <h3 style="font-size:1.1rem;font-weight:700;color:var(--dark);margin-bottom:0.5rem;">No bookings yet</h3>
    <p style="margin-bottom:1.5rem;">You haven't booked any cars yet. Explore our fleet and hit the road!</p>
    <a href="<%= request.getContextPath() %>/customer/dashboard" class="btn btn-primary">Browse Available Fleet &rarr;</a>
</div>
<% } %>
</div>

<script>
(function() {
    const input = document.getElementById('searchInput');
    if (!input) return;
    input.addEventListener('input', function() {
        const q = this.value.toLowerCase().trim();
        document.querySelectorAll('.booking-card[data-search]').forEach(function(card) {
            const matches = !q || card.dataset.search.includes(q);
            card.style.display = matches ? '' : 'none';
        });
    });
})();
</script>

<jsp:include page="/includes/footer.jsp" />
