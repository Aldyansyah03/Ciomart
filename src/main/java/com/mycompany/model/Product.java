package com.mycompany.model;

import com.mycompany.util.Constants;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Class Product - Aggregation dengan Category
 */
public class Product {
    private int id;
    private String sku;
    private String name;
    private Category category; // Aggregation
    private BigDecimal price;
    private int stock;
    private String description;
    private int discountPercentage; // Diskon produk dalam persen (0-100)
    
    // Constructor
    public Product() {}
    
    public Product(int id, String sku, String name, Category category, 
                   BigDecimal price, int stock, String description) {
        this.id = id;
        this.sku = sku;
        this.name = name;
        this.category = category;
        this.price = price;
        this.stock = stock;
        this.description = description;
    }
    
    // Encapsulation - Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public Category getCategory() { return category; }
    public void setCategory(Category category) { this.category = category; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) {
        if (price.compareTo(BigDecimal.ZERO) < 0) {
            throw new IllegalArgumentException("Price cannot be negative");
        }
        this.price = price;
    }
    
    public int getStock() { return stock; }
    public void setStock(int stock) {
        if (stock < 0) {
            throw new IllegalArgumentException("Stock cannot be negative");
        }
        this.stock = stock;
    }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public int getDiscountPercentage() { return discountPercentage; }
    public void setDiscountPercentage(int discountPercentage) {
        if (discountPercentage < Constants.MIN_DISCOUNT_PERCENTAGE || discountPercentage > Constants.MAX_DISCOUNT_PERCENTAGE) {
            throw new IllegalArgumentException("Discount must be between 0 and 100");
        }
        this.discountPercentage = discountPercentage;
    }
    
    // Business method
    public BigDecimal getSubtotal(int quantity) {
        // Hitung subtotal tanpa diskon per-produk
        return price.multiply(new BigDecimal(quantity));
    }
    
    // Hitung harga setelah diskon
    public BigDecimal getPriceAfterDiscount() {
        // Hitung harga satuan setelah diskon per-produk
        if (discountPercentage > 0) {
            BigDecimal discount = price.multiply(new BigDecimal(discountPercentage))
                                      .divide(new BigDecimal(100), 2, RoundingMode.HALF_UP);
            return price.subtract(discount);
        }
        return price;
    }
    
    // Hitung subtotal dengan diskon
    public BigDecimal getSubtotalWithDiscount(int quantity) {
        // Hitung subtotal setelah diskon per-produk
        return getPriceAfterDiscount().multiply(new BigDecimal(quantity));
    }
    
    public boolean isAvailable(int quantity) {
        // Cek stok cukup untuk quantity tertentu
        return stock >= quantity;
    }
    
    public void reduceStock(int quantity) {
        // Kurangi stok (validasi stok cukup)
        if (!isAvailable(quantity)) {
            throw new IllegalStateException("Insufficient stock");
        }
        this.stock -= quantity;
    }
    
    public void addStock(int quantity) {
        // Tambah stok produk
        this.stock += quantity;
    }
}
