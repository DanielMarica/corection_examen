import 'package:examen_juin1/services/dish_service.dart';
import 'package:examen_juin1/view_models/app_view_model.dart';
import 'package:examen_juin1/views/screens/cart_screen.dart';
import 'package:examen_juin1/views/widgets/form_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'views/screens/home_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'cart-screen',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(path: 'form', builder: (context, state) => const FormScreen()),
      ],
    ),
  ],
);
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dishService = DishService();
  // Initialize the database before running the app
  dishService.initDatabase().then((_) {
    runApp(MyApp(dishService: dishService));
  });
}

class MyApp extends StatelessWidget {
  final DishService dishService;

  const MyApp({super.key, required this.dishService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AppViewModel(dishService: dishService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Examen blanc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
