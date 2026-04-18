// Flutter translation of cocoa/src/app/pages/Home.tsx
//
// Semua komponen input, filter, dan list host harus terhubung ke backend.
// Gunakan Provider/Bloc untuk state management dan koneksi API.
//
// Contoh endpoint:
// - GET /hosts (list host)
// - GET /hosts?city=xxx&query=xxx (filter)
//
// Komponen reusable (HostCard, BottomNav) dibuat di folder components terpisah.
//
// Untuk pengembangan backend, pastikan response sesuai kebutuhan UI.

import 'package:flutter/material.dart';

import 'user_ui_shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeFilter = 'People';
  String searchQuery = '';
  String selectedCity = 'All Cities';
  String citySearchQuery = '';
  bool showCityDropdown = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cities = [
      'All Cities',
      ...{for (final host in demoUserHosts) host.city}.toList()..sort(),
    ];

    final filteredHosts = demoUserHosts.where((host) {
      final matchCity = selectedCity == 'All Cities' || host.city == selectedCity;
      final matchQuery = searchQuery.isEmpty ||
          host.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          host.city.toLowerCase().contains(searchQuery.toLowerCase());
      final matchFilter = switch (activeFilter) {
        'Online' => host.isOnline,
        'VIP' => host.badges.any((badge) => badge.toLowerCase().contains('vip')),
        _ => true,
      };
      return matchCity && matchQuery && matchFilter;
    }).toList();
    final topHosts = filteredHosts.take(3).toList();
    final newHosts = filteredHosts.length > 3 ? filteredHosts.skip(3).toList() : <DemoUserHost>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      bottomNavigationBar: const UserBottomNav(currentRoute: '/home'),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
                  // Header
                  Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Attention', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                children: const [
                                  Icon(Icons.account_balance_wallet, color: Colors.amber, size: 18),
                                  SizedBox(width: 4),
                                  Text('🪙 1,250', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.notifications, color: Colors.brown, size: 28),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Find Someone to Talk With', style: TextStyle(color: Colors.black54, fontSize: 15)),
                    const SizedBox(height: 16),
                    // Search
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search by name or city...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                      ),
                      onChanged: (val) => setState(() => searchQuery = val),
                    ),
                    const SizedBox(height: 12),
                    // City Selector
                    Stack(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on, color: Colors.grey),
                            hintText: 'Search cities...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          ),
                          controller: _cityController,
                          onChanged: (val) => setState(() {
                            citySearchQuery = val;
                            showCityDropdown = true;
                          }),
                          onTap: () => setState(() => showCityDropdown = true),
                        ),
                        if (showCityDropdown)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 48,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              constraints: const BoxConstraints(maxHeight: 180),
                              child: ListView(
                                shrinkWrap: true,
                                children: cities
                                    .where((city) => city.toLowerCase().contains(citySearchQuery.toLowerCase()))
                                    .map((city) => ListTile(
                                          leading: const Icon(Icons.location_on, size: 18, color: Colors.grey),
                                          title: Text(city),
                                          selected: selectedCity == city,
                                          onTap: () {
                                            setState(() {
                                              selectedCity = city;
                                              citySearchQuery = city;
                                              _cityController.text = city;
                                              showCityDropdown = false;
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Filter
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ['People', 'Online', 'New', 'VIP'].map((filter) {
                          final selected = activeFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: selected,
                              selectedColor: Colors.brown,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(color: selected ? Colors.white : Colors.brown),
                              onSelected: (_) => setState(() => activeFilter = filter),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              if (topHosts.isNotEmpty)
                _buildHostSection(
                  title: 'Top Hosts',
                  sectionHosts: topHosts,
                ),

              if (newHosts.isNotEmpty)
                _buildHostSection(
                  title: 'New Hosts',
                  sectionHosts: newHosts,
                ),

              // No Results
              if (topHosts.isEmpty && newHosts.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text('No hosts found matching your search', style: TextStyle(color: Colors.black54)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHostSection({
    required String title,
    required List<DemoUserHost> sectionHosts,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () {},
                child: const Text('See All >', style: TextStyle(color: Colors.brown)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 16.0;
              final itemWidth = (constraints.maxWidth - (spacing * 2)) / 3;

              return Wrap(
                spacing: spacing,
                runSpacing: 20,
                children: List.generate(sectionHosts.length, (idx) {
                  return SizedBox(
                    width: itemWidth,
                    child: UserHostCard(
                      host: sectionHosts[idx],
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }


}
