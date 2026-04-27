// Flutter translation of cocoa/src/app/pages/Favorites.tsx
//
// Semua aksi dan input harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /favorites
//
// Komponen reusable dibuat di folder components terpisah.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key, this.showBottomNav = true})
    : super(key: key);

  final bool showBottomNav;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final favorites = demoUserHosts.where((host) => [1, 3, 5].contains(host.id)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userCreamBackground,
      bottomNavigationBar: widget.showBottomNav
          ? const UserBottomNav(currentRoute: '/favorites')
          : null,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  const Row(
                    children: [
                      Icon(Icons.favorite_rounded, color: Color(0xFFE34A57), size: 28),
                      SizedBox(width: 8),
                      Text('Favorites', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Your favorite hosts', style: TextStyle(color: Color(0xFF7D7670), fontSize: 15)),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 16.0;
                      final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: 22,
                        children: favorites
                            .map(
                              (host) => SizedBox(
                                width: itemWidth,
                                child: UserHostCard(
                                  host: host,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    '/profile',
                                    arguments: host,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
