-- Menambahkan fitur diskon per produk
-- Jalankan di phpMyAdmin atau MySQL Workbench

USE tokoku;

-- Tambah kolom discount_percentage ke tabel products
ALTER TABLE products 
ADD COLUMN discount_percentage INT DEFAULT 0 COMMENT 'Diskon produk dalam persen (0-100)';

-- Update beberapa produk dengan diskon untuk testing
UPDATE products SET discount_percentage = 10 WHERE id = 1;
UPDATE products SET discount_percentage = 15 WHERE id = 2;
UPDATE products SET discount_percentage = 5 WHERE id = 3;
