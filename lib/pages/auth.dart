import 'package:flutter/material.dart';
import 'package:sedo/pages/first.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => firstpage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0)),
                child: Image(image: AssetImage('assets/images/logo.png')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
