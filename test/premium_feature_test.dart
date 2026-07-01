import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/models/trip.dart';
import 'package:drivelog/models/vehicle.dart';

void main() {
  test('GPS-Fahrt berechnet Durchschnittsgeschwindigkeit', () {
    final trip = Trip(
      id: 'gps-1',
      vehicleId: 'car-1',
      startLocation: 'Leutkirch',
      destination: 'Bad Saulgau',
      kilometers: 60,
      date: DateTime(2026, 7, 1),
      category: TripCategory.arbeit,
      note: '',
      durationSeconds: 3600,
      maxSpeedKmh: 120,
      createdByGps: true,
    );

    expect(trip.averageSpeedKmh, 60);
    expect(trip.durationLabel, '1h 0min');
  });

  test('Durchschnittsverbrauch wird berechnet', () {
    final trip = Trip(
      id: 'fuel-1',
      vehicleId: 'car-1',
      startLocation: 'A',
      destination: 'B',
      kilometers: 100,
      date: DateTime(2026, 7, 1),
      category: TripCategory.privat,
      note: '',
      fuelUsedLiters: 6.5,
    );

    expect(trip.averageConsumptionL100km, 6.5);
  });

  test('TÜV-Status erkennt abgelaufen und bald fällig', () {
    final expired = Vehicle(
      id: '1',
      brand: 'Ford',
      model: 'Focus',
      licensePlate: 'RV AB 123',
      vin: 'WF0ABCDEFG1234567',
      note: '',
      huDueDate: DateTime(2026, 6, 1),
    );

    final dueThisMonth = expired.copyWith(
      id: '2',
      huDueDate: DateTime(2026, 7, 20),
    );

    expect(expired.huStatus(today: DateTime(2026, 7, 1)), HuStatus.expired);
    expect(dueThisMonth.huStatus(today: DateTime(2026, 7, 1)), HuStatus.dueThisMonth);
    expect(expired.preTripWarnings(today: DateTime(2026, 7, 1)).isNotEmpty, true);
  });
}
