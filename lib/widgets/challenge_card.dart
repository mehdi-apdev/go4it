import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go4it/models/challenge.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/providers/auth_provider.dart';
import 'package:go4it/widgets/user_avatar_row.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().currentUserId;
    final isDoneByMe = challenge.dones.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0, // Minimaliste : pas d'ombre, ou très légère
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade100), // Bordure subtile
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Ligne du haut : Emoji + Textes + Checkbox ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.05), // Plus léger
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    challenge.emoji ?? '🎯',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),

                // Titre et Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: isDoneByMe ? TextDecoration.lineThrough : null,
                          color: isDoneByMe ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Bouton Action
                IconButton(
                  onPressed: () {
                    context.read<FeedProvider>().toggleDone(challenge.id);
                  },
                  icon: Icon(
                    isDoneByMe ? Icons.check_circle : Icons.circle_outlined,
                    color: isDoneByMe ? theme.colorScheme.secondary : Colors.grey[300],
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- 2. Ligne du bas : Avatar + Date + Likes ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Groupe Gauche : Avatar + Date
                Expanded(
                  child: Row(
                    children: [
                      // Avatar et Nom
                      UserAvatarRow(userId: challenge.userId),

                      const SizedBox(width: 8),

                      // Petit point séparateur
                      Text("•", style: TextStyle(color: Colors.grey[400])),

                      const SizedBox(width: 8),

                      // Date relative (Minimaliste)
                      Flexible(
                        child: Text(
                          timeago.format(challenge.createdAt, locale: 'fr'),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                            // Pas d'italique pour le look minimaliste
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // Groupe Droite : Compteur de likes (si > 0)
                if (challenge.dones.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.favorite, size: 12, color: Colors.red[400]),
                        const SizedBox(width: 4),
                        Text(
                          "${challenge.dones.length}",
                          style: TextStyle(
                              color: Colors.red[400],
                              fontWeight: FontWeight.bold,
                              fontSize: 11
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}