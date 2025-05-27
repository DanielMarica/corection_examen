import 'dish.dart';

class CartItem {
  final Dish dish;
  int count;

  CartItem({required this.dish, this.count = 0});
}

/*
final testCartItem1 = CartItem(dish: testDish1, count: 2);
final testCartItem2 = CartItem(dish: testDish2, count: 1);

final testCart = [testCartItem1, testCartItem2];
*/
