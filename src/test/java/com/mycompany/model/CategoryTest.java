package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for Category class
 */
public class CategoryTest {
    
    private Category category;
    
    @Before
    public void setUp() {
        category = new Category(1, "Electronics");
    }
    
    @Test
    public void testCategoryCreation() {
        assertNotNull(category);
        assertEquals(1, category.getId());
        assertEquals("Electronics", category.getName());
    }
    
    @Test
    public void testCategoryGettersSetters() {
        category.setId(2);
        category.setName("Books");
        
        assertEquals(2, category.getId());
        assertEquals("Books", category.getName());
    }
    
    @Test
    public void testCategoryDefaultConstructor() {
        Category emptyCategory = new Category();
        assertNotNull(emptyCategory);
    }
    
    @Test
    public void testSetCategoryName() {
        category.setName("Furniture");
        assertEquals("Furniture", category.getName());
    }
}
