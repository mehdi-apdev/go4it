import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go4it/models/challenge.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/providers/auth_provider.dart';
import 'package:go4it/widgets/user_avatar_row.dart';
import 'package:go4it/utils/app_styles.dart';
import 'package:timeago/timeago.dart' as timeago;
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
// --- Widget utilitaire pour afficher l'image (URL ou Base64) ---
  Widget _buildChallengeImage() {
    if (challenge.imageUrl == null) return const SizedBox.shrink();

    ImageProvider imageProvider;

    if (challenge.imageUrl!.startsWith('data:')) {
      // C'est du Base64
      try {
        // On retire le préfixe "data:image/jpeg;base64," pour décoder
        final base64String = challenge.imageUrl!.split(',')[1];
        imageProvider = MemoryImage(base64Decode(base64String));
      } catch (e) {
        return const SizedBox.shrink(); // Erreur de décodage
      }
    } else {
      // C'est une URL normale
      imageProvider = NetworkImage(challenge.imageUrl!);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image(
          image: imageProvider,
          width: double.infinity,
          height: 200, // Hauteur fixe pour l'uniformité
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stack) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthProvider>().currentUserId;
    final isMyChallenge = challenge.userId == currentUserId;

    Widget cardContent = _buildCardContent(context, isMyChallenge);

    if (!isMyChallenge) {
      return cardContent;
    }

    return Dismissible(
      key: Key(challenge.id),
      background: Container(
        margin: AppStyles.cardMargin,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: AppStyles.primary,
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
      secondaryBackground: Container(
        margin: AppStyles.cardMargin,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editChallenge(context);
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<FeedProvider>().deleteChallenge(challenge.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Défi supprimé 🗑️')),
          );
        }
      },
      child: cardContent,
    );
  }

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppStyles.emojiBoxDecoration,
                  child: Text(
                    challenge.emoji ?? '🎯',
                    style: AppStyles.emojiText,
                  ),
                ),
                const SizedBox(width: 16),
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
                if (!isMyChallenge)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      onPressed: () {
                        context.read<FeedProvider>().toggleDone(challenge.id);
                      },
                      icon: Icon(
                        isDoneByMe ? Icons.check_circle : Icons.circle_outlined,
                        color: isDoneByMe ? AppStyles.secondary : AppStyles.textLight,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),

            // --- AJOUT DE L'IMAGE ICI ---
            _buildChallengeImage(),
            // ---------------------------

            const SizedBox(height: 16),

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