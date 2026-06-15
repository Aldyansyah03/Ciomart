package com.mycompany.model;

import java.math.BigDecimal;

/**
 * Interface DiscountPolicy - Strategy Pattern & Polymorphism
 * Abstraction untuk berbagai strategi diskon
 */
public interface DiscountPolicy {
    BigDecimal apply(BigDecimal total);
    default BigDecimal applyDiscount(BigDecimal total) {
        return apply(total);
    }
    String getDiscountType();
}
