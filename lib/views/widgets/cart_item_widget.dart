import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart_item.dart';
import '../../utils/number_format.dart';
import '../../view_models/app_view_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListTile(
              title: Text(item.dish.name),
              subtitle: Text(
                ' Unit Price : ${item.dish.price} € \n'
                'Quantity : ${item.count}\n'
                'Total : ${formatter.format(item.dish.price * item.count)} €',
              ),
              isThreeLine: true,
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed:
                    () => Provider.of<AppViewModel>(
                      context,
                      listen: false,
                    ).increaseDish(item.dish),
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed:
                    () => Provider.of<AppViewModel>(
                      context,
                      listen: false,
                    ).decreaseDish(item.dish),
                icon: Icon(Icons.remove),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
