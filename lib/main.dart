import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

// Imports des Providers
import 'package:go4it/providers/auth_provider.dart';
import 'package:go4it/providers/feed_provider.dart';
import 'package:go4it/providers/friends_provider.dart'; // <-- NOUVEAU
import 'package:go4it/providers/history_provider.dart';

// Imports des Ecrans
import 'package:go4it/screens/splash_screen.dart';

// Nos couleurs de base
const Color primaryBlue = Color(0xFF283593);
const Color accentGreen = Color(0xFF00BFA5);

void main() {
  // Initialise les messages en français pour la librairie timeago.
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthProvider (Indépendant)
        ChangeNotifierProvider(create: (context) => AuthProvider()),

        // 2. FeedProvider (Dépend de Auth)
        ChangeNotifierProxyProvider<AuthProvider, FeedProvider>(
          create: (context) => FeedProvider(context.read<AuthProvider>()),
          update: (context, auth, prev) => FeedProvider(auth),
        ),

        // 3. FriendsProvider (Dépend de Auth)
        ChangeNotifierProxyProvider<AuthProvider, FriendsProvider>(
          create: (context) => FriendsProvider(context.read<AuthProvider>()),
          update: (context, auth, prev) => FriendsProvider(auth),
        ),

        // 4. HistoryProvider (Dépend de Auth)
        ChangeNotifierProxyProvider<AuthProvider, HistoryProvider>(
          create: (context) => HistoryProvider(context.read<AuthProvider>()),
          update: (context, auth, prev) => HistoryProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Go4it',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlue,
            primary: primaryBlue,
            secondary: accentGreen,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
          ),
          // Style global pour les FloatingActionButton
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: accentGreen,
            foregroundColor: Colors.white,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}