import 'package:flutter/foundation.dart';
import 'package:go4it/models/user.dart';
import 'package:go4it/services/user_service.dart';
import 'package:go4it/utils/app_status.dart';

/// Gère l'état de l'utilisateur "connecté"
class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  // --- État ---
  final String _currentUserId = 'u1'; // Simulation de connexion
  User? _currentUser;
  AppStatus _status = AppStatus.uninitialized;
  String? _error;

  // --- Getters ---
  String get currentUserId => _currentUserId;
  User? get currentUser => _currentUser;
  AppStatus get status => _status;
  String? get error => _error;

  /// Récupère les infos de l'utilisateur connecté
  Future<void> fetchCurrentUser() async {
    _status = AppStatus.loading;
    notifyListeners();

    try {
      // Appelle le service pour récupérer les infos de 'u1'
      _currentUser = await _userService.getUserInfo(_currentUserId);
      _status = AppStatus.loaded;
    } catch (e) {
      _status = AppStatus.error;
      _error = e.toString();
      if (kDebugMode) {
        print("Erreur fetchCurrentUser: $e");
      }
    }
    notifyListeners();
  }
}