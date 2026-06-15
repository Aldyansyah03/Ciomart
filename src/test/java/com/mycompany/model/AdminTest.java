package com.mycompany.model;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

/**
 * Unit tests for Admin class
 */
public class AdminTest {
    
    private Admin admin;
    
    @Before
    public void setUp() {
        admin = new Admin(1, "admin001", "hashedPassword123", "ADMIN", "John Doe");
    }
    
    @Test
    public void testAdminCreation() {
        assertNotNull(admin);
        assertEquals(1, admin.getId());
        assertEquals("admin001", admin.getUsername());
        assertEquals("ADMIN", admin.getRole());
        assertEquals("John Doe", admin.getFullName());
    }
    
    @Test
    public void testAdminGettersSetters() {
        admin.setId(2);
        admin.setUsername("admin002");
        admin.setFullName("Jane Smith");
        
        assertEquals(2, admin.getId());
        assertEquals("admin002", admin.getUsername());
        assertEquals("Jane Smith", admin.getFullName());
    }
    
    @Test
    public void testAdminAccessLevel() {
        assertEquals("FULL_ACCESS", admin.getAccessLevel());
    }
    
    @Test
    public void testAdminCheckPassword() {
        admin.setPasswordHash("correctPassword");
        assertTrue(admin.checkPassword("correctPassword"));
        assertFalse(admin.checkPassword("wrongPassword"));
    }
    
    @Test
    public void testAdminRole() {
        assertEquals("ADMIN", admin.getRole());
    }
}
