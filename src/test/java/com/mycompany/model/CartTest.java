package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;
import java.math.BigDecimal;
import java.util.List;

/**
 * Unit tests for Cart class
 */
public class CartTest {
    
    private Cart cart;
    private Product product;
    
    @Before
    public void setUp() {
        cart = new Cart();
        Category category = new Category(1, "Electronics");
        product = new Product(1, "SKU001", "Laptop", category, new BigDecimal("999.99"), 10, "High-end laptop");
    }
    
    @Test
    public void testCartCreation() {
        assertNotNull(cart);
    }
    
    @Test
    public void testAddItemToCart() {
        cart.addItem(product, 2);
        assertEquals(1, cart.getCartItems().size());
    }
    
    @Test
    public void testRemoveItemFromCart() {
        cart.addItem(product, 2);
        cart.removeItem(product.getSku());
        assertEquals(0, cart.getCartItems().size());
    }
    
    @Test
    public void testGetCartItems() {
        cart.addItem(product, 2);
        List<CartItem> items = cart.getCartItems();
        assertNotNull(items);
        assertEquals(1, items.size());
    }
    
    @Test
    public void testClearCart() {
        cart.addItem(product, 2);
        cart.clear();
        assertEquals(0, cart.getCartItems().size());
    }
    
    @Test
    public void testCalculateTotal() {
        cart.addItem(product, 2);
        BigDecimal total = cart.calculateTotal();
        assertNotNull(total);
    }
}
