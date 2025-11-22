// Un simple 'enum' pour suivre l'état des requêtes API
enum AppStatus {
  uninitialized, // L'état initial, avant tout appel
  loading,       // En cours de chargement
  loaded,        // Chargement terminé avec succès
  error          // Le chargement a échoué
}