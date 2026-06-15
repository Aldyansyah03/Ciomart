package com.mycompany.util;

import java.math.BigDecimal;

/**
 * Constants class untuk menyimpan konstanta yang digunakan di aplikasi
 */
public final class Constants {
    
    // Private constructor to prevent instantiation
    private Constants() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }
    
    // Tax rate constants
    public static final BigDecimal TAX_RATE = new BigDecimal("0.10"); // PPN 10%
    
    // Discount percentage bounds
    public static final int MIN_DISCOUNT_PERCENTAGE = 0;
    public static final int MAX_DISCOUNT_PERCENTAGE = 100;
    
    // User roles
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_CASHIER = "CASHIER";
    
    // Discount types
    public static final String DISCOUNT_TYPE_NONE = "NONE";
    public static final String DISCOUNT_TYPE_PERCENTAGE = "PERCENTAGE";
    public static final String DISCOUNT_TYPE_FIXED = "FIXED";
    
    // Access levels
    public static final String ACCESS_LEVEL_FULL = "FULL_ACCESS";
    public static final String ACCESS_LEVEL_TRANSACTION = "TRANSACTION_ONLY";
}
