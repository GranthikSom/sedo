import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart' show Box;
import 'package:sedo/pages/first.dart';
import 'package:sedo/pages/settings.dart';

class DrawerPage extends StatelessWidget {
  const DrawerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.home,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
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
                  child: Box(
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Icon(
                            Icons.settings,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
