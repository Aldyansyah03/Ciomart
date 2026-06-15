-- MINIMART Database Schema
-- Aplikasi Manajemen Kasir Mini Market

-- Gunakan database tokoku yang sudah ada
USE tokoku;

-- Table: users (untuk Admin dan Cashier)
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'CASHIER') NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: categories (untuk kategori produk)
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: products (produk/barang)
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(15,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- Table: sales (transaksi penjualan)
CREATE TABLE sales (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sale_number VARCHAR(50) UNIQUE NOT NULL,
    cashier_id INT NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    discount_type VARCHAR(50),
    discount_amount DECIMAL(15,2) DEFAULT 0,
    tax_amount DECIMAL(15,2) DEFAULT 0,
    total DECIMAL(15,2) NOT NULL,
    cash_paid DECIMAL(15,2) NOT NULL,
    cash_change DECIMAL(15,2) NOT NULL,
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cashier_id) REFERENCES users(id)
);

-- Table: sale_items (detail item per transaksi)
CREATE TABLE sale_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    product_price DECIMAL(15,2) NOT NULL,
    quantity INT NOT NULL,
    subtotal DECIMAL(15,2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- Insert default users
INSERT INTO users (username, password_hash, role, full_name) VALUES
('admin', 'admin123', 'ADMIN', 'Administrator'),
('kasir1', 'kasir123', 'CASHIER', 'Kasir 1'),
('kasir2', 'kasir123', 'CASHIER', 'Kasir 2');

-- Insert default categories
INSERT INTO categories (name, description) VALUES
('Makanan', 'Produk makanan dan snack'),
('Minuman', 'Produk minuman dan beverage'),
('Kebutuhan Rumah Tangga', 'Produk keperluan rumah tangga'),
('Elektronik', 'Produk elektronik dan gadget'),
('Kesehatan', 'Produk kesehatan dan obat-obatan');

-- Insert sample products
INSERT INTO products (sku, name, category_id, price, stock) VALUES
('SKU001', 'Indomie Goreng', 1, 3500, 100),
('SKU002', 'Aqua 600ml', 2, 4000, 150),
('SKU003', 'Sabun Lifebuoy', 3, 5500, 80),
('SKU004', 'Baterai AA', 4, 15000, 50),
('SKU005', 'Paracetamol', 5, 8000, 60),
('SKU006', 'Chitato Rasa Sapi Panggang', 1, 12000, 75),
('SKU007', 'Coca Cola 330ml', 2, 6500, 120),
('SKU008', 'Rinso Detergen', 3, 25000, 40),
('SKU009', 'Kabel USB Type-C', 4, 35000, 30),
('SKU010', 'Tolak Angin', 5, 3000, 90);
