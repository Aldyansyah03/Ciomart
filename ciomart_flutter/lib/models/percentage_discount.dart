import 'discount_policy.dart';

class PercentageDiscount implements DiscountPolicy {
  final double rate;

  PercentageDiscount(this.rate);

  @override
  double apply(double subtotal) {
    return subtotal - (subtotal * (rate / 100));
  }
}
