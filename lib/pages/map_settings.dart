import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:sedo/pages/drawer_secondary.dart';
import 'package:sedo/service/gps_provider.dart';
import 'package:sedo/service/map_settings_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

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
// MAP SETTINGS PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class MapSettings extends StatefulWidget {
  const MapSettings({super.key});

  @override
  State<MapSettings> createState() => _MapSettingsState();
}

class _MapSettingsState extends State<MapSettings> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mapPrefs = Provider.of<MapSettingsProvider>(context);

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
                'M A P   S E T T I N G S',
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
                  _buildMapAppearanceSection(cs, mapPrefs),
                  _buildNavigationSettingsSection(cs, mapPrefs),
                  _buildMapBehaviorSection(cs, mapPrefs),
                  _buildOfflineMapsSection(cs),
                  _buildRouteDisplaySection(cs, mapPrefs),
                  _buildUnitsSection(cs, mapPrefs),
                  if (kDebugMode) _buildDebugSection(cs),
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

  Widget _buildMapAppearanceSection(ColorScheme cs, MapSettingsProvider prefs) {
    return SettingCard(
      title: 'Map Appearance',
      icon: Icons.map_outlined,
      children: [
        SettingTile(
          title: 'Map Theme',
          icon: Icons.palette_outlined,
          trailing: _buildSegmented<String>(
            value: prefs.mapTheme,
            options: const {'Default': 'Def', 'Dark': 'Dark', 'Satellite': 'Sat'},
            onChanged: (v) => prefs.setMapTheme(v),
          ),
        ),
        SettingTile(
          title: 'Show Buildings',
          icon: Icons.location_city_outlined,
          trailing: Switch(
            value: prefs.showBuildings,
            onChanged: (v) => prefs.setShowBuildings(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show Labels',
          icon: Icons.label_outline,
          trailing: Switch(
            value: prefs.showLabels,
            onChanged: (v) => prefs.setShowLabels(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show Compass',
          icon: Icons.explore_outlined,
          trailing: Switch(
            value: prefs.showCompass,
            onChanged: (v) => prefs.setShowCompass(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show Scale Bar',
          icon: Icons.straighten_outlined,
          trailing: Switch(
            value: prefs.showScaleBar,
            onChanged: (v) => prefs.setShowScaleBar(v),
            activeColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationSettingsSection(ColorScheme cs, MapSettingsProvider prefs) {
    return SettingCard(
      title: 'Navigation Settings',
      icon: Icons.navigation_outlined,
      children: [
        SettingTile(
          title: 'Enable Navigation',
          icon: Icons.directions_outlined,
          trailing: Switch(
            value: prefs.enableNavigation,
            onChanged: (v) => prefs.setEnableNavigation(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Auto Recalculate Route',
          icon: Icons.alt_route_outlined,
          trailing: Switch(
            value: prefs.autoRecalculateRoute,
            onChanged: (v) => prefs.setAutoRecalculateRoute(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Snap To Road',
          icon: Icons.add_road_outlined,
          trailing: Switch(
            value: prefs.snapToRoad,
            onChanged: (v) => prefs.setSnapToRoad(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Voice Guidance',
          subtitle: 'Placeholder for future update',
          icon: Icons.record_voice_over_outlined,
          trailing: Switch(
            value: prefs.voiceGuidance,
            onChanged: (v) => prefs.setVoiceGuidance(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Keep Screen Awake',
          icon: Icons.screen_lock_portrait_outlined,
          trailing: Switch(
            value: prefs.keepScreenAwakeNav,
            onChanged: (v) => prefs.setKeepScreenAwakeNav(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Routing Profile',
          icon: Icons.motorcycle_outlined,
          trailing: DropdownButton<String>(
            value: prefs.routingProfile,
            dropdownColor: cs.surface,
            underline: const SizedBox(),
            items: ['Motorcycle', 'Driving', 'Fastest Route', 'Shortest Route']
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e, style: TextStyle(color: cs.tertiary, fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) prefs.setRoutingProfile(v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMapBehaviorSection(ColorScheme cs, MapSettingsProvider prefs) {
    return SettingCard(
      title: 'Map Behavior',
      icon: Icons.settings_applications_outlined,
      children: [
        SettingTile(
          title: 'Auto Center Map',
          icon: Icons.center_focus_strong_outlined,
          trailing: Switch(
            value: prefs.autoCenterMap,
            onChanged: (v) => prefs.setAutoCenterMap(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Follow Rider Position',
          icon: Icons.my_location_outlined,
          trailing: Switch(
            value: prefs.followRiderPosition,
            onChanged: (v) => prefs.setFollowRiderPosition(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Rotate Map With Heading',
          icon: Icons.screen_rotation_outlined,
          trailing: Switch(
            value: prefs.rotateMapWithHeading,
            onChanged: (v) => prefs.setRotateMapWithHeading(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show Current Speed',
          icon: Icons.speed_outlined,
          trailing: Switch(
            value: prefs.showCurrentSpeed,
            onChanged: (v) => prefs.setShowCurrentSpeed(v),
            activeColor: Colors.blue,
          ),
        ),
        SettingTile(
          title: 'Show GPS Accuracy Ring',
          icon: Icons.gps_fixed_outlined,
          trailing: Switch(
            value: prefs.showGpsAccuracyRing,
            onChanged: (v) => prefs.setShowGpsAccuracyRing(v),
            activeColor: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineMapsSection(ColorScheme cs) {
    return SettingCard(
      title: 'Offline Maps',
      icon: Icons.offline_pin_outlined,
      children: [
        SettingTile(
          title: 'Downloaded Regions',
          subtitle: 'None',
          icon: Icons.sd_storage_outlined,
        ),
        SettingTile(
          title: 'Offline Storage Used',
          subtitle: '0 MB',
          icon: Icons.folder_outlined,
        ),
        _SettingButton(
          label: 'Manage Downloads',
          icon: Icons.settings_outlined,
          onTap: () => _showPlaceholder('Manage Downloads'),
        ),
        _SettingButton(
          label: 'Download Region',
          icon: Icons.download_outlined,
          onTap: () => _showPlaceholder('Download Region'),
        ),
        _SettingButton(
          label: 'Clear Offline Cache',
          icon: Icons.delete_outline,
          color: Colors.redAccent,
          onTap: () => _showPlaceholder('Clear Offline Cache'),
        ),
      ],
    );
  }

  Widget _buildRouteDisplaySection(ColorScheme cs, MapSettingsProvider prefs) {
    return SettingCard(
      title: 'Route Display',
      icon: Icons.route_outlined,
      children: [
        SettingTile(
          title: 'Show Route Line',
          icon: Icons.timeline_outlined,
          trailing: Switch(
            value: prefs.showRouteLine,
            onChanged: (v) => prefs.setShowRouteLine(v),
            activeColor: Colors.blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.line_weight_outlined, size: 22, color: cs.tertiary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Route Line Width', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.tertiary)),
                    Text('${prefs.routeLineWidth.toStringAsFixed(1)} px', style: TextStyle(fontSize: 12, color: cs.inversePrimary.withOpacity(0.6))),
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
              min: 1,
              max: 20,
              divisions: 19,
              value: prefs.routeLineWidth,
              onChanged: (v) => prefs.setRouteLineWidth(v),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(Icons.opacity_outlined, size: 22, color: cs.tertiary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Route Transparency', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.tertiary)),
                    Text('${(prefs.routeTransparency * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, color: cs.inversePrimary.withOpacity(0.6))),
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
              min: 0.1,
              max: 1.0,
              divisions: 9,
              value: prefs.routeTransparency,
              onChanged: (v) => prefs.setRouteTransparency(v),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsSection(ColorScheme cs, MapSettingsProvider prefs) {
    return SettingCard(
      title: 'Units',
      icon: Icons.straighten_outlined,
      children: [
        SettingTile(
          title: 'Speed Unit',
          icon: Icons.speed_outlined,
          trailing: _buildSegmented<String>(
            value: prefs.speedUnit,
            options: const {'KM/H': 'KM/H', 'MPH': 'MPH'},
            onChanged: (v) => prefs.setSpeedUnit(v),
          ),
        ),
        SettingTile(
          title: 'Distance Unit',
          icon: Icons.merge_type_outlined,
          trailing: _buildSegmented<String>(
            value: prefs.distanceUnit,
            options: const {'Kilometers': 'KM', 'Miles': 'MI'},
            onChanged: (v) => prefs.setDistanceUnit(v),
          ),
        ),
      ],
    );
  }

  Widget _buildDebugSection(ColorScheme cs) {
    return Consumer<SpeedProvider>(
      builder: (context, gps, _) {
        return SettingCard(
          title: 'Debug Options',
          icon: Icons.developer_mode_outlined,
          children: [
            SettingTile(
              title: 'Current Latitude',
              subtitle: gps.latitude.toStringAsFixed(6),
              icon: Icons.gps_fixed_outlined,
            ),
            SettingTile(
              title: 'Current Longitude',
              subtitle: gps.longitude.toStringAsFixed(6),
              icon: Icons.gps_fixed_outlined,
            ),
            SettingTile(
              title: 'GPS Accuracy',
              subtitle: gps.currentPosition != null ? '${gps.currentPosition!.accuracy.toStringAsFixed(2)} meters' : 'Waiting...',
              icon: Icons.satellite_alt_outlined,
            ),
            SettingTile(
              title: 'Current Heading',
              subtitle: gps.currentPosition != null ? '${gps.currentPosition!.heading.toStringAsFixed(1)}°' : 'Waiting...',
              icon: Icons.explore_outlined,
            ),
            SettingTile(
              title: 'Current Zoom Level',
              subtitle: '18.0 (Placeholder)',
              icon: Icons.zoom_in_outlined,
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
}
