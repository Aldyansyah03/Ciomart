package com.mycompany.model;

import com.mycompany.util.Constants;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * PercentageDiscount - Implementation of DiscountPolicy
 * Diskon berdasarkan persentase
 */
public class PercentageDiscount implements DiscountPolicy {
    private final BigDecimal rate; // dalam persen (contoh: 10 untuk 10%)
    
    // Constructor dengan int (untuk kemudahan penggunaan)
    public PercentageDiscount(int rate) {
        this(new BigDecimal(rate));
    }
    
    // Constructor dengan BigDecimal (untuk presisi)
    public PercentageDiscount(BigDecimal rate) {
        if (rate.compareTo(BigDecimal.ZERO) < 0 || rate.compareTo(new BigDecimal(Constants.MAX_DISCOUNT_PERCENTAGE)) > 0) {
            throw new IllegalArgumentException("Discount rate must be between 0 and 100");
        }
        this.rate = rate;
    }
    
    @Override
    public BigDecimal apply(BigDecimal total) {
        return total.multiply(rate)
                   .divide(new BigDecimal(100), 2, RoundingMode.HALF_UP);
    }
    
    @Override
    public String getDiscountType() {
        return "PERCENTAGE_" + rate.intValue() + "%";
    }
    
    public BigDecimal getRate() {
        return rate;
    }
}
