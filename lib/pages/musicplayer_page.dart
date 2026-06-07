// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show Consumer, Provider;
import 'package:sedo/models/ball.dart' show Ball;

import '../models/box.dart' show Box;
import '../service/playlist_provider.dart' show PlaylistProvider;

class MusicplayerPage extends StatefulWidget {
  const MusicplayerPage({super.key});

  @override
  State<MusicplayerPage> createState() => _MusicplayerPageState();
}

class _MusicplayerPageState extends State<MusicplayerPage> {
  @override
  void initState() {
    super.initState();

    // Delay to ensure context is available
    Future.microtask(() {
      final provider = Provider.of<PlaylistProvider>(context, listen: false);

      if (!provider.isPlaying) {
        provider.play(); // or provider.playCurrentSong()
      }
    });
  }

  String formatTime(Duration duration) {
    String twoDigitSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String formattedTime = "${duration.inMinutes}:$twoDigitSeconds";

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistProvider>(
      builder: (context, value, child) {
        // playlist data
        final playlist = value.playlists;
        //song index
        final songIndex = playlist[value.currentSongIndex ?? 0];
        //ui return
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image(image: AssetImage(songIndex.album), fit: BoxFit.cover),

              // Blur Layer
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.05), // dark overlay
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 40,
                    right: 40,
                    bottom: 40,
                    top: 10,
                  ),

                  child: Column(
                    children: [
                      Opacity(
                        opacity: 0.2,
                        child: Box(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                songIndex.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 20.0,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                songIndex.artist,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 20.0,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      //song duration slider
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formatTime(value.currentDuration),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),

                                //Icon(Icons.shuffle),

                                //Icon(Icons.repeat),
                                Text(
                                  formatTime(value.totalDuration),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 0,
                              ),
                            ),
                            child: Slider(
                              value: value.currentDuration.inSeconds.toDouble(),
                              min: 0,
                              max: value.totalDuration.inSeconds.toDouble(),
                              activeColor: Colors.green,
                              onChanged: (double double) {},
                              onChangeEnd: (double double) {
                                value.seek(Duration(seconds: double.toInt()));
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Ball(
                            child: Expanded(
                              child: GestureDetector(
                                onTap: value.playPrevious,
                                child: CircleAvatar(
                                  radius: 30,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: Icon(Icons.skip_previous),
                                ),
                              ),
                            ),
                          ),

                          Ball(
                            child: Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: value.pauseOrResume,
                                child: CircleAvatar(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  radius: 34,
                                  child: Icon(
                                    value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 1),
                          Ball(
                            child: Expanded(
                              child: GestureDetector(
                                onTap: value.playNext,
                                child: CircleAvatar(
                                  radius: 30,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.inversePrimary,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: Icon(Icons.skip_next),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
