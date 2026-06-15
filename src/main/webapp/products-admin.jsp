<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%
// Cek akses admin
if(session.getAttribute("userId") == null || !"ADMIN".equals(session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

// Handle CRUD operations
String action = request.getParameter("action");
String message = null;

if("POST".equalsIgnoreCase(request.getMethod())){
    if("add".equals(action)){
        String sku = request.getParameter("sku");
        String name = request.getParameter("name");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        double price = Double.parseDouble(request.getParameter("price"));
        int stock = Integer.parseInt(request.getParameter("stock"));
        String description = request.getParameter("description");
        int discount = Integer.parseInt(request.getParameter("discount") != null && !request.getParameter("discount").isEmpty() ? request.getParameter("discount") : "0");
        
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO products (sku, name, category_id, price, stock, description, discount_percentage) VALUES (?, ?, ?, ?, ?, ?, ?)");
        ps.setString(1, sku);
        ps.setString(2, name);
        ps.setInt(3, categoryId);
        ps.setDouble(4, price);
        ps.setInt(5, stock);
        ps.setString(6, description);
        ps.setInt(7, discount);
        ps.executeUpdate();
        ps.close(); conn.close();
        message = "Produk berhasil ditambahkan!";
    }
    else if("edit".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        String sku = request.getParameter("sku");
        String name = request.getParameter("name");
        int categoryId = Integer.parseInt(request.getParameter("categoryId"));
        double price = Double.parseDouble(request.getParameter("price"));
        int stock = Integer.parseInt(request.getParameter("stock"));
        String description = request.getParameter("description");
        int discount = Integer.parseInt(request.getParameter("discount") != null && !request.getParameter("discount").isEmpty() ? request.getParameter("discount") : "0");
        
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE products SET sku=?, name=?, category_id=?, price=?, stock=?, description=?, discount_percentage=? WHERE id=?");
        ps.setString(1, sku);
        ps.setString(2, name);
        ps.setInt(3, categoryId);
        ps.setDouble(4, price);
        ps.setInt(5, stock);
        ps.setString(6, description);
        ps.setInt(7, discount);
        ps.setInt(8, id);
        ps.executeUpdate();
        ps.close(); conn.close();
        message = "Produk berhasil diupdate!";
    }
    else if("delete".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("DELETE FROM products WHERE id=?");
        ps.setInt(1, id);
        ps.executeUpdate();
        ps.close(); conn.close();
        message = "Produk berhasil dihapus!";
    }
}
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kelola Produk - CIOMART</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-style.css" %>
</style>
</head>
<body>

<%@ include file="admin-header.jsp" %>

<div class="container">
    <% if(message != null) { %>
    <div class="success-alert">
        <span>✅</span>
        <span><%= message %></span>
    </div>
    <% } %>

    <div class="page-header">
        <h2>📦 Kelola Produk</h2>
        <button class="btn btn-primary" onclick="showAddModal()">➕ Tambah Produk</button>
    </div>

    <div class="card">
        <div class="card-header">
            <input type="text" id="searchInput" class="search-input" placeholder="🔍 Cari produk..." onkeyup="filterTable()">
        </div>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>SKU</th>
                        <th>Nama Produk</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Diskon</th>
                        <th>Stok</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody id="productTable">
                <%
                Connection conn = DBConnection.getConnection();
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery(
                    "SELECT p.*, c.name as category_name FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id ORDER BY p.id DESC"
                );
                while(rs.next()){
                %>
                    <tr>
                        <td><span class="badge"><%= rs.getString("sku") %></span></td>
                        <td><%= rs.getString("name") %></td>
                        <td><%= rs.getString("category_name") %></td>
                        <td class="price">Rp <%= String.format("%,.0f", rs.getDouble("price")) %></td>
                        <td><span class="badge" style="background: <%= rs.getInt("discount_percentage") > 0 ? "linear-gradient(135deg, #FAB12F, #FA812F)" : "#6b7280" %>;"><%= rs.getInt("discount_percentage") %>%</span></td>
                        <td><span class="stock <%= rs.getInt("stock") < 20 ? "low" : "" %>"><%= rs.getInt("stock") %></span></td>
                        <td class="action">
                            <button class="btn-edit" onclick='editProduct(<%= rs.getInt("id") %>, "<%= rs.getString("sku") %>", "<%= rs.getString("name").replace("\"", "\\\"") %>", <%= rs.getInt("category_id") %>, <%= rs.getDouble("price") %>, <%= rs.getInt("stock") %>, "<%= rs.getString("description") != null ? rs.getString("description").replace("\"", "\\\"") : "" %>", <%= rs.getInt("discount_percentage") %>)'>✏️ Edit</button>
                            <button class="btn-delete" onclick="deleteProduct(<%= rs.getInt("id") %>, '<%= rs.getString("name").replace("'", "\\'") %>')">🗑️ Hapus</button>
                        </td>
                    </tr>
                <%
                }
                rs.close(); st.close(); conn.close();
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Add/Edit Modal -->
<div id="productModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle">Tambah Produk</h3>
            <button type="button" class="close" onclick="closeModal()" aria-label="Close">&times;</button>
        </div>
        <form id="productForm" method="post">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id" id="productId">
            
            <div class="form-group">
                <label for="sku">SKU *</label>
                <input type="text" name="sku" id="sku" required>
            </div>
            
            <div class="form-group">
                <label for="name">Nama Produk *</label>
                <input type="text" name="name" id="name" required>
            </div>
            
            <div class="form-group">
                <label for="categoryId">Kategori *</label>
                <select name="categoryId" id="categoryId" required>
                    <%
                    Connection conn2 = DBConnection.getConnection();
                    Statement st2 = conn2.createStatement();
                    ResultSet rs2 = st2.executeQuery("SELECT * FROM categories ORDER BY name");
                    while(rs2.next()){
                    %>
                    <option value="<%= rs2.getInt("id") %>"><%= rs2.getString("name") %></option>
                    <%
                    }
                    rs2.close(); st2.close(); conn2.close();
                    %>
                </select>
            </div>
            
            <div class="form-row">
                <div class="form-group">
                    <label for="price">Harga *</label>
                    <input type="number" name="price" id="price" required min="0" step="100">
                </div>
                
                <div class="form-group">
                    <label for="stock">Stok *</label>
                    <input type="number" name="stock" id="stock" required min="0">
                </div>
                
                <div class="form-group">
                    <label for="discount">Diskon (%) 🏷️</label>
                    <input type="number" name="discount" id="discount" min="0" max="100" value="0" placeholder="0-100">
                </div>
            </div>
            
            <div class="form-group">
                <label for="description">Deskripsi</label>
                <textarea name="description" id="description" rows="3"></textarea>
            </div>
            
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Batal</button>
                <button type="submit" class="btn btn-primary">💾 Simpan</button>
            </div>
        </form>
    </div>
</div>

<style>
.success-alert {
    background: rgba(250, 177, 47, 0.16);
    border: 1px solid rgba(250, 129, 47, 0.18);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1.5rem;
    color: #FA812F;
    display: flex;
    align-items: center;
    gap: 0.75rem;
}

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

.btn-secondary {
    background: rgba(250, 177, 47, 0.16);
    border: 1px solid rgba(250, 129, 47, 0.18);
    color: #DD0303;
}

.card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    padding: 0;
    backdrop-filter: none;
    box-shadow: 0 16px 40px rgba(2, 6, 23, 0.06);
}

.card-header {
    padding: 1.5rem;
    border-bottom: 1px solid #e2e8f0;
}

.search-input {
    width: 100%;
    max-width: 400px;
    padding: 0.75rem 1rem;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    color: #0f172a;
}

.search-input:focus {
    outline: none;
    border-color: #FA812F;
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

.price {
    font-weight: 700;
    color: #FA812F;
}

.stock {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 6px;
    background: rgba(250, 177, 47, 0.18);
    color: #FA812F;
}

.stock.low {
    background: rgba(221, 3, 3, 0.12);
    color: #DD0303;
}

.action {
    display: flex;
    gap: 0.5rem;
}

.btn-edit, .btn-delete {
    padding: 0.5rem 1rem;
    border-radius: 8px;
    border: 1px solid;
    cursor: pointer;
    font-size: 0.85rem;
    font-weight: 600;
}

.btn-edit {
    background: rgba(250, 177, 47, 0.16);
    border-color: rgba(250, 129, 47, 0.18);
    color: #DD0303;
}

.btn-edit:hover {
    background: rgba(250, 177, 47, 0.26);
}

.btn-delete {
    background: rgba(221, 3, 3, 0.08);
    border-color: rgba(221, 3, 3, 0.22);
    color: #DD0303;
}

.btn-delete:hover {
    background: rgba(221, 3, 3, 0.14);
}

.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(15, 23, 42, 0.25);
    backdrop-filter: blur(6px);
}

.modal-content {
    background: #ffffff;
    margin: 5% auto;
    padding: 0;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    width: 90%;
    max-width: 600px;
    box-shadow: 0 24px 70px rgba(2, 6, 23, 0.14);
}

.modal-header {
    padding: 1.5rem 2rem;
    border-bottom: 1px solid #e2e8f0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.modal-header h3 {
    margin: 0;
    color: #DD0303;
}

.close {
    font-size: 2rem;
    cursor: pointer;
    color: #94a3b8;
}

.close:hover {
    color: #0f172a;
}

.modal form {
    padding: 2rem;
}

.form-group {
    margin-bottom: 1.5rem;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 1rem;
}

label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #0f172a;
    font-size: 0.9rem;
}

input, select, textarea {
    width: 100%;
    padding: 0.75rem;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    color: #0f172a;
    font-family: 'Inter', sans-serif;
}

input:focus, select:focus, textarea:focus {
    outline: none;
    border-color: #FA812F;
    box-shadow: 0 0 0 3px rgba(250, 177, 47, 0.30);
}

.modal-footer {
    display: flex;
    gap: 1rem;
    justify-content: flex-end;
    padding-top: 1rem;
    border-top: 1px solid #e2e8f0;
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
</style>

<script>
// Tampilkan modal tambah produk dan reset form
function showAddModal() {
    document.getElementById('modalTitle').textContent = 'Tambah Produk';
    document.getElementById('formAction').value = 'add';
    document.getElementById('productForm').reset();
    document.getElementById('productModal').style.display = 'block';
}

// Tampilkan modal edit produk dan isi form berdasarkan data produk
function editProduct(id, sku, name, categoryId, price, stock, description, discount) {
    document.getElementById('modalTitle').textContent = 'Edit Produk';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('productId').value = id;
    document.getElementById('sku').value = sku;
    document.getElementById('name').value = name;
    document.getElementById('categoryId').value = categoryId;
    document.getElementById('price').value = price;
    document.getElementById('stock').value = stock;
    document.getElementById('description').value = description;
    document.getElementById('discount').value = discount || 0;
    document.getElementById('productModal').style.display = 'block';
}

// Hapus produk setelah konfirmasi
function deleteProduct(id, name) {
    if(confirm('Yakin ingin menghapus produk "' + name + '"?')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.innerHTML = '<input type="hidden" name="action" value="delete">' +
                         '<input type="hidden" name="id" value="' + id + '">';
        document.body.appendChild(form);
        form.submit();
    }
}

// Tutup modal produk
function closeModal() {
    document.getElementById('productModal').style.display = 'none';
}

// Saring tabel produk berdasarkan input pencarian
function filterTable() {
    const input = document.getElementById('searchInput');
    const filter = input.value.toLowerCase();
    const table = document.getElementById('productTable');
    const tr = table.getElementsByTagName('tr');
    
    for (let i = 0; i < tr.length; i++) {
        const td = tr[i].getElementsByTagName('td');
        let found = false;
        for (let j = 0; j < td.length; j++) {
            if (td[j].textContent.toLowerCase().indexOf(filter) > -1) {
                found = true;
                break;
            }
        }
        tr[i].style.display = found ? '' : 'none';
    }
}

// Tutup modal jika klik di area luar konten modal
window.onclick = function(event) {
    const modal = document.getElementById('productModal');
    if (event.target == modal) {
        closeModal();
    }
}
</script>

</body>
</html>
