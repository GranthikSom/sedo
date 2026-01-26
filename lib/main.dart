import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sedo/pages/first.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight, // or landscapeLeft / landscapeRight
  ]).then((_) {
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: firstpage()));
  });
}
