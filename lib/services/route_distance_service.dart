import 'dart:convert';

import 'package:http/http.dart' as http;

class DistanceCalculationException implements Exception {
  final String message;
  const DistanceCalculationException(this.message);
  @override
  String toString() => message;
}

class RouteDistanceResult {
  final double kilometers;
  final int durationMinutes;
  const RouteDistanceResult({required this.kilometers, required this.durationMinutes});
}

class _GeoPoint {
  final double latitude;
  final double longitude;
  const _GeoPoint({required this.latitude, required this.longitude});
}

/// Berechnet die Strecke zwischen zwei Orten.
///
/// Ablauf:
/// 1. Nominatim sucht Koordinaten zum Ort.
/// 2. OSRM berechnet die Autostrecke zwischen den Koordinaten.
class RouteDistanceService {
  static const String _userAgent = 'DriveLogSchulprojekt/2.0';

  Future<RouteDistanceResult> calculateDrivingDistance({
    required String startLocation,
    required String destination,
  }) async {
    final start = await _findCoordinates(startLocation);
    final target = await _findCoordinates(destination);

    final uri = Uri.https(
      'router.project-osrm.org',
      '/route/v1/driving/${start.longitude},${start.latitude};${target.longitude},${target.latitude}',
      {'overview': 'false'},
    );

    final response = await http.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw const DistanceCalculationException('Route konnte nicht berechnet werden.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>? ?? [];
    if (routes.isEmpty) {
      throw const DistanceCalculationException('Keine Route gefunden.');
    }

    final route = routes.first as Map<String, dynamic>;
    final meters = (route['distance'] as num).toDouble();
    final seconds = (route['duration'] as num).toDouble();

    return RouteDistanceResult(
      kilometers: meters / 1000,
      durationMinutes: (seconds / 60).round(),
    );
  }

  Future<_GeoPoint> _findCoordinates(String location) async {
    final cleaned = location.trim();
    if (cleaned.isEmpty) {
      throw const DistanceCalculationException('Bitte einen Ort eintragen.');
    }

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': '$cleaned, Deutschland',
      'format': 'jsonv2',
      'limit': '1',
    });

    final response = await http.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw const DistanceCalculationException('Ort konnte nicht gesucht werden.');
    }

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) {
      throw DistanceCalculationException('Ort "$cleaned" wurde nicht gefunden.');
    }

    final first = results.first as Map<String, dynamic>;
    final latitude = double.tryParse(first['lat'] as String? ?? '');
    final longitude = double.tryParse(first['lon'] as String? ?? '');

    if (latitude == null || longitude == null) {
      throw const DistanceCalculationException('Ort hat keine gültigen Koordinaten.');
    }

    return _GeoPoint(latitude: latitude, longitude: longitude);
  }
}
