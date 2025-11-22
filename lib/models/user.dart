/*
 * C'est la classe Modèle pour un Utilisateur.
 * Elle représente la structure de nos données "User"
 * (telle que définie dans server.js et validée dans Postman).
 */
class User {
  // --- 1. Propriétés (Fields) ---
  // Doivent correspondre aux clés JSON de notre API
  final String id;
  final String username;
  final String? avatarUrl; // Peut être nul
  final List<String> friends; // Une liste d'IDs d'amis

  // --- 2. Constructeur ---
  // Un constructeur standard pour créer un User dans notre code
  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.friends,
  });

  // --- 3. Factory 'fromJson' (Le "Décodeur" JSON) ---
  // C'est la partie la plus importante.
  // C'est une "usine" (factory) qui sait comment construire (créer)
  // un objet User à partir d'un Map (JSON).
  //
  // Nous l'utiliserons dans le Service pour parser
  // la réponse de l'API.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?, // On le cast en String?, car il peut être nul

      // On convertit la liste JSON (qui est List<dynamic>)
      // en une List<String> propre.
      friends: List<String>.from(json['friends']),
    );
  }

  // --- 4. Méthode 'toJson' (L'"Encodeur" JSON) ---
  // Utile si on doit un jour envoyer un objet User complet à l'API.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'friends': friends,
    };
  }
}