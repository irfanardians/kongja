import 'package:flutter/material.dart';

import 'core/auth/auth_session.dart';
import 'screens/talent/talent_tab_shell.dart';
import 'screens/talent/register_talent_screen.dart';
import 'screens/shared/loading_splash.dart';
import 'screens/user/login_screen.dart';
import 'screens/user/register_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/chat_screen.dart';
import 'screens/user/settings_screen.dart';
import 'screens/user/topup_screen.dart';
import 'screens/user/transaction_history_screen.dart';
import 'screens/user/user_tab_shell.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthSession.instance.restore();
  runApp(MyApp(initialRoute: AuthSession.instance.launchRoute));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  static final Map<String, WidgetBuilder> _routeBuilders = {
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/home': (context) => const UserTabShell(initialRoute: '/home'),
    '/profile': (context) => const ProfileScreen(),
    '/chat': (context) => const ChatScreen(),
    '/messages': (context) => const UserTabShell(initialRoute: '/messages'),
    '/settings': (context) => const SettingsScreen(),
    '/favorites': (context) => const UserTabShell(initialRoute: '/favorites'),
    '/topup': (context) => const TopUpScreen(),
    '/transactions': (context) => const TransactionHistoryScreen(),
    '/user-profile': (context) =>
      const UserTabShell(initialRoute: '/user-profile'),
    '/talent-home': (context) =>
      const TalentTabShell(initialRoute: '/talent-home'),
    '/talent-profile': (context) =>
      const TalentTabShell(initialRoute: '/talent-profile'),
    '/talent-messages': (context) =>
      const TalentTabShell(initialRoute: '/talent-messages'),
    '/talent-settings': (context) =>
      const TalentTabShell(initialRoute: '/talent-settings'),
    '/register-talent': (context) => const RegisterTalentScreen(),
  };

  Route<dynamic>? _buildRoute(RouteSettings settings) {
    final builder = _routeBuilders[settings.name];
    if (builder == null) {
      return null;
    }

    return MaterialPageRoute<dynamic>(settings: settings, builder: builder);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talent Profile Demo',
      builder: (context, child) {
        return AppLoadingOverlay(child: child ?? const SizedBox.shrink());
      },
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
      initialRoute: initialRoute,
      onGenerateRoute: _buildRoute,
    );
  }
}

// Sisa kode MyHomePage dan _MyHomePageState benar-benar dihapus
// Sisa kode MyHomePage dan _MyHomePageState dihapus karena sudah tidak digunakan
