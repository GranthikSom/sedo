import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class RouteProgress {
  final double distanceRemaining;
  final double etaSeconds;
  final LatLng snappedLocation;
  final int currentStepIndex;
  final double distanceToNextManeuver;
  final bool isOffRoute;

  RouteProgress({
    required this.distanceRemaining,
    required this.etaSeconds,
    required this.snappedLocation,
    required this.currentStepIndex,
    required this.distanceToNextManeuver,
    required this.isOffRoute,
  });
}

class RouteProgressService {
  static const double offRouteThresholdMeters = 50.0;

  /// Calculates the rider's progress along the route and snaps them to the nearest segment.
  static RouteProgress calculateProgress(LatLng currentLoc, List<LatLng> polyline) {
    if (polyline.isEmpty) {
      return RouteProgress(
        distanceRemaining: 0,
        etaSeconds: 0,
        snappedLocation: currentLoc,
        currentStepIndex: 0,
        distanceToNextManeuver: 0,
        isOffRoute: false,
      );
    }

    int nearestSegmentIndex = 0;
    double minDistance = double.infinity;
    LatLng snappedLoc = currentLoc;

    for (int i = 0; i < polyline.length - 1; i++) {
      final p1 = polyline[i];
      final p2 = polyline[i + 1];
      
      final snap = _getClosestPointOnSegment(currentLoc, p1, p2);
      final dist = _haversineDistance(currentLoc, snap);

      if (dist < minDistance) {
        minDistance = dist;
        nearestSegmentIndex = i;
        snappedLoc = snap;
      }
    }

    bool offRoute = minDistance > offRouteThresholdMeters;

    double distanceRemaining = 0;
    distanceRemaining += _haversineDistance(snappedLoc, polyline[nearestSegmentIndex + 1]);
    for (int i = nearestSegmentIndex + 1; i < polyline.length - 1; i++) {
      distanceRemaining += _haversineDistance(polyline[i], polyline[i + 1]);
    }

    // Rough ETA based on 40 km/h average if not off route, otherwise just standard
    // (In a real app, you'd match the segment to the OSRM speed data)
    double etaSeconds = distanceRemaining / (40.0 * 1000.0 / 3600.0);

    return RouteProgress(
      distanceRemaining: distanceRemaining,
      etaSeconds: etaSeconds,
      snappedLocation: offRoute ? currentLoc : snappedLoc, // don't snap if too far
      currentStepIndex: nearestSegmentIndex, // roughly mapping polyline index to steps is complex, simplifying here
      distanceToNextManeuver: 0, // This needs to be calculated against the actual maneuver locations
      isOffRoute: offRoute,
    );
  }

  static double _haversineDistance(LatLng p1, LatLng p2) {
    const R = 6371e3; // metres
    final phi1 = p1.latitude * math.pi / 180; // φ, λ in radians
    final phi2 = p2.latitude * math.pi / 180;
    final deltaPhi = (p2.latitude - p1.latitude) * math.pi / 180;
    final deltaLambda = (p2.longitude - p1.longitude) * math.pi / 180;

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) * math.cos(phi2) *
            math.sin(deltaLambda / 2) * math.sin(deltaLambda / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // in metres
  }

  // Gets closest point on segment p1-p2 to point p3 using equirectangular approximation
  static LatLng _getClosestPointOnSegment(LatLng p3, LatLng p1, LatLng p2) {
    double x3 = p3.longitude;
    double y3 = p3.latitude;
    double x1 = p1.longitude;
    double y1 = p1.latitude;
    double x2 = p2.longitude;
    double y2 = p2.latitude;

    double dx = x2 - x1;
    double dy = y2 - y1;
    
    if (dx == 0 && dy == 0) return p1;

    double u = ((x3 - x1) * dx + (y3 - y1) * dy) / (dx * dx + dy * dy);

    if (u < 0) {
      return p1;
    } else if (u > 1) {
      return p2;
    } else {
      double x = x1 + u * dx;
      double y = y1 + u * dy;
      return LatLng(y, x);
    }
  }
}
