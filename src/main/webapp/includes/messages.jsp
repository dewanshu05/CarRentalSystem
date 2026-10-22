<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String successMsg = request.getParameter("msg");
    if (successMsg == null || successMsg.trim().isEmpty()) {
        successMsg = (String) request.getAttribute("msg");
    }

    String errorMsg = request.getParameter("error");
    if (errorMsg == null || errorMsg.trim().isEmpty()) {
        errorMsg = (String) request.getAttribute("error");
    }
%>

<% if (successMsg != null && !successMsg.trim().isEmpty()) { %>
    <div class="alert alert-success" id="successAlert">
        <div>
            <strong>✓ Success:</strong> <%= successMsg %>
        </div>
        <button type="button" class="alert-close" onclick="this.parentElement.remove();">&times;</button>
    </div>
<% } %>

<% if (errorMsg != null && !errorMsg.trim().isEmpty()) { %>
    <div class="alert alert-danger" id="dangerAlert">
        <div>
            <strong>⚠ Error:</strong> <%= errorMsg %>
        </div>
        <button type="button" class="alert-close" onclick="this.parentElement.remove();">&times;</button>
    </div>
<% } %>
