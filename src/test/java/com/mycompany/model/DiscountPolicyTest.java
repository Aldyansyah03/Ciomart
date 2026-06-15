package com.mycompany.model;

import org.junit.Test;
import static org.junit.Assert.*;
import java.math.BigDecimal;

/**
 * Unit tests for Discount policies
 */
public class DiscountPolicyTest {
    
    @Test
    public void testNoDiscountPolicy() {
        DiscountPolicy noDiscount = new NoDiscount();
        BigDecimal amount = new BigDecimal("100.00");
        BigDecimal result = noDiscount.applyDiscount(amount);
        // NoDiscount returns 0 discount amount
        assertEquals(0, BigDecimal.ZERO.compareTo(result));
    }
    
    @Test
    public void testPercentageDiscountPolicy() {
        DiscountPolicy percentDiscount = new PercentageDiscount(20); // 20% discount
        BigDecimal amount = new BigDecimal("100.00");
        BigDecimal result = percentDiscount.applyDiscount(amount);
        // 20% of 100 = 20 discount amount
        assertEquals(0, new BigDecimal("20.00").compareTo(result));
    }
    
    @Test
    public void testPercentageDiscountPolicyZero() {
        DiscountPolicy percentDiscount = new PercentageDiscount(0);
        BigDecimal amount = new BigDecimal("100.00");
        BigDecimal result = percentDiscount.applyDiscount(amount);
        // 0% discount = 0 discount amount
        assertEquals(0, BigDecimal.ZERO.compareTo(result));
    }
    
    @Test
    public void testPercentageDiscountPolicyFull() {
        DiscountPolicy percentDiscount = new PercentageDiscount(100);
        BigDecimal amount = new BigDecimal("100.00");
        BigDecimal result = percentDiscount.applyDiscount(amount);
        // 100% of 100 = 100 discount amount
        assertEquals(0, new BigDecimal("100.00").compareTo(result));
    }
}
