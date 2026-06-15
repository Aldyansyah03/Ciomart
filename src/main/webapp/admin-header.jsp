<%
String __uri = request.getRequestURI();
String __page = __uri != null ? __uri.substring(__uri.lastIndexOf('/') + 1) : "";
%>

<nav class="navbar">
    <div class="nav-brand">
        <span class="brand-text">CIOMART</span>
    </div>
    <div class="nav-menu">
        <a href="admin-dashboard.jsp" class="nav-link <%= "admin-dashboard.jsp".equals(__page) ? "active" : "" %>">Dashboard</a>
        <a href="products-admin.jsp" class="nav-link <%= "products-admin.jsp".equals(__page) ? "active" : "" %>">Produk</a>
        <a href="categories-admin.jsp" class="nav-link <%= "categories-admin.jsp".equals(__page) ? "active" : "" %>">Kategori</a>
        <a href="reports-admin.jsp" class="nav-link <%= "reports-admin.jsp".equals(__page) ? "active" : "" %>">Laporan</a>
        <a href="users-admin.jsp" class="nav-link <%= "users-admin.jsp".equals(__page) ? "active" : "" %>">User</a>
    </div>
    <div class="nav-user">
        <span class="user-name"><%= session.getAttribute("fullName") %></span>
        <a href="logout.jsp" class="btn-logout">Keluar</a>
    </div>
</nav>
