import 'package:flutter/material.dart';
import 'package:sedo/models/drawer.dart' show MyDrawer;
import 'package:sedo/models/drawer_page.dart';

class firstpage extends StatelessWidget {
  const firstpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerPage(),
      appBar: AppBar(title: const Text('')),
      body: Center(child: Text('S E D O', style: TextStyle(fontSize: 24))),
    );
  }
}
