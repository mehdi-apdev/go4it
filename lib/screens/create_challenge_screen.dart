import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/utils/app_styles.dart';
import 'package:characters/characters.dart'; // Import pour gérer les émojis complexes

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _emojiController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _emojiController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<FeedProvider>().createChallenge(
        _titleController.text.trim(),
        _descController.text.trim(),
        emoji: _emojiController.text.trim().isEmpty ? null : _emojiController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Défi créé avec succès ! 🚀')),
        );
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
                      const Text(
                        'Nouveau Défi',
                        style: AppStyles.titleLarge,
                      ),
                      Text(
                        'Lance-toi un challenge pour aujourd\'hui',
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

                  // Bouton Valider
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: AppStyles.primaryButtonStyle,
                      child: _isLoading
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch_outlined),
                          SizedBox(width: 8),
                          Text('LANCER LE DÉFI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

// --- FORMATTER PERSONNALISÉ POUR ÉMOJIS ---
// Ce formatter s'assure qu'il n'y a qu'un seul émoji visuel,
// même si cet émoji est composé de plusieurs caractères techniques.
class _EmojiLimiter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    // Utilise le package 'characters' pour compter les vrais caractères visuels
    if (newValue.text.characters.length > 1) {
      // Si plus d'un émoji, on garde l'ancien ou on tronque
      // Ici, on garde simplement le premier émoji tapé
      String firstChar = newValue.text.characters.first;
      return TextEditingValue(
        text: firstChar,
        selection: TextSelection.collapsed(offset: firstChar.length),
      );
    }
    return newValue;
  }
}