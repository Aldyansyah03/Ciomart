package com.mycompany.model;

import com.mycompany.util.Constants;

/**
 * Class Cashier - Inheritance dari User
 * Memiliki akses untuk melakukan transaksi penjualan
 */
public class Cashier extends User {
    
    public Cashier() {
        super();
    }
    
    public Cashier(int id, String username, String passwordHash, String fullName) {
        super(id, username, passwordHash, Constants.ROLE_CASHIER, fullName);
    }
    
    public Cashier(int id, String username, String passwordHash, String role, String fullName) {
        super(id, username, passwordHash, role, fullName);
    }
    
    @Override
    public String getAccessLevel() {
        return Constants.ACCESS_LEVEL_TRANSACTION;
    }
    
    // Method khusus Cashier
    public boolean canProcessTransaction() {
        return true;
    }
    
    public boolean canPrintReceipt() {
        return true;
    }
}
