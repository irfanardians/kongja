import 'package:flutter/material.dart';

const Color userCreamBackground = Color(0xFFF5F1E8);
const Color userAmber = Color(0xFF9A654D);
const Color userAmberDark = Color(0xFF8B5A3C);
const Color userAmberLight = Color(0xFFD08D43);

class DemoUserHost {
  const DemoUserHost({
    required this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.countryCode,
    required this.description,
    required this.imageUrl,
    required this.pricePerMin,
    required this.rating,
    required this.reviewCount,
    required this.badges,
    required this.portfolio,
    required this.isOnline,
    required this.location,
  });

  final int id;
  final String name;
  final int age;
  final String city;
  final String countryCode;
  final String description;
  final String imageUrl;
  final int pricePerMin;
  final double rating;
  final int reviewCount;
  final List<String> badges;
  final List<String> portfolio;
  final bool isOnline;
  final String location;
}

const List<DemoUserHost> demoUserHosts = [
  DemoUserHost(
    id: 1,
    name: 'Clara',
    age: 24,
    city: 'Manila',
    countryCode: 'PH',
    description: 'Sweet & Caring',
    imageUrl: 'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=800',
    pricePerMin: 30,
    rating: 4.9,
    reviewCount: 125,
    badges: ['Friendly', 'Verified', 'Travel Buddy'],
    portfolio: [
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=400',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
    ],
    isOnline: true,
    location: 'Makati, Manila',
  ),
  DemoUserHost(
    id: 2,
    name: 'Sophie',
    age: 23,
    city: 'Bandung',
    countryCode: 'ID',
    description: 'Elegant & Fun',
    imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    pricePerMin: 28,
    rating: 4.8,
    reviewCount: 92,
    badges: ['Music', 'Late Night Chat'],
    portfolio: [
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
    ],
    isOnline: false,
    location: 'Dago, Bandung',
  ),
  DemoUserHost(
    id: 3,
    name: 'Emma',
    age: 26,
    city: 'Surabaya',
    countryCode: 'US',
    description: 'Cheerful Soul',
    imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800',
    pricePerMin: 32,
    rating: 4.7,
    reviewCount: 88,
    badges: ['Voice Call', 'Good Listener'],
    portfolio: [
      'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400',
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
    ],
    isOnline: true,
    location: 'West Surabaya',
  ),
  DemoUserHost(
    id: 4,
    name: 'Mia',
    age: 25,
    city: 'Bali',
    countryCode: 'VN',
    description: 'Kind Hearted',
    imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=800',
    pricePerMin: 27,
    rating: 4.9,
    reviewCount: 140,
    badges: ['Travel', 'Offline Meet'],
    portfolio: [
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
    ],
    isOnline: false,
    location: 'Seminyak, Bali',
  ),
  DemoUserHost(
    id: 5,
    name: 'Nara',
    age: 22,
    city: 'Medan',
    countryCode: 'JP',
    description: 'Sweet Smile',
    imageUrl: 'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=800',
    pricePerMin: 25,
    rating: 4.8,
    reviewCount: 64,
    badges: ['Gaming', 'Study Buddy'],
    portfolio: [
      'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=400',
      'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=400',
    ],
    isOnline: true,
    location: 'Central Medan',
  ),
  DemoUserHost(
    id: 6,
    name: 'Lia',
    age: 27,
    city: 'Makassar',
    countryCode: 'TH',
    description: 'Playful Cat',
    imageUrl: 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=800',
    pricePerMin: 35,
    rating: 4.9,
    reviewCount: 111,
    badges: ['VIP', 'Video Call'],
    portfolio: [
      'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?w=400',
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    ],
    isOnline: true,
    location: 'Panakkukang, Makassar',
  ),
];

class UserBottomNav extends StatelessWidget {
  const UserBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = [
      _BottomNavItem(icon: Icons.home_rounded, label: 'Home', route: '/home'),
      _BottomNavItem(icon: Icons.message_rounded, label: 'Messages', route: '/messages'),
      _BottomNavItem(icon: Icons.favorite_rounded, label: 'Favorites', route: '/favorites'),
      _BottomNavItem(icon: Icons.person_rounded, label: 'Profile', route: '/user-profile'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE8E1D8))),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isActive = currentRoute == item.route;
            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (!isActive) {
                  Navigator.pushReplacementNamed(context, item.route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive ? userAmberDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        size: 20,
                        color: isActive ? Colors.white : const Color(0xFF7F7A75),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive ? userAmberDark : const Color(0xFF7F7A75),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class UserFlagBadge extends StatelessWidget {
  const UserFlagBadge({super.key, required this.countryCode});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        countryCode,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF303030),
        ),
      ),
    );
  }
}

class UserHostCard extends StatelessWidget {
  const UserHostCard({super.key, required this.host, this.onTap});

  final DemoUserHost host;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 0.78,
                    child: Image.network(host.imageUrl, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: host.isOnline ? const Color(0xFF3BC45B) : const Color(0xFFC9C9C9),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: UserFlagBadge(countryCode: host.countryCode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${host.name}, ${host.age}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFFE54184)),
              const SizedBox(width: 2),
              Text(
                host.city,
                style: const TextStyle(fontSize: 14, color: Color(0xFF7A716D)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            host.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8A633D)),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on, size: 16, color: Color(0xFFF1B62D)),
              const SizedBox(width: 2),
              Text(
                '${host.pricePerMin} / Min',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF1B62D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}