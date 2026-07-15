// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sedo/pages/homepage.dart' show Homepage;
import 'package:sedo/pages/map_settings.dart';
import 'package:sedo/pages/picture.dart';
import 'package:sedo/pages/settings.dart';

class DrawerPage extends StatelessWidget {
  final Function(int) onItemTap;

  const DrawerPage({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface.withOpacity(0.92),
      child: SafeArea(
        child: ListView(
          children: [
            // Header
            const SizedBox(height: 16),

            // Navigation grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _DrawerItem(
                        icon: Icons.speed,
                        label: 'Speedo',
                        onTap: () {
                          onItemTap(0);
                          Navigator.pop(context);
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.music_note,
                        label: 'Music',
                        onTap: () {
                          onItemTap(2);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _DrawerItem(
                        icon: Icons.home,
                        label: 'Home',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const Homepage()),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ImageGalleryPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _DrawerItem(
                        icon: Icons.settings,
                        label: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                      _DrawerItem(
                        icon: Icons.map_outlined,
                        label: 'Map',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapSettings(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single drawer grid item with icon and label.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: cs.secondary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.inversePrimary.withOpacity(0.06)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: cs.tertiary),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: cs.inversePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
