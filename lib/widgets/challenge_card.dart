import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go4it/models/challenge.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/providers/auth_provider.dart';
import 'package:go4it/widgets/user_avatar_row.dart';
import 'package:go4it/utils/app_styles.dart';
import 'package:timeago/timeago.dart' as timeago;
// Import de l'écran d'édition
import 'package:go4it/screens/create_challenge_screen.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({super.key, required this.challenge});

  // Fonction pour afficher la confirmation de suppression
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le défi ?'),
        content: const Text('Cette action est irréversible.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // Annuler
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Confirmer
            child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false; // Si on clique à côté, on renvoie false
  }

  // Fonction pour ouvrir le mode édition
  void _editChallenge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 16, right: 16, top: 60,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.hardEdge,
          child: CreateChallengeScreen(challengeToEdit: challenge),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUserId;
    final isMyChallenge = challenge.userId == currentUserId;

    // Le contenu visuel de la carte (extrait pour être réutilisé)
    Widget cardContent = _buildCardContent(context, isMyChallenge);

    // Si ce n'est pas mon défi, on affiche juste la carte sans swipe
    if (!isMyChallenge) {
      return cardContent;
    }

    // Si c'est mon défi, on ajoute les gestures de Swipe
    return Dismissible(
      key: Key(challenge.id), // Clé unique indispensable

      // --- 1. Swipe vers la DROITE (Modifier) ---
      background: Container(
        margin: AppStyles.cardMargin,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppStyles.primary, // Bleu
          borderRadius: BorderRadius.circular(AppStyles.cardRadiusValue),
        ),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.edit, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text("Modifier", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),

      // --- 2. Swipe vers la GAUCHE (Supprimer) ---
      secondaryBackground: Container(
        margin: AppStyles.cardMargin,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400], // Rouge
          borderRadius: BorderRadius.circular(AppStyles.cardRadiusValue),
        ),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Supprimer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ],
        ),
      ),

      // --- 3. Logique de confirmation ---
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // ---> Swipe vers la Droite (Modifier)
          _editChallenge(context);
          return false; // On retourne false pour que la carte revienne à sa place (ne disparaisse pas)
        } else {
          // <--- Swipe vers la Gauche (Supprimer)
          final bool confirm = await _confirmDelete(context);
          return confirm; // Si true, l'animation de suppression continue
        }
      },

      // --- 4. Action finale (Une fois l'animation finie) ---
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          // On appelle le provider pour supprimer la donnée
          context.read<FeedProvider>().deleteChallenge(challenge.id);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Défi supprimé 🗑️')),
          );
        }
      },

      child: cardContent,
    );
  }

  // Le design de la carte elle-même
  Widget _buildCardContent(BuildContext context, bool isMyChallenge) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().currentUserId;
    final isDoneByMe = challenge.dones.contains(currentUserId);

    return Card(
      margin: AppStyles.cardMargin,
      elevation: 0,
      color: AppStyles.cardBackground,
      shape: AppStyles.cardShape,
      child: Padding(
        padding: AppStyles.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Haut : Emoji + Contenu + Actions ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppStyles.emojiBoxDecoration,
                  child: Text(
                    challenge.emoji ?? '🎯',
                    style: AppStyles.emojiText,
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
                        style: AppStyles.cardTitle.copyWith(
                          decoration: isDoneByMe ? TextDecoration.lineThrough : null,
                          color: isDoneByMe ? AppStyles.textLight : AppStyles.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: AppStyles.cardDescription,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Bouton Action (Check)
                // Note: On a retiré le menu "..." ici car il est remplacé par le swipe
                IconButton(
                  onPressed: () {
                    context.read<FeedProvider>().toggleDone(challenge.id);
                  },
                  icon: Icon(
                    isDoneByMe ? Icons.check_circle : Icons.circle_outlined,
                    color: isDoneByMe ? AppStyles.secondary : AppStyles.textLight,
                    size: 32,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Bas : Avatar + Date + Likes ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      UserAvatarRow(userId: challenge.userId),
                      const SizedBox(width: 8),
                      Text("•", style: TextStyle(color: AppStyles.textLight)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          timeago.format(challenge.createdAt, locale: 'fr'),
                          style: TextStyle(color: AppStyles.textLight, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (challenge.dones.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.favorite, size: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          "${challenge.dones.length}",
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11),
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