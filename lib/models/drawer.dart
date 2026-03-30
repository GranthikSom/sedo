import 'package:flutter/material.dart';
import 'package:sedo/pages/first.dart';
import 'package:sedo/pages/settings.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.secondary.withOpacity(0.99),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 40),
            child: ListTile(
              title: const Text('H O M E', style: TextStyle(fontSize: 24)),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => firstpage()),
                );
              },
            ),
          ),

          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 0),
            child: ListTile(
              title: const Text(
                'P R O F I L E',
                style: TextStyle(fontSize: 24),
              ),
              leading: const Icon(Icons.person),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => firstpage()),
                );
              },
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(left: 25, top: 0),
            child: ListTile(
              title: const Text(
                'S E T T I N G S',
                style: TextStyle(fontSize: 24),
              ),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
