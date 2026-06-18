import 'package:flutter/material.dart';
import 'package:sedo/pages/first.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),

          // Dark overlay (optional, makes text easier to read)
          Container(color: Colors.black.withOpacity(0.3)),

          // Center Content
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const firstpage()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Image.asset('assets/images/logo.png', width: 400),

                  // Subtitle
                  const Text(
                    'Tap anywhere on the logo to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const Text(
                    'Sedo Test Mk1',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
