import 'cart_item.dart';
import 'product.dart';

class Cart {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addItem(Product product, int quantity) {
    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
  }

  void updateQuantity(Product product, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(product);
      return;
    }

    final existingItemIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity = newQuantity;
    }
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
  }

  double getTotal() {
    return _items.fold(0, (total, item) => total + item.getSubtotal());
  }

  void clear() {
    _items.clear();
  }
}
