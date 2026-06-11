// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sedo/pages/auth.dart';
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/service/playlist_provider.dart';
import 'package:sedo/themes/theme_provider.dart';

import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Keep screen awake
  await WakelockPlus.enable();

  // Landscape only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => PlaylistProvider()),

        ChangeNotifierProvider(
          create: (_) {
            final gpsProvider = SpeedProvider();

            // Start GPS once for entire app
            gpsProvider.startTracking();

            return gpsProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeDate,
      home: const Auth(),
    );
  }
}
