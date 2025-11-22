import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go4it/providers/auth_provider.dart';
import 'package:go4it/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // On décale l'initialisation après la construction de l'interface
    // pour éviter l'erreur "setState() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // 1. On récupère l'AuthProvider
    final authProvider = context.read<AuthProvider>();

    // 2. On lance en PARALLÈLE :
    //    - Le chargement des données (qui peut être rapide)
    //    - Une attente minimale de 3 secondes
    // Le 'await Future.wait' attend que les DEUX soient finis.
    await Future.wait([
      authProvider.fetchCurrentUser(), // Tâche 1 : Chargement réel
      Future.delayed(const Duration(seconds: 3)), // Tâche 2 : Timer minimum
    ]);

    // 3. Une fois les 3 secondes passées ET les données chargées, on navigue
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            // Indicateur de chargement
            CircularProgressIndicator(
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}