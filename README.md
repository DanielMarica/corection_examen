# 🍽️ Menu App – Flutter + Provider + SQLite

![Flutter](https://img.shields.io/badge/Framework-Flutter-blue?style=flat-square)
![Provider](https://img.shields.io/badge/State_Management-Provider-green?style=flat-square)
![SQLite](https://img.shields.io/badge/Database-SQLite-orange?style=flat-square)
![Dart](https://img.shields.io/badge/Language-Dart-lightblue?style=flat-square)

---

## 🚀 Installation et Configuration

### 1. Ajout des dépendances

Exécute les commandes suivantes dans l'ordre pour installer toutes les dépendances nécessaires :

```bash
flutter pub add go_router
flutter pub add provider
flutter pub add url_launcher
flutter pub add http
flutter pub add shared_preferences
flutter pub add sqflite
flutter pub add path
flutter pub add sqflite_common_ffi
flutter pub add sqflite_common_ffi_web
flutter pub add intl
flutter pub get
dart run sqflite_common_ffi_web:setup
```

### 2. Dépendances dans `pubspec.yaml`

Après l'exécution des commandes, ton fichier `pubspec.yaml` devrait contenir :

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  go_router: ^13.2.1
  provider: ^6.1.2
  url_launcher: ^6.3.1
  http: ^1.2.1
  shared_preferences: ^2.5.3
  sqflite: ^2.4.2
  path: ^1.9.1
  sqflite_common_ffi: ^2.3.3
  sqflite_common_ffi_web: ^1.0.0
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

---

## 📱 Utilisation avec Provider

### 📌 Configuration du `AppViewModel`

Voici un exemple complet d'utilisation avec ton `AppViewModel` :

```dart
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
  
  Future<void> addDish(Dish dish) async {
    await _dishService.createDish(
      dish.name,
      dish.price,
      dish.category,
      dish.imagePath,
    );
    await _loadDishes();
  }
  
  // Gestion du panier
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
}
```

### 📌 Ajout d'un plat (`Dish`) au ViewModel

Utilise `Provider.of<AppViewModel>(context, listen: false)` pour appeler une méthode sans reconstruire le widget :

```dart
Provider.of<AppViewModel>(
  context,
  listen: false,
).addDish(newDish);
```

- `newDish` est une instance de ton modèle `Dish`
- Cette méthode met à jour les données et appelle `notifyListeners()` dans ton `ViewModel`

### 🖼️ Affichage dynamique de la liste avec `Consumer`

Le widget `Consumer` permet de reconstruire l'interface automatiquement lorsque la liste change :

```dart
body: Consumer<AppViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.dish.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return MenuWidget(menu: viewModel.dish);
  },
),
```

- Si la liste est vide, un `loader` est affiché
- Sinon, un widget `MenuWidget` personnalisé affiche les plats

---

## 🗄️ Configuration SQLite

### Structure de base

La configuration SQLite est automatiquement gérée par les dépendances ajoutées. Le support web est activé grâce à `sqflite_common_ffi_web`.

### Exemple d'utilisation avec `DishService` (Support Web + Mobile)

Voici ton service complet avec gestion kIsWeb et API :

```dart
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
```

---

## 🛣️ Navigation avec GoRouter

### Configuration de base

```dart
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/menu',
      builder: (context, state) => const MenuScreen(),
    ),
    GoRoute(
      path: '/dish/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return DishDetailScreen(dishId: id);
      },
    ),
  ],
);
```

### Navigation

```dart
// Aller à une route
context.go('/menu');

// Aller à une route avec paramètres
context.go('/dish/123');

// Retour
context.pop();
```

---

## 📦 Structure du Projet

```
lib/
├── main.dart
├── models/
│   └── dish.dart
├── viewmodels/
│   └── app_view_model.dart
├── screens/
│   ├── home_screen.dart
│   └── menu_screen.dart
├── widgets/
│   └── menu_widget.dart
└── database/
    └── database_helper.dart
```

---

## ✅ Résumé des Actions

| Action | Code utilisé |
|--------|--------------|
| ➕ **Ajouter un plat** | `Provider.of<AppViewModel>(context, listen: false).addDish(newDish);` |
| 👀 **Afficher la liste** | `Consumer<AppViewModel>(...)` avec `viewModel.dish` dans le `builder` |
| 🗄️ **Base de données** | `sqflite` + `path` pour la persistance locale |
| 🛣️ **Navigation** | `go_router` pour la navigation déclarative |
### 📌 Configuration avec `SharedPreferences` pour le panier

Utilise `SharedPreferences` pour sauvegarder le panier :

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Sauvegarder le panier
Future<void> save(List<CartItem> cart) async {
  final prefs = await SharedPreferences.getInstance();
  final cartJson = cart.map((item) => {
    'dishId': item.dish.id,
    'count': item.count,
  }).toList();
  await prefs.setString('cart', jsonEncode(cartJson));
}

// Charger le panier
Future<List<CartItem>> load(List<Dish> dishes) async {
  final prefs = await SharedPreferences.getInstance();
  final cartString = prefs.getString('cart');
  if (cartString == null) return [];
  
  final cartJson = jsonDecode(cartString) as List;
  return cartJson.map((item) {
    final dish = dishes.firstWhere((d) => d.id == item['dishId']);
    return CartItem(dish: dish)..count = item['count'];
  }).toList();
}
```

---

## 🚀 Démarrage Rapide

1. Clone le projet
2. Exécute les commandes d'installation ci-dessus
3. Lance l'application avec `flutter run`
4. Profite de ton app de menu avec gestion d'état et base de données !

✨ **Gère tes états de façon fluide et propre avec Provider dans Flutter !**