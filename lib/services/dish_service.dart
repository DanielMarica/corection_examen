/*
import 'dart:convert';

import 'package:examen_juin1/models/dish.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const _apiUrl = "https://sebstreb.github.io/binv2110-examen-blanc-api/dishes";

Future<List<Dish>> fetchDishes() async {
  var response = await http.get(Uri.parse("$_apiUrl/"));

  if (response.statusCode != 200) {
    throw Exception("Error ${response.statusCode} fetching movies");
  }

  return compute((input) {
    final jsonList = jsonDecode(input);
    return jsonList
        .map<Dish>(
          (jsonObj) => Dish(
            name: jsonObj["name"],
            price: jsonObj["price"],
            category: jsonObj["category"],
            imagePath: jsonObj["imagePath"],
          ),
        )
        .toList();
  }, response.body);
}
*/

import 'dart:convert';

import 'package:examen_juin1/models/dish.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DishService {
  late Database _database;

  Future<Database> get database async {
    await initDatabase();
    return _database;
  }

  Future<void> initDatabase() async {
    // Open the database
    if (kIsWeb) {
      // Web-specific initialization
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      // Mobile-specific initialization (optional, sqflite handles this by default)
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await openDatabase(
      join(await getDatabasesPath(), 'dishes.db'),
      version: 1,
      onCreate: (db, version) async {
        // Create the Dish table
        await db.execute(
          'CREATE TABLE Dish(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, category TEXT, imagePath TEXT)',
        );
      },
    );

    // Check if the table is empty; if so, fetch from API and populate
    final result = await _database.rawQuery(
      "SELECT COUNT(*) AS count FROM Dish",
    );
    if (result[0]["count"] == 0) {
      // Fetch dishes from API and insert them into the database
      final apiDishes = await fetchDishesFromApi();
      for (var dish in apiDishes) {
        await _database.insert('Dish', {
          'name': dish.name,
          'price': dish.price,
          'category': dish.category,
          'imagePath': dish.imagePath,
        });
      }
    }
  }

  // Fetch dishes from the API (same as your original fetchDishes)
  Future<List<Dish>> fetchDishesFromApi() async {
    const String apiUrl =
        "https://sebstreb.github.io/binv2110-examen-blanc-api/dishes";
    var response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode != 200) {
      throw Exception("Error ${response.statusCode} fetching dishes");
    }

    return compute((input) {
      final jsonList = jsonDecode(input);
      return jsonList
          .map<Dish>(
            (jsonObj) => Dish(
              name: jsonObj["name"],
              price: jsonObj["price"],
              category: jsonObj["category"],
              imagePath: jsonObj["imagePath"],
            ),
          )
          .toList();
    }, response.body);
  }

  // Fetch all dishes from the database
  Future<List<Dish>> getDishes() async {
    final maps = await _database.query('Dish');
    return List.generate(maps.length, (i) {
      return Dish(
        name: maps[i]['name'] as String,
        price: maps[i]['price'] as double,
        category: maps[i]['category'] as String,
        imagePath: maps[i]['imagePath'] as String,
      );
    });
  }

  // Add a new dish to the database
  Future<Dish> createDish(
    String name,
    double price,
    String category,
    String imagePath,
  ) async {
    final id = await _database.insert('Dish', {
      "name": name,
      "price": price,
      "category": category,
      "imagePath": imagePath,
    });
    return Dish(
      name: name,
      price: price,
      category: category,
      imagePath: imagePath,
    );
  }
}
