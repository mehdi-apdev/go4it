import 'dart:convert'; // Pour json.decode (décoder) et json.encode (encoder)
import 'package:flutter/foundation.dart'; // Pour kDebugMode (savoir si on est en mode debug)
import 'package:http/http.dart' as http; // Le package HTTP
import 'package:go4it/models/challenge.dart'; // Notre modèle
import 'package:go4it/utils/config.dart'; // La configuration



/*
 * C'est la couche "Service" pour les Défis.
 * Son seul rôle est de parler à l'API. Elle ne connaît rien
 * à la gestion d'état (Provider) ou à l'interface (Widgets).
 */
class ChallengeService {

  // En-têtes standards pour envoyer du JSON (POST, PATCH, DELETE)
  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // --- 2. MÉTHODES DE L'API (LE CRUD) ---

  /// GET /api/feed/:userId
  /// Récupère le flux de défis pour l'utilisateur
  Future<List<Challenge>> getFeed(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/feed/$userId'));

    if (response.statusCode == 200) {
      // 1. Décode le texte de la réponse (qui est une String JSON)
      final List<dynamic> jsonList = json.decode(response.body);

      // 2. Transforme la liste de JSON en une liste de Challenges
      // en utilisant notre factory .fromJson de l'Étape B
      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else {
      // Gérer l'erreur
      throw Exception('Failed to load feed');
    }
  }

  /// POST /api/challenges
  /// Crée un nouveau défi
  Future<Challenge> createChallenge({
    required String title,
    required String description,
    required String userId,
    String? emoji,
    String? imageUrl,
  }) async {
    // 1. Crée le "colis" (body) à envoyer
    final body = json.encode({
      'title': title,
      'description': description,
      'userId': userId,
      'emoji': emoji,
      'imageUrl': imageUrl,
    });

    // 2. Fait l'appel POST
    final response = await http.post(
      Uri.parse('$baseUrl/challenges'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 201) { // 201 = Créé
      // 3. Décode la réponse (le nouveau défi) et le renvoie
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create challenge');
    }
  }

  /// POST /api/challenges/:id/done
  /// Ajoute un "done" (like) à un défi
  Future<Challenge> addDone(String challengeId, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/challenges/$challengeId/done'),
      headers: _headers,
      body: json.encode({'userId': userId}), // Dit au serveur QUI "like"
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add done');
    }
  }

  /// DELETE /api/challenges/:id/done
  /// Retire un "done" (unlike)
  Future<Challenge> removeDone(String challengeId, String userId) async {
    // NOTE: http.delete ne supporte pas de body. Nous devons
    // utiliser une méthode manuelle pour envoyer un body avec DELETE.
    final response = await _sendDeleteWithBody(
      Uri.parse('$baseUrl/challenges/$challengeId/done'),
      headers: _headers,
      body: json.encode({'userId': userId}), // Dit au serveur QUI "unlike"
    );

    if (response.statusCode == 200) {
      return Challenge.fromJson(json.decode(await response.stream.bytesToString()));
    } else {
      throw Exception('Failed to remove done');
    }
  }

  /// DELETE /api/challenges/:id
  /// Supprime un défi (requiert le userId pour la sécurité)
  Future<void> deleteChallenge(String challengeId, String userId) async {
    final response = await _sendDeleteWithBody(
      Uri.parse('$baseUrl/challenges/$challengeId'),
      headers: _headers,
      body: json.encode({'userId': userId}), // Prouve qui fait la suppression
    );

    if (response.statusCode != 204) { // 204 = No Content (Succès)
      throw Exception('Failed to delete challenge');
    }
    // Pas de 'return' car la réponse est 204 (vide)
  }

  /// GET /api/history/published/:userId
  /// Récupère l'historique des défis publiés par l'utilisateur
  Future<List<Challenge>> getHistoryPublished(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/history/published/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load published history');
    }
  }

  /// GET /api/history/done/:userId
  /// Récupère l'historique des défis "likés" par l'utilisateur
  Future<List<Challenge>> getHistoryDone(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/history/done/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Challenge.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load done history');
    }
  }

  /// PATCH /api/challenges/:id
  /// Met à jour un défi (Titre, Description, etc.)
  Future<Challenge> updateChallenge({
    required String challengeId,
    required String userId, // Requis pour la vérification de sécurité côté serveur
    String? title,
    String? description,
    String? emoji,
    String? imageUrl,
  }) async {
    // 1. Crée le "colis" (body) à envoyer
    // On n'inclut que les champs qui ne sont pas nulls
    final Map<String, dynamic> data = {'userId': userId};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (emoji != null) data['emoji'] = emoji;
    if (imageUrl != null) data['imageUrl'] = imageUrl;

    final body = json.encode(data);

    // 2. Fait l'appel PATCH.
    // La méthode standard `http.patch` supporte un body.
    final response = await http.patch(
      Uri.parse('$baseUrl/challenges/$challengeId'),
      headers: _headers,
      body: body,
    );

    if (response.statusCode == 200) {
      // 3. Décode la réponse (le défi mis à jour) et le renvoie
      return Challenge.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update challenge');
    }
  }

  // --- 3. MÉTHODE HELPER (Outil interne) ---

  /// Une fonction "helper" pour envoyer une requête DELETE avec un "body",
  /// car le `http.delete()` standard ne le permet pas.
  /// Notre serveur Express a besoin d'un body pour le `userId`.
  Future<http.StreamedResponse> _sendDeleteWithBody(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    try {
      final request = http.Request('DELETE', uri);
      if (body != null) {
        request.body = body as String;
      }
      if (headers != null) {
        request.headers.addAll(headers);
      }
      return await request.send();
    } catch (e) {
      if (kDebugMode) {
        print('Error in _sendDeleteWithBody: $e');
      }
      throw Exception('Failed to send DELETE request with body');
    }
  }
}