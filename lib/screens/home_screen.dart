import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/utils/app_status.dart';
import 'package:go4it/screens/create_challenge_screen.dart';
import 'package:go4it/widgets/challenge_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // On charge le flux au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final feedProvider = context.watch<FeedProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond très légèrement grisé pour faire ressortir les cartes
      appBar: AppBar(
        title: const Text('Mes Défis Du Jour'),
        centerTitle: true, // Titre aligné au centre
        backgroundColor: theme.colorScheme.onSecondaryContainer, // Couleur de fond
        foregroundColor: Colors.white, // Couleur du texte en blanc
        elevation: 0,
      ),
      body: _buildBody(context, feedProvider, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent, // Le fond doit être transparent !
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                // Marges sur les côtés et en bas (plus l'espace du clavier si ouvert)
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 16,
                right: 16,
                // Une petite marge en haut pour ne pas coller au status bar si la modale est grande
                top: 60,
              ),
              child: Container(
                // On limite la hauteur de la bulle (ex: 85% de l'écran max)
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24), // Coins bien arrondis partout
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                // Important : Clip pour que le contenu ne dépasse pas des coins arrondis
                clipBehavior: Clip.hardEdge,
                child: const CreateChallengeScreen(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FeedProvider feedProvider, ThemeData theme) {
    switch (feedProvider.feedStatus) {
      case AppStatus.uninitialized:
      case AppStatus.loading:
        return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));

      case AppStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Oups ! ${feedProvider.feedError}'),
              TextButton(
                onPressed: () => context.read<FeedProvider>().fetchFeed(),
                child: const Text('Réessayer'),
              )
            ],
          ),
        );

      case AppStatus.loaded:
        if (feedProvider.feed.isEmpty) {
          return const Center(child: Text('Aucun défi pour aujourd\'hui.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 12, bottom: 80),
          itemCount: feedProvider.feed.length,
          itemBuilder: (context, index) {
            // On utilise notre belle carte ici
            return ChallengeCard(challenge: feedProvider.feed[index]);
          },
        );
    }
  }
}