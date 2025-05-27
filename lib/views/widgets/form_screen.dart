import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/dish.dart';
import '../../view_models/app_view_model.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final categoryController = TextEditingController();
  final imagePathController = TextEditingController(); //Url

  final key = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    categoryController.dispose();
    imagePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Dish"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Form(
          key: key,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Dish name"),
                validator:
                    (value) =>
                        (value == null || value == "")
                            ? "name can't be empty"
                            : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: "Dish price"),
                validator:
                    (value) =>
                        (value == null || value == "")
                            ? "price can't be empty"
                            : null,
              ),
              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: "Dish category"),
                validator:
                    (value) =>
                        (value == null || value == "")
                            ? "category can't be empty"
                            : null,
              ),
              TextFormField(
                controller: imagePathController,
                decoration: const InputDecoration(labelText: "Dish imagePath"),
                validator:
                    (value) =>
                        (value == null || value == "")
                            ? "imagePath can't be empty"
                            : null,
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text("Create Dish"),
                onPressed: () {
                  if (key.currentState!.validate()) {
                    Dish newDish = Dish(
                      name: nameController.text,
                      price: double.parse(priceController.text),
                      category: categoryController.text,
                      imagePath: imagePathController.text,
                    );
                    // TODO F07 create article
                    Provider.of<AppViewModel>(
                      context,
                      listen: false,
                    ).addDish(newDish);
                    // clear form thanks to the form key
                    key.currentState!.reset();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
