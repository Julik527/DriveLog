import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';

/// Speichert, lädt und berechnet Fahrten.
class TripStorageService {
  static const String _storageKey = 'drivelog_trips_v2';

  Future<List<Trip>> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    return data.map(Trip.decode).toList();
  }

  Future<void> saveTrips(List<Trip> trips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, trips.map((trip) => trip.encode()).toList());
  }

  Future<void> addTrip(Trip trip) async {
    final trips = await loadTrips();
    trips.add(trip);
    await saveTrips(trips);
  }

  Future<void> updateTrip(Trip updatedTrip) async {
    final trips = await loadTrips();
    final index = trips.indexWhere((trip) => trip.id == updatedTrip.id);
    if (index == -1) {
      trips.add(updatedTrip);
    } else {
      trips[index] = updatedTrip;
    }
    await saveTrips(trips);
  }

  Future<void> deleteTrip(String id) async {
    final trips = await loadTrips();
    trips.removeWhere((trip) => trip.id == id);
    await saveTrips(trips);
  }

  double calculateTotalKilometers(List<Trip> trips) {
    return trips.fold(0, (sum, trip) => sum + trip.kilometers);
  }

  double calculateKilometersByCategory(List<Trip> trips, TripCategory category) {
    return trips.where((trip) => trip.category == category).fold(0, (sum, trip) => sum + trip.kilometers);
  }

  double calculateKilometersByVehicle(List<Trip> trips, String vehicleId) {
    return trips.where((trip) => trip.vehicleId == vehicleId).fold(0, (sum, trip) => sum + trip.kilometers);
  }

  double? calculateAverageSpeed(List<Trip> trips) {
    final speeds = trips.map((trip) => trip.averageSpeedKmh).whereType<double>().toList();
    if (speeds.isEmpty) return null;
    return speeds.fold(0.0, (sum, speed) => sum + speed) / speeds.length;
  }

  double? findMaxSpeed(List<Trip> trips) {
    final speeds = trips.map((trip) => trip.maxSpeedKmh).whereType<double>().toList();
    if (speeds.isEmpty) return null;
    speeds.sort();
    return speeds.last;
  }

  String buildCsv(List<Trip> trips, {List<Vehicle> vehicles = const []}) {
    final buffer = StringBuffer();
    buffer.writeln('Datum;Fahrzeug;Kennzeichen;Start;Ziel;Kilometer;Kategorie;Dauer;Durchschnitt kmh;Max kmh;Verbrauch l/100km;Notiz');

    for (final trip in trips) {
      final matchingVehicles = vehicles.where((item) => item.id == trip.vehicleId).toList();
      final vehicle = matchingVehicles.isEmpty ? null : matchingVehicles.first;
      buffer.writeln([
        trip.date.toIso8601String(),
        vehicle?.displayName ?? '',
        vehicle?.licensePlate ?? '',
        trip.startLocation,
        trip.destination,
        trip.kilometers.toStringAsFixed(1),
        trip.category.label,
        trip.durationSeconds?.toString() ?? '',
        trip.averageSpeedKmh?.toStringAsFixed(1) ?? '',
        trip.maxSpeedKmh?.toStringAsFixed(1) ?? '',
        trip.averageConsumptionL100km?.toStringAsFixed(1) ?? '',
        trip.note.replaceAll(';', ','),
      ].join(';'));
    }

    return buffer.toString();
  }
}
