import 'discount_policy.dart';

class NoDiscount implements DiscountPolicy {
  @override
  double apply(double subtotal) {
    return subtotal;
  }
}
