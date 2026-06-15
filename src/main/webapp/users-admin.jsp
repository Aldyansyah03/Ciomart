<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%@ page import="java.security.MessageDigest" %>
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
        String username = request.getParameter("username").trim();
        String password = request.getParameter("password").trim();
        String fullName = request.getParameter("fullName").trim();
        String role = request.getParameter("role");
        
        // Hash password with SHA-256
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
        
        // Cek apakah username sudah ada
        PreparedStatement psCheck = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE username=?");
        psCheck.setString(1, username);
        ResultSet rsCheck = psCheck.executeQuery();
        rsCheck.next();
        if(rsCheck.getInt(1) > 0) {
            message = "Gagal! Username sudah digunakan.";
            rsCheck.close(); psCheck.close(); conn.close();
        } else {
            rsCheck.close(); psCheck.close();
            
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (username, password_hash, full_name, role) VALUES (?, ?, ?, ?)");
            ps.setString(1, username);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setString(4, role);
            ps.executeUpdate();
            ps.close(); conn.close();
            message = "User berhasil ditambahkan!";
        }
    }
    else if("edit".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        String username = request.getParameter("username").trim();
        String password = request.getParameter("password");
        String fullName = request.getParameter("fullName").trim();
        String role = request.getParameter("role");
        
        Connection conn = DBConnection.getConnection();
        
        try {
            // Cek apakah username sudah dipakai user lain
            PreparedStatement psCheck = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE username=? AND id!=?");
            psCheck.setString(1, username);
            psCheck.setInt(2, id);
            ResultSet rsCheck = psCheck.executeQuery();
            rsCheck.next();
            if(rsCheck.getInt(1) > 0) {
                message = "Gagal! Username sudah digunakan.";
                rsCheck.close(); psCheck.close();
            } else {
                rsCheck.close(); psCheck.close();
                
                if(password != null && password.trim().length() > 0) {
                    // Perbarui dengan password baru (buat hash dulu pakai SHA-256)
                    String cleanPassword = password.trim();
                    MessageDigest md = MessageDigest.getInstance("SHA-256");
                    byte[] hash = md.digest(cleanPassword.getBytes("UTF-8"));
                    StringBuilder hexString = new StringBuilder(hash.length * 2);
                    for (byte b : hash) {
                        String hex = Integer.toHexString(0xff & b);
                        if(hex.length() == 1) hexString.append('0');
                        hexString.append(hex);
                    }
                    String passwordHash = hexString.toString();
                    
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET username=?, password_hash=?, full_name=?, role=? WHERE id=?");
                    ps.setString(1, username);
                    ps.setString(2, passwordHash);
                    ps.setString(3, fullName);
                    ps.setString(4, role);
                    ps.setInt(5, id);
                    int updated = ps.executeUpdate();
                    ps.close();
                    
                    if(updated > 0) {
                        message = "User berhasil diupdate dengan password baru!";
                    } else {
                        message = "Gagal! User tidak ditemukan.";
                    }
                } else {
                    // Perbarui tanpa mengubah password
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE users SET username=?, full_name=?, role=? WHERE id=?");
                    ps.setString(1, username);
                    ps.setString(2, fullName);
                    ps.setString(3, role);
                    ps.setInt(4, id);
                    int updated = ps.executeUpdate();
                    ps.close();
                    
                    if(updated > 0) {
                        message = "User berhasil diupdate!";
                    } else {
                        message = "Gagal! User tidak ditemukan.";
                    }
                }
            }
        } catch(Exception e) {
            message = "Error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            conn.close();
        }
    }
    else if("delete".equals(action)){
        int id = Integer.parseInt(request.getParameter("id"));
        
        Connection conn = DBConnection.getConnection();
        
         // Cek apakah user punya transaksi
        PreparedStatement psCheck = conn.prepareStatement("SELECT COUNT(*) FROM sales WHERE cashier_id=?");
        psCheck.setInt(1, id);
        ResultSet rsCheck = psCheck.executeQuery();
        rsCheck.next();
        int salesCount = rsCheck.getInt(1);
        rsCheck.close(); psCheck.close();
        
        if(salesCount > 0) {
            message = "Gagal! User ini memiliki " + salesCount + " transaksi.";
        } else {
            PreparedStatement ps = conn.prepareStatement("DELETE FROM users WHERE id=?");
            ps.setInt(1, id);
            ps.executeUpdate();
            ps.close();
            message = "User berhasil dihapus!";
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
<title>Kelola User - CIOMART</title>
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
        <h2>👥 Kelola User</h2>
        <button class="btn btn-primary" onclick="showAddModal()">➕ Tambah User</button>
    </div>

    <div class="card">
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>Username</th>
                        <th>Nama Lengkap</th>
                        <th>Role</th>
                        <th>Total Transaksi</th>
                        <th>Aksi</th>
                    </tr>
                </thead>
                <tbody>
                <%
                Connection conn = DBConnection.getConnection();
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery(
                    "SELECT u.*, COUNT(s.id) as sales_count " +
                    "FROM users u " +
                    "LEFT JOIN sales s ON u.id = s.cashier_id " +
                    "GROUP BY u.id ORDER BY u.role, u.full_name"
                );
                while(rs.next()){
                %>
                    <tr>
                        <td><span class="badge"><%= rs.getString("username") %></span></td>
                        <td><%= rs.getString("full_name") %></td>
                        <td><span class="role-badge <%= rs.getString("role").toLowerCase() %>"><%= rs.getString("role") %></span></td>
                        <td>
                            <% if("ADMIN".equalsIgnoreCase(rs.getString("role"))) { %>
                                —
                            <% } else { %>
                                <%= rs.getInt("sales_count") %> transaksi
                            <% } %>
                        </td>
                        <td class="action">
                            <button class="btn-edit" onclick='editUser(<%= rs.getInt("id") %>, "<%= rs.getString("username") %>", "<%= rs.getString("full_name").replace("\"", "\\\"") %>", "<%= rs.getString("role") %>")'>✏️ Edit</button>
                            <button class="btn-delete" onclick="deleteUser(<%= rs.getInt("id") %>, '<%= rs.getString("username") %>', <%= rs.getInt("sales_count") %>)">🗑️ Hapus</button>
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
<div id="userModal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 id="modalTitle">Tambah User</h3>
            <button type="button" class="close" onclick="closeModal()" aria-label="Close">&times;</button>
        </div>
        <form id="userForm" method="post">
            <input type="hidden" name="action" id="formAction" value="add">
            <input type="hidden" name="id" id="userId">
            
            <div class="form-group">
                <label for="username">Username *</label>
                <input type="text" name="username" id="username" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password <span id="passwordHint">*</span></label>
                <input type="password" name="password" id="password" required>
                <small id="passwordNote" style="display:none; color: #94a3b8;">Kosongkan jika tidak ingin mengubah password</small>
            </div>
            
            <div class="form-group">
                <label for="fullName">Nama Lengkap *</label>
                <input type="text" name="fullName" id="fullName" required>
            </div>
            
            <div class="form-group">
                <label for="role">Role *</label>
                <select name="role" id="role" required>
                    <option value="ADMIN">Admin</option>
                    <option value="CASHIER">Kasir</option>
                </select>
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

.card {
    background: #ffffff;
    border: 1px solid #e2e8f0;
    border-radius: 20px;
    padding: 0;
    backdrop-filter: none;
    box-shadow: 0 16px 40px rgba(2, 6, 23, 0.06);
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
    font-weight: 600;
}

.role-badge {
    display: inline-block;
    padding: 0.35rem 0.85rem;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

.role-badge.admin {
    background: rgba(250, 177, 47, 0.22);
    color: #0f172a;
    border: 1px solid rgba(250, 177, 47, 0.28);
}

.role-badge.cashier {
    background: rgba(250, 129, 47, 0.14);
    color: #FA812F;
    border: 1px solid rgba(250, 129, 47, 0.22);
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
// Tampilkan modal tambah user dan reset form
function showAddModal() {
    document.getElementById('modalTitle').textContent = 'Tambah User';
    document.getElementById('formAction').value = 'add';
    document.getElementById('userForm').reset();
    document.getElementById('password').required = true;
    document.getElementById('passwordHint').textContent = '*';
    document.getElementById('passwordNote').style.display = 'none';
    document.getElementById('userModal').style.display = 'block';
}

// Tampilkan modal edit user dan isi form berdasarkan data user
function editUser(id, username, fullName, role) {
    document.getElementById('modalTitle').textContent = 'Edit User';
    document.getElementById('formAction').value = 'edit';
    document.getElementById('userId').value = id;
    document.getElementById('username').value = username;
    document.getElementById('password').value = '';
    document.getElementById('password').required = false;
    document.getElementById('passwordHint').textContent = '';
    document.getElementById('passwordNote').style.display = 'block';
    document.getElementById('fullName').value = fullName;
    document.getElementById('role').value = role;
    document.getElementById('userModal').style.display = 'block';
}

// Hapus user (dengan validasi: tidak boleh jika masih punya transaksi)
function deleteUser(id, username, salesCount) {
    if(salesCount > 0) {
        alert('Tidak dapat menghapus! User "' + username + '" memiliki ' + salesCount + ' transaksi.');
        return;
    }
    
    if(confirm('Yakin ingin menghapus user "' + username + '"?')) {
        const form = document.createElement('form');
        form.method = 'POST';
        form.innerHTML = '<input type="hidden" name="action" value="delete">' +
                         '<input type="hidden" name="id" value="' + id + '">';
        document.body.appendChild(form);
        form.submit();
    }
}

// Tutup modal user
function closeModal() {
    document.getElementById('userModal').style.display = 'none';
}

// Tutup modal jika klik di area luar konten modal
window.onclick = function(event) {
    const modal = document.getElementById('userModal');
    if (event.target == modal) {
        closeModal();
    }
}
</script>

</body>
</html>
