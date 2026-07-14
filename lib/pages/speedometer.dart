import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sedo/service/firebaseauth.dart';
import 'package:sedo/service/gps_provider.dart';

class SpeedometerPage extends StatelessWidget {
  const SpeedometerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<SpeedProvider>(
      builder: (context, speedProvider, child) {
        return SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight;

              // Dynamically scale speed text size based on height to prevent layout overflows
              final speedFontSize = height * 0.26;

              final isSpeeding =
                  speedProvider.speed >= speedProvider.overspeedWarning;
              final primaryColor = isSpeeding ? Colors.redAccent : cs.tertiary;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: Column(
                  children: [
                    // ── TOP BAR (COMBINED CONTROL BUTTON) ────────────────────
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: speedProvider.togglePause,
                        onLongPress: () async {
                          HapticFeedback.heavyImpact();

                          // Read current stats before reset
                          final maxSpd = speedProvider.maxSpeed;
                          final avgSpd = speedProvider.averageSpeed;
                          final dist = speedProvider.distanceTravelled;

                          // Reset speedometer local stats
                          speedProvider.resetStats();

                          // Save completed ride stats to Firebase cloud
                          await AuthService().saveRideStats(
                            maxSpeed: maxSpd,
                            averageSpeed: avgSpd,
                            distance: dist,
                          );

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Ride stats saved to cloud and reset',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: cs.secondary,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: speedProvider.isPaused
                              ? Colors.orange
                              : Colors.blue,
                          side: BorderSide(
                            color:
                                (speedProvider.isPaused
                                        ? Colors.orange
                                        : Colors.blue)
                                    .withOpacity(0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        icon: Icon(
                          speedProvider.isPaused
                              ? Icons.play_arrow
                              : Icons.pause,
                          size: 16,
                        ),
                        label: Text(
                          "${speedProvider.isPaused ? 'RESUME' : 'PAUSE'} (HOLD TO RESET & SAVE)",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── CIRCULAR SPEEDOMETER GAUGE ───────────────────────────
                    Expanded(
                      flex: 12,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: _BlinkingCircularRing(
                            isOverspeeding: isSpeeding,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      speedProvider.speed.toStringAsFixed(0),
                                      style: GoogleFonts.orbitron(
                                        fontSize: speedFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "KM/H",
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 15,
                                    letterSpacing: 4,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// A stateful widget that blinks red when overspeeding, otherwise displays a clean solid theme-based circular ring outline.
class _BlinkingCircularRing extends StatefulWidget {
  final bool isOverspeeding;
  final Widget child;

  const _BlinkingCircularRing({
    required this.isOverspeeding,
    required this.child,
  });

  @override
  State<_BlinkingCircularRing> createState() => _BlinkingCircularRingState();
}

class _BlinkingCircularRingState extends State<_BlinkingCircularRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _colorAnimation = ColorTween(
      begin: Colors.redAccent.withOpacity(0.15),
      end: Colors.redAccent,
    ).animate(_controller);

    if (widget.isOverspeeding) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _BlinkingCircularRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOverspeeding != oldWidget.isOverspeeding) {
      if (widget.isOverspeeding) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        final Color ringColor = widget.isOverspeeding
            ? (_colorAnimation.value ?? Colors.redAccent)
            : cs.inversePrimary.withOpacity(0.15);

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ringColor, width: 6.0),
          ),
          padding: const EdgeInsets.all(12),
          child: widget.child,
        );
      },
    );
  }
}
