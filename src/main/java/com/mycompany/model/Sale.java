package com.mycompany.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/**
 * Class Sale - represents a completed transaction
 * Aggregation dengan User (Cashier)
 */
public class Sale {
    private int id;
    private String saleNumber;
    private User cashier; // Aggregation
    private List<CartItem> items; // Snapshot dari cart items
    private BigDecimal subtotal;
    private String discountType;
    private BigDecimal discountAmount;
    private BigDecimal taxAmount;
    private BigDecimal total;
    private BigDecimal cashPaid;
    private BigDecimal cashChange;
    private LocalDateTime saleDate;
    
    // Constructor
    public Sale() {
        this.items = new ArrayList<>();
        this.saleDate = LocalDateTime.now();
    }
    
    public Sale(int id, BigDecimal total, User cashier, LocalDateTime saleDate) {
        this.id = id;
        this.total = total;
        this.cashier = cashier;
        this.saleDate = saleDate;
        this.items = new ArrayList<>();
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getSaleNumber() { return saleNumber; }
    public void setSaleNumber(String saleNumber) { this.saleNumber = saleNumber; }
    
    public User getCashier() { return cashier; }
    public void setCashier(User cashier) { this.cashier = cashier; }
    
    public List<CartItem> getItems() { return items; }
    public void setItems(List<CartItem> items) { this.items = items; }
    
    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }
    
    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }
    
    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }
    
    public BigDecimal getTaxAmount() { return taxAmount; }
    public void setTaxAmount(BigDecimal taxAmount) { this.taxAmount = taxAmount; }
    
    public BigDecimal getTotal() { return total; }
    public void setTotal(BigDecimal total) { this.total = total; }
    
    public BigDecimal getCashPaid() { return cashPaid; }
    public void setCashPaid(BigDecimal cashPaid) { this.cashPaid = cashPaid; }
    
    public BigDecimal getCashChange() { return cashChange; }
    public void setCashChange(BigDecimal cashChange) { this.cashChange = cashChange; }
    
    public LocalDateTime getSaleDate() { return saleDate; }
    public void setSaleDate(LocalDateTime saleDate) { this.saleDate = saleDate; }
    
    public LocalDateTime getTimestamp() { return getSaleDate(); }
    
    // Business method
    public void addItem(CartItem item) {
        this.items.add(item);
    }
}
