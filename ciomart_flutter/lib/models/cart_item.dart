import 'product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double getSubtotal() {
    return product.getPriceAfterDiscount() * quantity;
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'product_price': product.getPriceAfterDiscount(),
      'quantity': quantity,
      'subtotal': getSubtotal(),
    };
  }
}
