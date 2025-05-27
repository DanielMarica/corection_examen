import 'dart:collection';
import 'dart:developer';

import 'package:examen_juin1/services/dish_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/dish.dart';
import '../services/cart_service.dart';

class AppViewModel with ChangeNotifier {
  final _dishes = <Dish>[];
  final _cart = <CartItem>[];
  final DishService _dishService = DishService();

  AppViewModel({required DishService dishService}) {
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    try {
      await _dishService.initDatabase();
      final dishes = await _dishService.getDishes();
      _dishes.clear();
      _dishes.addAll(dishes);
      notifyListeners();
    } catch (error) {
      log("Error loading dishes: $error");
    }
  }

  UnmodifiableListView<Dish> get dish => UnmodifiableListView(_dishes);

  UnmodifiableListView<CartItem> get cartItem => UnmodifiableListView(_cart);

  int get total => cartItem.map((item) => item.count).fold(0, (a, b) => a + b);

  double get sum => cartItem.fold(0, (a, b) => a + b.count * b.dish.price);

  Future<void> addDish(Dish dish) async {
    await _dishService.createDish(
      dish.name,
      dish.price,
      dish.category,
      dish.imagePath,
    );
    await _loadDishes();
  }

  Future<void> increaseDish(Dish dish) async {
    final item = _cart.firstWhere(
      (item) => item.dish == dish,
      orElse: () {
        final item = CartItem(dish: dish);
        _cart.add(item);
        return item;
      },
    );
    item.count++;
    notifyListeners();
  }

  Future<void> decreaseDish(Dish dish) async {
    final item = _cart.firstWhere(
      (item) => item.dish == dish,
      orElse: () {
        final item = CartItem(dish: dish);
        _cart.remove(item);
        return item;
      },
    );
    item.count--;
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();
  }

  Future<void> loadCart() async {
    final cart = await load(_dishes);
    _cart.clear();
    _cart.addAll(cart);
    notifyListeners();
  }

  Future<void> saveCart() async {
    await save(_cart);
    notifyListeners();
  }

  /*
  Future<void> decreaseDish(String name) async {
    final articles = await service.getDishs();
    final article = articles.firstWhere((article) => article.name == name);
    if (article.nbrDish <= 0) return;
    await service.decreaseDishCount(name);
    await refreshList();
  }
  Future<void> deleteDish(String name) async {
    await service.deleteDish(name);
    await refreshList();
  }
  Future<void> createDish(String name, double prix, int nbrDish) async {
    await service.createDish(name, prix, nbrDish);
    await refreshList();
  }

  */
}
