import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;
import 'package:provider/provider.dart';
import 'package:sedo/service/gps_provider.dart';

class SpeedometerPage extends StatefulWidget {
  const SpeedometerPage({super.key});

  @override
  State<SpeedometerPage> createState() => _SpeedometerPageState();
}

class _SpeedometerPageState extends State<SpeedometerPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<SpeedProvider>().startTracking();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedProvider>(
      builder: (context, speedProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  speedProvider.speed.toStringAsFixed(0),
                  style: GoogleFonts.orbitron(
                    fontSize: 140,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Text(
                  'KM/H',
                  style: GoogleFonts.rajdhani(
                    fontSize: 24,
                    letterSpacing: 4,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
