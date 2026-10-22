<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Car" %>

<%
    request.setAttribute("pageTitle", "Fleet Inventory");
    List<Car> carList = (List<Car>) request.getAttribute("carList");

    if (carList == null) {
        response.sendRedirect(request.getContextPath() + "/cars");
        return;
    }

    long availableCount = carList.stream().filter(c -> "AVAILABLE".equalsIgnoreCase(c.getStatus())).count();
    long rentedCount = carList.stream().filter(c -> "RENTED".equalsIgnoreCase(c.getStatus())).count();
    long maintenanceCount = carList.stream().filter(c -> "MAINTENANCE".equalsIgnoreCase(c.getStatus())).count();
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header" style="margin-bottom: 1.5rem;">
    <div class="page-title">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--slate-500); margin-bottom:0.25rem;">Asset Management</div>
        <h1 style="font-size:1.85rem; font-weight:800; letter-spacing:-0.03em; color:var(--dark); margin:0;">Fleet Inventory &amp; Assets</h1>
        <p style="color:var(--slate-600); font-size:0.93rem; margin-top:0.25rem;">Monitor vehicle status, update rates, track maintenance, and dispatch fleet</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/cars?action=new" class="btn btn-primary" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.6rem 1.2rem; font-weight:600;">
            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
            + Add New Vehicle
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; width:100%;">
            <!-- Status Filter Pills -->
            <div style="display:flex; gap:0.5rem; flex-wrap:wrap;">
                <button type="button" class="btn-filter-tab active" data-filter="all">
                    All Vehicles (<%= carList.size() %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="AVAILABLE">
                    Available (<%= availableCount %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="RENTED">
                    Rented (<%= rentedCount %>)
                </button>
                <button type="button" class="btn-filter-tab" data-filter="MAINTENANCE">
                    Maintenance (<%= maintenanceCount %>)
                </button>
            </div>

            <!-- Live Search Box -->
            <div style="position:relative; min-width:280px; max-width:360px; width:100%;">
                <input type="text" id="carSearchInput" class="form-control" 
                       style="padding-left:2.4rem; border-radius:8px; font-size:0.9rem;" 
                       placeholder="Search model, brand, reg plate...">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" 
                     style="position:absolute; left:0.85rem; top:50%; transform:translateY(-50%); color:var(--slate-400); pointer-events:none;">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
            </div>
        </div>
    </div>

    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="data-table" id="carsTable">
                <thead>
                    <tr>
                        <th style="width:70px;">ID</th>
                        <th>Vehicle Name &amp; Brand</th>
                        <th>Category</th>
                        <th>Registration Plate</th>
                        <th>Daily Rate</th>
                        <th>Capacity &amp; Fuel</th>
                        <th>Operational Status</th>
                        <th style="text-align: right;">Fleet Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!carList.isEmpty()) { 
                        for (Car car : carList) { 
                            String status = car.getStatus() != null ? car.getStatus().toUpperCase() : "AVAILABLE";
                            String badgeClass = "badge-available";
                            if ("RENTED".equals(status)) {
                                badgeClass = "badge-rented";
                            } else if ("MAINTENANCE".equals(status)) {
                                badgeClass = "badge-maintenance";
                            }
                    %>
                        <tr class="car-row" data-status="<%= status %>" data-search="<%= car.getCarModel().toLowerCase() %> <%= car.getBrand().toLowerCase() %> <%= car.getRegistrationNumber().toLowerCase() %> <%= car.getCategory().toLowerCase() %>">
                            <td>
                                <span style="font-weight:700; color:var(--slate-500); font-size:0.85rem;">#<%= car.getCarId() %></span>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <div class="vehicle-avatar" style="<%= "AVAILABLE".equals(status) ? "background:#ecfdf5; border-color:#a7f3d0; color:#059669;" : ("RENTED".equals(status) ? "background:#fffbeb; border-color:#fde68a; color:#d97706;" : "background:#f1f5f9; color:#64748b;") %>">
                                        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <rect x="1" y="3" width="15" height="13" rx="2"/><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"/><circle cx="5.5" cy="18.5" r="2.5"/><circle cx="18.5" cy="18.5" r="2.5"/>
                                        </svg>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.95rem;"><%= car.getCarModel() %></strong><br>
                                        <span style="font-size:0.8rem; color:var(--slate-500);"><%= car.getBrand() %></span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge" style="background:var(--slate-100); color:var(--slate-800); font-weight:600;"><%= car.getCategory() %></span>
                            </td>
                            <td>
                                <code style="font-size:0.82rem; background:var(--bg-light); border:1px solid var(--border); padding:0.18rem 0.45rem; border-radius:4px;"><%= car.getRegistrationNumber() %></code>
                            </td>
                            <td>
                                <strong style="font-size:1.02rem; color:var(--dark);">₹<%= String.format("%.2f", car.getDailyRate()) %></strong>
                                <span style="font-size:0.78rem; color:var(--slate-500);">/day</span>
                            </td>
                            <td>
                                <div style="font-size:0.86rem; color:var(--slate-700);">
                                    <strong><%= car.getSeatingCapacity() %></strong> Seats &bull; <%= car.getFuelType() %>
                                </div>
                            </td>
                            <td>
                                <span class="badge <%= badgeClass %>" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.3rem 0.65rem;">
                                    <span style="width:6px; height:6px; border-radius:50%; background:currentColor; display:inline-block;"></span>
                                    <%= status %>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display:inline-flex; gap:0.35rem; align-items:center;">
                                    <% if (car.isAvailable()) { %>
                                        <a href="<%= request.getContextPath() %>/rentals?action=new&carId=<%= car.getCarId() %>" 
                                           class="btn-action-ghost btn-action-success" title="Quick Book This Vehicle">
                                            <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14"/></svg>
                                            Book
                                        </a>
                                    <% } %>
                                    <a href="<%= request.getContextPath() %>/cars?action=edit&id=<%= car.getCarId() %>" 
                                       class="btn-action-ghost" title="Edit Vehicle Specs">
                                        <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        Edit
                                    </a>
                                    <a href="<%= request.getContextPath() %>/cars?action=delete&id=<%= car.getCarId() %>" 
                                       class="btn-action-ghost btn-action-danger" 
                                       onclick="return confirm('Delete vehicle <%= car.getCarModel() %> (#<%= car.getCarId() %>)? This cannot be undone.');" 
                                       title="Remove From Fleet">
                                        <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                        Delete
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <%  } 
                       } else { %>
                        <tr>
                            <td colspan="8" style="text-align:center; padding: 3rem; color: var(--slate-500);">
                                No vehicles in inventory. Click <strong>+ Add New Vehicle</strong> to register your first fleet asset.
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
    const searchInput = document.getElementById('carSearchInput');
    const rows = document.querySelectorAll('.car-row');

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
