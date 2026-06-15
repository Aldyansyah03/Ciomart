package com.mycompany.repository;

import com.mycompany.model.*;
import com.mycompany.db.DBConnection;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * SaleRepository - Repository Pattern
 * Memisahkan logika akses data sale dari business logic
 */
public class SaleRepository {
    
    public SaleRepository() {
        // No initialization needed - repository uses static database connections via DBConnection
    }
    
    /**
     * Save new sale with items and update stock
     */
    public void save(Sale sale) throws SQLException {
        // Simpan transaksi (sales + sale_items) dan update stok dalam 1 DB transaction
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            if (conn == null) {
                throw new SQLException("Database connection is null");
            }
            conn.setAutoCommit(false); // Mulai transaksi
            
            // 1. Insert sale
            String sqlSale = "INSERT INTO sales (sale_number, cashier_id, subtotal, discount_type, " +
                           "discount_amount, tax_amount, total, cash_paid, cash_change) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            try (PreparedStatement psSale = conn.prepareStatement(sqlSale, Statement.RETURN_GENERATED_KEYS)) {
                psSale.setString(1, sale.getSaleNumber());
                psSale.setInt(2, sale.getCashier().getId());
                psSale.setBigDecimal(3, sale.getSubtotal());
                psSale.setString(4, sale.getDiscountType());
                psSale.setBigDecimal(5, sale.getDiscountAmount());
                psSale.setBigDecimal(6, sale.getTaxAmount());
                psSale.setBigDecimal(7, sale.getTotal());
                psSale.setBigDecimal(8, sale.getCashPaid());
                psSale.setBigDecimal(9, sale.getCashChange());
                psSale.executeUpdate();
                
                try (ResultSet rsKey = psSale.getGeneratedKeys()) {
                    if (rsKey.next()) {
                        sale.setId(rsKey.getInt(1));
                    }
                }
            }
            
            // 2. Insert sale items
            String sqlItem = "INSERT INTO sale_items (sale_id, product_id, product_name, " +
                           "product_price, quantity, subtotal) VALUES (?, ?, ?, ?, ?, ?)";
            
            // 3. Update stock (gunakan connection yang sama agar atomik & tidak membuka koneksi baru)
            String sqlStock = "UPDATE products SET stock = stock - ? WHERE id = ?";
            
            try (PreparedStatement psItem = conn.prepareStatement(sqlItem);
                 PreparedStatement psStock = conn.prepareStatement(sqlStock)) {
                
                for (CartItem item : sale.getItems()) {
                    psItem.setInt(1, sale.getId());
                    psItem.setInt(2, item.getProduct().getId());
                    psItem.setString(3, item.getProduct().getName());
                    psItem.setBigDecimal(4, item.getProduct().getPriceAfterDiscount());
                    psItem.setInt(5, item.getQuantity());
                    psItem.setBigDecimal(6, item.getSubtotal());
                    psItem.addBatch();

                    psStock.setInt(1, item.getQuantity());
                    psStock.setInt(2, item.getProduct().getId());
                    psStock.addBatch();
                }
                psItem.executeBatch();
                psStock.executeBatch();
            }
            
            conn.commit(); // Commit transaction
            
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException e) {
                    // Log exception when resetting autocommit during cleanup
                    e.printStackTrace();
                }
                conn.close();
            }
        }
    }
    
    /**
     * Find sale by ID with items
     */
    public Sale findById(int id) throws SQLException {
        // Ambil 1 transaksi beserta item-itemnya
        String sql = "SELECT s.*, u.username, u.full_name FROM sales s " +
                     "LEFT JOIN users u ON s.cashier_id = u.id " +
                     "WHERE s.id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            
            if (rs.next()) {
                Sale sale = mapResultSetToSale(rs);
                
                // Load items with proper resource management
                String sqlItems = "SELECT si.*, p.sku FROM sale_items si " +
                                "LEFT JOIN products p ON si.product_id = p.id " +
                                "WHERE si.sale_id = ?";
                try (PreparedStatement psItems = conn.prepareStatement(sqlItems)) {
                    psItems.setInt(1, id);
                    try (ResultSet rsItems = psItems.executeQuery()) {
                        while (rsItems.next()) {
                            sale.addItem(mapResultSetToCartItem(rsItems));
                        }
                    }
                }
                
                return sale;
            }
            return null;
        }
    }
    
    /**
     * Find all sales
     */
    public List<Sale> findAll() throws SQLException {
        // Ambil semua transaksi (tanpa detail item)
        List<Sale> sales = new ArrayList<>();
        String sql = "SELECT s.*, u.username, u.full_name FROM sales s " +
                     "LEFT JOIN users u ON s.cashier_id = u.id " +
                     "ORDER BY s.sale_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                sales.add(mapResultSetToSale(rs));
            }
        }
        return sales;
    }
    
    /**
     * Find sales by date range
     */
    public List<Sale> findByDateRange(LocalDateTime startDate, LocalDateTime endDate) throws SQLException {
        // Ambil transaksi dalam rentang tanggal
        List<Sale> sales = new ArrayList<>();
        String sql = "SELECT s.*, u.username, u.full_name FROM sales s " +
                     "LEFT JOIN users u ON s.cashier_id = u.id " +
                     "WHERE s.sale_date BETWEEN ? AND ? " +
                     "ORDER BY s.sale_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setTimestamp(1, Timestamp.valueOf(startDate));
            ps.setTimestamp(2, Timestamp.valueOf(endDate));
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                sales.add(mapResultSetToSale(rs));
            }
        }
        return sales;
    }
    
    /**
     * Map ResultSet to Sale object
     */
    private Sale mapResultSetToSale(ResultSet rs) throws SQLException {
        // Mapping row ResultSet -> object Sale
        Sale sale = new Sale();
        sale.setId(rs.getInt("id"));
        sale.setSaleNumber(rs.getString("sale_number"));
        sale.setSubtotal(rs.getBigDecimal("subtotal"));
        sale.setDiscountType(rs.getString("discount_type"));
        sale.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        sale.setTaxAmount(rs.getBigDecimal("tax_amount"));
        sale.setTotal(rs.getBigDecimal("total"));
        sale.setCashPaid(rs.getBigDecimal("cash_paid"));
        sale.setCashChange(rs.getBigDecimal("cash_change"));
        sale.setSaleDate(rs.getTimestamp("sale_date").toLocalDateTime());
        
        // Create cashier object (simplified)
        Cashier cashier = new Cashier();
        cashier.setId(rs.getInt("cashier_id"));
        cashier.setUsername(rs.getString("username"));
        cashier.setFullName(rs.getString("full_name"));
        sale.setCashier(cashier);
        
        return sale;
    }
    
    /**
     * Map ResultSet to CartItem object
     */
    private CartItem mapResultSetToCartItem(ResultSet rs) throws SQLException {
        // Mapping row sale_items -> CartItem (snapshot untuk histori)
        Product product = new Product();
        product.setId(rs.getInt("product_id"));
        product.setSku(rs.getString("sku"));
        product.setName(rs.getString("product_name"));
        product.setPrice(rs.getBigDecimal("product_price"));
        
        return new CartItem(product, rs.getInt("quantity"));
    }
}
