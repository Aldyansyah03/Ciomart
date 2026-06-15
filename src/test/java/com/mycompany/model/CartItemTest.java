package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;
import java.math.BigDecimal;

/**
 * Unit tests for CartItem class
 */
public class CartItemTest {
    
    private CartItem cartItem;
    private Product product;
    
    @Before
    public void setUp() {
        Category category = new Category(1, "Electronics");
        product = new Product(1, "SKU001", "Laptop", category, new BigDecimal("999.99"), 10, "High-end laptop");
        cartItem = new CartItem(product, 2);
    }
    
    @Test
    public void testCartItemCreation() {
        assertNotNull(cartItem);
        assertEquals(product, cartItem.getProduct());
        assertEquals(2, cartItem.getQuantity());
    }
    
    @Test
    public void testCartItemGettersSetters() {
        cartItem.setQuantity(5);
        assertEquals(5, cartItem.getQuantity());
    }
    
    @Test
    public void testCartItemProduct() {
        Category newCategory = new Category(2, "Books");
        Product newProduct = new Product(2, "SKU002", "Book", newCategory, new BigDecimal("29.99"), 50, "Technical book");
        cartItem.setProduct(newProduct);
        assertEquals(newProduct, cartItem.getProduct());
    }
    
    @Test
    public void testCartItemSubtotal() {
        BigDecimal subtotal = cartItem.getSubtotal();
        assertNotNull(subtotal);
    }
}
