package com.mycompany.model;

import java.math.BigDecimal;

/**
 * Class CartItem - represents one item in shopping cart
 * Composition dengan Cart
 */
public class CartItem {
    private Product product;
    private int quantity;
    
    // Constructor
    public CartItem() {}
    
    public CartItem(Product product, int quantity) {
        this.product = product;
        this.quantity = quantity;
    }
    
    // Getters and Setters
    public Product getProduct() { return product; }
    public void setProduct(Product product) { this.product = product; }
    
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) {
        // Set kuantitas item (harus > 0)
        if (quantity <= 0) {
            throw new IllegalArgumentException("Quantity must be positive");
        }
        this.quantity = quantity;
    }
    
    // Business method
    public BigDecimal getSubtotal() {
        // Hitung subtotal item (qty * harga setelah diskon produk)
        // Subtotal sudah memperhitungkan diskon per-produk (jika ada)
        return product.getSubtotalWithDiscount(quantity);
    }
    
    public void addQuantity(int qty) {
        // Tambah kuantitas item (merge saat add ke cart)
        this.quantity += qty;
    }
}
