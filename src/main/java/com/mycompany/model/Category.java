package com.mycompany.model;

/**
 * Class Category - untuk pengelompokan produk
 */
public class Category {
    private int id;
    private String name;
    private String description;
    
    // Constructor
    public Category() {}
    
    public Category(int id, String name) {
        this.id = id;
        this.name = name;
    }
    
    public Category(int id, String name, String description) {
        this.id = id;
        this.name = name;
        this.description = description;
    }
    
    // Encapsulation - Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    @Override
    public String toString() {
        return name;
    }
}
