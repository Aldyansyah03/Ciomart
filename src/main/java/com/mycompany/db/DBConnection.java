/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */

/**
 *
 * @author Asus
 */
package com.mycompany.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    // Konfigurasi Database sesuai soal
    private static final String URL = "jdbc:mysql://localhost:3306/tokoku?allowPublicKeyRetrieval=true&useSSL=false";
    private static final String USER = "root";
    @SuppressWarnings({"java:S2068", "squid:S2068"}) // Development environment
    private static final String PASSWORD = ""; // Password kosong
    
    // Private constructor to prevent instantiation
    private DBConnection() {
        throw new UnsupportedOperationException("Utility class");
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }
    }
}