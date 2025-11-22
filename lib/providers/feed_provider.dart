import 'package:flutter/foundation.dart';
import 'package:go4it/models/challenge.dart';
import 'package:go4it/services/challenge_service.dart';
import 'package:go4it/utils/app_status.dart';
import 'package:go4it/providers/auth_provider.dart';

/// Gère l'état du flux (feed) principal
class FeedProvider extends ChangeNotifier {
  // --- Dépendances ---
  final ChallengeService _challengeService = ChallengeService();
  final AuthProvider _authProvider; // Le lien vers l'autre provider

  // --- État ---
  List<Challenge> _feed = [];
  AppStatus _feedStatus = AppStatus.uninitialized;
  String? _feedError;

  // --- Getters ---
  List<Challenge> get feed => _feed;
  AppStatus get feedStatus => _feedStatus;
  String? get feedError => _feedError;

  // --- Constructeur ---
  FeedProvider(this._authProvider);

  /// Récupère le flux principal
  Future<void> fetchFeed() async {
    // Si l'utilisateur n'est pas chargé, on ne peut pas charger le flux
    if (_authProvider.currentUser == null) return;

    _feedStatus = AppStatus.loading;
    notifyListeners();

    try {
      // On délègue l'appel réseau au SERVICE
      _feed = await _challengeService.getFeed(_authProvider.currentUserId);
      _feedStatus = AppStatus.loaded;
    } catch (e) {
      _feedStatus = AppStatus.error;
      _feedError = e.toString();
      if (kDebugMode) {
        print("Erreur fetchFeed: $e");
      }
    }
    notifyListeners();
  }

  /// Gère le "like" ou "unlike" d'un défi
  Future<void> toggleDone(String challengeId) async {
    final challengeIndex = _feed.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _feed[challengeIndex];
    final userId = _authProvider.currentUserId;
    bool isCurrentlyDone = challenge.dones.contains(userId);

    try {
      Challenge updatedChallenge;
      if (isCurrentlyDone) {
        // Appel au SERVICE pour retirer le done
        updatedChallenge = await _challengeService.removeDone(challengeId, userId);
      } else {
        // Appel au SERVICE pour ajouter le done
        updatedChallenge = await _challengeService.addDone(challengeId, userId);
      }

      // Met à jour la liste locale avec le défi retourné par le service
      _feed[challengeIndex] = updatedChallenge;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur toggleDone: $e");
      }
      // Ici, vous pourriez ajouter une gestion d'erreur spécifique (ex: SnackBar)
    }
  }

  /// Crée un nouveau défi et l'ajoute au flux
  Future<void> createChallenge(String title, String description, {String? emoji, String? imageUrl}) async {
    try {
      // Appel au SERVICE
      final newChallenge = await _challengeService.createChallenge(
        title: title,
        description: description,
        userId: _authProvider.currentUserId,
        emoji: emoji,
        imageUrl: imageUrl,
      );

      // Ajoute le nouveau défi tout en haut de la liste locale
      _feed.insert(0, newChallenge);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur createChallenge: $e");
      }
      rethrow; // On renvoie l'erreur pour que l'UI puisse l'afficher
    }
  }

  /// Met à jour un défi existant dans le flux
  Future<void> updateChallenge({
    required String challengeId,
    String? title,
    String? description,
    String? emoji,
    String? imageUrl,
  }) async {
    try {
      // Appel au SERVICE
      final updatedChallenge = await _challengeService.updateChallenge(
        challengeId: challengeId,
        userId: _authProvider.currentUserId,
        title: title,
        description: description,
        emoji: emoji,
        imageUrl: imageUrl,
      );

      // Met à jour le défi dans la liste locale s'il s'y trouve
      final index = _feed.indexWhere((c) => c.id == challengeId);
      if (index != -1) {
        _feed[index] = updatedChallenge;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Erreur updateChallenge: $e");
      }
      rethrow;
    }
  }

  /// Supprime un défi
  Future<void> deleteChallenge(String challengeId) async {
    try {
      // 1. Appel au SERVICE
      await _challengeService.deleteChallenge(challengeId, _authProvider.currentUserId);

      // 2. Mise à jour locale : on retire le défi de la liste
      _feed.removeWhere((c) => c.id == challengeId);

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur deleteChallenge: $e");
      }
      rethrow;
    }
  }
}