package com.mycompany.service;

/**
 * Custom exception for SaleService operations
 */
public class SaleServiceException extends Exception {
    
    public SaleServiceException(String message) {
        super(message);
    }
    
    public SaleServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}