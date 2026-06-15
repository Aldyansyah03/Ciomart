# CLASS DIAGRAM - CIOMART SYSTEM
## Implementasi OOP Sesuai Proposal

---

## 📊 STRUKTUR KELAS

### 1️⃣ USER MANAGEMENT (Inheritance & Abstraction)

```
┌─────────────────────────────┐
│    <<abstract>>             │
│         User                │
├─────────────────────────────┤
│ - id: int                   │
│ - username: String          │
│ - passwordHash: String      │
│ - role: String              │
│ - fullName: String          │
├─────────────────────────────┤
│ + checkPassword(String): boolean │
│ + getRole(): String         │
└─────────────────────────────┘
          △ (inheritance)
          │
    ┌─────┴─────┐
    │           │
┌───▼────────┐ ┌▼────────────┐
│   Admin    │ │   Cashier   │
├────────────┤ ├─────────────┤
│            │ │             │
├────────────┤ ├─────────────┤
│ + manageProduct() │ + processTransaction() │
│ + viewReport()    │ + printReceipt()       │
└────────────┘ └─────────────┘
```

**Konsep OOP:**
- ✅ **Abstraction:** User adalah abstract class
- ✅ **Inheritance:** Admin & Cashier extends User
- ✅ **Encapsulation:** Semua atribut private dengan getter/setter
- ✅ **Polymorphism:** checkPassword() dapat dipanggil dari Admin/Cashier

---

### 2️⃣ PRODUCT & CATEGORY (Aggregation)

```
┌─────────────────┐       1     *  ┌──────────────────────┐
│    Category     │◇──────────────▷│      Product         │
├─────────────────┤ (aggregation)  ├──────────────────────┤
│ - id: int       │                │ - id: int            │
│ - name: String  │                │ - sku: String        │
│ - description   │                │ - name: String       │
├─────────────────┤                │ - category: Category │
│ + getName()     │                │ - price: BigDecimal  │
│ + setName()     │                │ - stock: int         │
└─────────────────┘                │ - description: String│
                                   │ - discountPercentage │
                                   ├──────────────────────┤
                                   │ + getSubtotal(int)   │
                                   │ + getPriceAfterDiscount() │
                                   │ + isAvailable(int)   │
                                   │ + reduceStock(int)   │
                                   └──────────────────────┘
```

**Konsep OOP:**
- ✅ **Aggregation:** Product HAS-A Category (lifecycle independen)
- ✅ **Encapsulation:** Validasi pada setPrice(), setStock()
- ✅ **Business Logic:** getPriceAfterDiscount() menghitung diskon otomatis

**Fitur Tambahan:**
- 🎁 **Diskon per Produk:** Admin dapat set diskon 0-100%
- 💰 **Auto-Calculate:** Harga final otomatis terhitung saat transaksi

---

### 3️⃣ CART & CART ITEM (Composition)

```
┌─────────────────┐       1    *  ┌──────────────────┐
│      Cart       │◆──────────────▷│    CartItem      │
├─────────────────┤ (composition)  ├──────────────────┤
│ - items: List   │                │ - product: Product│
├─────────────────┤                │ - qty: int       │
│ + addItem()     │                ├──────────────────┤
│ + removeItem()  │                │ + getSubtotal()  │
│ + getTotal()    │                └──────────────────┘
│ + clear()       │                        │
└─────────────────┘                        │ refers to
                                           ▽
                                   ┌──────────────┐
                                   │   Product    │
                                   └──────────────┘
```

**Konsep OOP:**
- ✅ **Composition:** CartItem adalah bagian dari Cart (lifecycle dependent)
- ✅ **Aggregation:** CartItem merujuk ke Product (independent)
- ✅ **Encapsulation:** Cart mengelola internal List<CartItem>

---

### 4️⃣ DISCOUNT STRATEGY (Interface & Polymorphism)

```
┌──────────────────────────┐
│    <<interface>>         │
│    DiscountPolicy        │
├──────────────────────────┤
│ + apply(BigDecimal): BigDecimal │
└──────────────────────────┘
            △
            │ (implements)
     ┌──────┴──────┐
     │             │
┌────▼─────┐  ┌───▼──────────────┐
│NoDiscount│  │PercentageDiscount│
├──────────┤  ├──────────────────┤
│          │  │ - rate: BigDecimal│
├──────────┤  ├──────────────────┤
│ + apply()│  │ + apply()        │
└──────────┘  └──────────────────┘
```

**Konsep OOP:**
- ✅ **Interface:** DiscountPolicy mendefinisikan kontrak
- ✅ **Polymorphism:** apply() memiliki implementasi berbeda
- ✅ **Strategy Pattern:** Dapat switch strategi diskon runtime
- ✅ **Open/Closed Principle:** Mudah tambah strategi baru tanpa ubah kode existing

**Strategi Tersedia:**
1. **NoDiscount:** Tidak ada potongan
2. **PercentageDiscount(10):** Diskon 10%
3. **PercentageDiscount(20):** Diskon 20%

---

### 5️⃣ SALE SERVICE (Facade Pattern)

```
┌──────────────────────────────┐
│       SaleService            │
│        (Facade)              │
├──────────────────────────────┤
│ - productRepo: ProductRepo   │
│ - saleRepo: SaleRepository   │
├──────────────────────────────┤
│ + processCheckout(Cart, DiscountPolicy, User, BigDecimal): Sale │
└──────────────────────────────┘
         │ uses
         │
    ┌────▼────┐
    │  Cart   │
    └─────────┘
         │
         ▽
    ┌─────────┐
    │  Sale   │
    └─────────┘
```

**Konsep OOP:**
- ✅ **Facade Pattern:** Menyederhanakan proses checkout kompleks
- ✅ **Encapsulation:** Menyembunyikan detail validasi, kalkulasi, persistence
- ✅ **Single Responsibility:** Satu method untuk seluruh checkout flow

**Proses di processCheckout():**
1. Validasi stok produk
2. Hitung subtotal
3. Apply discount strategy
4. Hitung PPN 10%
5. Validasi pembayaran
6. Kurangi stok
7. Simpan Sale ke database
8. Return Sale object

---

### 6️⃣ REPOSITORY PATTERN

```
┌──────────────────────────┐
│   ProductRepository      │
├──────────────────────────┤
│ + findById(int): Product │
│ + findAll(): List        │
│ + save(Product): void    │
│ + update(Product): void  │
│ + deleteById(int): void  │
└──────────────────────────┘

┌──────────────────────────┐
│    SaleRepository        │
├──────────────────────────┤
│ + save(Sale): void       │
│ + findAll(): List        │
│ + findByDate(): List     │
│ + getTotalSales(): BigDecimal │
└──────────────────────────┘
```

**Konsep OOP:**
- ✅ **Separation of Concerns:** Business logic terpisah dari data access
- ✅ **Repository Pattern:** Abstraksi untuk persistence
- ✅ **Testability:** Mudah mock untuk unit testing

---

### 7️⃣ SALE (Transaction Record)

```
┌──────────────────────────┐
│         Sale             │
├──────────────────────────┤
│ - id: int                │
│ - saleNumber: String     │
│ - cashier: User          │
│ - items: List<CartItem>  │
│ - subtotal: BigDecimal   │
│ - discountAmount: BigDecimal │
│ - taxAmount: BigDecimal  │
│ - total: BigDecimal      │
│ - cashPaid: BigDecimal   │
│ - cashChange: BigDecimal │
│ - saleDate: Timestamp    │
├──────────────────────────┤
│ + getSaleNumber()        │
│ + getTotal()             │
│ + getChange()            │
└──────────────────────────┘
         │ aggregation
         ▽
    ┌─────────┐
    │  User   │
    │(Cashier)│
    └─────────┘
```

**Konsep OOP:**
- ✅ **Aggregation:** Sale merujuk ke User (Cashier) yang melakukan transaksi
- ✅ **Value Object:** Sale menyimpan snapshot item (immutable setelah checkout)
- ✅ **Encapsulation:** Data transaksi terlindungi

---

## 🎯 RELASI ANTAR KELAS

### Inheritance (Pewarisan) - IS-A
```
User (abstract)
  ├─ Admin
  └─ Cashier
```

### Composition (Kepemilikan Kuat) - HAS-A
```
Cart ◆───→ CartItem
  - CartItem tidak bisa eksis tanpa Cart
  - Lifecycle dependent
```

### Aggregation (Kepemilikan Lemah) - HAS-A
```
Product ◇───→ Category
  - Product merujuk Category
  - Lifecycle independent
  
Sale ◇───→ User (Cashier)
  - Sale merujuk User yang melakukan transaksi
  - User bisa eksis tanpa Sale

CartItem ◇───→ Product
  - CartItem merujuk Product
  - Product bisa eksis tanpa CartItem
```

### Interface Implementation
```
DiscountPolicy (interface)
  ├─ NoDiscount
  └─ PercentageDiscount
```

---

## 📐 DESIGN PATTERNS YANG DITERAPKAN

### 1. **Strategy Pattern**
- **Where:** DiscountPolicy interface
- **Purpose:** Memungkinkan algoritma diskon dapat dipertukarkan
- **Benefit:** Mudah tambah strategi diskon baru (Fixed amount, Buy X Get Y, dll)

### 2. **Facade Pattern**
- **Where:** SaleService
- **Purpose:** Menyederhanakan kompleksitas checkout
- **Benefit:** Client hanya perlu panggil 1 method untuk checkout penuh

### 3. **Repository Pattern**
- **Where:** ProductRepository, SaleRepository
- **Purpose:** Abstraksi akses database
- **Benefit:** Business logic tidak terikat dengan database specifics

### 4. **Abstract Factory** (implisit)
- **Where:** User class hierarchy
- **Purpose:** Mencegah instansiasi langsung User
- **Benefit:** Hanya Admin atau Cashier yang bisa dibuat

---

## ✅ CHECKLIST KONSEP OOP

### ✅ Encapsulation
- [x] Semua atribut private
- [x] Akses via getter/setter
- [x] Validasi di setter (price >= 0, stock >= 0, discount 0-100)

### ✅ Inheritance
- [x] User sebagai superclass
- [x] Admin & Cashier sebagai subclass
- [x] Method overriding (implisit via polymorphism)

### ✅ Abstraction
- [x] User adalah abstract class
- [x] DiscountPolicy adalah interface
- [x] Client tidak perlu tahu detail implementasi

### ✅ Polymorphism
- [x] DiscountPolicy.apply() memiliki berbagai implementasi
- [x] User reference bisa menunjuk ke Admin/Cashier
- [x] Runtime binding pada strategi diskon

### ✅ Composition
- [x] Cart memiliki CartItem (strong ownership)
- [x] Lifecycle CartItem tergantung Cart

### ✅ Aggregation
- [x] Product merujuk Category
- [x] Sale merujuk User
- [x] CartItem merujuk Product

---

## 🔧 TEKNOLOGI & TOOLS

- **Language:** Java 8+
- **Web Framework:** JSP/Servlet (Jakarta EE)
- **Database:** MySQL 8.0
- **Build Tool:** Maven
- **Server:** Apache Tomcat 10
- **IDE:** Apache NetBeans
- **ORM:** JDBC (Raw)
- **Security:** SHA-256 password hashing

---

## 📂 STRUKTUR FILE

```
src/main/java/com/mycompany/
├── db/
│   └── DBConnection.java          # Database connection utility
├── model/
│   ├── User.java                  # Abstract class
│   ├── Admin.java                 # User implementation
│   ├── Cashier.java               # User implementation
│   ├── Product.java               # Entity dengan diskon
│   ├── Category.java              # Entity
│   ├── Cart.java                  # Composition dengan CartItem
│   ├── CartItem.java              # Item dalam keranjang
│   ├── Sale.java                  # Transaction record
│   ├── DiscountPolicy.java        # Interface
│   ├── NoDiscount.java            # Strategy implementation
│   └── PercentageDiscount.java    # Strategy implementation
├── service/
│   └── SaleService.java           # Facade untuk checkout
└── repository/
    ├── ProductRepository.java     # Data access untuk Product
    └── SaleRepository.java        # Data access untuk Sale

src/main/webapp/
├── login.jsp                      # Login page
├── admin-dashboard.jsp            # Admin home
├── cashier-dashboard.jsp          # Cashier home
├── products-admin.jsp             # CRUD produk + set diskon
├── categories-admin.jsp           # CRUD kategori
├── users-admin.jsp                # CRUD user
├── reports-admin.jsp              # Laporan penjualan
└── transaction.jsp                # POS kasir (diskon otomatis)
```

---

## 🎁 FITUR UNGGULAN

### 1. **Diskon Produk (Baru!)**
- Admin dapat set diskon 0-100% per produk
- Diskon otomatis diterapkan saat transaksi
- Visual badge hijau untuk produk diskon
- Harga coret untuk harga asli

### 2. **Strategi Diskon Transaksi**
- No Discount
- Percentage 10%
- Percentage 20%
- Mudah tambah strategi baru

### 3. **Auto Calculate**
- Subtotal otomatis
- Diskon produk + diskon transaksi
- PPN 10% otomatis
- Kembalian otomatis

### 4. **Role-Based Access**
- Admin: kelola produk, kategori, user, laporan
- Kasir: hanya transaksi penjualan

### 5. **Security**
- Password hashing SHA-256
- Session management
- Role validation di setiap page

---

**© 2025 CIOMART - Kelompok 9 | Implementasi OOP Lengkap**
