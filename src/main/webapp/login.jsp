<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setAttribute("pageTitle", "Sign In");
%>
<jsp:include page="/includes/header.jsp" />

<div class="form-container" style="max-width: 480px; margin: 2rem auto;">
    <div class="card" style="box-shadow: var(--shadow-lg);">
        <div class="card-header" style="text-align: center; flex-direction: column; gap: 0.3rem;">
            <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--dark);">Sign In to DriveEase</h1>
            <p style="font-size: 0.88rem; color: var(--slate-600);">Choose your portal: Vehicle Owner (Admin) or Customer</p>
        </div>

        <div class="card-body">
            <!-- 1-Click Quick Demo Login Shortcuts -->
            <div style="background: var(--slate-100); border-radius: var(--radius-sm); padding: 0.9rem; margin-bottom: 1.5rem; border: 1px dashed var(--slate-400);">
                <div style="font-size: 0.8rem; font-weight: 700; text-transform: uppercase; color: var(--slate-600); margin-bottom: 0.6rem; text-align: center;">
                    ⚡ Quick Demo Login (Click to Auto-Fill)
                </div>
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.6rem;">
                    <button type="button" class="btn btn-outline btn-sm" onclick="fillCredentials('admin', 'admin123')" style="background:#fff; justify-content:center;">
                        👑 Owner / Admin
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" onclick="fillCredentials('aarav', 'customer123')" style="background:#fff; justify-content:center;">
                        🚗 Customer (Aarav)
                    </button>
                </div>
            </div>

            <form action="<%= request.getContextPath() %>/login" method="post" id="loginForm">
                <div class="form-group" style="margin-bottom: 1.1rem;">
                    <label for="username">Username or Email Address *</label>
                    <input type="text" id="username" name="username" class="form-control" 
                           placeholder="Enter username or email" required autofocus>
                </div>

                <div class="form-group" style="margin-bottom: 1.4rem;">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="Enter your password" required>
                </div>

                <button type="submit" class="btn btn-primary" style="width: 100%; justify-content: center; padding: 0.75rem;">
                    Sign In &rarr;
                </button>
            </form>

            <div style="text-align: center; margin-top: 1.5rem; padding-top: 1.2rem; border-top: 1px solid var(--slate-200); font-size: 0.9rem;">
                Don't have a customer account? 
                <a href="<%= request.getContextPath() %>/register" style="color: var(--primary); font-weight: 600; text-decoration: underline;">
                    Register here
                </a>
            </div>
        </div>
    </div>
</div>

<script>
function fillCredentials(user, pass) {
    document.getElementById('username').value = user;
    document.getElementById('password').value = pass;
    document.getElementById('loginForm').submit();
}
</script>

<jsp:include page="/includes/footer.jsp" />
