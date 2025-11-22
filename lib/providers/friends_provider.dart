import 'package:flutter/foundation.dart';
import 'package:go4it/models/user.dart';
import 'package:go4it/services/user_service.dart';
import 'package:go4it/utils/app_status.dart';
import 'package:go4it/providers/auth_provider.dart';

/// Gère l'état de la liste d'amis
class FriendsProvider extends ChangeNotifier {
  // --- Dépendances ---
  final UserService _userService = UserService();
  final AuthProvider _authProvider;

  // --- État ---
  List<User> _friends = [];
  AppStatus _status = AppStatus.uninitialized;
  String? _error;

  // --- Getters ---
  List<User> get friends => _friends;
  AppStatus get status => _status;
  String? get error => _error;

  // --- Constructeur ---
  FriendsProvider(this._authProvider);

  /// Récupère la liste des amis
  Future<void> fetchFriends() async {
    if (_authProvider.currentUser == null) return;

    _status = AppStatus.loading;
    notifyListeners();

    try {
      // Appel au SERVICE
      _friends = await _userService.getUserFriends(_authProvider.currentUserId);
      _status = AppStatus.loaded;
    } catch (e) {
      _status = AppStatus.error;
      _error = e.toString();
      if (kDebugMode) {
        print("Erreur fetchFriends: $e");
      }
    }
    notifyListeners();
  }

  /// Ajoute un nouvel ami via son ID
  Future<void> addFriend(String friendId) async {
    try {
      // Appel au SERVICE
      // Note: Notre API renvoie la nouvelle liste d'IDs, mais pour l'affichage
      // complet (avec nom/avatar), il est souvent plus simple de recharger
      // la liste complète ou d'ajouter l'objet manuellement si on l'avait.
      // Ici, on va simplement recharger la liste pour être sûr d'avoir les infos à jour.

      await _userService.addFriend(_authProvider.currentUserId, friendId);

      // Recharge la liste pour avoir les détails complets du nouvel ami
      await fetchFriends();

    } catch (e) {
      if (kDebugMode) {
        print("Erreur addFriend: $e");
      }
      rethrow;
    }
  }

  /// Supprime un ami
  Future<void> removeFriend(String friendId) async {
    try {
      // Appel au SERVICE
      await _userService.removeFriend(_authProvider.currentUserId, friendId);

      // Met à jour la liste locale directement (optimiste)
      _friends.removeWhere((user) => user.id == friendId);
      notifyListeners();

    } catch (e) {
      if (kDebugMode) {
        print("Erreur removeFriend: $e");
      }
      // En cas d'erreur, on pourrait recharger la liste pour être sûr de l'état
      await fetchFriends();
      rethrow;
    }
  }
}