<%@ page contentType="text/html;charset=UTF-8" %>
<%
// Clear session
session.invalidate();
// Arahkan ke halaman login
response.sendRedirect("login.jsp");
%>
