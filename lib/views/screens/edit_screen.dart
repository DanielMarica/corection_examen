import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditScreen extends StatelessWidget {
  const EditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                ),
                onPressed: () async {
                  // Sélectionner un fichier existant
                  await _openExistingFile(context);
                },
                child: const Text("Ouvrir un fichier existant"),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                ),
                onPressed: () {
                  // Créer un nouveau fichier (pas de PlatformFile)
                  context.go('/open-creation');
                },
                child: const Text("Créer un nouveau fichier"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExistingFile(BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        withData: true, // Important: récupère le contenu du fichier
        type: FileType.custom,
        allowedExtensions: [
          'txt',
          'md',
          'json',
          'csv',
        ], // Types de fichiers autorisés
      );

      // Fermer l'indicateur de chargement
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;

        // Vérifier que le fichier a bien du contenu
        if (file.bytes != null) {
          // Naviguer vers l'éditeur avec le fichier
          if (context.mounted) {
            context.go('/open-existing', extra: file);
          }
        } else {
          // Erreur si pas de contenu
          if (context.mounted) {
            _showErrorSnackBar(
              context,
              'Impossible de lire le contenu du fichier',
            );
          }
        }
      }
      // Si result est null, l'utilisateur a annulé la sélection
    } catch (e) {
      // Fermer l'indicateur de chargement en cas d'erreur
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(
          context,
          'Erreur lors de l\'ouverture du fichier: $e',
        );
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
