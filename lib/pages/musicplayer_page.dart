import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sedo/service/music_provider.dart';

class MusicPlayerPage extends StatefulWidget {
  const MusicPlayerPage({super.key});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage>
    with SingleTickerProviderStateMixin {
  final MediaController _controller = MediaController();

  String _title = '—';
  String _artist = '—';
  bool _isPlaying = true;
  bool _loading = true;
  bool _fetching = false;

  Timer? _pollTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _controller.setOnNowPlayingChanged(_fetchNowPlaying);
    _fetchNowPlaying();

    _pollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchNowPlaying(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchNowPlaying() async {
    if (_fetching) return;
    _fetching = true;

    final info = await _controller.nowPlaying();

    _fetching = false;
    if (!mounted) return;

    setState(() {
      _title = info['title'] as String? ?? '—';
      _artist = info['artist'] as String? ?? '—';
      _isPlaying = info['isPlaying'] as bool? ?? false;
      _loading = false;

      if (_isPlaying) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });
  }

  Future<void> _handlePlayPause() async {
    HapticFeedback.mediumImpact();
    await _controller.playPause();
    await _fetchNowPlaying();
  }

  Future<void> _handleNext() async {
    HapticFeedback.lightImpact();
    await _controller.next();
    await _fetchNowPlaying();
  }

  Future<void> _handlePrevious() async {
    HapticFeedback.lightImpact();
    await _controller.previous();
    await _fetchNowPlaying();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _loading ? _buildLoadingState() : _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 90),
        Text(
          _title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _artist,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF888888), fontSize: 15),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 40,
              color: Colors.white,
              onPressed: _handlePrevious,
              icon: const Icon(Icons.skip_previous),
            ),
            const SizedBox(width: 20),
            //ScaleTransition(
            // scale: _pulseAnimation,
            // child:
            GestureDetector(
              onTap: _handlePlayPause,
              child: Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
            ),
            // ),
            const SizedBox(width: 20),
            IconButton(
              iconSize: 40,
              color: Colors.white,
              onPressed: _handleNext,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        ),
      ],
    );
  }
}
