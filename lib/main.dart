import 'package:flutter/material.dart';
import 'package:provider/provider.dart'
    show MultiProvider, ChangeNotifierProvider, Provider;
import 'package:sedo/pages/first.dart';
import 'package:sedo/themes/theme_provider.dart' show ThemeProvider;

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => ThemeProvider())],
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
      home: firstpage(),
      theme: Provider.of<ThemeProvider>(context).themeDate,
    );
  }
}
