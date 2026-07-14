import 'package:flutter/material.dart';
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/pages/map_page.dart';
import 'package:sedo/pages/speedometer.dart';
import 'musicplayer_page.dart' show MusicPlayerPage;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pages = [
    const SpeedometerPage(),
    const SpeedometerPage(), // ponytail: index 1 kept for drawer parity, remove when drawer indices are fixed
    const MusicPlayerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,

      drawer: DrawerPage(onItemTap: changePage),

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

          // Interactive UI page layer
          Positioned.fill(
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                Expanded(child: pages[currentIndex]),
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
