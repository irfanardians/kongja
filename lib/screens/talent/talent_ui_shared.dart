import 'package:flutter/material.dart';

const Color talentBg = Color(0xFFFFF8E1);
const Color talentAmberDark = Color(0xFFB45309);
const Color talentAmber = Color(0xFFF59E42);
const Color talentPink = Color(0xFFDB2777);
const Color talentPurple = Color(0xFF7C3AED);

class TalentBottomNav extends StatelessWidget {
  const TalentBottomNav({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final items = [
      _TalentNavItem(
        icon: Icons.home_rounded,
        label: 'Home',
        route: '/talent-home',
      ),
      _TalentNavItem(
        icon: Icons.local_activity_rounded,
        label: 'Activity',
        route: '/talent-messages',
      ),
      _TalentNavItem(
        icon: Icons.person_rounded,
        label: 'Profile',
        route: '/talent-profile',
      ),
      _TalentNavItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        route: '/talent-settings',
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -6),
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
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                if (!isActive) {
                  Navigator.pushReplacementNamed(context, item.route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? const LinearGradient(
                                colors: [talentAmberDark, talentAmber],
                              )
                            : null,
                        color: isActive ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF7C746D),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive
                            ? talentAmberDark
                            : const Color(0xFF7C746D),
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

class TalentSectionCard extends StatelessWidget {
  const TalentSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class TalentField extends StatelessWidget {
  const TalentField({
    super.key,
    required this.label,
    required this.icon,
    required this.initialValue,
    this.helper,
    this.trailing,
    this.maxLines = 1,
    this.enabled = true,
    this.controller,
  });

  final String label;
  final IconData icon;
  final String initialValue;
  final String? helper;
  final Widget? trailing;
  final int maxLines;
  final bool enabled;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7F7770)),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: enabled ? Colors.white : const Color(0xFFF4F1ED),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE6DED6)),
            ),
            child: Row(
              crossAxisAlignment: maxLines > 1
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Icon(icon, color: const Color(0xFFA59D96)),
                ),
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    enabled: enabled,
                    initialValue: controller == null ? initialValue : null,
                    maxLines: maxLines,
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
                if (trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: trailing,
                  ),
              ],
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(
              helper!,
              style: const TextStyle(fontSize: 12, color: Color(0xFFA59D96)),
            ),
          ],
        ],
      ),
    );
  }
}

class _TalentNavItem {
  const _TalentNavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}
