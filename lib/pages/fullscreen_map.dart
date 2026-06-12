import 'package:flutter/material.dart';
import 'package:sedo/pages/drawer_secondary.dart' show DrawerSecondary;
import 'package:sedo/pages/map_page.dart' show MapPage;

class FullscreenMap extends StatelessWidget {
  const FullscreenMap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(drawer: DrawerSecondary(), body: MapPage());
  }
}
