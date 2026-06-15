package com.mycompany.model;

import com.mycompany.util.Constants;

/**
 * Class Admin - Inheritance dari User
 * Memiliki akses penuh untuk mengelola produk dan melihat laporan
 */
public class Admin extends User {
    
    public Admin() {
        super();
    }
    
    public Admin(int id, String username, String passwordHash, String fullName) {
        super(id, username, passwordHash, Constants.ROLE_ADMIN, fullName);
    }
    
    public Admin(int id, String username, String passwordHash, String role, String fullName) {
        super(id, username, passwordHash, role, fullName);
    }
    
    @Override
    public String getAccessLevel() {
        return Constants.ACCESS_LEVEL_FULL;
    }
    
    // Method khusus Admin
    public boolean canManageProducts() {
        return true;
    }
    
    public boolean canViewReports() {
        return true;
    }
    
    public boolean canManageUsers() {
        return true;
    }
}
