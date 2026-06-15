<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%@ page import="java.security.MessageDigest" %>
<%
// Process login
if("POST".equalsIgnoreCase(request.getMethod())){
    String username = request.getParameter("username");
    String password = request.getParameter("password");
    
    // Hash the password with SHA-256
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    byte[] hash = md.digest(password.getBytes("UTF-8"));
    StringBuilder hexString = new StringBuilder(hash.length * 2);
    for (byte b : hash) {
        String hex = Integer.toHexString(0xff & b);
        if(hex.length() == 1) hexString.append('0');
        hexString.append(hex);
    }
    String passwordHash = hexString.toString();
    
    Connection conn = DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement(
        "SELECT * FROM users WHERE username=? AND password_hash=?");
    ps.setString(1, username);
    ps.setString(2, passwordHash);
    ResultSet rs = ps.executeQuery();
    
    if(rs.next()){
        // Login successful
        session.setAttribute("userId", rs.getInt("id"));
        session.setAttribute("username", rs.getString("username"));
        session.setAttribute("fullName", rs.getString("full_name"));
        session.setAttribute("role", rs.getString("role"));
        
        String role = rs.getString("role");
        rs.close(); ps.close(); conn.close();
        
        // Arahkan halaman sesuai role
        if("ADMIN".equals(role)){
            response.sendRedirect("admin-dashboard.jsp");
        } else {
            response.sendRedirect("cashier-dashboard.jsp");
        }
        return;
    } else {
        rs.close(); ps.close(); conn.close();
        request.setAttribute("error", "Username atau password salah!");
    }
}
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Login - CIOMART System</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

:root {
    --brand-cream: #FEF3E2;
    --brand-yellow: #FAB12F;
    --brand-orange: #FA812F;
    --brand-red: #DD0303;
    --primary: var(--brand-orange);
    --secondary: var(--brand-red);

    --bg: var(--brand-cream);
    --card-bg: #ffffff;
    --card-border: #e2e8f0;
    --text-primary: #0f172a;
    --text-secondary: #475569;

    --tint-yellow: rgba(250, 177, 47, 0.22);
    --tint-orange: rgba(250, 129, 47, 0.16);
    --tint-red: rgba(221, 3, 3, 0.10);
    --glow-soft: rgba(2, 6, 23, 0.08);

    --danger: #DD0303;
}

body {
    font-family: 'Inter', sans-serif;
    background: var(--bg);
    color: var(--text-primary);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    overflow: hidden;
}

.login-container {
    position: relative;
    z-index: 10;
    width: 100%;
    max-width: 450px;
    padding: 2rem;
}

.login-header {
    text-align: center;
    margin-bottom: 3rem;
}

.logo-box {
    width: 80px;
    height: 80px;
    margin: 0 auto 1.5rem;
    background: linear-gradient(135deg, var(--brand-orange), var(--brand-red));
    border-radius: 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 3rem;
    box-shadow: 0 18px 45px var(--tint-orange);
    animation: pulse 3s ease-in-out infinite;
}

@keyframes pulse {
    0%, 100% { box-shadow: 0 18px 45px var(--tint-orange); }
    50% { box-shadow: 0 22px 55px rgba(170, 43, 29, 0.16); }
}

.login-header h1 {
    font-size: 2rem;
    font-weight: 800;
    margin-bottom: 0.5rem;
    color: #0f172a;
}

.login-header p {
    color: var(--text-secondary);
    font-size: 1rem;
}

.login-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 24px;
    padding: 3rem;
    backdrop-filter: none;
    box-shadow: 0 22px 70px rgba(2, 6, 23, 0.10);
    position: relative;
    overflow: hidden;
}

.login-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, var(--brand-yellow), var(--brand-orange), var(--brand-red), var(--brand-yellow));
    background-size: 200% 100%;
    animation: shimmer 3s linear infinite;
}

@keyframes shimmer {
    0% { background-position: 200% 0; }
    100% { background-position: -200% 0; }
}

.error-alert {
    background: rgba(170, 43, 29, 0.08);
    border: 1px solid rgba(170, 43, 29, 0.25);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1.5rem;
    color: var(--danger);
    display: flex;
    align-items: center;
    gap: 0.75rem;
    font-size: 0.9rem;
}

.form-group {
    margin-bottom: 1.5rem;
}

label {
    display: block;
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-primary);
    margin-bottom: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

input {
    width: 100%;
    padding: 1.25rem 1.5rem;
    background: #f8fafc;
    border: 1px solid var(--card-border);
    border-radius: 12px;
    color: var(--text-primary);
    font-size: 1rem;
    transition: all 0.3s ease;
    font-family: 'Inter', sans-serif;
}

input:focus {
    outline: none;
    border-color: var(--brand-orange);
    background: #ffffff;
    box-shadow: 0 0 0 4px rgba(250, 177, 47, 0.30), 0 14px 30px rgba(250, 129, 47, 0.12);
}

input::placeholder {
    color: var(--text-secondary);
}

.btn-login {
    width: 100%;
    padding: 1.25rem;
    background: linear-gradient(135deg, var(--brand-orange), var(--brand-red));
    border: none;
    border-radius: 12px;
    color: white;
    font-weight: 700;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    box-shadow: 0 18px 45px var(--tint-orange);
    font-family: 'Inter', sans-serif;
    margin-top: 1rem;
}

.btn-login:hover {
    transform: translateY(-3px);
    box-shadow: 0 22px 60px rgba(221, 3, 3, 0.14);
}

.demo-accounts {
    margin-top: 2rem;
    padding: 1.5rem;
    background: rgba(250, 177, 47, 0.16);
    border: 1px solid rgba(250, 129, 47, 0.18);
    border-radius: 12px;
}

.demo-accounts h3 {
    font-size: 0.85rem;
    color: var(--primary-blue);
    margin-bottom: 1rem;
    text-transform: uppercase;
    letter-spacing: 1px;
}

.demo-item {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    color: var(--text-secondary);
    font-size: 0.85rem;
}

.demo-item span:first-child {
    color: var(--text-primary);
    font-weight: 500;
}

.footer-text {
    text-align: center;
    margin-top: 2rem;
    color: var(--text-secondary);
    font-size: 0.85rem;
}

@media (max-width: 768px) {
    .login-container {
        padding: 1rem;
    }
    
    .login-card {
        padding: 2rem;
    }
}
</style>
</head>
<body>

<div class="login-container">
    <div class="login-header">
        <div class="logo-box">🏪</div>
        <h1>CIOMART</h1>
        <p>Sistem Manajemen Kasir Mini Market</p>
    </div>
    
    <div class="login-card">
        <% if(request.getAttribute("error") != null) { %>
        <div class="error-alert">
            <span>⚠️</span>
            <span><%= request.getAttribute("error") %></span>
        </div>
        <% } %>
        
        <form method="post">
            <div class="form-group">
                <label for="username">👤 Username</label>
                <input type="text" id="username" name="username" placeholder="Masukkan username..." required autofocus>
            </div>
            
            <div class="form-group">
                <label for="password">🔒 Password</label>
                <input type="password" id="password" name="password" placeholder="Masukkan password..." required>
            </div>
            
            <button type="submit" class="btn-login">
                🚀 Login ke Sistem
            </button>
        </form>
    
    <div class="footer-text">
        © 2025 CIOMART System • Kelompok 9 • PBO
    </div>
</div>

</body>
</html>
