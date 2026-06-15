package com.mycompany.model;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Class Cart - Composition dengan CartItem
 */
public class Cart {
    private final List<CartItem> items;
    
    // Constructor
    public Cart() {
        this.items = new ArrayList<>();
    }
    
    // Getters - return unmodifiable list for defensive copy
    public List<CartItem> getItems() { 
        return Collections.unmodifiableList(items); 
    }
    
    public List<CartItem> getCartItems() { 
        return Collections.unmodifiableList(items); 
    }
    
    // Business methods
    public void addItem(Product product, int quantity) {
        // Tambah item ke keranjang (merge jika produk sudah ada)
        // Check if product already exists in cart
        for (CartItem item : items) {
            if (item.getProduct().getId() == product.getId()) {
                item.addQuantity(quantity);
                return;
            }
        }
        // If not exists, add new item
        items.add(new CartItem(product, quantity));
    }
    
    public void removeItem(String sku) {
        // Hapus item dari keranjang berdasarkan SKU
        items.removeIf(item -> item.getProduct().getSku().equals(sku));
    }
    
    public void updateQuantity(String sku, int quantity) {
        // Ubah kuantitas item berdasarkan SKU
        for (CartItem item : items) {
            if (item.getProduct().getSku().equals(sku)) {
                item.setQuantity(quantity);
                return;
            }
        }
    }
    
    public BigDecimal getSubtotal() {
        // Hitung subtotal keranjang (sudah memperhitungkan diskon per-produk)
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            total = total.add(item.getSubtotal());
        }
        return total;
    }

    /**
     * Subtotal sebelum diskon per-produk (gross subtotal).
     * Ini penting untuk pelaporan diskon agar diskon produk ikut terhitung.
     */
    public BigDecimal getSubtotalBeforeProductDiscount() {
        // Hitung subtotal sebelum diskon per-produk (gross)
        BigDecimal total = BigDecimal.ZERO;
        for (CartItem item : items) {
            Product product = item.getProduct();
            total = total.add(product.getSubtotal(item.getQuantity()));
        }
        return total;
    }
    
    public int getTotalItems() {
        // Hitung total kuantitas semua item di keranjang
        return items.stream().mapToInt(CartItem::getQuantity).sum();
    }
    
    public void clear() {
        // Kosongkan isi keranjang
        items.clear();
    }
    
    public boolean isEmpty() {
        // Cek apakah keranjang kosong
        return items.isEmpty();
    }
    
    public BigDecimal calculateTotal() {
        return getSubtotal();
    }
}
