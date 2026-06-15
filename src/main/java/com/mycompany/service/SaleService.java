package com.mycompany.service;

import com.mycompany.model.*;
import com.mycompany.repository.ProductRepository;
import com.mycompany.repository.SaleRepository;
import com.mycompany.util.Constants;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;

/**
 * SaleService - Facade Pattern
 * Menyederhanakan proses checkout dengan menyembunyikan kompleksitas
 * subsistem (stock check, discount, payment, record sale)
 */
public class SaleService {
    
    /**
     * Parameter object to encapsulate sale calculation data
     */
    private static class SaleCalculation {
        BigDecimal subtotal;
        BigDecimal discountAmount;
        BigDecimal taxAmount;
        BigDecimal total;
        BigDecimal cashPaid;
        BigDecimal cashChange;
        
        SaleCalculation(BigDecimal subtotal, BigDecimal discountAmount, BigDecimal taxAmount,
                       BigDecimal total, BigDecimal cashPaid, BigDecimal cashChange) {
            this.subtotal = subtotal;
            this.discountAmount = discountAmount;
            this.taxAmount = taxAmount;
            this.total = total;
            this.cashPaid = cashPaid;
            this.cashChange = cashChange;
        }
    }
    
    private final ProductRepository productRepo;
    private final SaleRepository saleRepo;
    
    public SaleService(ProductRepository productRepo, SaleRepository saleRepo) {
        this.productRepo = productRepo;
        this.saleRepo = saleRepo;
    }
    
    /**
     * Process checkout - Facade method yang menyembunyikan detail implementasi
     * @param cart Shopping cart
     * @param discountPolicy Strategy pattern untuk diskon
     * @param cashier User yang melakukan transaksi
     * @param cashPaid Jumlah uang yang dibayarkan
     * @return Sale object yang telah disimpan
     * @throws SaleServiceException jika stok tidak cukup atau validasi gagal
     */
    public Sale processCheckout(Cart cart, DiscountPolicy discountPolicy, User cashier, BigDecimal cashPaid) throws SaleServiceException {
        try {
            // 1. Validasi cart tidak kosong
            if (cart.isEmpty()) {
                throw new SaleServiceException("Keranjang belanja kosong");
            }
            
            // 2. Validasi stok produk
            validateStock(cart);
            
            // 3. Hitung subtotal
            BigDecimal subtotalGross = cart.getSubtotalBeforeProductDiscount();
            BigDecimal subtotalNet = cart.getSubtotal();

            // 4. Apply discount strategy
            BigDecimal transactionDiscount = discountPolicy.apply(subtotalNet);

            // Total diskon
            BigDecimal productDiscount = subtotalGross.subtract(subtotalNet);
            if (productDiscount.compareTo(BigDecimal.ZERO) < 0) {
                productDiscount = BigDecimal.ZERO;
            }
            BigDecimal discountAmount = productDiscount.add(transactionDiscount);

            // 5. Hitung pajak
            BigDecimal afterDiscount = subtotalGross.subtract(discountAmount);
            BigDecimal taxAmount = afterDiscount.multiply(Constants.TAX_RATE).setScale(2, RoundingMode.HALF_UP);
            
            // 6. Hitung total akhir
            BigDecimal total = afterDiscount.add(taxAmount);
            
            // 7. Validasi pembayaran
            if (cashPaid.compareTo(total) < 0) {
                throw new SaleServiceException("Uang tidak cukup. Total: Rp " + total + ", Dibayar: Rp " + cashPaid);
            }
            
            // 8. Hitung kembalian
            BigDecimal cashChange = cashPaid.subtract(total);
            
            // 9. Buat objek Sale
            SaleCalculation calculation = new SaleCalculation(subtotalGross, discountAmount, taxAmount, total, cashPaid, cashChange);
            Sale sale = createSale(cart, discountPolicy, cashier, calculation);
            
            // 10. Simpan sale ke database
            saleRepo.save(sale);
            
            // 11. Clear cart
            cart.clear();
            
            return sale;
            
        } catch (SQLException e) {
            throw new SaleServiceException("Database error: " + e.getMessage(), e);
        }
    }
    
    /**
     * Validasi stok untuk semua item di cart
     */
    private void validateStock(Cart cart) throws SaleServiceException, SQLException {
        for (CartItem item : cart.getItems()) {
            Product product = productRepo.findById(item.getProduct().getId());
            if (product == null) {
                throw new SaleServiceException("Produk " + item.getProduct().getName() + " tidak ditemukan");
            }
            if (product.getStock() < item.getQuantity()) {
                throw new SaleServiceException("Stok " + product.getName() + " tidak cukup. Tersedia: " + product.getStock());
            }
        }
    }
    
    /**
     * Create Sale object dengan snapshot cart items
     */
    private Sale createSale(Cart cart, DiscountPolicy discountPolicy, User cashier, SaleCalculation calculation) {
        Sale sale = new Sale();
        sale.setSaleNumber("TRX" + System.currentTimeMillis());
        sale.setCashier(cashier);
        sale.setSubtotal(calculation.subtotal);
        sale.setDiscountType(discountPolicy.getClass().getSimpleName());
        sale.setDiscountAmount(calculation.discountAmount);
        sale.setTaxAmount(calculation.taxAmount);
        sale.setTotal(calculation.total);
        sale.setCashPaid(calculation.cashPaid);
        sale.setCashChange(calculation.cashChange);
        
        // Copy cart items
        for (CartItem cartItem : cart.getItems()) {
            CartItem snapshot = new CartItem(cartItem.getProduct(), cartItem.getQuantity());
            sale.addItem(snapshot);
        }
        
        return sale;
    }
    
    public BigDecimal calculateDiscount(BigDecimal subtotal, DiscountPolicy discountPolicy) {
        return discountPolicy.apply(subtotal);
    }
    
    public BigDecimal calculateTax(BigDecimal subtotal, BigDecimal discountAmount) {
        BigDecimal afterDiscount = subtotal.subtract(discountAmount);
        return afterDiscount.multiply(Constants.TAX_RATE).setScale(2, RoundingMode.HALF_UP);
    }
    
    public BigDecimal calculateTotal(BigDecimal subtotal, BigDecimal discountAmount, BigDecimal taxAmount) {
        return subtotal.subtract(discountAmount).add(taxAmount);
    }
}