<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Rental" %>
<%@ page import="com.carrental.model.Car" %>

<%
    request.setAttribute("pageTitle", "Operations Dashboard");
    
    // Fallback if accessed directly without servlet
    Integer totalCars = (Integer) request.getAttribute("totalCars");
    Integer availableCars = (Integer) request.getAttribute("availableCars");
    Integer totalCustomers = (Integer) request.getAttribute("totalCustomers");
    Integer activeRentals = (Integer) request.getAttribute("activeRentals");
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    List<Rental> activeRentalList = (List<Rental>) request.getAttribute("activeRentalList");
    List<Car> availableCarList = (List<Car>) request.getAttribute("availableCarList");

    if (totalCars == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }

    int rentedCount = totalCars - (availableCars != null ? availableCars : 0);
    double utilization = totalCars > 0 ? ((double) rentedCount / totalCars) * 100.0 : 0.0;
%>

<jsp:include page="/includes/header.jsp" />

<!-- Executive Operations Hero Banner -->
<div class="admin-hero">
    <div class="admin-hero-content">
        <div>
            <div style="display:inline-flex; align-items:center; gap:0.5rem; background:rgba(255,255,255,0.1); border:1px solid rgba(255,255,255,0.15); padding:0.25rem 0.75rem; border-radius:20px; font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:#93c5fd; margin-bottom:0.6rem;">
                <span style="width:7px; height:7px; border-radius:50%; background:#10b981; display:inline-block; box-shadow:0 0 6px #10b981;"></span>
                Enterprise Fleet Command
            </div>
            <h1 class="admin-hero-title">Fleet Operations Center</h1>
            <p class="admin-hero-subtitle">
                Live oversight of vehicle dispatch, active bookings, return processing, and revenue collection.
            </p>
        </div>
        <div class="admin-quick-actions">
            <a href="<%= request.getContextPath() %>/rentals?action=new" class="btn-hero-primary">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
                Create Booking
            </a>
            <a href="<%= request.getContextPath() %>/cars?action=new" class="btn-hero-outline">
                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="8" cy="10" r="2"/><path d="m21 16-5-5-5 5"/></svg>
                + Add Car
            </a>
            <a href="<%= request.getContextPath() %>/customers?action=new" class="btn-hero-outline">
                <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
                + Register Customer
            </a>
        </div>
    </div>
</div>

<!-- 5-Metric Executive KPI Cards -->
<div class="stats-grid-exec">
    <!-- Total Fleet -->
    <div class="stat-card-exec accent-blue">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Total Fleet</span>
            <span class="stat-badge-trend trend-neutral">Full Roster</span>
        </div>
        <div class="stat-value-exec"><%= totalCars %></div>
        <div class="stat-footer-exec">Vehicles in garage catalogue</div>
    </div>

    <!-- Available Now -->
    <div class="stat-card-exec accent-green">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Available Fleet</span>
            <span class="stat-badge-trend trend-positive">Ready to Rent</span>
        </div>
        <div class="stat-value-exec" style="color:#059669;"><%= availableCars %></div>
        <div class="stat-footer-exec">Cleaned, inspected &amp; ready</div>
    </div>

    <!-- Active on Road -->
    <div class="stat-card-exec accent-amber">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Active Rentals</span>
            <span class="stat-badge-trend trend-warning"><%= String.format("%.0f%%", utilization) %> Utilized</span>
        </div>
        <div class="stat-value-exec" style="color:#d97706;"><%= activeRentals %></div>
        <div class="stat-footer-exec">Vehicles currently on the road</div>
    </div>

    <!-- Customers -->
    <div class="stat-card-exec accent-cyan">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Customers</span>
            <span class="stat-badge-trend trend-neutral">Verified</span>
        </div>
        <div class="stat-value-exec"><%= totalCustomers %></div>
        <div class="stat-footer-exec">Registered driver accounts</div>
    </div>

    <!-- Total Invoiced Revenue -->
    <div class="stat-card-exec accent-purple">
        <div class="stat-header-flex">
            <span class="stat-title-exec">Total Revenue</span>
            <span class="stat-badge-trend trend-positive">Collected</span>
        </div>
        <div class="stat-value-exec" style="color:#4f46e5;">₹<%= String.format("%.0f", totalRevenue) %></div>
        <div class="stat-footer-exec">Gross rental &amp; fee billings</div>
    </div>
</div>

<!-- Active Rentals In-Progress Requiring Return -->
<div class="card" style="margin-bottom: 2rem;">
    <div class="card-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.75rem;">
        <div>
            <h2 style="font-size:1.15rem; font-weight:700; color:var(--dark); margin:0;">Active Rentals Requiring Check-In</h2>
            <p style="font-size:0.85rem; color:var(--slate-500); margin:0.15rem 0 0;">Vehicles currently on the road awaiting customer return</p>
        </div>
        <a href="<%= request.getContextPath() %>/rentals?filter=active" class="btn-action-ghost">
            View All Rentals
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
    <div class="card-body" style="padding:0;">
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th style="width:110px;">Booking ID</th>
                        <th>Vehicle Details</th>
                        <th>Customer / Driver</th>
                        <th>Rental Period</th>
                        <th>Duration</th>
                        <th>Estimated Total</th>
                        <th style="text-align:right;">Operations Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (activeRentalList != null && !activeRentalList.isEmpty()) { 
                        for (Rental r : activeRentalList) { %>
                        <tr>
                            <td>
                                <span style="font-weight:700; color:var(--dark);">#RN-<%= r.getRentalId() %></span>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <div class="vehicle-avatar">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                                        </svg>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.95rem;"><%= r.getCarModel() %></strong><br>
                                        <code style="font-size:0.78rem; background:var(--bg-light); padding:0.1rem 0.35rem; border-radius:3px; color:var(--slate-600);"><%= r.getRegistrationNumber() %></code>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.65rem;">
                                    <div class="customer-avatar">
                                        <%= r.getCustomerName() != null && r.getCustomerName().length() > 0 ? r.getCustomerName().substring(0, 1).toUpperCase() : "C" %>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.92rem;"><%= r.getCustomerName() %></strong><br>
                                        <small style="color:var(--slate-500);"><%= r.getCustomerPhone() %></small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="font-size:0.86rem;">
                                    <span style="color:var(--slate-500);">From:</span> <strong><%= r.getRentalDate() %></strong><br>
                                    <span style="color:var(--slate-500);">Due:</span> <strong style="color:var(--primary);"><%= r.getExpectedReturnDate() %></strong>
                                </div>
                            </td>
                            <td>
                                <span class="badge" style="background:#eff6ff; color:#1e40af; font-weight:600;"><%= r.getTotalDays() %> Days</span>
                            </td>
                            <td>
                                <strong style="font-size:1.05rem; color:var(--dark);">₹<%= String.format("%.2f", r.getTotalCost()) %></strong>
                            </td>
                            <td style="text-align:right;">
                                <a href="<%= request.getContextPath() %>/rentals?action=returnForm&id=<%= r.getRentalId() %>" 
                                   class="btn btn-sm btn-action-success" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.4rem 0.85rem; font-weight:600;">
                                    <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                                    Process Return
                                </a>
                            </td>
                        </tr>
                    <%  } 
                       } else { %>
                        <tr>
                            <td colspan="7" style="text-align:center; padding: 2.5rem; color: var(--slate-500);">
                                <svg width="36" height="36" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24" style="margin-bottom:0.5rem; opacity:0.4;">
                                    <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 14 14"/>
                                </svg>
                                <p style="margin:0; font-weight:500;">No vehicles currently out on rent. All fleet inventory is checked in.</p>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Available Fleet Ready for Immediate Dispatch -->
<div class="card">
    <div class="card-header" style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.75rem;">
        <div>
            <h2 style="font-size:1.15rem; font-weight:700; color:var(--dark); margin:0;">Available Fleet for Immediate Dispatch (<%= availableCars %> Vehicles)</h2>
            <p style="font-size:0.85rem; color:var(--slate-500); margin:0.15rem 0 0;">Pre-inspected vehicles ready to assign to walk-in or phone customers</p>
        </div>
        <a href="<%= request.getContextPath() %>/cars" class="btn-action-ghost">
            Manage Fleet Inventory
            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
        </a>
    </div>
    <div class="card-body" style="padding:0;">
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th>Vehicle Name &amp; Brand</th>
                        <th>Category</th>
                        <th>Registration Plate</th>
                        <th>Daily Rental Rate</th>
                        <th>Seating Capacity</th>
                        <th>Fuel Type</th>
                        <th style="text-align:right;">Fast Dispatch</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (availableCarList != null && !availableCarList.isEmpty()) { 
                        for (Car car : availableCarList) { %>
                        <tr>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <div class="vehicle-avatar" style="background:#ecfdf5; border-color:#a7f3d0; color:#059669;">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                                        </svg>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.95rem;"><%= car.getCarModel() %></strong><br>
                                        <small style="color:var(--slate-500);"><%= car.getBrand() %></small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge" style="background:var(--slate-100); color:var(--slate-800); font-weight:600;"><%= car.getCategory() %></span>
                            </td>
                            <td>
                                <code style="font-size:0.82rem; background:var(--bg-light); padding:0.15rem 0.45rem; border-radius:4px;"><%= car.getRegistrationNumber() %></code>
                            </td>
                            <td>
                                <strong style="font-size:1.02rem; color:var(--dark);">₹<%= String.format("%.2f", car.getDailyRate()) %></strong>
                                <span style="font-size:0.78rem; color:var(--slate-500);">/day</span>
                            </td>
                            <td>
                                <span style="font-size:0.88rem; color:var(--slate-700);"><%= car.getSeatingCapacity() %> Passengers</span>
                            </td>
                            <td>
                                <span style="font-size:0.88rem; color:var(--slate-700);"><%= car.getFuelType() %></span>
                            </td>
                            <td style="text-align:right;">
                                <a href="<%= request.getContextPath() %>/rentals?action=new&carId=<%= car.getCarId() %>" 
                                   class="btn btn-sm btn-primary" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.4rem 0.85rem;">
                                    <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
                                    Book Car
                                </a>
                            </td>
                        </tr>
                    <%  } 
                       } else { %>
                        <tr>
                            <td colspan="7" style="text-align:center; padding: 2.5rem; color: var(--slate-500);">
                                <em>All vehicles in the fleet are currently rented or in scheduled maintenance.</em>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
