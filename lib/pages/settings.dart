// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sedo/pages/about.dart';
import 'package:sedo/pages/auth.dart';
import 'package:sedo/pages/drawer_secondary.dart' show DrawerSecondary;
import 'package:sedo/service/firebaseauth.dart';

import 'package:sedo/themes/theme_provider.dart' show ThemeProvider;
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSecondary(),
      appBar: AppBar(title: Text('S E T T I N G S')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.tertiary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'light Mode',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          //switch
                          Switch(
                            value: Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).isDarkMode,
                            onChanged: (value) => Provider.of<ThemeProvider>(
                              context,
                              listen: false,
                            ).toggleTheme(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AboutPage()),
                        );
                      },
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text("about", style: TextStyle(fontSize: 30)),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await AuthService().signOut();
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const Auth()),
                        );
                      },

                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text("Logout", style: TextStyle(fontSize: 30)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
