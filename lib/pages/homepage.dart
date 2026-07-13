// ignore_for_file: unused_import, camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart';
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/pages/map_page.dart';

import 'package:sedo/pages/speedometer.dart';
import 'package:sedo/models/future.dart';

import 'musicplayer_page.dart' show MusicPlayerPage;

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentIndex = 0;

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pages = [
    SpeedometerPage(),
    // MapSettings(),
    Future(),
    MusicPlayerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      extendBodyBehindAppBar: true,

      drawer: DrawerPage(onItemTap: changePage),

      body: Stack(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.inversePrimary.withOpacity(0.7),
                    blurRadius: 20,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              child: MapPage(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: SizedBox()),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: pages[currentIndex],
                ),
              ),
            ],
          ),

          // iOS only for testing
          if (Platform.isAndroid)
            Positioned(
              width: 100,
              height: 100,

              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                //mini: true,
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Icon(
                  Icons.menu,
                  size: 40,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
