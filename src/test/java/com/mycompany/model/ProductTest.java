package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;
import java.math.BigDecimal;

/**
 * Unit tests for Product class
 */
public class ProductTest {
    
    private Product product;
    private Category category;
    
    @Before
    public void setUp() {
        category = new Category(1, "Electronics");
        product = new Product(1, "SKU001", "Laptop", category, new BigDecimal("999.99"), 10, "High-end laptop");
    }
    
    @Test
    public void testProductCreation() {
        assertNotNull(product);
        assertEquals(1, product.getId());
        assertEquals("SKU001", product.getSku());
        assertEquals("Laptop", product.getName());
    }
    
    @Test
    public void testProductGettersSetters() {
        product.setId(2);
        product.setSku("SKU002");
        product.setName("Desktop");
        product.setStock(5);
        
        assertEquals(2, product.getId());
        assertEquals("SKU002", product.getSku());
        assertEquals("Desktop", product.getName());
        assertEquals(5, product.getStock());
    }
    
    @Test
    @SuppressWarnings("java:S5778") // Single method call in lambda is intentional
    public void testSetNegativePrice() {
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, 
            () -> product.setPrice(new BigDecimal("-100")));
        assertNotNull(exception);
    }
    
    @Test
    @SuppressWarnings("java:S5778") // Single method call in lambda is intentional
    public void testSetNegativeStock() {
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, 
            () -> product.setStock(-5));
        assertNotNull(exception);
    }
    
    @Test
    public void testProductPrice() {
        product.setPrice(new BigDecimal("1500.00"));
        assertEquals(new BigDecimal("1500.00"), product.getPrice());
    }
    
    @Test
    public void testProductStock() {
        product.setStock(20);
        assertEquals(20, product.getStock());
    }
    
    @Test
    public void testProductCategory() {
        Category newCategory = new Category(2, "Books");
        product.setCategory(newCategory);
        assertEquals(newCategory, product.getCategory());
    }
    
    @Test
    public void testProductDiscountPercentage() {
        product.setDiscountPercentage(10);
        assertEquals(10, product.getDiscountPercentage());
    }
}
