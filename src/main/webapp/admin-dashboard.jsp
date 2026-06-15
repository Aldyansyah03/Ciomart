<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%
// Cek apakah user sudah login dan role admin
if(session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");

// Ambil statistik
Connection conn = DBConnection.getConnection();

// Total produk
Statement st1 = conn.createStatement();
ResultSet rs1 = st1.executeQuery("SELECT COUNT(*) as total FROM products");
rs1.next();
int totalProducts = rs1.getInt("total");

// Total kategori
Statement st2 = conn.createStatement();
ResultSet rs2 = st2.executeQuery("SELECT COUNT(*) as total FROM categories");
rs2.next();
int totalCategories = rs2.getInt("total");

// Total penjualan hari ini
Statement st3 = conn.createStatement();
ResultSet rs3 = st3.executeQuery("SELECT COUNT(*) as total, SUM(total) as revenue FROM sales WHERE DATE(sale_date) = CURDATE()");
rs3.next();
int todaySales = rs3.getInt("total");
double todayRevenue = rs3.getDouble("revenue");

// Produk dengan stok menipis
Statement st4 = conn.createStatement();
ResultSet rs4 = st4.executeQuery("SELECT COUNT(*) as total FROM products WHERE stock < 20");
rs4.next();
int lowStock = rs4.getInt("total");

rs1.close(); st1.close();
rs2.close(); st2.close();
rs3.close(); st3.close();
rs4.close(); st4.close();
conn.close();
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Admin Dashboard - CIOMART</title>
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
    --primary-blue: var(--brand-red);
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
    background: linear-gradient(90deg, var(--brand-orange), var(--brand-red));
}

.stat-card.success::before { background: linear-gradient(90deg, var(--success), #34d399); }
.stat-card.warning::before { background: linear-gradient(90deg, var(--warning), #fbbf24); }
.stat-card.danger::before { background: linear-gradient(90deg, var(--danger), #f87171); }

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
    background: linear-gradient(135deg, var(--brand-orange), var(--brand-red));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
}

.stat-label {
    color: var(--text-secondary);
    margin-top: 0.5rem;
    font-size: 0.9rem;
}

/* Menu Grid */
.menu-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 2rem;
}

.menu-card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
    border-radius: 20px;
    padding: 2.5rem;
    backdrop-filter: none;
    transition: all 0.4s ease;
    text-decoration: none;
    display: block;
}

.menu-card:hover {
    transform: translateY(-10px);
    border-color: var(--primary-blue);
    box-shadow: 0 20px 60px rgba(2, 6, 23, 0.08);
}

.menu-icon {
    width: 60px;
    height: 60px;
    background: linear-gradient(135deg, rgba(250, 177, 47, 0.28), rgba(250, 129, 47, 0.14));
    border-radius: 15px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 2rem;
    margin-bottom: 1.5rem;
    border: 1px solid rgba(250, 129, 47, 0.18);
}

.menu-card h3 {
    font-size: 1.5rem;
    margin-bottom: 1rem;
    color: var(--text-primary);
}

.menu-card p {
    color: var(--text-secondary);
    line-height: 1.8;
}

@media (max-width: 768px) {
    .header-content {
        flex-direction: column;
        gap: 1rem;
    }
    
    .stats-grid {
        grid-template-columns: 1fr;
    }
    
    .menu-grid {
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
                <p>Admin Dashboard</p>
            </div>
        </div>
        <div class="user-info">
            <div class="user-badge">
                <span>👤</span>
                <span><strong><%= fullName %></strong> (Admin)</span>
            </div>
            <a href="logout.jsp" class="btn-logout">🚪 Logout</a>
        </div>
    </div>
</header>

<!-- Main Container -->
<div class="container">
    <div class="page-header">
        <h2>📊 Dashboard Admin</h2>
        <p>Selamat datang di sistem manajemen CIOMART</p>
    </div>

    <!-- Statistics -->
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">📦</div>
            <div class="stat-value"><%= totalProducts %></div>
            <div class="stat-label">Total Produk</div>
        </div>
        <div class="stat-card success">
            <div class="stat-icon">🏷️</div>
            <div class="stat-value"><%= totalCategories %></div>
            <div class="stat-label">Kategori</div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-value">Rp <%= String.format("%,.0f", todayRevenue) %></div>
            <div class="stat-label">Penjualan Hari Ini (<%= todaySales %> transaksi)</div>
        </div>
        <div class="stat-card <%= lowStock > 0 ? "danger" : "success" %>">
            <div class="stat-icon">⚠️</div>
            <div class="stat-value"><%= lowStock %></div>
            <div class="stat-label">Stok Menipis (< 20)</div>
        </div>
    </div>

    <!-- Menu -->
    <div class="menu-grid">
        <a href="products-admin.jsp" class="menu-card">
            <div class="menu-icon">📦</div>
            <h3>Kelola Produk</h3>
            <p>Tambah, edit, dan hapus produk. Atur stok dan harga barang.</p>
        </a>
        
        <a href="categories-admin.jsp" class="menu-card">
            <div class="menu-icon">🏷️</div>
            <h3>Kelola Kategori</h3>
            <p>Manajemen kategori produk untuk pengelompokan barang.</p>
        </a>
        
        <a href="reports-admin.jsp" class="menu-card">
            <div class="menu-icon">📊</div>
            <h3>Laporan Penjualan</h3>
            <p>Lihat laporan penjualan harian, bulanan, dan statistik.</p>
        </a>
        
        <a href="users-admin.jsp" class="menu-card">
            <div class="menu-icon">👥</div>
            <h3>Kelola Pengguna</h3>
            <p>Manajemen akun admin dan kasir dalam sistem.</p>
        </a>
    </div>
</div>

</body>
</html>
