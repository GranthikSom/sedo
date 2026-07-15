import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sedo/firebase_options.dart' show DefaultFirebaseOptions;
import 'package:sedo/pages/auth.dart';

import 'package:sedo/pages/homepage.dart' show Homepage;
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/service/map_settings_provider.dart';
import 'package:sedo/navigation/navigation_session_provider.dart';
import 'package:sedo/navigation/navigation_search_provider.dart';
import 'package:sedo/themes/theme_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //runApp(const MyApp());

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
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

        ChangeNotifierProvider(
          create: (_) {
            final gpsProvider = SpeedProvider();

            // Start GPS once for entire app
            gpsProvider.startTracking();

            return gpsProvider;
          },
        ),
        ChangeNotifierProvider(create: (_) => MapSettingsProvider()),
        ChangeNotifierProvider(create: (_) => NavigationSessionProvider()),
        ChangeNotifierProvider(create: (_) => NavigationSearchProvider()),
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
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User logged in
          if (snapshot.hasData) {
            return const Homepage();
          }

          // User not logged in
          return const Auth();
        },
      ),
    );
  }
}
