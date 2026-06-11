import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sedo/service/gps_provider.dart';

class SpeedometerPage extends StatelessWidget {
  const SpeedometerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeedProvider>(
      builder: (context, speedProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: speedProvider.resetStats,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // button color
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text("RESET"),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
                        onPressed: speedProvider.togglePause,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // button color
                          foregroundColor: Colors.white,
                        ),
                        icon: Icon(
                          speedProvider.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                        ),
                        label: Text(
                          speedProvider.isPaused ? "RESUME" : "PAUSE",
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.gps_fixed,
                        color: speedProvider.isPaused
                            ? Colors.orange
                            : Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        speedProvider.isPaused ? "PAUSED" : "GPS",
                        style: GoogleFonts.rajdhani(
                          color: speedProvider.isPaused
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Column(
                children: [
                  Text(
                    speedProvider.speed.toStringAsFixed(0),
                    style: GoogleFonts.orbitron(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),

                  Text(
                    "KM/H",
                    style: GoogleFonts.rajdhani(
                      fontSize: 24,
                      letterSpacing: 5,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatCard(
                    title: "MAX",
                    value: speedProvider.maxSpeed.toStringAsFixed(0),
                  ),

                  _StatCard(
                    title: "AVG",
                    value: speedProvider.averageSpeed.toStringAsFixed(0),
                  ),

                  _StatCard(
                    title: "TIME",
                    value: speedProvider.formattedRideTime,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            letterSpacing: 2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ],
    );
  }
}
