import 'dart:math'; // Import nécessaire pour Random
import 'package:flutter/material.dart';
import 'package:go4it/models/user.dart';
import 'package:go4it/services/user_service.dart';

class UserAvatarRow extends StatelessWidget {
  final String userId;
  final double size;

  final UserService _userService = UserService();

  UserAvatarRow({super.key, required this.userId, this.size = 16});

  /// Génère une couleur déterministe à partir du nom de l'utilisateur.
  /// "Mehdi" donnera toujours la même couleur, "Sarah" une autre, etc.
  Color _getUserColor(String username) {
    final int hash = username.hashCode;
    final Random random = Random(hash);
    // On génère une couleur un peu vive (pas trop sombre, pas trop claire)
    return Color.fromARGB(
      255,
      random.nextInt(200), // R (0-200 pour éviter le blanc)
      random.nextInt(200), // G
      random.nextInt(200), // B
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _userService.getUserInfo(userId),
      builder: (context, snapshot) {
        // 1. En cours de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              CircleAvatar(radius: size, backgroundColor: Colors.grey[200]),
              const SizedBox(width: 8),
              Container(width: 50, height: 10, color: Colors.grey[200]),
            ],
          );
        }

        // 2. En cas d'erreur ou pas de données
        if (snapshot.hasError || !snapshot.hasData) {
          return Row(
            children: [
              Icon(Icons.error_outline, size: size * 2, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Inconnu', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          );
        }

        final user = snapshot.data!;

        // On détermine la couleur de fond (soit primaire si c'est moi, soit aléatoire)
        // (Ici j'ai mis aléatoire pour tout le monde comme demandé)
        final backgroundColor = _getUserColor(user.username);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: size,
              backgroundColor: backgroundColor.withOpacity(0.2), // Fond clair
              child: Text(
                user.username.isNotEmpty ? user.username[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: size,
                  color: backgroundColor, // Texte de la même couleur mais vif
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              user.username,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}