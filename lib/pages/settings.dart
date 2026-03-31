import 'package:flutter/material.dart';
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/themes/theme_provider.dart' show ThemeProvider;
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerPage(onItemTap: (index) {}),
      appBar: AppBar(title: Text('S E T T I N G S')),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Dark Mode',
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
            ],
          ),
        ],
      ),
    );
  }
}
