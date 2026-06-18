import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sedo/pages/drawer_secondary.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openGithub() async {
    final uri = Uri.parse('https://github.com/GranthikSom/sedo');

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerSecondary(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            Text(
              "SEDO",
              style: GoogleFonts.orbitron(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),
            Text("Mk1 (testing)", style: GoogleFonts.rajdhani(fontSize: 16)),
            const SizedBox(height: 4),

            Text(
              "Motorcycle Dashboard App",
              style: GoogleFonts.rajdhani(fontSize: 22),
            ),

            const SizedBox(height: 20),

            Text(
              "Built with Flutter.\nOpen source project for riders.",
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(fontSize: 18),
            ),

            const Spacer(),

            Container(
              width: double.infinity,
              height: 60,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                ),

                onPressed: _openGithub,
                icon: const Icon(Icons.code),
                label: const Text("GitHub"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
