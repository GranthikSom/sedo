// ignore_for_file: unused_import, camel_case_types

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sedo/models/box.dart';
import 'package:sedo/models/drawer_page.dart';
import 'package:sedo/pages/map_page.dart';
import 'package:sedo/pages/speedometer.dart';
import 'package:sedo/models/future.dart';

import 'musicplayer_page.dart'
    show MusicPlayerPage, MusicplayerPage, SedoMusicBridgeApp;

class firstpage extends StatefulWidget {
  const firstpage({super.key});

  @override
  State<firstpage> createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
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
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                Expanded(
                  child: Box(
                    child: Center(
                      child: SizedBox(
                        width: 450,
                        height: 450,
                        child: IndexedStack(
                          index: currentIndex,
                          children: pages,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // iOS only for testing
          if (Platform.isAndroid)
            Positioned(
              width: 100,
              height: 100,

              child: FloatingActionButton(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.inversePrimary.withOpacity(0),
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
