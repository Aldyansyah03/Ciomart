package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for Cashier class
 */
public class CashierTest {
    
    private Cashier cashier;
    
    @Before
    public void setUp() {
        cashier = new Cashier(1, "cashier001", "hashedPassword456", "CASHIER", "Alice Johnson");
    }
    
    @Test
    public void testCashierCreation() {
        assertNotNull(cashier);
        assertEquals(1, cashier.getId());
        assertEquals("cashier001", cashier.getUsername());
        assertEquals("CASHIER", cashier.getRole());
        assertEquals("Alice Johnson", cashier.getFullName());
    }
    
    @Test
    public void testCashierGettersSetters() {
        cashier.setId(2);
        cashier.setUsername("cashier002");
        cashier.setFullName("Bob Wilson");
        
        assertEquals(2, cashier.getId());
        assertEquals("cashier002", cashier.getUsername());
        assertEquals("Bob Wilson", cashier.getFullName());
    }
    
    @Test
    public void testCashierAccessLevel() {
        assertEquals("TRANSACTION_ONLY", cashier.getAccessLevel());
    }
    
    @Test
    public void testCashierCheckPassword() {
        cashier.setPasswordHash("correctPassword");
        assertTrue(cashier.checkPassword("correctPassword"));
        assertFalse(cashier.checkPassword("wrongPassword"));
    }
    
    @Test
    public void testCashierRole() {
        assertEquals("CASHIER", cashier.getRole());
    }
}
