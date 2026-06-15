<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
// Cek akses admin
if(session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

// Ambil parameter penyaringan
String dateFrom = request.getParameter("dateFrom");
String dateTo = request.getParameter("dateTo");
String cashierId = request.getParameter("cashierId");
String categoryId = request.getParameter("categoryId");

SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
SimpleDateFormat displaySdf = new SimpleDateFormat("dd/MM/yyyy");

// Set default dates if not provided
if(dateFrom == null || dateFrom.isEmpty()) {
    dateFrom = sdf.format(new java.util.Date());
}
if(dateTo == null || dateTo.isEmpty()) {
    dateTo = sdf.format(new java.util.Date());
}
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Laporan Penjualan - CIOMART</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-style.css" %>
</style>
</head>
<body>

<%@ include file="admin-header.jsp" %>

<div class="container">
    <div class="page-header">
        <h2>📊 Laporan Penjualan</h2>
        <button class="btn btn-primary" onclick="window.print()">🖨️ Cetak Laporan</button>
    </div>

    <!-- Filter Section -->
    <div class="card filter-card">
        <h3>🔍 Filter Laporan</h3>
        <form method="get" class="filter-form">
            <div class="form-row">
                <div class="form-group">
                    <label for="dateFrom">Dari Tanggal</label>
                    <input type="date" id="dateFrom" name="dateFrom" value="<%= dateFrom %>">
                </div>
                <div class="form-group">
                    <label for="dateTo">Sampai Tanggal</label>
                    <input type="date" id="dateTo" name="dateTo" value="<%= dateTo %>">
                </div>
                <div class="form-group">
                    <label for="cashierId">Kasir</label>
                    <select id="cashierId" name="cashierId">
                        <option value="">Semua Kasir</option>
                        <%
                        Connection connFilter = DBConnection.getConnection();
                        Statement stFilter = connFilter.createStatement();
                        ResultSet rsFilter = stFilter.executeQuery("SELECT id, full_name FROM users WHERE role='CASHIER' ORDER BY full_name");
                        while(rsFilter.next()){
                            String selected = rsFilter.getString("id").equals(cashierId) ? "selected" : "";
                        %>
                        <option value="<%= rsFilter.getInt("id") %>" <%= selected %>><%= rsFilter.getString("full_name") %></option>
                        <%
                        }
                        rsFilter.close(); stFilter.close(); connFilter.close();
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="categoryId">Kategori</label>
                    <select id="categoryId" name="categoryId">
                        <option value="">Semua Kategori</option>
                        <%
                        Connection connCat = DBConnection.getConnection();
                        Statement stCat = connCat.createStatement();
                        ResultSet rsCat = stCat.executeQuery("SELECT * FROM categories ORDER BY name");
                        while(rsCat.next()){
                            String selected = rsCat.getString("id").equals(categoryId) ? "selected" : "";
                        %>
                        <option value="<%= rsCat.getInt("id") %>" <%= selected %>><%= rsCat.getString("name") %></option>
                        <%
                        }
                        rsCat.close(); stCat.close(); connCat.close();
                        %>
                    </select>
                </div>
            </div>
            <button type="submit" class="btn btn-primary">🔎 Tampilkan</button>
        </form>
    </div>

    <!-- Summary Statistics -->
    <%
    Connection connStats = DBConnection.getConnection();
    StringBuilder sqlStats = new StringBuilder(
        "SELECT COUNT(*) as total_trx, SUM(total) as total_revenue, " +
        "SUM(discount_amount) as total_discount, SUM(tax_amount) as total_tax " +
        "FROM sales WHERE DATE(sale_date) BETWEEN ? AND ?"
    );
    
    if(cashierId != null && !cashierId.isEmpty()) {
        sqlStats.append(" AND cashier_id = ?");
    }
    
    PreparedStatement psStats = connStats.prepareStatement(sqlStats.toString());
    psStats.setString(1, dateFrom);
    psStats.setString(2, dateTo);
    if(cashierId != null && !cashierId.isEmpty()) {
        psStats.setInt(3, Integer.parseInt(cashierId));
    }
    
    ResultSet rsStats = psStats.executeQuery();
    rsStats.next();
    int totalTrx = rsStats.getInt("total_trx");
    double totalRevenue = rsStats.getDouble("total_revenue");
    double totalDiscount = rsStats.getDouble("total_discount");
    double totalTax = rsStats.getDouble("total_tax");
    rsStats.close(); psStats.close(); connStats.close();
    %>
    
    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-icon">🛒</div>
            <div class="stat-info">
                <h4>Total Transaksi</h4>
                <p class="stat-value"><%= totalTrx %></p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">💰</div>
            <div class="stat-info">
                <h4>Total Pendapatan</h4>
                <p class="stat-value">Rp <%= String.format("%,.0f", totalRevenue) %></p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">🎫</div>
            <div class="stat-info">
                <h4>Total Diskon</h4>
                <p class="stat-value">Rp <%= String.format("%,.0f", totalDiscount) %></p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon">📈</div>
            <div class="stat-info">
                <h4>Total Pajak</h4>
                <p class="stat-value">Rp <%= String.format("%,.0f", totalTax) %></p>
            </div>
        </div>
    </div>

    <!-- Sales Table -->
    <div class="card">
        <div class="card-header">
            <h3>📋 Detail Transaksi</h3>
        </div>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>No. Transaksi</th>
                        <th>Tanggal</th>
                        <th>Kasir</th>
                        <th>Item</th>
                        <th>Subtotal</th>
                        <th>Diskon</th>
                        <th>Pajak</th>
                        <th>Total</th>
                    </tr>
                </thead>
                <tbody>
                <%
                Connection conn = DBConnection.getConnection();
                StringBuilder sql = new StringBuilder(
                    "SELECT s.*, u.full_name as cashier_name " +
                    "FROM sales s " +
                    "JOIN users u ON s.cashier_id = u.id " +
                    "WHERE DATE(s.sale_date) BETWEEN ? AND ?"
                );
                
                if(cashierId != null && !cashierId.isEmpty()) {
                    sql.append(" AND s.cashier_id = ?");
                }
                
                sql.append(" ORDER BY s.sale_date DESC");
                
                PreparedStatement ps = conn.prepareStatement(sql.toString());
                ps.setString(1, dateFrom);
                ps.setString(2, dateTo);
                if(cashierId != null && !cashierId.isEmpty()) {
                    ps.setInt(3, Integer.parseInt(cashierId));
                }
                
                ResultSet rs = ps.executeQuery();
                
                if(!rs.next()) {
                %>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 2rem; color: #94a3b8;">
                            Tidak ada data transaksi untuk periode ini
                        </td>
                    </tr>
                <%
                } else {
                    do {
                        // Ambil jumlah item untuk transaksi ini
                        PreparedStatement psItems = conn.prepareStatement(
                            "SELECT COUNT(*) as item_count FROM sale_items WHERE sale_id = ?"
                        );
                        psItems.setInt(1, rs.getInt("id"));
                        ResultSet rsItems = psItems.executeQuery();
                        rsItems.next();
                        int itemCount = rsItems.getInt("item_count");
                        rsItems.close(); psItems.close();
                %>
                    <tr onclick="toggleDetails(<%= rs.getInt("id") %>)" onkeypress="if(event.key==='Enter'||event.key===' ')toggleDetails(<%= rs.getInt("id") %>)" style="cursor: pointer;" tabindex="0">
                        <td><span class="badge"><%= rs.getString("sale_number") %></span></td>
                        <td><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("sale_date")) %></td>
                        <td><%= rs.getString("cashier_name") %></td>
                        <td><span class="item-count"><%= itemCount %> item</span></td>
                        <td class="amount">Rp <%= String.format("%,.0f", rs.getDouble("subtotal")) %></td>
                        <td class="discount">Rp <%= String.format("%,.0f", rs.getDouble("discount_amount")) %></td>
                        <td class="tax">Rp <%= String.format("%,.0f", rs.getDouble("tax_amount")) %></td>
                        <td class="total">Rp <%= String.format("%,.0f", rs.getDouble("total")) %></td>
                    </tr>
                    <tr id="details-<%= rs.getInt("id") %>" class="details-row" style="display: none;">
                        <td colspan="8">
                            <div class="details-content">
                                <h4>Detail Produk</h4>
                                <table class="details-table">
                                    <thead>
                                        <tr>
                                            <th>Produk</th>
                                            <th>Kategori</th>
                                            <th>Harga</th>
                                            <th>Qty</th>
                                            <th>Subtotal</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    <%
                                    PreparedStatement psDetail = conn.prepareStatement(
                                        "SELECT si.product_name, si.product_price, si.quantity, si.subtotal, c.name as category_name " +
                                        "FROM sale_items si " +
                                        "LEFT JOIN products p ON si.product_id = p.id " +
                                        "LEFT JOIN categories c ON p.category_id = c.id " +
                                        "WHERE si.sale_id = ?"
                                    );
                                    psDetail.setInt(1, rs.getInt("id"));
                                    ResultSet rsDetail = psDetail.executeQuery();
                                    while(rsDetail.next()){
                                    %>
                                        <tr>
                                            <td><%= rsDetail.getString("product_name") %></td>
                                            <td><%= rsDetail.getString("category_name") != null ? rsDetail.getString("category_name") : "-" %></td>
                                            <td>Rp <%= String.format("%,.0f", rsDetail.getDouble("product_price")) %></td>
                                            <td><%= rsDetail.getInt("quantity") %></td>
                                            <td>Rp <%= String.format("%,.0f", rsDetail.getDouble("subtotal")) %></td>
                                        </tr>
                                    <%
                                    }
                                    rsDetail.close(); psDetail.close();
                                    %>
                                    </tbody>
                                </table>
                            </div>
                        </td>
                    </tr>
                <%
                    } while(rs.next());
                }
                rs.close(); ps.close(); conn.close();
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<style>
.page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.page-header h2 {
    font-size: 2rem;
    font-weight: 800;
}

.btn {
    padding: 0.75rem 1.5rem;
    border-radius: 10px;
    border: none;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-primary {
    background: linear-gradient(135deg, #FA812F, #DD0303);
    color: white;
    box-shadow: 0 12px 34px rgba(250, 129, 47, 0.24);
}

.btn-primary:hover {
    transform: translateY(-2px);
    box-shadow: 0 18px 50px rgba(221, 3, 3, 0.20);
}

.card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    padding: 0;
    backdrop-filter: none;
    box-shadow: 0 16px 40px rgba(2, 6, 23, 0.06);
    margin-bottom: 2rem;
}

.filter-card {
    padding: 2rem;
}

.filter-card h3 {
    margin-bottom: 1.5rem;
    color: #DD0303;
}

.filter-form {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
}

.form-row {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
}

.form-group label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #0f172a;
    font-size: 0.9rem;
}

input, select {
    width: 100%;
    padding: 0.75rem;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    color: #0f172a;
    font-family: 'Inter', sans-serif;
}

input:focus, select:focus {
    outline: none;
    border-color: #FA812F;
    box-shadow: 0 0 0 3px rgba(250, 177, 47, 0.30);
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
    margin-bottom: 2rem;
}

.stat-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 16px;
    padding: 1.5rem;
    display: flex;
    align-items: center;
    gap: 1rem;
    transition: all 0.3s ease;
}

.stat-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 20px 40px rgba(250, 129, 47, 0.14);
    border-color: rgba(250, 129, 47, 0.22);
}

.stat-icon {
    font-size: 2.5rem;
    width: 60px;
    height: 60px;
    display: flex;
    align-items: center;
    justify-content: center;
    background: rgba(250, 177, 47, 0.18);
    border-radius: 12px;
}

.stat-info h4 {
    font-size: 0.85rem;
    color: #94a3b8;
    font-weight: 600;
    margin-bottom: 0.5rem;
}

.stat-value {
    font-size: 1.5rem;
    font-weight: 800;
    color: #DD0303;
}

.card-header {
    padding: 1.5rem;
    border-bottom: 1px solid #e2e8f0;
}

.card-header h3 {
    color: #DD0303;
}

.table-container {
    overflow-x: auto;
}

table {
    width: 100%;
    border-collapse: collapse;
}

th {
    padding: 1rem 1.5rem;
    text-align: left;
    font-size: 0.75rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 1.5px;
    color: #DD0303;
    background: rgba(250, 177, 47, 0.18);
}

td {
    padding: 1rem 1.5rem;
    border-bottom: 1px solid #e2e8f0;
}

tr:hover td {
    background: rgba(250, 177, 47, 0.12);
}

.badge {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 6px;
    font-size: 0.85rem;
    background: rgba(250, 177, 47, 0.22);
    color: #DD0303;
    border: 1px solid rgba(250, 129, 47, 0.18);
}

.item-count {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 6px;
    background: rgba(250, 177, 47, 0.18);
    color: #FA812F;
    font-size: 0.85rem;
}

.amount, .total {
    font-weight: 700;
    color: #FA812F;
}

.discount {
    color: #FA812F;
}

.tax {
    color: #DD0303;
}

.details-row td {
    padding: 0;
    background: rgba(250, 177, 47, 0.12);
}

.details-content {
    padding: 1.5rem;
}

.details-content h4 {
    color: #DD0303;
    margin-bottom: 1rem;
}

.details-table {
    width: 100%;
    font-size: 0.9rem;
}

.details-table th {
    background: rgba(250, 177, 47, 0.14);
    font-size: 0.75rem;
}

.details-table td {
    padding: 0.75rem 1rem;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Inter', sans-serif;
    background: linear-gradient(180deg, #FEF3E2, #ffffff);
    color: #0f172a;
    min-height: 100vh;
}

.container {
    position: relative;
    z-index: 10;
    max-width: 1400px;
    margin: 0 auto;
    padding: 2rem;
}

@media print {
    body::before, .page-header button, .filter-card { display: none; }
    .card { border: 1px solid #000; }
}
</style>

<script>
// Tampilkan/sembunyikan baris detail item transaksi pada laporan
function toggleDetails(saleId) {
    const row = document.getElementById('details-' + saleId);
    if(row.style.display === 'none') {
        row.style.display = 'table-row';
    } else {
        row.style.display = 'none';
    }
}
</script>

</body>
</html>
