import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart';
//import 'package:sedo/models/drawer.dart' show MyDrawer;
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/pages/map_page.dart';
import 'package:sedo/pages/map_settings.dart';
import 'package:sedo/pages/speedometer.dart';

import 'musicplayer_page.dart' show MusicplayerPage;

class firstpage extends StatefulWidget {
  const firstpage({super.key});

  @override
  State<firstpage> createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
  int currentIndex = 0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pages = [
    MapSettings(),
    SpeedometerPage(),
    MusicplayerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerPage(onItemTap: changePage),

      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Box(
              child: Center(
                child: SizedBox(width: 450, height: 430, child: MapPage()),
              ),
            ),
          ),
          Expanded(
            child: Box(
              child: Center(
                child: SizedBox(
                  width: 450,
                  height: 450,
                  child: ClipRRect(
                    child: IndexedStack(index: currentIndex, children: pages),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
