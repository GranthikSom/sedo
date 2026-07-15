// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sedo/pages/auth.dart';
import 'package:sedo/pages/drawer_secondary.dart' show DrawerSecondary;
import 'package:sedo/service/firebaseauth.dart';
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/service/tile_cache.dart';
import 'package:sedo/themes/theme_provider.dart' show ThemeProvider;

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// A themed card container used to group related settings.
class SettingCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const SettingCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cs.secondary.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.inversePrimary.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Icon(icon, size: 18, color: cs.inversePrimary.withOpacity(0.6)),
                const SizedBox(width: 8),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: cs.inversePrimary.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// A single row inside a [SettingCard].
class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingTile({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: cs.tertiary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.tertiary,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.inversePrimary.withOpacity(0.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (onTap != null && trailing == null)
              Icon(Icons.chevron_right, size: 20, color: cs.inversePrimary.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}

/// A small action button used inside setting cards.
class _SettingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _SettingButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.tertiary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 42,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: c,
            side: BorderSide(color: c.withOpacity(0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SETTINGS PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // ponytail: persisted via setState only; upgrade to SharedPreferences when needed
  bool _followSystem = false;
  bool _offlineMaps = false;
  bool _autoConnectMedia = true;
  bool _showAlbumArt = true;
  bool _bgPolling = true;
  String _speedUnit = 'KM/H';
  String _distanceUnit = 'Kilometers';

  int _cacheSizeMB = 0;
  int _tileCount = 0;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _refreshCacheStats();
  }

  Future<void> _refreshCacheStats() async {
    final size = await OfflineMapManager.getCacheSizeMB();
    final count = await OfflineMapManager.getTileCount();
    if (mounted) setState(() { _cacheSizeMB = size; _tileCount = count; });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    final speedProvider = Provider.of<SpeedProvider>(context);

    return Scaffold(
      drawer: const DrawerSecondary(),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: cs.surface,
              title: Text(
                'S E T T I N G S',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: cs.tertiary,
                ),
              ),
              centerTitle: true,
            ),

            SliverPadding(
              padding: const EdgeInsets.only(bottom: 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Account ──────────────────────────────────────────
                  _buildAccountSection(cs, user),

                  // ── Lifetime Statistics (from Firebase) ──────────────
                  _buildStatsSection(cs),

                  // ── Appearance ───────────────────────────────────────
                  _buildAppearanceSection(cs, themeProvider),

                  // ── Maps & Navigation ────────────────────────────────
                  _buildMapsSection(cs),

                  // ── Ride Settings ────────────────────────────────────
                  _buildRideSection(cs, speedProvider),

                  // ── Music ────────────────────────────────────────────
                  _buildMusicSection(cs),

                  // ── Storage ──────────────────────────────────────────
                  _buildStorageSection(cs),

                  // ── About ────────────────────────────────────────────
                  _buildAboutSection(cs),

                  // ── Developer Options (debug only) ───────────────────
                  if (kDebugMode) _buildDevSection(cs),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SECTION BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildAccountSection(ColorScheme cs, User? user) {
    return SettingCard(
      title: 'Account',
      icon: Icons.person_outline,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cs.inversePrimary.withOpacity(0.15),
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 28, color: cs.inversePrimary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? 'Rider',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user?.email ?? 'Not signed in',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.inversePrimary.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _SettingButton(
          label: 'Sign Out',
          icon: Icons.logout,
          color: Colors.redAccent,
          onTap: () async {
            await AuthService().signOut();
            if (!mounted) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const Auth()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(ColorScheme cs, ThemeProvider themeProvider) {
    return SettingCard(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      children: [
        SettingTile(
          title: 'Dark Mode',
          icon: Icons.dark_mode_outlined,
          trailing: Switch(
            value: themeProvider.isDarkMode,
            onChanged: _followSystem ? null : (_) => themeProvider.toggleTheme(),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Follow System Theme',
          subtitle: 'Override manual toggle',
          icon: Icons.brightness_auto_outlined,
          trailing: Switch(
            value: _followSystem,
            onChanged: (v) => setState(() => _followSystem = v),
            activeColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildMapsSection(ColorScheme cs) {
    return SettingCard(
      title: 'Maps & Navigation',
      icon: Icons.map_outlined,
      children: [
        SettingTile(
          title: 'Offline Maps',
          subtitle: 'Download regions for offline use',
          icon: Icons.download_outlined,
          trailing: Switch(
            value: _offlineMaps,
            onChanged: (v) => setState(() => _offlineMaps = v),
            activeColor: Colors.blue,
          ),
        ),
        if (_isDownloading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: LinearProgressIndicator(value: _downloadProgress),
          ),
        SettingTile(
          title: 'Downloaded Regions',
          subtitle: '$_tileCount tiles cached',
          icon: Icons.sd_storage_outlined,
          onTap: () => _showDownloadDialog(),
        ),
        SettingTile(
          title: 'Map Cache Size',
          subtitle: '$_cacheSizeMB MB',
          icon: Icons.cached_outlined,
        ),
        _SettingButton(
          label: 'Clear Map Cache',
          icon: Icons.delete_sweep_outlined,
          onTap: () async {
            await OfflineMapManager.clearCache();
            await _refreshCacheStats();
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Map cache cleared'), behavior: SnackBarBehavior.floating),
            );
          },
        ),
      ],
    );
  }

  void _showDownloadDialog() {
    final speedProvider = Provider.of<SpeedProvider>(context, listen: false);
    final lat = speedProvider.latitude;
    final lng = speedProvider.longitude;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Offline Maps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('5 km radius'),
              onTap: () {
                Navigator.pop(ctx);
                _startDownload(lat, lng, radiusKm: 5, minZoom: 13, maxZoom: 16);
              },
            ),
            ListTile(
              title: const Text('15 km radius'),
              onTap: () {
                Navigator.pop(ctx);
                _startDownload(lat, lng, radiusKm: 15, minZoom: 11, maxZoom: 15);
              },
            ),
            ListTile(
              title: const Text('50 km radius'),
              onTap: () {
                Navigator.pop(ctx);
                _startDownload(lat, lng, radiusKm: 50, minZoom: 10, maxZoom: 14);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startDownload(
    double lat, double lng, {
    required double radiusKm,
    required int minZoom,
    required int maxZoom,
  }) async {
    setState(() { _isDownloading = true; _downloadProgress = 0.0; });
    await for (final progress in OfflineMapManager.downloadRegion(
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      minZoom: minZoom,
      maxZoom: maxZoom,
    )) {
      if (mounted) setState(() => _downloadProgress = progress.percent);
    }
    if (mounted) setState(() => _isDownloading = false);
    await _refreshCacheStats();
  }

  Widget _buildRideSection(ColorScheme cs, SpeedProvider speedProvider) {
    return SettingCard(
      title: 'Ride Settings',
      icon: Icons.speed_outlined,
      children: [
        SettingTile(
          title: 'Speed Unit',
          icon: Icons.speed,
          trailing: _buildSegmented<String>(
            value: _speedUnit,
            options: const {'KM/H': 'KM/H', 'MPH': 'MPH'},
            onChanged: (v) => setState(() => _speedUnit = v),
          ),
        ),
        SettingTile(
          title: 'Distance Unit',
          icon: Icons.straighten_outlined,
          trailing: _buildSegmented<String>(
            value: _distanceUnit,
            options: const {'Kilometers': 'KM', 'Miles': 'MI'},
            onChanged: (v) => setState(() => _distanceUnit = v),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.warning_amber_outlined, size: 22, color: cs.tertiary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overspeed Warning',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.tertiary),
                    ),
                    Text(
                      '${speedProvider.overspeedWarning.round()} $_speedUnit',
                      style: TextStyle(fontSize: 12, color: cs.inversePrimary.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.blue,
              thumbColor: Colors.blue,
              inactiveTrackColor: cs.inversePrimary.withOpacity(0.15),
              overlayColor: Colors.blue.withOpacity(0.12),
            ),
            child: Slider(
              min: 20,
              max: 150,
              divisions: 26,
              value: speedProvider.overspeedWarning,
              onChanged: (v) => speedProvider.setOverspeedWarning(v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicSection(ColorScheme cs) {
    return SettingCard(
      title: 'Music',
      icon: Icons.music_note_outlined,
      children: [
        SettingTile(
          title: 'Auto Connect Media',
          subtitle: 'Connect to system media on launch',
          icon: Icons.bluetooth_audio_outlined,
          trailing: Switch(
            value: _autoConnectMedia,
            onChanged: (v) => setState(() => _autoConnectMedia = v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show Album Art',
          icon: Icons.album_outlined,
          trailing: Switch(
            value: _showAlbumArt,
            onChanged: (v) => setState(() => _showAlbumArt = v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Background Polling',
          subtitle: 'Poll now-playing info periodically',
          icon: Icons.sync_outlined,
          trailing: Switch(
            value: _bgPolling,
            onChanged: (v) => setState(() => _bgPolling = v),
            activeColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageSection(ColorScheme cs) {
    return SettingCard(
      title: 'Storage',
      icon: Icons.storage_outlined,
      children: [
        SettingTile(title: 'App Storage Used', subtitle: '— MB', icon: Icons.folder_outlined),
        SettingTile(title: 'Offline Maps Storage', subtitle: 'None', icon: Icons.map_outlined),
        SettingTile(title: 'Cached Images', subtitle: '— MB', icon: Icons.image_outlined),
        _SettingButton(
          label: 'Clear Cache',
          icon: Icons.delete_outline,
          onTap: () => _showPlaceholder('Clear Cache'),
        ),
        _SettingButton(
          label: 'Reset Downloads',
          icon: Icons.restart_alt_outlined,
          color: Colors.redAccent,
          onTap: () => _showPlaceholder('Reset Downloads'),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ColorScheme cs) {
    return SettingCard(
      title: 'About Sedo',
      icon: Icons.info_outline,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/logobg.png', width: 64, height: 64),
                ),
                const SizedBox(height: 8),
                Text('Sedo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.tertiary)),
                Text('Version 1.0.0  •  Build 1',
                    style: TextStyle(fontSize: 12, color: cs.inversePrimary.withOpacity(0.5))),
              ],
            ),
          ),
        ),
        SettingTile(
          title: 'GitHub Repository',
          icon: Icons.code,
          onTap: () => _launchUrl('https://github.com/GranthikSom/sedo'),
        ),
        SettingTile(
          title: 'Report Bug',
          icon: Icons.bug_report_outlined,
          onTap: () => _launchUrl('https://github.com/GranthikSom/sedo/issues'),
        ),
        SettingTile(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          onTap: () => _showPlaceholder('Privacy Policy'),
        ),
        SettingTile(
          title: 'Licenses',
          icon: Icons.description_outlined,
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'Sedo',
            applicationVersion: '1.0.0',
          ),
        ),
      ],
    );
  }

  Widget _buildDevSection(ColorScheme cs) {
    return Consumer<SpeedProvider>(
      builder: (context, gps, _) {
        return SettingCard(
          title: 'Developer Options',
          icon: Icons.developer_mode_outlined,
          children: [
            SettingTile(
              title: 'GPS Coordinates',
              subtitle: '${gps.latitude.toStringAsFixed(6)}, ${gps.longitude.toStringAsFixed(6)}',
              icon: Icons.gps_fixed,
            ),
            SettingTile(
              title: 'Current Speed',
              subtitle: '${gps.speed.toStringAsFixed(1)} km/h',
              icon: Icons.speed,
            ),
            SettingTile(
              title: 'App Version',
              subtitle: '1.0.0+1 (debug)',
              icon: Icons.info_outline,
            ),
            SettingTile(
              title: 'GPS Status',
              subtitle: gps.currentPosition != null ? 'Active' : 'Waiting…',
              icon: Icons.satellite_alt_outlined,
            ),
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSegmented<T>({
    required T value,
    required Map<T, String> options,
    required ValueChanged<T> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.inversePrimary.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.entries.map((e) {
          final selected = e.key == value;
          return GestureDetector(
            onTap: () => onChanged(e.key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? Colors.blue.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                e.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.blue : cs.inversePrimary.withOpacity(0.6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showPlaceholder(String feature) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming soon'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ponytail: clipboard-copy instead of url_launcher dep; swap to url_launcher when added
  void _launchUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Link copied: $url'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildStatsSection(ColorScheme cs) {
    return StreamBuilder<Map<String, double>>(
      stream: AuthService().getLifetimeStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {'maxSpeed': 0.0, 'averageSpeed': 0.0, 'distance': 0.0};
        final maxSpeed = stats['maxSpeed'] ?? 0.0;
        final avgSpeed = stats['averageSpeed'] ?? 0.0;
        final distance = stats['distance'] ?? 0.0;

        return SettingCard(
          title: 'Lifetime Statistics',
          icon: Icons.analytics_outlined,
          children: [
            SettingTile(
              title: 'Total Distance',
              subtitle: '${(distance / 1000).toStringAsFixed(1)} km',
              icon: Icons.straighten_outlined,
            ),
            SettingTile(
              title: 'Highest Speed',
              subtitle: '${maxSpeed.toStringAsFixed(0)} KM/H',
              icon: Icons.speed,
            ),
            SettingTile(
              title: 'Overall Average Speed',
              subtitle: '${avgSpeed.toStringAsFixed(0)} KM/H',
              icon: Icons.show_chart_outlined,
            ),
          ],
        );
      },
    );
  }
}
