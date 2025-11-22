import 'package:flutter/material.dart';

/// Une classe utilitaire pour centraliser tous les styles de l'application.
/// Elle reprend les couleurs définies dans main.dart pour assurer la cohérence.
class AppStyles {
  // --- COULEURS (Doivent matcher main.dart) ---
  static const Color primary = Color(0xFF283593); // primaryBlue
  static const Color secondary = Color(0xFF00BFA5); // accentGreen

  static const Color background = Color(0xFFFAFAFA); // Colors.grey[50]
  static const Color cardBackground = Colors.white;

  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF757575); // Colors.grey[600]
  static const Color textLight = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color border = Color(0xFFEEEEEE); // Colors.grey[200]

  // --- ESPACEMENTS ---
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
  static const double cardRadiusValue = 20.0;

  // --- FORMES & BORDURES ---

  // Style des Cartes (utilisé dans Home et ChallengeCard)
  static ShapeBorder get cardShape => RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardRadiusValue),
    side: const BorderSide(color: border),
  );

  // Style des Inputs (Champs de texte)
  static InputDecoration inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: textLight),
      filled: true,
      fillColor: cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      // Bordure par défaut (grise légère)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadiusValue),
        borderSide: const BorderSide(color: border),
      ),
      // Bordure quand on clique (Bleu primaire)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadiusValue),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      // Bordure en cas d'erreur (Rouge)
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadiusValue),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(cardRadiusValue),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // Style des Boutons Principaux (Utilise la couleur primaire)
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(cardRadiusValue),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  // Style de la boite Emoji (carré arrondi avec fond primaire très clair)
  static BoxDecoration get emojiBoxDecoration => BoxDecoration(
    color: primary.withOpacity(0.05),
    borderRadius: BorderRadius.circular(16),
  );

  // --- TYPOGRAPHIE ---

  static const TextStyle titleLarge = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textPrimary
  );

  static const TextStyle cardTitle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle cardDescription = TextStyle(
    color: textSecondary,
    fontSize: 13,
    height: 1.4,
  );

  static const TextStyle emojiText = TextStyle(
    fontSize: 28,
  );
}