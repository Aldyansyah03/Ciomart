<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.mycompany.db.DBConnection" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.mycompany.model.*" %>
<%@ page import="com.mycompany.service.SaleService" %>
<%@ page import="com.mycompany.repository.*" %>
<%
if(session.getAttribute("userId") == null || !"CASHIER".equals(session.getAttribute("role"))){
    response.sendRedirect("login.jsp");
    return;
}

String fullName = (String) session.getAttribute("fullName");
Integer userId = (Integer) session.getAttribute("userId");
String username = (String) session.getAttribute("username");

if("POST".equalsIgnoreCase(request.getMethod()) && "checkout".equals(request.getParameter("action"))){
    try {
        String cartData = request.getParameter("cartData");
        BigDecimal cashPaid = new BigDecimal(request.getParameter("cashPaid"));
        
        ProductRepository productRepo = new ProductRepository();
        SaleRepository saleRepo = new SaleRepository();
        Cart cart = new Cart();
        
        String[] items = cartData.split("\\|");
        for(String item : items){
            String[] parts = item.split(",");
            Product product = productRepo.findById(Integer.parseInt(parts[0]));
            if(product != null) {
                cart.addItem(product, Integer.parseInt(parts[3]));
            }
        }
        
        Cashier cashier = new Cashier();
        cashier.setId(userId);
        cashier.setUsername(username);
        cashier.setFullName(fullName);
        
        // Diskon transaksi TIDAK bisa di-set oleh kasir.
        // Diskon hanya berasal dari diskon per-produk yang diatur admin.
        DiscountPolicy discountPolicy = new NoDiscount();
        
        SaleService saleService = new SaleService(productRepo, saleRepo);
        Sale sale = saleService.processCheckout(cart, discountPolicy, cashier, cashPaid);

        // Simpan info transaksi terakhir untuk cetak struk
        session.setAttribute("lastSaleId", sale.getId());
        session.setAttribute("lastSaleNumber", sale.getSaleNumber());
        session.setAttribute("lastSaleCashier", fullName);
        session.setAttribute("successMessage", "Transaksi berhasil! Nomor: " + sale.getSaleNumber());

        // Arahkan ke halaman struk (bisa dicetak)
        response.sendRedirect("transaction.jsp?action=receipt&saleId=" + sale.getId());
        return;
    } catch(Exception e){
        session.setAttribute("errorMessage", "Error: " + e.getMessage());
        e.printStackTrace();
    }
}

// Tampilkan struk berdasarkan parameter action
String action = request.getParameter("action");
if("receipt".equals(action)){
    try {
        String saleIdParam = request.getParameter("saleId");
        int saleId = saleIdParam != null ? Integer.parseInt(saleIdParam) : 0;
        if(saleId <= 0){
            throw new Exception("Sale ID tidak valid");
        }

        SaleRepository saleRepo = new SaleRepository();
        Sale sale = saleRepo.findById(saleId);
        if(sale == null){
            throw new Exception("Transaksi tidak ditemukan");
        }

        // Halaman struk yang ramah untuk dicetak
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Struk - CIOMART</title>
    <style>
        body { font-family: Arial, sans-serif; background: #ffffff; color: #111827; padding: 24px; }
        .paper { max-width: 420px; margin: 0 auto; border: 1px solid #e5e7eb; border-radius: 10px; padding: 18px; }
        .title { text-align: center; font-weight: 800; font-size: 18px; margin-bottom: 4px; }
        .sub { text-align: center; color: #6b7280; font-size: 12px; margin-bottom: 14px; }
        .row { display:flex; justify-content: space-between; gap: 10px; font-size: 13px; margin: 6px 0; }
        .hr { border-top: 1px dashed #d1d5db; margin: 12px 0; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th, td { padding: 6px 0; border-bottom: 1px dotted #e5e7eb; vertical-align: top; }
        th { text-align: left; color: #6b7280; font-weight: 700; }
        .right { text-align: right; }
        .total { font-weight: 900; font-size: 14px; }
        .actions { max-width: 420px; margin: 14px auto 0; display:flex; gap: 10px; justify-content: space-between; }
        .btn { padding: 10px 14px; border-radius: 8px; border: 1px solid #d1d5db; background: #ffffff; cursor: pointer; font-weight: 700; }
        .btn-primary { border-color: #FA812F; background: #FA812F; color: #ffffff; }
        @media print {
            .actions { display: none; }
            body { padding: 0; }
            .paper { border: none; border-radius: 0; }
        }
    </style>
</head>
<body>
    <div class="paper">
        <div class="title">CIOMART</div>
        <div class="sub">Struk Transaksi</div>

        <div class="row"><span>No. Transaksi</span><span><%= sale.getSaleNumber() %></span></div>
        <div class="row"><span>Tanggal</span><span><%= sale.getSaleDate() != null ? sale.getSaleDate().toString().replace('T',' ') : "-" %></span></div>
        <div class="row"><span>Kasir</span><span><%= sale.getCashier() != null ? sale.getCashier().getFullName() : "-" %></span></div>

        <div class="hr"></div>

        <table>
            <thead>
                <tr>
                    <th>Item</th>
                    <th class="right">Qty</th>
                    <th class="right">Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <% for(CartItem it : sale.getItems()) { %>
                <tr>
                    <td>
                        <div style="font-weight:700;"><%= it.getProduct().getName() %></div>
                        <div style="color:#6b7280; font-size:12px;">@ Rp <%= String.format("%,.0f", it.getProduct().getPrice()) %></div>
                    </td>
                    <td class="right"><%= it.getQuantity() %></td>
                    <td class="right">Rp <%= String.format("%,.0f", it.getSubtotal()) %></td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <div class="hr"></div>

        <div class="row"><span>Subtotal</span><span>Rp <%= String.format("%,.0f", sale.getSubtotal()) %></span></div>
        <div class="row"><span>Diskon</span><span>- Rp <%= String.format("%,.0f", sale.getDiscountAmount()) %></span></div>
        <div class="row"><span>PPN 10%</span><span>Rp <%= String.format("%,.0f", sale.getTaxAmount()) %></span></div>
        <div class="row total"><span>TOTAL</span><span>Rp <%= String.format("%,.0f", sale.getTotal()) %></span></div>

        <div class="hr"></div>

        <div class="row"><span>Tunai</span><span>Rp <%= String.format("%,.0f", sale.getCashPaid()) %></span></div>
        <div class="row"><span>Kembalian</span><span>Rp <%= String.format("%,.0f", sale.getCashChange()) %></span></div>

        <div class="hr"></div>
        <div class="sub">Terima kasih telah berbelanja</div>
    </div>

    <div class="actions">
        <button class="btn" onclick="location.href='transaction.jsp'">Kembali</button>
        <button class="btn btn-primary" onclick="window.print()">Cetak</button>
    </div>
</body>
</html>
<%
        return;
    } catch(Exception e){
        session.setAttribute("errorMessage", "Error: " + e.getMessage());
        response.sendRedirect("transaction.jsp");
        return;
    }
}

String successMsg = (String) session.getAttribute("successMessage");
if(successMsg != null) session.removeAttribute("successMessage");

String errorMsg = (String) session.getAttribute("errorMessage");
if(errorMsg != null) session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Transaksi - CIOMART</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: Arial, sans-serif;
            background: #FEF3E2;
            color: #0f172a;
            padding: 20px;
        }
        
        .header {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .btn {
            padding: 10px 20px;
            background: #FA812F;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            border: none;
            cursor: pointer;
        }
        
        .btn:hover { background: #DD0303; }
        
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .alert-success { background: #FAB12F; color: #0f172a; }
        .alert-error { background: #DD0303; color: white; }
        
        .grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 20px;
        }
        
        .card {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 20px;
            border-radius: 10px;
        }
        
        .card h3 {
            color: #DD0303;
            margin-bottom: 15px;
        }
        
        .products {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 10px;
            max-height: 400px;
            overflow-y: auto;
        }

        .product-filter {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 12px;
        }

        .product-filter label {
            font-weight: 700;
            color: #0f172a;
            font-size: 0.95em;
        }

        .product-filter select {
            width: auto;
            min-width: 220px;
        }
        
        .product {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            padding: 15px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .product:hover {
            background: #f1f5f9;
            transform: translateY(-2px);
            box-shadow: 0 10px 24px rgba(204, 86, 30, 0.18);
        }
        
        .product-name { font-weight: bold; margin-bottom: 5px; }
        .product-category { color: #64748b; font-size: 0.85em; margin-bottom: 6px; }
        .product-price { color: #FA812F; font-weight: bold; }
        .product-stock { color: #475569; font-size: 0.9em; }
        
        .cart-item {
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .qty-control {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        
        .qty-btn {
            width: 30px;
            height: 30px;
            background: #FA812F;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }
        
        .summary {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 2px solid #e2e8f0;
        }
        
        .summary-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
        }
        
        .summary-row.total {
            font-size: 1.2em;
            font-weight: bold;
            color: #DD0303;
        }
        
        input, select {
            width: 100%;
            padding: 10px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 5px;
            color: #0f172a;
            margin: 5px 0;
        }
        
        .btn-checkout {
            width: 100%;
            padding: 15px;
            background: #DD0303;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
        }
        
        .btn-checkout:disabled {
            background: #6b7280;
            cursor: not-allowed;
        }
        
        .empty {
            text-align: center;
            padding: 40px;
            color: #94a3b8;
        }
    </style>
</head>
<body>

<div class="header">
    <div>
        <h2>🛍️ Transaksi Penjualan - CIOMART</h2>
        <p>Kasir: <%= fullName %></p>
    </div>
    <a href="cashier-dashboard.jsp" class="btn">← Kembali</a>
</div>

<% if(successMsg != null) { %>
<div class="alert alert-success">✅ <%= successMsg %></div>
<% } %>

<% if(errorMsg != null) { %>
<div class="alert alert-error">❌ <%= errorMsg %></div>
<% } %>

<div class="grid">
    <div class="card">
        <h3>📦 Pilih Produk</h3>

        <div class="product-filter">
            <label for="categoryFilter">Kategori:</label>
            <select id="categoryFilter" onchange="filterProductsByCategory()">
                <option value="ALL">Semua Kategori</option>
                <%
                try {
                    Connection connCatFilter = DBConnection.getConnection();
                    Statement stCatFilter = connCatFilter.createStatement();
                    ResultSet rsCatFilter = stCatFilter.executeQuery("SELECT id, name FROM categories ORDER BY name");
                    while (rsCatFilter.next()) {
                %>
                    <option value="<%= rsCatFilter.getInt("id") %>"><%= rsCatFilter.getString("name") %></option>
                <%
                    }
                    rsCatFilter.close();
                    stCatFilter.close();
                    connCatFilter.close();
                } catch (Exception e) {
                    // Abaikan error saat memuat penyaringan
                }
                %>
            </select>
        </div>

        <div class="products">
            <%
            try {
                Connection conn = DBConnection.getConnection();
                Statement st = conn.createStatement();
                ResultSet rs = st.executeQuery(
                    "SELECT p.*, c.name as category_name FROM products p " +
                    "LEFT JOIN categories c ON p.category_id = c.id " +
                    "WHERE p.stock > 0 ORDER BY p.name"
                );
                
                while(rs.next()){
                    int discount = rs.getInt("discount_percentage");
                    double originalPrice = rs.getDouble("price");
                    double finalPrice = discount > 0 ? originalPrice * (100 - discount) / 100 : originalPrice;
                    String productName = rs.getString("name");
                    String safeDataName = productName == null ? "" : productName
                            .replace("&", "&amp;")
                            .replace("\"", "&quot;")
                            .replace("<", "&lt;")
                            .replace(">", "&gt;");
            %>
            <div class="product"
                 data-id="<%= rs.getInt("id") %>"
                 data-name="<%= safeDataName %>"
                 data-price="<%= originalPrice %>"
                 data-stock="<%= rs.getInt("stock") %>"
                 data-discount="<%= discount %>"
                 data-category-id="<%= rs.getInt("category_id") %>"
                 onclick="addToCartFromEl(this)">
                <div class="product-name"><%= rs.getString("name") %></div>
                <div class="product-category"><%= rs.getString("category_name") != null ? rs.getString("category_name") : "-" %></div>
                <% if(discount > 0) { %>
                <div style="text-decoration: line-through; color: #94a3b8; font-size: 0.85em;">Rp <%= String.format("%,d", (int)originalPrice) %></div>
                <div class="product-price" style="display: flex; align-items: center; gap: 5px;">
                    Rp <%= String.format("%,d", (int)finalPrice) %>
                    <span style="background: #FA812F; color: white; padding: 2px 6px; border-radius: 4px; font-size: 0.75em; font-weight: bold;"><%= discount %>%</span>
                </div>
                <% } else { %>
                <div class="product-price">Rp <%= String.format("%,d", (int)originalPrice) %></div>
                <% } %>
                <div class="product-stock">Stok: <%= rs.getInt("stock") %></div>
            </div>
            <%
                }
                rs.close();
                st.close();
                conn.close();
            } catch(Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            }
            %>
        </div>
    </div>
    
    <div class="card">
        <h3>🛒 Keranjang</h3>
        <div id="cartItems">
            <div class="empty">
                <p style="font-size: 3em;">🛒</p>
                <p>Keranjang kosong</p>
            </div>
        </div>
        
        <div id="summary" style="display:none;">
            <div class="summary">
                <div class="summary-row">
                    <span>Subtotal:</span>
                    <span id="subtotal">Rp 0</span>
                </div>

                        <div class="summary-row" style="padding-top: 0;">
                            <span style="color:#475569;">Diskon (otomatis dari produk):</span>
                            <span style="color:#475569;">—</span>
                        </div>
                
                <div class="summary-row">
                    <span>Potongan:</span>
                    <span id="discount">Rp 0</span>
                </div>
                
                <div class="summary-row">
                    <span>PPN 10%:</span>
                    <span id="tax">Rp 0</span>
                </div>
                
                <div class="summary-row total">
                    <span>TOTAL:</span>
                    <span id="total">Rp 0</span>
                </div>
                
                <label>Uang Dibayar:</label>
                <input type="number" id="cashPaid" oninput="calculateChange()" placeholder="Masukkan jumlah uang">
                
                <div class="summary-row" id="changeRow" style="display:none; color:#FA812F;">
                    <span>Kembalian:</span>
                    <span id="change">Rp 0</span>
                </div>
                
                <button class="btn-checkout" id="btnCheckout" onclick="checkout()" disabled>
                    💰 Proses Pembayaran
                </button>
            </div>
        </div>
    </div>
</div>

<form id="checkoutForm" method="post" style="display:none;">
    <input type="hidden" name="action" value="checkout">
    <input type="hidden" name="cartData" id="cartData">
    <input type="hidden" name="cashPaid" id="hdnCashPaid">
</form>

<script>
var cart = [];

// Tambah produk ke keranjang menggunakan data-* dari elemen kartu produk
function addToCartFromEl(el) {
    if(!el || !el.dataset) return;
    var id = parseInt(el.dataset.id, 10);
    var name = el.dataset.name || '';
    var price = parseFloat(el.dataset.price) || 0;
    var stock = parseInt(el.dataset.stock, 10) || 0;
    var discount = parseInt(el.dataset.discount, 10) || 0;
    addToCart(id, name, price, stock, discount);
}

// Saring kartu produk berdasarkan kategori yang dipilih
function filterProductsByCategory() {
    var select = document.getElementById('categoryFilter');
    if(!select) return;
    var selected = select.value;

    var cards = document.querySelectorAll('.products .product');
    for(var i = 0; i < cards.length; i++) {
        var card = cards[i];
        var cardCatId = (card.dataset && card.dataset.categoryId) ? String(card.dataset.categoryId) : '';
        if(selected === 'ALL' || selected === cardCatId) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    }
}

// Tambah item ke keranjang (gabungkan jumlah jika produk sudah ada)
function addToCart(id, name, originalPrice, maxStock, discount) {
    discount = discount || 0;
    originalPrice = parseFloat(originalPrice) || 0;
    var price = originalPrice;
    if(discount > 0) {
        price = originalPrice * (100 - discount) / 100;
    }
    var existing = cart.find(function(item) { return item.id === id; });
    if(existing) {
        if(existing.qty < maxStock) {
            existing.qty++;
        } else {
            alert('Stok tidak cukup!');
            return;
        }
    } else {
        cart.push({ id: id, name: name, price: price, originalPrice: originalPrice, qty: 1, maxStock: maxStock, discount: discount });
    }
    updateCart();
}

// Ubah kuantitas item di keranjang (+/-)
function updateQty(id, change) {
    var item = cart.find(function(i) { return i.id === id; });
    if(item) {
        var newQty = item.qty + change;
        if(newQty > 0 && newQty <= item.maxStock) {
            item.qty = newQty;
            updateCart();
        } else if(newQty <= 0) {
            removeItem(id);
        }
    }
}

// Hapus item dari keranjang
function removeItem(id) {
    cart = cart.filter(function(item) { return item.id !== id; });
    updateCart();
}

// Tampilkan ulang keranjang + ringkasan
function updateCart() {
    var cartDiv = document.getElementById('cartItems');
    var summaryDiv = document.getElementById('summary');
    
    if(cart.length === 0) {
        cartDiv.innerHTML = '<div class="empty"><p style="font-size: 3em;">🛒</p><p>Keranjang kosong</p></div>';
        summaryDiv.style.display = 'none';
        return;
    }
    
    var html = '';
    for(var i = 0; i < cart.length; i++) {
        var item = cart[i];
        var subtotal = item.price * item.qty;
        html += '<div class="cart-item">';
        html += '<div>';
        html += '<div style="font-weight:bold;">' + item.name + '</div>';
        html += '<div style="color:#94a3b8;">@Rp ' + formatNumber(item.price);
        if(item.discount > 0) {
            html += ' <span style="background:#FA812F;color:white;padding:2px 6px;border-radius:4px;font-size:0.7em;font-weight:bold;">' + item.discount + '%</span>';
        }
        html += '</div>';
        html += '</div>';
        html += '<div class="qty-control">';
        html += '<button class="qty-btn" onclick="updateQty(' + item.id + ', -1)">-</button>';
        html += '<span>' + item.qty + '</span>';
        html += '<button class="qty-btn" onclick="updateQty(' + item.id + ', 1)">+</button>';
        html += '</div>';
        html += '<div style="color:#FA812F; font-weight:bold;">Rp ' + formatNumber(subtotal) + '</div>';
        html += '<button class="btn" style="background:#DD0303; padding:5px 10px;" onclick="removeItem(' + item.id + ')">🗑️</button>';
        html += '</div>';
    }
    
    cartDiv.innerHTML = html;
    summaryDiv.style.display = 'block';
    updateTotal();
}

// Hitung subtotal/diskon/pajak/total (diskon hanya dari produk yang di-set admin)
function updateTotal() {
    // Subtotal sebelum diskon produk
    var subtotalBeforeProductDiscount = 0;
    // Subtotal setelah diskon produk
    var subtotalAfterProductDiscount = 0;
    for(var i = 0; i < cart.length; i++) {
        subtotalBeforeProductDiscount += (cart[i].originalPrice || cart[i].price) * cart[i].qty;
        subtotalAfterProductDiscount += cart[i].price * cart[i].qty;
    }
    var productDiscountAmount = subtotalBeforeProductDiscount - subtotalAfterProductDiscount;
    if(productDiscountAmount < 0) productDiscountAmount = 0;

    // Diskon transaksi tidak ada (hanya diskon per-produk dari admin)
    var totalDiscountAmount = productDiscountAmount;
    var afterDiscount = subtotalAfterProductDiscount;
    var taxAmount = afterDiscount * 0.10;
    var total = afterDiscount + taxAmount;
    
    document.getElementById('subtotal').textContent = 'Rp ' + formatNumber(subtotalBeforeProductDiscount);
    document.getElementById('discount').textContent = '- Rp ' + formatNumber(totalDiscountAmount);
    document.getElementById('tax').textContent = 'Rp ' + formatNumber(taxAmount);
    document.getElementById('total').textContent = 'Rp ' + formatNumber(total);
    
    window.currentTotal = total;
    calculateChange();
}

// Hitung kembalian dan enable/disable tombol checkout
function calculateChange() {
    var cashPaid = parseFloat(document.getElementById('cashPaid').value) || 0;
    var total = window.currentTotal || 0;
    var change = cashPaid - total;
    
    var changeRow = document.getElementById('changeRow');
    var btnCheckout = document.getElementById('btnCheckout');
    
    if(change >= 0 && cashPaid > 0) {
        changeRow.style.display = 'flex';
        document.getElementById('change').textContent = 'Rp ' + formatNumber(change);
        btnCheckout.disabled = false;
    } else {
        changeRow.style.display = 'none';
        btnCheckout.disabled = true;
    }
}

// Kirim form checkout (POST) untuk diproses server
function checkout() {
    var btn = document.getElementById('btnCheckout');
    if(btn && btn.dataset && btn.dataset.submitted === '1') {
        return;
    }
    if(cart.length === 0) {
        alert('Keranjang masih kosong!');
        return;
    }
    
    var cartData = '';
    for(var i = 0; i < cart.length; i++) {
        var item = cart[i];
        if(i > 0) cartData += '|';
        cartData += item.id + ',' + item.name + ',' + item.price + ',' + item.qty + ',' + (item.price * item.qty);
    }
    
    document.getElementById('cartData').value = cartData;
    document.getElementById('hdnCashPaid').value = document.getElementById('cashPaid').value;
    
    if(confirm('Proses pembayaran sebesar Rp ' + formatNumber(window.currentTotal) + '?')) {
        btn.disabled = true;
        btn.textContent = '⏳ Memproses...';
        btn.dataset.submitted = '1';
        document.getElementById('checkoutForm').submit();
    }
}

// Format angka jadi format rupiah sederhana (ribuan dengan titik)
function formatNumber(num) {
    return Math.round(num).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

console.log('Transaction page loaded');
</script>

</body>
</html>
