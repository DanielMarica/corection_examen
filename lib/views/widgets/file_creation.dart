import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class FileCreationScreen extends StatefulWidget {
  final PlatformFile? file; // Fichier optionnel passé en paramètre

  const FileCreationScreen({super.key, this.file});

  @override
  State<FileCreationScreen> createState() => _FileCreationScreenState();
}

class _FileCreationScreenState extends State<FileCreationScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  late String fileName;
  bool _isNewFile = true;

  @override
  void initState() {
    super.initState();

    // Vérifier si un fichier a été fourni
    if (widget.file != null) {
      _isNewFile = false;
      fileName = widget.file!.name;
      _fileNameController.text = fileName;

      // Pré-remplir le contenu du fichier
      if (widget.file!.bytes != null) {
        try {
          String content = utf8.decode(widget.file!.bytes!);
          _contentController.text = content;
        } catch (e) {
          // Si le décodage UTF-8 échoue, utiliser une méthode alternative
          _contentController.text = String.fromCharCodes(widget.file!.bytes!);
        }
      }
    } else {
      // Nouveau fichier
      _isNewFile = true;
      fileName = "Nouveau fichier.txt";
      _fileNameController.text = fileName;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _saveFile() async {
    try {
      // Récupérer le nom du fichier depuis le champ de texte (si sur web)
      String currentFileName =
          kIsWeb
              ? _fileNameController.text.isNotEmpty
                  ? _fileNameController.text
                  : "Nouveau fichier.txt"
              : fileName;

      String content = _contentController.text;

      // Convertir le contenu string en bytes
      Uint8List bytes = utf8.encode(content);

      // Sauvegarder le fichier
      String? result = await FilePicker.platform.saveFile(
        fileName: currentFileName,
        bytes: bytes,
      );

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fichier sauvegardé avec succès!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isNewFile ? "Nouveau fichier" : "Éditeur"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFile,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage du nom du fichier ou champ de texte pour le web
            if (kIsWeb) ...[
              // Sur le web, afficher un champ de texte pour modifier le nom
              TextField(
                controller: _fileNameController,
                decoration: InputDecoration(
                  labelText: 'Nom du fichier',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Sur les autres plateformes, afficher juste le nom
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(
                      _isNewFile ? Icons.note_add : Icons.description,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Fichier: $fileName",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Zone d'édition de texte
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: "Commencez à écrire votre contenu ici...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informations sur le fichier (si fichier existant)
            if (!_isNewFile && widget.file != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations du fichier:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nom: ${widget.file!.name}",
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    if (widget.file!.size > 0)
                      Text(
                        "Taille: ${(widget.file!.size / 1024).toStringAsFixed(1)} KB",
                        style: TextStyle(color: Colors.blue.shade700),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Bouton de sauvegarde en bas
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveFile,
                icon: const Icon(Icons.save),
                label: const Text("Sauvegarder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
