import 'package:flutter/material.dart';
import 'screens/talent/talent_profile_screen.dart';
import 'screens/talent/talent_home_screen.dart';
import 'screens/talent/talent_messages_screen.dart';
import 'screens/talent/talent_settings_screen.dart';
import 'screens/talent/register_talent_screen.dart';
import 'screens/user/login_screen.dart';
import 'screens/user/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/chat_screen.dart';
import 'screens/user/messages_screen.dart';
import 'screens/user/settings_screen.dart';
import 'screens/user/favorites_screen.dart';
import 'screens/user/topup_screen.dart';
import 'screens/user/transaction_history_screen.dart';
import 'screens/user/user_profile_screen.dart';

class _NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talent Profile Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9A654D)),
        scaffoldBackgroundColor: const Color(0xFFF5F1E8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.iOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.macOS: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.windows: _NoAnimationPageTransitionsBuilder(),
            TargetPlatform.linux: _NoAnimationPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: '/login',
      routes: {
        // User routes
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat': (context) => const ChatScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/topup': (context) => const TopUpScreen(),
        '/transactions': (context) => const TransactionHistoryScreen(),
        '/user-profile': (context) => const UserProfileScreen(),

        // Talent routes
        '/talent-home': (context) => const TalentHomeScreen(),
        '/talent-profile': (context) => const TalentProfileScreen(),
        '/talent-messages': (context) => const TalentMessagesScreen(),
        '/talent-settings': (context) => const TalentSettingsScreen(),
        '/register-talent': (context) => const RegisterTalentScreen(),
      },
    );
  }
}

// Sisa kode MyHomePage dan _MyHomePageState benar-benar dihapus
// Sisa kode MyHomePage dan _MyHomePageState dihapus karena sudah tidak digunakan
