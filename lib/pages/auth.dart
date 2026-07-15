import 'package:flutter/material.dart';

import 'package:sedo/pages/homepage.dart';
import 'package:sedo/service/firebaseauth.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/images/bg.jpg', fit: BoxFit.cover),
          ),

          // Dark overlay for readability
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Image.asset('assets/images/logo.png', width: 300),

                const SizedBox(height: 24),

                // Sign-in buttons
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Apple Sign-In button
                    Container(
                      width: 220,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/apple.png'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Google Sign-In button
                    GestureDetector(
                      onTap: () async {
                        final userCredential = await AuthService()
                            .signInWithGoogle();

                        if (userCredential != null) {
                          if (!context.mounted) return;

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Homepage(),
                            ),
                          );
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sign in failed'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: cs.secondary,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 220,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/images/google.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Log in with your account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: cs.inversePrimary.withOpacity(0.7),
                    fontSize: 12,
                    letterSpacing: 0.5,
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
