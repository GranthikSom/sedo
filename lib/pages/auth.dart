import 'package:flutter/material.dart';
import 'package:sedo/pages/first.dart';
import 'package:sedo/service/firebaseauth.dart';

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
                  Image.asset('assets/images/logo.png', width: 300),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const firstpage(),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const firstpage(),
                              ),
                            );
                          },
                          child: Container(
                            width: 200,
                            height: 50,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage('assets/images/apple.png'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const firstpage(),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const firstpage(),
                              ),
                            );
                            final userCredential = await AuthService()
                                .signInWithGoogle();

                            if (userCredential != null) {
                              print(userCredential.user?.email);
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 50,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage('assets/images/google.png'),
                                //fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Log in with your account',
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
