// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'
    show MultiProvider, ChangeNotifierProvider, Provider;
import 'package:sedo/pages/auth.dart' show Auth;
import 'package:sedo/pages/first.dart';
import 'package:sedo/service/playlist_provider.dart' show PlaylistProvider;
import 'package:sedo/themes/theme_provider.dart' show ThemeProvider;

import 'pages/map_page.dart' show MapPage;
import 'pages/musicplayer_page.dart' show MusicplayerPage;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Auth(),
      theme: Provider.of<ThemeProvider>(context).themeDate,
    );
  }
}
