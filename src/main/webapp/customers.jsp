<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.carrental.model.Customer" %>

<%
    request.setAttribute("pageTitle", "Customer Directory");
    List<Customer> customerList = (List<Customer>) request.getAttribute("customerList");

    if (customerList == null) {
        response.sendRedirect(request.getContextPath() + "/customers");
        return;
    }
%>

<jsp:include page="/includes/header.jsp" />

<div class="page-header" style="margin-bottom: 1.5rem;">
    <div class="page-title">
        <div style="font-size:0.75rem; font-weight:700; text-transform:uppercase; letter-spacing:0.07em; color:var(--slate-500); margin-bottom:0.25rem;">Client Relationship Management</div>
        <h1 style="font-size:1.85rem; font-weight:800; letter-spacing:-0.03em; color:var(--dark); margin:0;">Customer &amp; Driver Directory</h1>
        <p style="color:var(--slate-600); font-size:0.93rem; margin-top:0.25rem;">Manage authorized driver records, verify government license IDs, and update contact profiles</p>
    </div>
    <div class="header-actions">
        <a href="<%= request.getContextPath() %>/customers?action=new" class="btn btn-primary" style="display:inline-flex; align-items:center; gap:0.4rem; padding:0.6rem 1.2rem; font-weight:600;">
            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
            + Register New Customer
        </a>
    </div>
</div>

<div class="card">
    <div class="card-header" style="padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border);">
        <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:1rem; width:100%;">
            <div style="font-size:0.95rem; font-weight:700; color:var(--dark);">
                Registered Drivers (<span id="customerCount"><%= customerList.size() %></span>)
            </div>

            <!-- Search Box -->
            <div style="position:relative; min-width:280px; max-width:380px; width:100%;">
                <input type="text" id="customerSearchInput" class="form-control" 
                       style="padding-left:2.4rem; border-radius:8px; font-size:0.9rem;" 
                       placeholder="Search by name, email, phone, license...">
                <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24" 
                     style="position:absolute; left:0.85rem; top:50%; transform:translateY(-50%); color:var(--slate-400); pointer-events:none;">
                    <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
                </svg>
            </div>
        </div>
    </div>

    <div class="card-body" style="padding: 0;">
        <div class="table-responsive">
            <table class="data-table" id="customersTable">
                <thead>
                    <tr>
                        <th style="width:70px;">ID</th>
                        <th>Customer / Driver</th>
                        <th>Email Contact</th>
                        <th>Phone Number</th>
                        <th>Driver's License</th>
                        <th>Registered Address</th>
                        <th style="text-align: right;">Profile Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (!customerList.isEmpty()) { 
                        for (Customer c : customerList) { 
                            String initial = c.getFullName() != null && c.getFullName().length() > 0 ? c.getFullName().substring(0, 1).toUpperCase() : "U";
                    %>
                        <tr class="customer-row" data-search="<%= c.getFullName().toLowerCase() %> <%= c.getEmail().toLowerCase() %> <%= c.getPhone().toLowerCase() %> <%= c.getLicenseNumber() != null ? c.getLicenseNumber().toLowerCase() : "" %>">
                            <td>
                                <span style="font-weight:700; color:var(--slate-500); font-size:0.85rem;">#<%= c.getCustomerId() %></span>
                            </td>
                            <td>
                                <div style="display:flex; align-items:center; gap:0.75rem;">
                                    <div class="customer-avatar" style="width:38px; height:38px; font-size:0.9rem;">
                                        <%= initial %>
                                    </div>
                                    <div>
                                        <strong style="color:var(--dark); font-size:0.95rem;"><%= c.getFullName() %></strong><br>
                                        <span class="badge" style="background:#f0fdf4; color:#166534; font-size:0.7rem; padding:0.1rem 0.4rem; border:1px solid #bbf7d0;">Verified Driver</span>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span style="color:var(--slate-700); font-size:0.88rem;"><%= c.getEmail() %></span>
                            </td>
                            <td>
                                <span style="color:var(--slate-800); font-weight:600; font-size:0.88rem;"><%= c.getPhone() %></span>
                            </td>
                            <td>
                                <code style="font-size:0.82rem; background:var(--bg-light); border:1px solid var(--border); padding:0.2rem 0.5rem; border-radius:4px; color:#1e293b;">
                                    <%= c.getLicenseNumber() %>
                                </code>
                            </td>
                            <td>
                                <span style="color:var(--slate-600); font-size:0.85rem;">
                                    <%= c.getAddress() != null && !c.getAddress().isEmpty() ? c.getAddress() : "—" %>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display:inline-flex; gap:0.35rem; align-items:center;">
                                    <a href="<%= request.getContextPath() %>/customers?action=edit&id=<%= c.getCustomerId() %>" 
                                       class="btn-action-ghost" title="Edit Customer Details">
                                        <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                        Edit
                                    </a>
                                    <a href="<%= request.getContextPath() %>/customers?action=delete&id=<%= c.getCustomerId() %>" 
                                       class="btn-action-ghost btn-action-danger" 
                                       onclick="return confirm('Delete customer record for <%= c.getFullName() %> (#<%= c.getCustomerId() %>)? This cannot be undone.');" 
                                       title="Remove Customer Record">
                                        <svg width="13" height="13" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                                        Delete
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <%  } 
                       } else { %>
                        <tr>
                            <td colspan="7" style="text-align:center; padding: 3rem; color: var(--slate-500);">
                                No customers registered yet. Click <strong>+ Register New Customer</strong> to add one.
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script>
(function() {
    const searchInput = document.getElementById('customerSearchInput');
    const rows = document.querySelectorAll('.customer-row');
    const countDisplay = document.getElementById('customerCount');

    if (searchInput) {
        searchInput.addEventListener('input', function() {
            const query = (this.value || '').toLowerCase().trim();
            let visibleCount = 0;
            rows.forEach(function(row) {
                const searchData = row.dataset.search || '';
                const matches = !query || searchData.includes(query);
                row.style.display = matches ? '' : 'none';
                if (matches) visibleCount++;
            });
            if (countDisplay) countDisplay.textContent = visibleCount;
        });
    }
})();
</script>

<jsp:include page="/includes/footer.jsp" />
