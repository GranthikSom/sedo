import 'package:flutter/material.dart';
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/pages/map_page.dart';
import 'package:sedo/pages/speedometer.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,

      drawer: const DrawerPage(),

      body: Stack(
        children: [
          const Positioned.fill(child: MapPage()),

          // Non-interactive gradient overlay above the map (theme-aware)
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                children: [
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            cs.surface.withOpacity(0.92),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speedometer (always visible)
          Positioned.fill(
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                const Expanded(child: SpeedometerPage()),
              ],
            ),
          ),

          // Drawer menu button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu,
                  size: 26,
                  color: cs.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

