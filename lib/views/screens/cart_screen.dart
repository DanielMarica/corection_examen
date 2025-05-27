import 'package:examen_juin1/utils/number_format.dart';
import 'package:examen_juin1/view_models/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/cart_item_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Cart'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: () {
                  Provider.of<AppViewModel>(context, listen: false).saveCart();
                },
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () {
                  Provider.of<AppViewModel>(context, listen: false).loadCart();
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.clear_all),
            onPressed: () {
              Provider.of<AppViewModel>(context, listen: false).clearCart();
            },
          ),
          body: Column(
            children: [
              Expanded(
                child: SizedBox(
                  width: 512,
                  child:
                      viewModel.cartItem.isNotEmpty
                          ? ListView.builder(
                            itemCount: viewModel.cartItem.length,
                            itemBuilder:
                                (context, index) => CartItemWidget(
                                  item: viewModel.cartItem[index],
                                ),
                          )
                          : const Center(child: Text("Cart is empty.")),
                ),
              ),
              Center(
                child: Text(
                  'Total price: ${formatter.format(Provider.of<AppViewModel>(context).sum)}€',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
