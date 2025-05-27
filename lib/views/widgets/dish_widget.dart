import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dish.dart';
import '../../view_models/app_view_model.dart';

class DishWidget extends StatelessWidget {
  final Dish dish;

  const DishWidget({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            leading: Image.network(dish.imagePath),
            title: Text(dish.name),
            subtitle: Text(' ${dish.price} €\n'),
            trailing: IconButton(
              onPressed: () {
                Provider.of<AppViewModel>(
                  context,
                  listen: false,
                ).increaseDish(dish);
              },
              icon: Icon(Icons.shopping_basket),
            ),
          ),
        ],
      ),
    );
  }
}
