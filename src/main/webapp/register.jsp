<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setAttribute("pageTitle", "Customer Registration");
%>
<jsp:include page="/includes/header.jsp" />

<div class="form-container" style="max-width: 650px; margin: 2rem auto;">
    <div class="card" style="box-shadow: var(--shadow-lg);">
        <div class="card-header">
            <div>
                <h1 style="font-size: 1.4rem; font-weight: 700; color: var(--dark);">Create Customer Account</h1>
                <p style="font-size: 0.88rem; color: var(--slate-600);">Sign up to rent and book cars instantly</p>
            </div>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-outline btn-sm">Sign In Instead</a>
        </div>

        <div class="card-body">
            <form action="<%= request.getContextPath() %>/register" method="post">
                <div class="form-grid">
                    <!-- Full Name -->
                    <div class="form-group col-span-2">
                        <label for="fullName">Full Legal Name *</label>
                        <input type="text" id="fullName" name="fullName" class="form-control" 
                               placeholder="e.g. Vikram Malhotra" required>
                    </div>

                    <!-- Username -->
                    <div class="form-group">
                        <label for="username">Username *</label>
                        <input type="text" id="username" name="username" class="form-control" 
                               placeholder="e.g. vikram99" required>
                    </div>

                    <!-- Password -->
                    <div class="form-group">
                        <label for="password">Password *</label>
                        <input type="password" id="password" name="password" class="form-control" 
                               placeholder="Create secure password" required minlength="4">
                    </div>

                    <!-- Email -->
                    <div class="form-group">
                        <label for="email">Email Address *</label>
                        <input type="email" id="email" name="email" class="form-control" 
                               placeholder="e.g. vikram@example.com" required>
                    </div>

                    <!-- Phone -->
                    <div class="form-group">
                        <label for="phone">Phone Number *</label>
                        <input type="tel" id="phone" name="phone" class="form-control" 
                               placeholder="e.g. 9876543210" required>
                    </div>

                    <!-- License Number -->
                    <div class="form-group col-span-2">
                        <label for="licenseNumber">Driving License Number *</label>
                        <input type="text" id="licenseNumber" name="licenseNumber" class="form-control" 
                               placeholder="e.g. DL-0420220019283" required>
                        <span class="form-hint">Required by law for vehicle rental reservation verification.</span>
                    </div>

                    <!-- Residential Address -->
                    <div class="form-group col-span-2">
                        <label for="address">Residential City / Address</label>
                        <textarea id="address" name="address" class="form-control" 
                                  placeholder="e.g. 104 Palm Grove, Indiranagar, Bengaluru"></textarea>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 0.75rem;">
                        Register & Launch Customer Dashboard &rarr;
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<jsp:include page="/includes/footer.jsp" />
