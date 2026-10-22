<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.carrental.model.User" %>
<%
    String currentUri = request.getRequestURI();
    String contextPath = request.getContextPath();
    User currentUser = (User) session.getAttribute("currentUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= request.getAttribute("pageTitle") != null ? request.getAttribute("pageTitle") + " | " : "" %>DriveEase Car Rental</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= contextPath %>/css/style.css?v=2.5.0">
</head>
<body>

<!-- Role-Aware Modern Navigation Bar -->
<header class="navbar">
    <div class="nav-container">
        <!-- Brand Logo & Portal Indicator -->
        <a href="<%= currentUser != null && currentUser.isCustomer() ? contextPath + "/customer/dashboard" : contextPath + "/dashboard" %>" class="nav-brand">
            <span class="brand-icon-box">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/>
                    <circle cx="7" cy="17" r="2"/>
                    <path d="M9 17h6"/>
                    <circle cx="17" cy="17" r="2"/>
                </svg>
            </span>
            <span class="brand-text">DriveEase</span>
            <% if (currentUser != null && currentUser.isAdmin()) { %>
                <span class="portal-badge-admin">Admin Console</span>
            <% } else if (currentUser != null && currentUser.isCustomer()) { %>
                <span class="portal-badge-customer">Customer Portal</span>
            <% } %>
        </a>

        <nav>
            <ul class="nav-links">
                <% if (currentUser == null) { %>
                    <!-- Guest Navigation (Not Logged In) -->
                    <li>
                        <a href="<%= contextPath %>/login" class="nav-link <%= currentUri.endsWith("/login.jsp") ? "active" : "" %>">
                            Sign In
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/register" class="btn-book-cta">
                            Register as Customer
                        </a>
                    </li>
                <% } else if (currentUser.isAdmin()) { %>
                    <!-- OWNER / ADMIN NAVIGATION -->
                    <li>
                        <a href="<%= contextPath %>/dashboard" class="nav-link <%= currentUri.endsWith("/dashboard") || currentUri.endsWith("/dashboard.jsp") ? "active" : "" %>">
                            Dashboard
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/cars" class="nav-link <%= currentUri.contains("/cars") || currentUri.endsWith("/cars.jsp") ? "active" : "" %>">
                            Fleet Inventory
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/customers" class="nav-link <%= currentUri.contains("/customers") || currentUri.endsWith("/customers.jsp") ? "active" : "" %>">
                            Customers
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/rentals" class="nav-link <%= currentUri.contains("/rentals") || currentUri.endsWith("/rentals.jsp") ? "active" : "" %>">
                            Bookings &amp; Returns
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/cars?action=new" class="nav-btn-action" title="Add New Vehicle">
                            <svg width="14" height="14" fill="none" stroke="currentColor" stroke-width="2.2" viewBox="0 0 24 24"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                            Add Vehicle
                        </a>
                    </li>
                    <!-- Admin User Pill & Logout -->
                    <li class="admin-profile-pill">
                        <div class="admin-avatar">AD</div>
                        <div class="admin-details">
                            <span class="admin-name">Operations</span>
                            <span class="admin-role">Admin</span>
                        </div>
                        <a href="<%= contextPath %>/logout" class="btn-logout-sleek" title="Sign out of Admin Console">
                            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                <polyline points="16 17 21 12 16 7"/>
                                <line x1="21" y1="12" x2="9" y2="12"/>
                            </svg>
                        </a>
                    </li>

                <% } else if (currentUser.isCustomer()) { 
                    String custInit = "CU";
                    if (currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()) {
                        String[] p = currentUser.getFullName().trim().split("\\s+");
                        if (p.length >= 2) {
                            custInit = ("" + p[0].charAt(0) + p[1].charAt(0)).toUpperCase();
                        } else {
                            custInit = ("" + p[0].charAt(0)).toUpperCase();
                        }
                    }
                %>
                    <!-- CUSTOMER NAVIGATION -->
                    <li>
                        <a href="<%= contextPath %>/customer/dashboard" class="nav-link <%= currentUri.contains("/customer/dashboard") ? "active" : "" %>">
                            Browse Fleet
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/customer/bookings" class="nav-link <%= currentUri.contains("/customer/bookings") ? "active" : "" %>">
                            My Bookings
                        </a>
                    </li>
                    <li>
                        <a href="<%= contextPath %>/customer/book" class="btn-book-cta" style="margin-left:0.25rem;">
                            + Reserve a Car
                        </a>
                    </li>
                    <!-- Customer Profile Pill -->
                    <li class="admin-profile-pill">
                        <div class="customer-avatar" style="width:28px; height:28px; font-size:0.75rem; background:linear-gradient(135deg, #0ea5e9, #6366f1); color:#fff; font-weight:700;">
                            <%= custInit %>
                        </div>
                        <div class="admin-details">
                            <span class="admin-name"><%= currentUser.getFullName().split(" ")[0] %></span>
                            <span class="admin-role" style="color:#7dd3fc;">Driver</span>
                        </div>
                        <a href="<%= contextPath %>/logout" class="btn-logout-sleek" title="Sign out of Customer Portal">
                            <svg width="15" height="15" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                <polyline points="16 17 21 12 16 7"/>
                                <line x1="21" y1="12" x2="9" y2="12"/>
                            </svg>
                        </a>
                    </li>
                <% } %>
            </ul>
        </nav>
    </div>
</header>

<main class="main-wrapper">
    <jsp:include page="/includes/messages.jsp" />
