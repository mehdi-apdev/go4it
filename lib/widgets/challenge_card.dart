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

  @override
  Widget build(BuildContext context) {
    // On récupère l'ID de l'utilisateur connecté
    final currentUserId = context.read<AuthProvider>().currentUserId;

    // Est-ce MON défi ?
    final isMyChallenge = challenge.userId == currentUserId;

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Titre (Flexible pour éviter l'overflow si le menu est là)
                          Flexible(
                            child: Text(
                              challenge.title,
                              style: AppStyles.cardTitle.copyWith(
                                decoration: isDoneByMe ? TextDecoration.lineThrough : null,
                                color: isDoneByMe ? AppStyles.textLight : AppStyles.textPrimary,
                              ),
                            ),
                          ),

                          // --- MINI MENU (Seulement si c'est mon défi) ---
                          if (isMyChallenge)
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: Icon(Icons.more_horiz, color: AppStyles.textSecondary),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Navigation vers l'écran de création EN MODE ÉDITION
                                    // On passe le défi actuel en paramètre
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
                                            color: AppStyles.cardBackground,
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          clipBehavior: Clip.hardEdge,
                                          // ON PASSE LE DÉFI ICI
                                          child: CreateChallengeScreen(challengeToEdit: challenge),
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    // À implémenter plus tard comme demandé
                                    print("Suppression demandée pour ${challenge.id}");
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20),
                                        SizedBox(width: 8),
                                        Text('Modifier'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Supprimer', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

                // Bouton Action (Check) - Seulement si ce n'est PAS mon défi (ou les deux ?)
                // Généralement on peut liker son propre post, donc on le laisse.
                // Si le menu gêne le bouton, on peut ajuster le layout.
                if (!isMyChallenge) // Optionnel : cacher le bouton check si c'est à moi et que j'ai le menu
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

            const SizedBox(height: 16),

            // --- Bas : Avatar + Date + Likes ---
            // (Code inchangé pour le bas)
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