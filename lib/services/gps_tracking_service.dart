import 'package:geolocator/geolocator.dart';

class GpsTrackingException implements Exception {
  final String message;
  const GpsTrackingException(this.message);
  @override
  String toString() => message;
}

/// Hilfsklasse für GPS-Berechtigungen und Distanzberechnung.
class GpsTrackingService {
  Future<void> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const GpsTrackingException('Standortdienst ist deaktiviert. Bitte GPS aktivieren.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const GpsTrackingException('Standortberechtigung wurde abgelehnt.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const GpsTrackingException('Standortberechtigung ist dauerhaft blockiert. Bitte in den Einstellungen erlauben.');
    }
  }

  Stream<Position> positionStream() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    );
    return Geolocator.getPositionStream(locationSettings: settings);
  }

  double distanceMeters(Position a, Position b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude);
  }
}
