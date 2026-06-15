package com.mycompany.model;

import java.math.BigDecimal;

/**
 * NoDiscount - Implementation of DiscountPolicy
 * Tidak ada diskon
 */
public class NoDiscount implements DiscountPolicy {
    
    @Override
    public BigDecimal apply(BigDecimal total) {
        return BigDecimal.ZERO;
    }
    
    @Override
    public String getDiscountType() {
        return "NO_DISCOUNT";
    }
}
