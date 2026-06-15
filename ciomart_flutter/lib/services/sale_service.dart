import '../models/cart.dart';
import '../models/discount_policy.dart';
import '../models/sale.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class SaleService {
  final ApiService _apiService = ApiService();

  // Facade Pattern: processCheckout handles the complex checkout flow
  Future<Sale> processCheckout(
    Cart cart,
    DiscountPolicy discountPolicy,
    User cashier,
    double cashPaid,
  ) async {
    if (cart.items.isEmpty) {
      throw Exception('Keranjang kosong');
    }

    // 1. Hitung Subtotal
    double subtotal = cart.getTotal();

    // 2. Apply Discount Strategy
    double afterDiscount = discountPolicy.apply(subtotal);
    double discountAmount = subtotal - afterDiscount;

    // 3. Hitung Tax
    double taxAmount = afterDiscount * AppConstants.taxRate;

    // 4. Hitung Total
    double total = afterDiscount + taxAmount;

    // 5. Validasi Pembayaran
    if (cashPaid < total) {
      throw Exception('Uang pembayaran kurang!');
    }
    double cashChange = cashPaid - total;

    // 6. Generate Sale Number
    String saleNumber = 'TRX-${DateTime.now().millisecondsSinceEpoch}';

    // 7. Simpan ke database via API
    final payload = {
      'sale': {
        'sale_number': saleNumber,
        'cashier_id': cashier.id,
        'subtotal': subtotal,
        'discount_type': discountPolicy.runtimeType.toString(),
        'discount_amount': discountAmount,
        'tax_amount': taxAmount,
        'total': total,
        'cash_paid': cashPaid,
        'cash_change': cashChange,
      },
      'items': cart.items.map((item) => item.toJson()).toList(),
    };

    final response = await _apiService.post('/sales/checkout', payload);
    
    if (response['id'] == null) {
      throw Exception('Gagal menyimpan transaksi');
    }

    // 8. Return Sale Object
    return Sale(
      id: response['id'],
      saleNumber: saleNumber,
      cashier: cashier,
      items: cart.items,
      subtotal: subtotal,
      discountType: discountPolicy.runtimeType.toString(),
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      total: total,
      cashPaid: cashPaid,
      cashChange: cashChange,
      saleDate: DateTime.now(),
    );
  }
}
