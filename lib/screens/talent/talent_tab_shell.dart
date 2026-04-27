import 'package:flutter/material.dart';

import 'talent_home_screen.dart';
import 'talent_messages_screen.dart';
import 'talent_profile_screen.dart';
import 'talent_settings_screen.dart';
import 'talent_ui_shared.dart';

class TalentTabShell extends StatefulWidget {
  const TalentTabShell({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<TalentTabShell> createState() => _TalentTabShellState();
}

class _TalentTabShellState extends State<TalentTabShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = normalizeTalentTabRoute(widget.initialRoute);
      if (talentTabRouteNotifier.value != route) {
        talentTabRouteNotifier.value = route;
      }
    });
  }

  @override
  void didUpdateWidget(covariant TalentTabShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    final route = normalizeTalentTabRoute(widget.initialRoute);
    if (route != talentTabRouteNotifier.value) {
      talentTabRouteNotifier.value = route;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: talentTabRouteNotifier,
      builder: (context, selectedRoute, _) {
        final route = normalizeTalentTabRoute(selectedRoute);
        final children = <Widget>[
          const TalentHomeScreen(showBottomNav: false),
          const TalentMessagesScreen(showBottomNav: false),
          const TalentProfileScreen(showBottomNav: false),
          const TalentSettingsScreen(
            showBottomNav: false,
            showBackButton: false,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: talentTabRoutes.indexOf(route),
            children: children,
          ),
          bottomNavigationBar: TalentBottomNav(currentRoute: route),
        );
      },
    );
  }
}
