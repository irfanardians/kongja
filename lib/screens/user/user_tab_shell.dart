import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'home_screen.dart';
import 'messages_screen.dart';
import 'user_profile_screen.dart';
import 'user_ui_shared.dart';

class UserTabShell extends StatefulWidget {
  const UserTabShell({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<UserTabShell> createState() => _UserTabShellState();
}

class _UserTabShellState extends State<UserTabShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = normalizeUserTabRoute(widget.initialRoute);
      if (userTabRouteNotifier.value != route) {
        userTabRouteNotifier.value = route;
      }
    });
  }

  @override
  void didUpdateWidget(covariant UserTabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final route = normalizeUserTabRoute(widget.initialRoute);
    if (route != userTabRouteNotifier.value) {
      userTabRouteNotifier.value = route;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: userTabRouteNotifier,
      builder: (context, selectedRoute, _) {
        final route = normalizeUserTabRoute(selectedRoute);
        final children = <Widget>[
          const HomeScreen(showBottomNav: false),
          const MessagesScreen(showBottomNav: false),
          const FavoritesScreen(showBottomNav: false),
          const UserProfileScreen(showBottomNav: false),
        ];

        return Scaffold(
          body: IndexedStack(
            index: userTabRoutes.indexOf(route),
            children: children,
          ),
          bottomNavigationBar: UserBottomNav(currentRoute: route),
        );
      },
    );
  }
}
