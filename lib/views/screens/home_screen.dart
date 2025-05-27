import 'package:examen_juin1/views/widgets/menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_business),
                    onPressed: () {
                      context.go("/form");
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      context.go("/cart-screen");
                    },
                  ),
                ],
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
      body: Consumer<AppViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.dish.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return MenuWidget(menu: viewModel.dish);
        },
      ),
    );
  }
}
