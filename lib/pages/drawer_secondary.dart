// ignore_for_file: avoid_unnecessary_containers, unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart';

import 'package:sedo/pages/homepage.dart' show Homepage;

class DrawerSecondary extends StatelessWidget {
  const DrawerSecondary({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homepage()),
          );
        },
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'DASHBOARD',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
