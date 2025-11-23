import 'dart:io'; // Pour File
import 'dart:convert'; // Pour base64Encode
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/utils/app_styles.dart';
import 'package:characters/characters.dart';
import 'package:go4it/models/challenge.dart';

class CreateChallengeScreen extends StatefulWidget {
  // Paramètre optionnel : si fourni, on est en mode "Modification"
  final Challenge? challengeToEdit;

  const CreateChallengeScreen({super.key, this.challengeToEdit});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emojiController = TextEditingController();
  File? _selectedImageFile; // L'image sélectionnée sur le téléphone
  String? _existingImageUrl; // L'URL de l'image existante (en cas d'édition)
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Getter pour savoir facilement si on édite
  bool get _isEditing => widget.challengeToEdit != null;

  @override
  void initState() {
    super.initState();
    // Si on édite, on pré-remplit les champs !
    if (_isEditing) {
      final c = widget.challengeToEdit!;
      _titleController.text = c.title;
      _descController.text = c.description;
      if (c.emoji != null) {
        _emojiController.text = c.emoji!;
      }
      _existingImageUrl = c.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  // --- MÉTHODE POUR CHOISIR UNE IMAGE ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800, // On réduit la taille pour ne pas exploser le base64
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          // Si on choisit une nouvelle image, on oublie l'ancienne URL
          _existingImageUrl = null;
        });
      }
    } catch (e) {
      print("Erreur image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de charger l\'image')),
      );
    }
  }

  // --- CONVERSION EN BASE64 ---
  Future<String?> _imageToBase64() async {
    if (_selectedImageFile == null) return null;
    try {
      final bytes = await _selectedImageFile!.readAsBytes();
      // On ajoute le préfixe pour que le serveur sache que c'est une image
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      print("Erreur encodage: $e");
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final feedProvider = context.read<FeedProvider>();

      // On prépare l'image (soit la nouvelle en base64, soit l'ancienne URL)
      String? finalImageUrl = _existingImageUrl;
      if (_selectedImageFile != null) {
        finalImageUrl = await _imageToBase64();
      }

      if (_isEditing) {
        await feedProvider.updateChallenge(
          challengeId: widget.challengeToEdit!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          emoji: _emojiController.text.trim().isEmpty ? null : _emojiController.text.trim(),
          imageUrl: finalImageUrl, // On envoie l'image
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Défi mis à jour ! ✨')),
          );
        }
      } else {
        await feedProvider.createChallenge(
          _titleController.text.trim(),
          _descController.text.trim(),
          emoji: _emojiController.text.trim().isEmpty ? null : _emojiController.text.trim(),
          imageUrl: finalImageUrl, // On envoie l'image
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Défi créé avec succès ! 🚀')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $error'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- WIDGET POUR AFFICHER L'IMAGE SÉLECTIONNÉE ---
  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      // Cas 1 : Nouvelle image locale
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(_selectedImageFile!, height: 150, width: double.infinity, fit: BoxFit.cover),
      );
    } else if (_existingImageUrl != null) {
      // Cas 2 : Image existante (URL ou Base64)
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _existingImageUrl!.startsWith('data:')
            ? Image.memory(
            base64Decode(_existingImageUrl!.split(',')[1]),
            height: 150, width: double.infinity, fit: BoxFit.cover
        )
            : Image.network(_existingImageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      // Cas 3 : Pas d'image
      return Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey[400], size: 32),
            const SizedBox(height: 8),
            Text("Ajouter une photo", style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }
  }

  // --- BOITE DE DIALOGUE POUR CHOISIR LA SOURCE ---
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Caméra'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Titre dynamique
                        _isEditing ? 'Modifier le Défi' : 'Nouveau Défi',
                        style: AppStyles.titleLarge,
                      ),
                      Text(
                        _isEditing ? 'Corrige ou améliore ton défi' : 'Lance-toi un challenge pour aujourd\'hui',
                        style: TextStyle(fontSize: 13, color: AppStyles.textSecondary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppStyles.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppStyles.textSecondary,
                  ),
                ],
              ),
            ),

            // --- CONTENU ---
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                children: [
                  // Champ Titre
                  TextFormField(
                    controller: _titleController,
                    decoration: AppStyles.inputDecoration('Titre', 'Ex: Lire 10 pages', Icons.title),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Le titre est obligatoire' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Champ Description
                  TextFormField(
                    controller: _descController,
                    decoration: AppStyles.inputDecoration('Description', 'Détails du défi...', Icons.description_outlined)
                        .copyWith(alignLabelWithHint: true),
                    maxLines: 3,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // --- Champ Emoji (Optimisé pour 1 seul émoji) ---
                  SizedBox(
                    width: 150,
                    child: TextFormField(
                      controller: _emojiController,
                      decoration: AppStyles.inputDecoration('Emoji', 'Ex: 📚', Icons.emoji_emotions_outlined).copyWith(
                        counterText: "",
                        hintText: 'Ex: 📚',
                      ),
                      // maxLength: 1,
                      inputFormatters: [
                        // 1. Interdit les lettres et chiffres
                        FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z0-9]')),

                        // 2. Limite intelligente à 1 seul caractère visuel (grapheme)
                        LengthLimitingTextInputFormatter(10), // Sécurité technique
                        _EmojiLimiter(), // Notre limiteur personnalisé
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- ZONE IMAGE ---
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: _buildImagePreview(),
                  ),
                  const SizedBox(height: 20),

                  // Bouton Valider Dynamique
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: AppStyles.primaryButtonStyle,
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isEditing ? Icons.save_outlined : Icons.rocket_launch_outlined),
                          const SizedBox(width: 8),
                          Text(
                              _isEditing ? 'SAUVEGARDER' : 'LANCER LE DÉFI',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// (Conservez la classe _EmojiLimiter à la fin du fichier)
class _EmojiLimiter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.characters.length > 1) {
      String firstChar = newValue.text.characters.first;
      return TextEditingValue(
        text: firstChar,
        selection: TextSelection.collapsed(offset: firstChar.length),
      );
    }
    return newValue;
  }
}