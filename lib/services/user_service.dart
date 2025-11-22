import 'dart:convert'; // Pour json.decode et json.encode
import 'package:http/http.dart' as http;
import 'package:go4it/models/user.dart'; // Importe le modèle User
import 'package:go4it/utils/config.dart'; // Importe le baseUrl


class UserService {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // --- AJOUT DU CACHE ---
  // On garde en mémoire les utilisateurs déjà chargés
  // Static pour que le cache soit partagé entre toutes les instances de UserService
  static final Map<String, User> _userCache = {};

  /// GET /api/users/:id
  Future<User> getUserInfo(String userId) async {
    // 1. Vérifier si l'utilisateur est déjà dans le cache
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!; // Retourne immédiatement la version en mémoire
    }

    // 2. Sinon, faire l'appel réseau
    final response = await http.get(Uri.parse('$baseUrl/users/$userId'));

    if (response.statusCode == 200) {
      final user = User.fromJson(json.decode(response.body));

      // 3. Sauvegarder dans le cache pour la prochaine fois
      _userCache[userId] = user;

      return user;
    } else {
      throw Exception('Failed to load user info');
    }
  }

  /// GET /api/users/:userId/friends
  /// Récupère la liste des *objets* User qui sont amis
  Future<List<User>> getUserFriends(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$userId/friends'));

    if (response.statusCode == 200) {
      // 1. Décode la liste JSON
      final List<dynamic> jsonList = json.decode(response.body);
      // 2. La transforme en liste d'objets User
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load friends');
    }
  }

  /// POST /api/users/:userId/friends
  /// Ajoute un nouvel ami.
  /// Renvoie la nouvelle liste d'IDs d'amis de l'utilisateur.
  Future<List<String>> addFriend(String userId, String friendId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/friends'),
      headers: _headers,
      body: json.encode({'friendId': friendId}), // Le "colis" (payload)
    );

    if (response.statusCode == 201) { // 201 = Créé
      // L'API renvoie la nouvelle liste d'IDs d'amis
      // Nous la convertissons en une List<String>
      return List<String>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to add friend');
    }
  }

  /// DELETE /api/users/:userId/friends/:friendId
  /// Supprime un ami
  Future<void> removeFriend(String userId, String friendId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/friends/$friendId'),
    );

    if (response.statusCode != 204) { // 204 = No Content (Succès)
      throw Exception('Failed to remove friend');
    }
    // Pas de 'return' car la réponse est 204 (vide)
  }
}