<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Database Connection</title>
</head>
<body>
    <h2>Test Koneksi Database</h2>
    <%
    try {
        Connection conn = DBConnection.getConnection();
        if(conn != null && !conn.isClosed()) {
            out.println("<p style='color:green;'>✅ <strong>KONEKSI BERHASIL!</strong></p>");
            out.println("<p>Database: tokoku</p>");
            out.println("<p>Connection: " + conn.toString() + "</p>");
            
            // Test query
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as total FROM users");
            if(rs.next()) {
                out.println("<p>Total users: " + rs.getInt("total") + "</p>");
            }
            rs.close();
            stmt.close();
            conn.close();
        }
    } catch(Exception e) {
        out.println("<p style='color:red;'>❌ <strong>KONEKSI GAGAL!</strong></p>");
        out.println("<p>Error: " + e.getMessage() + "</p>");
        out.println("<pre>");
        e.printStackTrace(new java.io.PrintWriter(out));
        out.println("</pre>");
    }
    %>
    
    <hr>
    <h3>Checklist:</h3>
    <ol>
        <li>✅ XAMPP MySQL harus running (hijau)</li>
        <li>✅ Database 'tokoku' harus ada</li>
        <li>✅ Tabel 'users' harus ada</li>
        <li>✅ Port MySQL = 3306</li>
    </ol>
</body>
</html>
