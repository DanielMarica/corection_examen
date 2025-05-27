import 'package:examen_juin1/views/widgets/menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/dish_service.dart';
import '../../view_models/app_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  context.go("/cart-screen");
                },
              ),
              Positioned(
                right: 3,
                bottom: 3,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${Provider.of<AppViewModel>(context).total}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3), () => fetchDishes()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Completed with a value
            final dishs = snapshot.data!;
            return MenuWidget(menu: dishs);
          }

          if (snapshot.hasError) {
            // Completed with an error
            return Center(child: Text("${snapshot.error}"));
          }

          // Uncompleted
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
