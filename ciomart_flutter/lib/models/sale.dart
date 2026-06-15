import 'cart_item.dart';
import 'user.dart';

class Sale {
  final int? id;
  final String saleNumber;
  final User? cashier;
  final List<CartItem> items;
  final double subtotal;
  final String discountType;
  final double discountAmount;
  final double taxAmount;
  final double total;
  final double cashPaid;
  final double cashChange;
  final DateTime? saleDate;

  Sale({
    this.id,
    required this.saleNumber,
    this.cashier,
    required this.items,
    required this.subtotal,
    this.discountType = 'NONE',
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    required this.cashPaid,
    required this.cashChange,
    this.saleDate,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      saleNumber: json['sale_number'],
      cashier: json['cashier_id'] != null 
          ? Cashier(
              id: json['cashier_id'] is int ? json['cashier_id'] : int.tryParse(json['cashier_id'].toString()),
              username: json['username'] ?? '',
              fullName: json['cashier_name'] ?? '',
            )
          : null,
      items: [], // Populated separately if needed
      subtotal: json['subtotal'] is num ? (json['subtotal'] as num).toDouble() : double.parse(json['subtotal'].toString()),
      discountType: json['discount_type'] ?? 'NONE',
      discountAmount: json['discount_amount'] is num ? (json['discount_amount'] as num).toDouble() : double.parse(json['discount_amount'].toString()),
      taxAmount: json['tax_amount'] is num ? (json['tax_amount'] as num).toDouble() : double.parse(json['tax_amount'].toString()),
      total: json['total'] is num ? (json['total'] as num).toDouble() : double.parse(json['total'].toString()),
      cashPaid: json['cash_paid'] is num ? (json['cash_paid'] as num).toDouble() : double.parse(json['cash_paid'].toString()),
      cashChange: json['cash_change'] is num ? (json['cash_change'] as num).toDouble() : double.parse(json['cash_change'].toString()),
      saleDate: json['sale_date'] != null ? DateTime.parse(json['sale_date']) : null,
    );
  }
}
