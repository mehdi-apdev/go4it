// lib/models/challenge.dart

/*
 * C'est la classe Modèle pour un Défi (Challenge/Post).
 * Elle représente la structure de nos données "Challenge"
 * (telle que définie dans server.js et validée dans Postman).
 */
class Challenge {
  // --- 1. Propriétés (Fields) ---
  // Doivent correspondre aux clés JSON de notre API
  final String id;
  final String userId; // L'auteur du défi
  final String title;
  final String description;
  final String? emoji; // Peut être nul
  final String? imageUrl; // Peut être nul
  final DateTime createdAt; // L'API envoie une String, nous la convertissons en DateTime
  final List<String> dones; // La liste des IDs des utilisateurs qui ont "liké"

  // --- 2. Constructeur ---
  Challenge({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.emoji,
    this.imageUrl,
    required this.createdAt,
    required this.dones,
  });

  // --- 3. Factory 'fromJson' (Le "Décodeur" JSON) ---
  // L'usine qui crée un Challenge à partir du JSON de l'API.
  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      emoji: json['emoji'] as String?,
      imageUrl: json['imageUrl'] as String?,

      // Conversion cruciale :
      // Le JSON envoie une String (ex: "2025-11-12T09:00:00Z")
      // Nous la convertissons en objet DateTime natif de Dart
      // pour pouvoir la trier et l'afficher facilement.
      createdAt: DateTime.parse(json['createdAt'] as String),

      // On convertit la liste JSON (List<dynamic>) en List<String>
      dones: List<String>.from(json['dones']),
    );
  }

/*
   * Note : Remarquez qu'il n'y a pas de 'isCompleted' ici.
   * D'après notre analyse de votre vision "flux social", nous avons
   * remplacé le concept de "complété" par la liste "dones".
   * Un défi est "fait" par vous si votre ID est dans la liste "dones".
   */
}