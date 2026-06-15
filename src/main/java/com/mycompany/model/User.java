package com.mycompany.model;

/**
 * Abstract class User - Abstraction & Inheritance
 * Base class untuk Admin dan Cashier
 */
public abstract class User {
    protected int id;
    protected String username;
    protected String passwordHash;
    protected String role;
    protected String fullName;
    
    // Constructor
    protected User() {}
    
    protected User(int id, String username, String passwordHash, String role, String fullName) {
        this.id = id;
        this.username = username;
        this.passwordHash = passwordHash;
        this.role = role;
        this.fullName = fullName;
    }
    
    // Encapsulation - Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    
    // Method untuk validasi password
    // Note: This should use proper password hashing comparison
    public boolean checkPassword(String plainPassword) {
        if (plainPassword == null || this.passwordHash == null) {
            return false;
        }
        return this.passwordHash.equals(plainPassword);
    }
    
    // Abstract method - harus diimplementasikan oleh subclass
    public abstract String getAccessLevel();
}
