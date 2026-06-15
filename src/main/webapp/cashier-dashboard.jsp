<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%
// Cek apakah user sudah login dan role kasir
if(session.getAttribute("userId") == null || !"CASHIER".equals(session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");
Integer userId = (Integer) session.getAttribute("userId");

// Ambil total penjualan hari ini oleh kasir ini
Connection conn = DBConnection.getConnection();
Statement st = conn.createStatement();
ResultSet rs = st.executeQuery(
    "SELECT COUNT(*) as total, COALESCE(SUM(total), 0) as revenue " +
    "FROM sales WHERE cashier_id=" + userId + " AND DATE(sale_date) = CURDATE()"
);
rs.next();
int todaySales = rs.getInt("total");
double todayRevenue = rs.getDouble("revenue");
rs.close();
st.close();
conn.close();
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kasir Dashboard - CIOMART</title>
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
    --primary-blue: var(--brand-orange);
    --dark-bg: #ffffff;
    --card-bg: #ffffff;
    --card-border: #e2e8f0;
    --text-primary: #0f172a;
    --text-secondary: #475569;
    --glow-blue: rgba(250, 129, 47, 0.14);
    --glow-blue-strong: rgba(221, 3, 3, 0.12);
    --success: var(--brand-yellow);
    --warning: var(--brand-orange);
    --danger: var(--brand-red);
}

body {
    font-family: 'Inter', sans-serif;
    background: linear-gradient(180deg, var(--brand-cream), #ffffff);
    color: var(--text-primary);
    min-height: 100vh;
    position: relative;
    overflow-x: hidden;
}

/* Header */
.header {
    position: sticky;
    top: 0;
    z-index: 100;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: none;
    border-bottom: 1px solid var(--card-border);
    box-shadow: 0 4px 20px rgba(2, 6, 23, 0.06);
}

.header-content {
    max-width: 1400px;
    margin: 0 auto;
    padding: 1.5rem 2rem;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.logo {
    display: flex;
    align-items: center;
    gap: 1rem;
}

.logo-icon {
    width: 48px;
    height: 48px;
    background: linear-gradient(135deg, var(--brand-orange), var(--brand-red));
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 24px;
    box-shadow: 0 10px 24px var(--glow-blue);
}

.logo-text h1 {
    font-size: 1.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, var(--brand-red), var(--brand-orange));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.logo-text p {
    font-size: 0.75rem;
    color: var(--text-secondary);
}

.user-info {
    display: flex;
    align-items: center;
    gap: 1.5rem;
}

.user-badge {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.75rem 1.25rem;
    background: rgba(250, 177, 47, 0.16);
    border: 1px solid rgba(250, 129, 47, 0.18);
    border-radius: 10px;
}

.btn-logout {
    padding: 0.75rem 1.5rem;
    background: rgba(221, 3, 3, 0.08);
    border: 1px solid rgba(221, 3, 3, 0.20);
    color: var(--danger);
    text-decoration: none;
    border-radius: 10px;
    font-weight: 500;
    transition: all 0.3s ease;
}

.btn-logout:hover {
    background: rgba(221, 3, 3, 0.16);
    transform: translateY(-2px);
}

/* Container */
.container {
    position: relative;
    z-index: 10;
    max-width: 1400px;
    margin: 0 auto;
    padding: 3rem 2rem;
}

.page-header {
    margin-bottom: 3rem;
}

.page-header h2 {
    font-size: 2.5rem;
    font-weight: 800;
    color: var(--text-primary);
    margin-bottom: 0.5rem;
}

.page-header p {
    color: var(--text-secondary);
    font-size: 1.1rem;
}

/* Stats Grid */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 3rem;
}

.stat-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 16px;
    padding: 2rem;
    backdrop-filter: none;
    transition: all 0.3s ease;
    position: relative;
    overflow: hidden;
}

.stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 3px;
    background: linear-gradient(90deg, var(--success), #34d399);
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 15px 40px rgba(2, 6, 23, 0.08);
}

.stat-icon {
    font-size: 2.5rem;
    margin-bottom: 1rem;
}

.stat-value {
    font-size: 2.5rem;
    font-weight: 800;
    background: linear-gradient(135deg, var(--success), #34d399);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.stat-label {
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-size: 0.9rem;
}

/* Action Button */
.action-btn {
    display: block;
    width: 100%;
    max-width: 500px;
    margin: 0 auto;
    padding: 2rem;
    background: linear-gradient(135deg, var(--brand-orange), var(--brand-red));
    border: none;
    border-radius: 20px;
    color: white;
    text-decoration: none;
    text-align: center;
    font-size: 1.5rem;
    font-weight: 800;
    box-shadow: 0 20px 60px var(--glow-blue);
    transition: all 0.4s ease;
    cursor: pointer;
}

.action-btn:hover {
    transform: translateY(-10px) scale(1.02);
    box-shadow: 0 30px 80px rgba(170, 43, 29, 0.16);
}

.action-icon {
    font-size: 3rem;
    display: block;
    margin-bottom: 1rem;
}

/* Quick Info */
.quick-info {
    margin-top: 3rem;
    padding: 2rem;
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 20px;
    backdrop-filter: none;
}

.quick-info h3 {
    font-size: 1.25rem;
    margin-bottom: 1.5rem;
    color: var(--brand-red);
}

.info-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1.5rem;
}

.info-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 1rem;
    background: rgba(250, 177, 47, 0.16);
    border-radius: 12px;
    border: 1px solid rgba(250, 129, 47, 0.14);
}

.info-icon {
    font-size: 2rem;
}

.info-text {
    flex: 1;
}

.info-label {
    font-size: 0.75rem;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 1px;
}

.info-value {
    font-size: 1.1rem;
    font-weight: 700;
    color: var(--text-primary);
}

@media (max-width: 768px) {
    .header-content {
        flex-direction: column;
        gap: 1rem;
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
    }
    
    .info-grid {
        grid-template-columns: 1fr;
    }
}
</style>
</head>
<body>

<!-- Header -->
<header class="header">
    <div class="header-content">
        <div class="logo">
            <div class="logo-icon">🏪</div>
            <div class="logo-text">
                <h1>CIOMART</h1>
                <p>Kasir Dashboard</p>
            </div>
        </div>
        <div class="user-info">
            <div class="user-badge">
                <span>👤</span>
                <span><strong><%= fullName %></strong> (Kasir)</span>
            </div>
            <a href="logout.jsp" class="btn-logout">🚪 Logout</a>
        </div>
    </div>
</header>

<!-- Main Container -->
<div class="container">
    <div class="page-header">
        <h2>💰 Dashboard Kasir</h2>
        <p>Selamat datang, <%= fullName %>! Siap melayani transaksi hari ini</p>
    </div>

    <!-- Statistics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">🛒</div>
            <div class="stat-value"><%= todaySales %></div>
            <div class="stat-label">Transaksi Hari Ini</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">💵</div>
            <div class="stat-value">Rp <%= String.format("%,.0f", todayRevenue) %></div>
            <div class="stat-label">Total Penjualan Hari Ini</div>
        </div>
    </div>

    <!-- Main Action -->
    <a href="transaction.jsp" class="action-btn">
        <span class="action-icon">🛍️</span>
        <div>Mulai Transaksi Baru</div>
    </a>

    <!-- Quick Info -->
    <div class="quick-info">
        <h3>📋 Informasi Cepat</h3>
        <div class="info-grid">
            <div class="info-item">
                <div class="info-icon">⏰</div>
                <div class="info-text">
                    <div class="info-label">Waktu</div>
                    <div class="info-value" id="current-time"></div>
                </div>
            </div>
            <div class="info-item">
                <div class="info-icon">📅</div>
                <div class="info-text">
                    <div class="info-label">Tanggal</div>
                    <div class="info-value" id="current-date"></div>
                </div>
            </div>
            <div class="info-item">
                <div class="info-icon">👤</div>
                <div class="info-text">
                    <div class="info-label">Kasir</div>
                    <div class="info-value"><%= fullName %></div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Perbarui tampilan waktu dan tanggal di dashboard kasir
function updateDateTime() {
    const now = new Date();
    
    // Atur format jam
    const hours = String(now.getHours()).padStart(2, '0');
    const minutes = String(now.getMinutes()).padStart(2, '0');
    const seconds = String(now.getSeconds()).padStart(2, '0');
    document.getElementById('current-time').textContent = hours + ':' + minutes + ':' + seconds;
    
    // Atur format tanggal
    const days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    const dateStr = days[now.getDay()] + ', ' + now.getDate() + ' ' + months[now.getMonth()] + ' ' + now.getFullYear();
    document.getElementById('current-date').textContent = dateStr;
}

// Jalankan update pertama dan perbarui tiap 1 detik
updateDateTime();
setInterval(updateDateTime, 1000);
</script>

</body>
</html>
