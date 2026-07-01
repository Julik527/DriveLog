import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/workshop.dart';

class WorkshopSearchException implements Exception {
  final String message;
  const WorkshopSearchException(this.message);
  @override
  String toString() => message;
}

class _WorkshopPoint {
  final double latitude;
  final double longitude;
  const _WorkshopPoint({required this.latitude, required this.longitude});
}

/// Sucht freie OpenStreetMap-Werkstattdaten in der Nähe eines Ortes.
class WorkshopSearchService {
  static const String _userAgent = 'DriveLogSchulprojekt/2.0';

  Future<List<Workshop>> searchNearbyWorkshops({
    required String location,
    int radiusMeters = 15000,
  }) async {
    final center = await _findCoordinates(location);

    final query = '''
[out:json][timeout:15];
(
  nwr(around:$radiusMeters,${center.latitude},${center.longitude})["shop"="car_repair"];
  nwr(around:$radiusMeters,${center.latitude},${center.longitude})["amenity"="car_repair"];
);
out center 25;
''';

    final uri = Uri.https('overpass-api.de', '/api/interpreter', {'data': query});
    final response = await http.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw const WorkshopSearchException('Werkstätten konnten gerade nicht geladen werden.');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = data['elements'] as List<dynamic>? ?? [];

    final workshops = elements.map((item) {
      final map = item as Map<String, dynamic>;
      final tags = map['tags'] as Map<String, dynamic>? ?? {};
      final centerMap = map['center'] as Map<String, dynamic>?;
      final name = (tags['name'] as String?)?.trim();
      final street = (tags['addr:street'] as String?)?.trim();
      final houseNumber = (tags['addr:housenumber'] as String?)?.trim();
      final city = (tags['addr:city'] as String?)?.trim();
      final phone = (tags['phone'] as String?)?.trim() ?? '';
      final addressParts = [
        if (street != null && street.isNotEmpty) '$street${houseNumber == null || houseNumber.isEmpty ? '' : ' $houseNumber'}',
        if (city != null && city.isNotEmpty) city,
      ];
      return Workshop(
        name: name == null || name.isEmpty ? 'Werkstatt ohne Namen' : name,
        address: addressParts.isEmpty ? 'Adresse nicht angegeben' : addressParts.join(', '),
        phone: phone,
        latitude: (map['lat'] as num?)?.toDouble() ?? (centerMap?['lat'] as num?)?.toDouble(),
        longitude: (map['lon'] as num?)?.toDouble() ?? (centerMap?['lon'] as num?)?.toDouble(),
      );
    }).toList();

    workshops.sort((a, b) => a.name.compareTo(b.name));
    return workshops;
  }

  Future<_WorkshopPoint> _findCoordinates(String location) async {
    final cleaned = location.trim();
    if (cleaned.isEmpty) throw const WorkshopSearchException('Bitte einen Ort eintragen.');

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': '$cleaned, Deutschland',
      'format': 'jsonv2',
      'limit': '1',
    });
    final response = await http.get(uri, headers: {'User-Agent': _userAgent}).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) throw const WorkshopSearchException('Ort konnte nicht gesucht werden.');

    final results = jsonDecode(response.body) as List<dynamic>;
    if (results.isEmpty) throw const WorkshopSearchException('Ort wurde nicht gefunden.');
    final first = results.first as Map<String, dynamic>;
    final latitude = double.tryParse(first['lat'] as String? ?? '');
    final longitude = double.tryParse(first['lon'] as String? ?? '');
    if (latitude == null || longitude == null) throw const WorkshopSearchException('Ort hat keine gültigen Koordinaten.');
    return _WorkshopPoint(latitude: latitude, longitude: longitude);
  }
}
