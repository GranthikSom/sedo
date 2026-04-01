import 'package:flutter/material.dart';
import 'package:sedo/models/ball.dart';

import '../models/box.dart' show Box;
import 'first.dart' show firstpage;
import 'settings.dart';

class MapSettings extends StatefulWidget {
  const MapSettings({super.key});

  @override
  State<MapSettings> createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('MAP CONTROLS'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => firstpage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ball(
                      child: CircleAvatar(
                        radius: 49,
                        child: Icon(
                          Icons.search,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 49,
                      child: Ball(
                        child: Icon(
                          Icons.local_gas_station,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ball(
                      child: CircleAvatar(
                        radius: 49,
                        child: Icon(
                          Icons.speed,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => firstpage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ball(
                      child: CircleAvatar(
                        radius: 49,
                        child: Icon(
                          Icons.home,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => firstpage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ball(
                      child: CircleAvatar(
                        radius: 49,
                        child: Icon(
                          Icons.home,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Ball(
                      child: CircleAvatar(
                        radius: 49,
                        child: Icon(
                          Icons.settings,
                          size: 40,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
