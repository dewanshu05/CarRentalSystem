<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Car" %>
<%@ page import="com.carrental.model.Rental" %>
<%@ page import="com.carrental.model.User" %>

<%
    request.setAttribute("pageTitle", "Fleet Catalog");
    User currentUser = (User) session.getAttribute("currentUser");

    List<Car> availableCars = (List<Car>) request.getAttribute("availableCars");
    List<Rental> myRentals = (List<Rental>) request.getAttribute("myRentals");
    Integer activeCount = (Integer) request.getAttribute("activeCount");
    Double totalSpent = (Double) request.getAttribute("totalSpent");
    String successMsg = request.getParameter("msg");
    String errorMsg = request.getParameter("error");

    if (currentUser == null || availableCars == null) {
        response.sendRedirect(request.getContextPath() + "/customer/dashboard");
        return;
    }
%>

<jsp:include page="/includes/header.jsp" />

<% if (successMsg != null && !successMsg.isEmpty()) { %>
<div class="alert alert-success" style="display:flex;align-items:center;gap:0.75rem;background:#f0fdf4;border:1px solid #bbf7d0;color:#166534;padding:1rem 1.25rem;border-radius:var(--radius-sm);margin-bottom:1.5rem;font-weight:500;">
    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
    <%= successMsg %>
</div>
<% } %>
<% if (errorMsg != null && !errorMsg.isEmpty()) { %>
<div class="alert alert-error" style="display:flex;align-items:center;gap:0.75rem;background:#fef2f2;border:1px solid #fecaca;color:#991b1b;padding:1rem 1.25rem;border-radius:var(--radius-sm);margin-bottom:1.5rem;font-weight:500;">
    <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
    <%= errorMsg %>
</div>
<% } %>

<!-- Premium Customer Hero Banner -->
<div class="admin-hero">
    <div class="admin-hero-content">
        <div>
            <div style="display:inline-flex; align-items:center; gap:0.5rem; background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.15); padding:0.25rem 0.75rem; border-radius:20px; font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:#7dd3fc; margin-bottom:0.6rem;">
                <span style="width:7px; height:7px; border-radius:50%; background:#38bdf8; display:inline-block; box-shadow:0 0 6px #38bdf8;"></span>
                Verified Member Portal
            </div>
            <h1 class="admin-hero-title">Welcome, <%= currentUser.getFullName() %>!</h1>
            <p class="admin-hero-subtitle">
                Explore our premium fleet of sanitized, insured, and GPS-tracked rental vehicles. Book instantly with transparent pricing.
            </p>
        </div>
        <div class="admin-quick-actions">
            <a href="<%= request.getContextPath() %>/customer/book" class="btn-hero-primary">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
                Book a Vehicle Now
            </a>
            <a href="<%= request.getContextPath() %>/customer/bookings" class="btn-hero-outline">
                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/></svg>
                My Bookings &amp; Invoices
            </a>
        </div>
    </div>
</div>

<!-- Customer KPI Executive Stats Grid -->
<div class="stats-grid-exec" style="margin-bottom: 2rem;">
    <!-- Active Rentals -->
    <div class="stat-card-exec accent-amber">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Active Reservations</span>
            <span class="stat-badge-trend trend-warning"><%= (activeCount != null && activeCount > 0) ? "On Road" : "None" %></span>
        </div>
        <div class="stat-value-exec" style="color:#d97706;"><%= activeCount != null ? activeCount : 0 %></div>
        <div class="stat-footer-exec">Vehicles currently in your possession</div>
    </div>

    <!-- Total Bookings -->
    <div class="stat-card-exec accent-blue">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Lifetime Trips</span>
            <span class="stat-badge-trend trend-neutral">History</span>
        </div>
        <div class="stat-value-exec"><%= myRentals != null ? myRentals.size() : 0 %></div>
        <div class="stat-footer-exec">Total completed &amp; active bookings</div>
    </div>

    <!-- Total Spent -->
    <div class="stat-card-exec accent-green">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Total Invoiced</span>
            <span class="stat-badge-trend trend-positive">Verified</span>
        </div>
        <div class="stat-value-exec" style="color:#059669;">₹<%= String.format("%.0f", totalSpent != null ? totalSpent : 0.0) %></div>
        <div class="stat-footer-exec">Combined rental charges &amp; fees</div>
    </div>
</div>

<!-- Active Bookings Alert Banner with Direct Action Options -->
<% if (activeCount != null && activeCount > 0) { %>
    <div class="card" style="border-left: 4px solid var(--warning); margin-bottom: 2.25rem; box-shadow: 0 4px 14px rgba(245, 158, 11, 0.1);">
        <div class="card-header" style="background: #fffbeb; padding:1.1rem 1.5rem;">
            <div style="display:flex; align-items:center; gap:0.6rem;">
                <span style="width:10px; height:10px; border-radius:50%; background:#d97706; display:inline-block; box-shadow:0 0 8px #d97706;"></span>
                <h2 style="color: #92400e; margin:0; font-size:1.15rem; font-weight:700;">You Currently Have an Active Vehicle Rental</h2>
            </div>
            <a href="<%= request.getContextPath() %>/customer/bookings" class="btn-action-ghost" style="color:#92400e; border-color:#fde68a;">
                View All Bookings &rarr;
            </a>
        </div>
        <div class="card-body" style="padding: 1.25rem 1.5rem;">
            <% for (Rental r : myRentals) { 
                if (r.isActive()) { %>
                <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1.25rem; padding: 1rem 0; border-bottom: 1px solid var(--border);">
                    <div style="display:flex; align-items:center; gap:1rem;">
                        <div class="vehicle-avatar" style="width:48px; height:48px; background:#eff6ff; color:#2563eb; border-color:#bfdbfe;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                            </svg>
                        </div>
                        <div>
                            <div style="font-weight: 800; font-size: 1.1rem; color: var(--dark);">
                                <%= r.getCarModel() %> 
                                <code style="font-size:0.82rem; background:var(--bg-light); border:1px solid var(--border); padding:0.15rem 0.45rem; border-radius:4px; margin-left:0.35rem;"><%= r.getRegistrationNumber() %></code>
                            </div>
                            <div style="color: var(--slate-600); font-size:0.88rem; margin-top: 0.25rem;">
                                Pickup: <strong><%= r.getRentalDate() %></strong> &bull; Scheduled Return: <strong style="color:var(--danger); font-size:0.95rem;"><%= r.getExpectedReturnDate() %></strong>
                            </div>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 0.65rem; flex-wrap: wrap;">
                        <span class="badge badge-active" style="padding: 0.45rem 0.85rem; font-weight:600;">
                            Active on Road
                        </span>
                        <a href="<%= request.getContextPath() %>/customer/edit-booking?rentalId=<%= r.getRentalId() %>" 
                           class="btn-action-ghost" style="padding:0.45rem 0.85rem; font-weight:600;">
                            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                            Edit Return Date
                        </a>
                        <form action="<%= request.getContextPath() %>/customer/cancel-booking" method="post" style="display:inline;margin:0;"
                              onsubmit="return confirm('Cancel booking #RN-<%= r.getRentalId() %>? The vehicle will be made available again.');">
                            <input type="hidden" name="rentalId" value="<%= r.getRentalId() %>">
                            <button type="submit" class="btn-action-ghost btn-action-danger" style="padding:0.45rem 0.85rem; font-weight:600;">
                                <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                Cancel Booking
                            </button>
                        </form>
                    </div>
                </div>
            <%  } 
               } %>
        </div>
    </div>
<% } %>

<!-- Available Vehicles Catalog for Customer -->
<div class="page-header" style="margin-bottom: 1.5rem;">
    <div class="page-title">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--slate-500); margin-bottom:0.25rem;">Available Fleet</div>
        <h2 style="font-size:1.65rem; font-weight:800; letter-spacing:-0.02em; color:var(--dark); margin:0;">
            Browse Available Vehicles (<span id="fleetVisibleCount"><%= availableCars.size() %></span>)
        </h2>
        <p style="color:var(--slate-600); font-size:0.93rem; margin-top:0.25rem;">Select your vehicle, customize your duration, and reserve immediately</p>
    </div>
    <div class="header-actions">
        <!-- Live Search Box -->
        <div style="position:relative; min-width:280px; width:100%;">
            <input type="text" id="customerFleetSearch" class="form-control" 
                   style="padding-left:2.4rem; border-radius:8px; font-size:0.9rem;" 
                   placeholder="Search vehicle model, brand, category...">
            <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" 
                 style="position:absolute; left:0.85rem; top:50%; transform:translateY(-50%); color:var(--slate-400); pointer-events:none;">
                <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
        </div>
    </div>
</div>

<!-- Fleet Grid -->
<div id="fleetCardsContainer" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; margin-bottom: 3rem;">
    <% if (!availableCars.isEmpty()) { 
        for (Car car : availableCars) { %>
        <div class="card car-catalog-card" data-search="<%= car.getBrand().toLowerCase() %> <%= car.getCarModel().toLowerCase() %> <%= car.getCategory().toLowerCase() %> <%= car.getFuelType().toLowerCase() %>" 
             style="display:flex; flex-direction:column; justify-content:space-between; border-radius:var(--radius-md); overflow:hidden; transition:box-shadow 0.2s ease, transform 0.2s ease; border:1px solid var(--border);">
            
            <div class="card-body" style="padding:1.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem;">
                    <div>
                        <span class="badge" style="background:#eff6ff; color:#2563eb; font-weight:700; font-size:0.75rem; text-transform:uppercase; letter-spacing:0.04em;">
                            <%= car.getCategory() %>
                        </span>
                        <h3 style="font-size: 1.35rem; font-weight: 800; color: var(--dark); margin-top: 0.4rem; letter-spacing:-0.02em;">
                            <%= car.getBrand() %> <%= car.getCarModel() %>
                        </h3>
                    </div>
                    <span class="badge badge-available" style="padding:0.3rem 0.65rem; font-size:0.75rem; font-weight:700;">
                        Ready
                    </span>
                </div>

                <div style="background: var(--bg-light); border:1px solid var(--border); border-radius: var(--radius-sm); padding: 0.85rem 1rem; margin: 1.1rem 0; font-size: 0.88rem; display: grid; grid-template-columns: 1fr 1fr; gap: 0.65rem;">
                    <div><span style="color:var(--slate-500);">Reg No:</span> <code style="font-size:0.8rem;"><%= car.getRegistrationNumber() %></code></div>
                    <div><span style="color:var(--slate-500);">Capacity:</span> <strong><%= car.getSeatingCapacity() %></strong> Seater</div>
                    <div><span style="color:var(--slate-500);">Fuel:</span> <strong><%= car.getFuelType() %></strong></div>
                    <div><span style="color:var(--slate-500);">Status:</span> <span style="color:#059669; font-weight:600;">✓ Inspected</span></div>
                </div>

                <div style="display: flex; justify-content: space-between; align-items: baseline; margin-top: 1.25rem; padding-top: 1rem; border-top: 1px solid var(--border);">
                    <div>
                        <span style="font-size: 1.6rem; font-weight: 800; color: var(--dark);">₹<%= String.format("%.2f", car.getDailyRate()) %></span>
                        <span style="color: var(--slate-500); font-size:0.85rem;">/ day</span>
                    </div>
                    <a href="<%= request.getContextPath() %>/customer/book?carId=<%= car.getCarId() %>" class="btn btn-primary" style="padding: 0.55rem 1.15rem; font-weight:600; display:inline-flex; align-items:center; gap:0.4rem;">
                        Reserve &rarr;
                    </a>
                </div>
            </div>
        </div>
    <%  } 
       } else { %>
        <div style="grid-column: 1 / -1; background: #fff; padding: 4rem 2rem; text-align: center; border-radius: var(--radius-md); border: 1px dashed var(--slate-400);">
            <svg width="48" height="48" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" style="margin-bottom:1rem; opacity:0.3;">
                <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
            </svg>
            <h3 style="font-weight:700; color:var(--dark); margin-bottom:0.4rem;">All Vehicles Currently Reserved</h3>
            <p style="color: var(--slate-600); font-size: 0.95rem; margin:0;">Our fleet is fully booked right now. Please check back soon as returns are processed daily.</p>
        </div>
    <% } %>
</div>

<script>
(function() {
    const searchInput = document.getElementById('customerFleetSearch');
    const cards = document.querySelectorAll('.car-catalog-card');
    const countDisplay = document.getElementById('fleetVisibleCount');

    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const query = (this.value || '').toLowerCase().trim();
            let count = 0;
            cards.forEach(function(card) {
                const searchData = card.dataset.search || '';
                const matches = !query || searchData.includes(query);
                card.style.display = matches ? '' : 'none';
                if (matches) count++;
            });
            if (countDisplay) countDisplay.textContent = count;
        });
    }
})();
</script>

<jsp:include page="/includes/footer.jsp" />
