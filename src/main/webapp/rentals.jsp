<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Rental" %>

<%
    request.setAttribute("pageTitle", "Bookings & Returns");
    List<Rental> rentalList = (List<Rental>) request.getAttribute("rentalList");
    String currentFilter = (String) request.getAttribute("currentFilter");
    if (currentFilter == null) currentFilter = "all";

    if (rentalList == null) {
        response.sendRedirect(request.getContextPath() + "/rentals");
        return;
    }

    long activeCount = rentalList.stream().filter(r -> r.isActive()).count();
    long completedCount = rentalList.stream().filter(r -> "COMPLETED".equalsIgnoreCase(r.getStatus())).count();
    long cancelledCount = rentalList.stream().filter(r -> "CANCELLED".equalsIgnoreCase(r.getStatus())).count();
    double totalBilled = rentalList.stream().mapToDouble(r -> r.getTotalCost()).sum();
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header" style="margin-bottom: 1.5rem;">
    <div class="page-title">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--slate-500); margin-bottom:0.25rem;">Dispatch &amp; Billing Ledger</div>
        <h1 style="font-size:1.85rem; font-weight:800; letter-spacing:-0.03em; color:var(--dark); margin:0;">Bookings &amp; Return Processing</h1>
        <p style="color:var(--slate-600); font-size:0.93rem; margin-top:0.25rem;">Track vehicle reservations, calculate check-in penalties, and record invoices</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/rentals?action=new" class="btn btn-primary" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.6rem 1.2rem; font-weight:600;">
            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
            + Create New Booking
        </a>
    </div>
</div>

<!-- KPI Mini Strip -->
<div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:1rem; margin-bottom:1.5rem;">
    <div style="background:#ffffff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem;">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:var(--slate-500); margin-bottom:0.25rem;">Total Bookings</div>
        <div style="font-size:1.5rem; font-weight:800; color:var(--dark);"><%= rentalList.size() %></div>
    </div>
    <div style="background:#ffffff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem;">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:var(--slate-500); margin-bottom:0.25rem;">Active on Road</div>
        <div style="font-size:1.5rem; font-weight:800; color:#d97706;"><%= activeCount %></div>
    </div>
    <div style="background:#ffffff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem;">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:var(--slate-500); margin-bottom:0.25rem;">Completed Trips</div>
        <div style="font-size:1.5rem; font-weight:800; color:#059669;"><%= completedCount %></div>
    </div>
    <div style="background:#ffffff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem;">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:var(--slate-500); margin-bottom:0.25rem;">Cancelled</div>
        <div style="font-size:1.5rem; font-weight:800; color:#64748b;"><%= cancelledCount %></div>
    </div>
    <div style="background:#ffffff; border:1px solid var(--border); border-radius:var(--radius-sm); padding:1rem 1.25rem;">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.06em; color:var(--slate-500); margin-bottom:0.25rem;">Total Ledger Value</div>
        <div style="font-size:1.5rem; font-weight:800; color:#4f46e5;">₹<%= String.format("%.0f", totalBilled) %></div>
    </div>
</div>

<div class="card">
    <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; width:100%;">
            <!-- Status Filter Pills -->
            <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                <button type="button" class="btn-filter-tab active" data-filter="all">
                    All Reservations (<%= rentalList.size() %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="ACTIVE">
                    Active (<%= activeCount %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="COMPLETED">
                    Completed (<%= completedCount %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="CANCELLED">
                    Cancelled (<%= cancelledCount %>)
                </button>
            </div>

            <!-- Search Filter -->
            <div style="position:relative; min-width:280px; max-width:360px; width:100%;">
                <input type="text" id="rentalSearchInput" class="form-control" 
                       style="padding-left:2.4rem; border-radius:8px; font-size:0.9rem;" 
                       placeholder="Search customer, vehicle, booking ID...">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" 
                     style="position:absolute; left:0.85rem; top:50%; transform:translateY(-50%); color:var(--slate-400); pointer-events:none;">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
            </div>
        </div>
    </div>

    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="data-table" id="rentalsTable">
                <thead>
                    <tr>
                        <th style="width:90px;">Booking</th>
                        <th>Vehicle Details</th>
                        <th>Customer / Driver</th>
                        <th>Rental Period</th>
                        <th>Duration</th>
                        <th>Base Cost</th>
                        <th>Late Fee</th>
                        <th>Total Invoiced</th>
                        <th>Status</th>
                        <th style="text-align: right;">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!rentalList.isEmpty()) { 
                        for (Rental r : rentalList) { 
                            boolean isActive = r.isActive();
                            boolean isCompleted = "COMPLETED".equalsIgnoreCase(r.getStatus());
                            boolean isCancelled = "CANCELLED".equalsIgnoreCase(r.getStatus());
                            String statusStr = r.getStatus() != null ? r.getStatus().toUpperCase() : "ACTIVE";
                            String badgeClass = isActive ? "badge-active" : (isCompleted ? "badge-completed" : "badge-cancelled");
                    %>
                        <tr class="rental-row" data-status="<%= statusStr %>" data-search="<%= r.getCarModel().toLowerCase() %> <%= r.getRegistrationNumber().toLowerCase() %> <%= r.getCustomerName().toLowerCase() %> rn-<%= r.getRentalId() %> <%= statusStr.toLowerCase() %>">
                            <td>
                                <strong style="color:var(--dark); font-size:0.9rem;">#RN-<%= r.getRentalId() %></strong>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <div class="vehicle-avatar" style="<%= isActive ? "background:#eff6ff; color:#2563eb;" : (isCompleted ? "background:#ecfdf5; color:#059669;" : "background:#f1f5f9; color:#64748b;") %>">
                                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                                        </svg>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.92rem;"><%= r.getCarModel() %></strong><br>
                                        <code style="font-size:0.78rem; background:var(--bg-light); padding:0.1rem 0.35rem; border-radius:3px; color:var(--slate-600);"><%= r.getRegistrationNumber() %></code>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.6rem;">
                                    <div class="customer-avatar">
                                        <%= r.getCustomerName() != null && r.getCustomerName().length() > 0 ? r.getCustomerName().substring(0, 1).toUpperCase() : "C" %>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.9rem;"><%= r.getCustomerName() %></strong><br>
                                        <small style="color:var(--slate-500);"><%= r.getCustomerPhone() %></small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div style="font-size:0.86rem;">
                                    <span style="color:var(--slate-500);">From:</span> <%= r.getRentalDate() %><br>
                                    <span style="color:var(--slate-500);">Due:</span> <strong style="color:<%= isActive ? "var(--primary)" : "var(--dark)" %>;"><%= r.getExpectedReturnDate() %></strong>
                                    <% if (r.getActualReturnDate() != null) { %>
                                        <br><span style="color:var(--success);">Returned:</span> <%= r.getActualReturnDate() %>
                                    <% } %>
                                </div>
                            </td>
                            <td>
                                <span class="badge" style="background:#f1f5f9; color:var(--slate-700); font-weight:600;"><%= r.getTotalDays() %> Days</span>
                            </td>
                            <td>
                                <span style="font-size:0.88rem; color:var(--slate-700);">₹<%= String.format("%.2f", r.getBaseCost()) %></span>
                            </td>
                            <td>
                                <% if (r.getLateFee() > 0) { %>
                                    <span style="color:#ef4444; font-weight:700; font-size:0.88rem;">+₹<%= String.format("%.2f", r.getLateFee()) %></span>
                                <% } else { %>
                                    <span style="color:var(--slate-400); font-size:0.85rem;">₹0.00</span>
                                <% } %>
                            </td>
                            <td>
                                <strong style="font-size:1.02rem; color:var(--dark);">
                                    ₹<%= String.format("%.2f", r.getTotalCost()) %>
                                </strong>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>" style="display:inline-flex; align-items:center; gap:0.35rem; padding:0.25rem 0.6rem;">
                                    <span style="width:6px; height:6px; border-radius:50%; background:currentColor; display:inline-block;"></span>
                                    <%= statusStr %>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <% if (isActive) { %>
                                    <a href="<%= request.getContextPath() %>/rentals?action=returnForm&id=<%= r.getRentalId() %>" 
                                       class="btn-action-ghost btn-action-success" style="font-weight:600;">
                                        <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                                        Return Car
                                    </a>
                                <% } else if (isCompleted) { %>
                                    <span style="color:#059669; font-size:0.84rem; font-weight:600; display:inline-flex; align-items:center; gap:0.25rem;">
                                        <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.5" viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                                        Settled
                                    </span>
                                <% } else if (isCancelled) { %>
                                    <span style="color:var(--slate-400); font-size:0.84rem; font-weight:500;">
                                        Cancelled
                                    </span>
                                <% } %>
                            </td>
                        </tr>
                    <%  } 
                       } else { %>
                        <tr>
                            <td colspan="10" style="text-align:center; padding: 3rem; color: var(--slate-500);">
                                No bookings found matching the selected criteria.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
.btn-filter-tab {
    background: transparent;
    border: 1px solid var(--border);
    color: var(--slate-600);
    padding: 0.45rem 0.85rem;
    border-radius: 7px;
    font-size: 0.84rem;
    font-weight: 600;
    cursor: pointer;
    transition: var(--transition);
}
.btn-filter-tab:hover {
    background: var(--bg-light);
    color: var(--dark);
}
.btn-filter-tab.active {
    background: var(--dark);
    color: #ffffff;
    border-color: var(--dark);
}
</style>

<script>
(function() {
    let currentFilter = 'all';
    const filterTabs = document.querySelectorAll('.btn-filter-tab');
    const searchInput = document.getElementById('rentalSearchInput');
    const rows = document.querySelectorAll('.rental-row');

    function applyFilters() {
        const query = (searchInput.value || '').toLowerCase().trim();
        rows.forEach(function(row) {
            const rowStatus = row.dataset.status || '';
            const rowSearch = row.dataset.search || '';
            const statusMatches = (currentFilter === 'all') || (rowStatus === currentFilter);
            const queryMatches = !query || rowSearch.includes(query);
            row.style.display = (statusMatches && queryMatches) ? '' : 'none';
        });
    }

    filterTabs.forEach(function(tab) {
        tab.addEventListener('click', function() {
            filterTabs.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
            currentFilter = this.dataset.filter;
            applyFilters();
        });
    });

    if (searchInput) {
        searchInput.addEventListener('input', applyFilters);
    }
})();
</script>

<jsp:include page="/includes/footer.jsp" />
