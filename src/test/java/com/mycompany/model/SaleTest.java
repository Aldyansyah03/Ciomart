package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Unit tests for Sale class
 */
public class SaleTest {
    
    private Sale sale;
    private Cashier cashier;
    
    @Before
    public void setUp() {
        cashier = new Cashier(1, "cashier001", "password", "CASHIER", "John");
        sale = new Sale(1, new BigDecimal("500.00"), cashier, LocalDateTime.now());
    }
    
    @Test
    public void testSaleCreation() {
        assertNotNull(sale);
        assertEquals(1, sale.getId());
        assertEquals(new BigDecimal("500.00"), sale.getTotal());
        assertEquals(cashier, sale.getCashier());
    }
    
    @Test
    public void testSaleGettersSetters() {
        sale.setId(2);
        sale.setTotal(new BigDecimal("750.00"));
        
        assertEquals(2, sale.getId());
        assertEquals(new BigDecimal("750.00"), sale.getTotal());
    }
    
    @Test
    public void testSaleTimestamp() {
        LocalDateTime timestamp = sale.getSaleDate();
        assertNotNull(timestamp);
    }
    
    @Test
    public void testSaleCashier() {
        Cashier newCashier = new Cashier(2, "cashier002", "password", "CASHIER", "Jane");
        sale.setCashier(newCashier);
        assertEquals(newCashier, sale.getCashier());
    }
}
