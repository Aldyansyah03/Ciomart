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
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO categories (name, description) VALUES (?, ?)");
        ps.setString(1, name);
        ps.setString(2, description);
        ps.executeUpdate();
        ps.close(); conn.close();
        message = "Kategori berhasil ditambahkan!";
    }
    else if("edit".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        String name = request.getParameter("name");
        String description = request.getParameter("description");
        
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE categories SET name=?, description=? WHERE id=?");
        ps.setString(1, name);
        ps.setString(2, description);
        ps.setInt(3, id);
        ps.executeUpdate();
        ps.close(); conn.close();
        message = "Kategori berhasil diupdate!";
    }
    else if("delete".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        
        // Cek apakah kategori masih memiliki produk
        Connection conn = DBConnection.getConnection();
        PreparedStatement psCheck = conn.prepareStatement("SELECT COUNT(*) FROM products WHERE category_id=?");
        psCheck.setInt(1, id);
        ResultSet rsCheck = psCheck.executeQuery();
        rsCheck.next();
        int productCount = rsCheck.getInt(1);
        rsCheck.close(); psCheck.close();
        
        if(productCount > 0) {
            message = "Gagal! Kategori masih memiliki " + productCount + " produk.";
        } else {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM categories WHERE id=?");
            ps.setInt(1, id);
            ps.executeUpdate();
            ps.close();
            message = "Kategori berhasil dihapus!";
        }
        conn.close();
    }
}
%>
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Kelola Kategori - CIOMART</title>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
<style>
<%@ include file="admin-style.css" %>
</style>
</head>
<body>

<%@ include file="admin-header.jsp" %>

<div class="container">
    <% if(message != null) { %>
    <div class="<%= message.startsWith("Gagal") ? "error-alert" : "success-alert" %>">
        <span><%= message.startsWith("Gagal") ? "❌" : "✅" %></span>
        <span><%= message %></span>
    </div>
    <% } %>

    <div class="page-header">
        <h2>🏷️ Kelola Kategori</h2>
        <button class="btn btn-primary" onclick="showAddModal()">➕ Tambah Kategori</button>
    </div>

    <div class="category-grid">
        <%
        Connection conn = DBConnection.getConnection();
        Statement st = conn.createStatement();
        ResultSet rs = st.executeQuery(
            "SELECT c.*, COUNT(p.id) as product_count FROM categories c " +
            "LEFT JOIN products p ON c.id = p.category_id " +
            "GROUP BY c.id ORDER BY c.name"
        );
        while(rs.next()){
        %>
        <div class="category-card">
            <div class="category-header">
                <h3><%= rs.getString("name") %></h3>
                <span class="product-count"><%= rs.getInt("product_count") %> produk</span>
            </div>
            <p class="category-desc"><%= rs.getString("description") != null ? rs.getString("description") : "Tidak ada deskripsi" %></p>
            <div class="category-actions">
                <button class="btn-edit" onclick='editCategory(<%= rs.getInt("id") %>, "<%= rs.getString("name").replace("\"", "\\\"") %>", "<%= rs.getString("description") != null ? rs.getString("description").replace("\"", "\\\"") : "" %>")'>✏️ Edit</button>
                <button class="btn-delete" onclick="deleteCategory(<%= rs.getInt("id") %>, '<%= rs.getString("name").replace("'", "\\'") %>', <%= rs.getInt("product_count") %>)">🗑️ Hapus</button>
            </div>
        </div>
        <%
        }
        rs.close(); st.close(); conn.close();
        %>
    </div>
</div>

<!-- Add/Edit Modal -->
<div id="categoryModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle">Tambah Kategori</h3>
            <button type="button" class="close" onclick="closeModal()" aria-label="Close">&times;</button>
        </div>
        <form id="categoryForm" method="post">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id" id="categoryId">
            
            <div class="form-group">
                <label for="name">Nama Kategori *</label>
                <input type="text" name="name" id="name" required>
            </div>
            
            <div class="form-group">
                <label for="description">Deskripsi</label>
                <textarea name="description" id="description" rows="4"></textarea>
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

.error-alert {
    background: rgba(221, 3, 3, 0.08);
    border: 1px solid rgba(221, 3, 3, 0.22);
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1.5rem;
    color: #DD0303;
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

.category-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
    gap: 1.5rem;
}

.category-card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 16px;
    padding: 1.5rem;
    transition: all 0.3s ease;
    backdrop-filter: none;
    box-shadow: 0 16px 40px rgba(2, 6, 23, 0.06);
}

.category-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 20px 40px rgba(250, 129, 47, 0.14);
    border-color: rgba(250, 129, 47, 0.22);
}

.category-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
}

.category-header h3 {
    font-size: 1.25rem;
    font-weight: 700;
    color: #DD0303;
}

.product-count {
    background: rgba(250, 177, 47, 0.22);
    color: #FA812F;
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.85rem;
    font-weight: 600;
}

.category-desc {
    color: #475569;
    margin-bottom: 1.5rem;
    min-height: 3rem;
    line-height: 1.5;
}

.category-actions {
    display: flex;
    gap: 0.5rem;
}

.btn-edit, .btn-delete {
    flex: 1;
    padding: 0.625rem;
    border-radius: 8px;
    border: 1px solid;
    cursor: pointer;
    font-size: 0.85rem;
    font-weight: 600;
    transition: all 0.3s ease;
}

.btn-edit {
    background: rgba(250, 177, 47, 0.16);
    border-color: rgba(250, 129, 47, 0.18);
    color: #DD0303;
}

.btn-edit:hover {
    background: rgba(250, 177, 47, 0.26);
    transform: translateY(-2px);
}

.btn-delete {
    background: rgba(221, 3, 3, 0.08);
    border-color: rgba(221, 3, 3, 0.22);
    color: #DD0303;
}

.btn-delete:hover {
    background: rgba(221, 3, 3, 0.14);
    transform: translateY(-2px);
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
    margin: 10% auto;
    padding: 0;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    width: 90%;
    max-width: 500px;
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

label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 600;
    color: #0f172a;
    font-size: 0.9rem;
}

input, textarea {
    width: 100%;
    padding: 0.75rem;
    background: #ffffff;
    border: 1px solid #cbd5e1;
    border-radius: 10px;
    color: #0f172a;
    font-family: 'Inter', sans-serif;
}

input:focus, textarea:focus {
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
// Tampilkan modal tambah kategori dan reset form
function showAddModal() {
    document.getElementById('modalTitle').textContent = 'Tambah Kategori';
    document.getElementById('formAction').value = 'add';
    document.getElementById('categoryForm').reset();
    document.getElementById('categoryModal').style.display = 'block';
}

// Tampilkan modal edit kategori dan isi form berdasarkan data kategori
function editCategory(id, name, description) {
    document.getElementById('modalTitle').textContent = 'Edit Kategori';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('categoryId').value = id;
    document.getElementById('name').value = name;
    document.getElementById('description').value = description;
    document.getElementById('categoryModal').style.display = 'block';
}

// Hapus kategori (dengan validasi: tidak boleh jika masih ada produk)
function deleteCategory(id, name, productCount) {
    if(productCount > 0) {
        alert('Tidak dapat menghapus! Kategori "' + name + '" masih memiliki ' + productCount + ' produk.');
        return;
    }
    
    if(confirm('Yakin ingin menghapus kategori "' + name + '"?')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.innerHTML = '<input type="hidden" name="action" value="delete">' +
                         '<input type="hidden" name="id" value="' + id + '">';
        document.body.appendChild(form);
        form.submit();
    }
}

// Tutup modal kategori
function closeModal() {
    document.getElementById('categoryModal').style.display = 'none';
}

// Tutup modal jika klik di area luar konten modal
window.onclick = function(event) {
    const modal = document.getElementById('categoryModal');
    if (event.target == modal) {
        closeModal();
    }
}
</script>

</body>
</html>
