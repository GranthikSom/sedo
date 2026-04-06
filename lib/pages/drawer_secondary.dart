// ignore_for_file: avoid_unnecessary_containers, unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart';
import 'package:sedo/pages/first.dart' show firstpage;

class DrawerSecondary extends StatelessWidget {
  const DrawerSecondary({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      child: Container(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => firstpage()),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Go to Dashboard',
                style: TextStyle(
                  fontSize: 18,
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
