import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/models/fuel_receipt.dart';
import 'package:drivelog/models/trip.dart';
import 'package:drivelog/services/fuel_receipt_storage_service.dart';
import 'package:drivelog/services/trip_storage_service.dart';

void main() {
  test('Gesamtkilometer werden richtig berechnet', () {
    final service = TripStorageService();
    final trips = [
      Trip(
        id: '1',
        vehicleId: 'car-1',
        startLocation: 'A',
        destination: 'B',
        kilometers: 10,
        date: DateTime(2026, 7, 1),
        category: TripCategory.privat,
        note: '',
      ),
      Trip(
        id: '2',
        vehicleId: 'car-1',
        startLocation: 'B',
        destination: 'C',
        kilometers: 15.5,
        date: DateTime(2026, 7, 2),
        category: TripCategory.arbeit,
        note: '',
      ),
    ];

    expect(service.calculateTotalKilometers(trips), 25.5);
  });

  test('Kilometer nach Kategorie werden richtig berechnet', () {
    final service = TripStorageService();
    final trips = [
      Trip(
        id: '1',
        vehicleId: 'car-1',
        startLocation: 'A',
        destination: 'B',
        kilometers: 10,
        date: DateTime(2026, 7, 1),
        category: TripCategory.schule,
        note: '',
      ),
      Trip(
        id: '2',
        vehicleId: 'car-2',
        startLocation: 'B',
        destination: 'C',
        kilometers: 20,
        date: DateTime(2026, 7, 2),
        category: TripCategory.schule,
        note: '',
      ),
      Trip(
        id: '3',
        vehicleId: 'car-1',
        startLocation: 'C',
        destination: 'D',
        kilometers: 5,
        date: DateTime(2026, 7, 3),
        category: TripCategory.privat,
        note: '',
      ),
    ];

    final result = service.calculateKilometersByCategory(trips, TripCategory.schule);

    expect(result, 30);
  });

  test('Kilometer nach Fahrzeug werden richtig berechnet', () {
    final service = TripStorageService();
    final trips = [
      Trip(
        id: '1',
        vehicleId: 'car-1',
        startLocation: 'A',
        destination: 'B',
        kilometers: 10,
        date: DateTime(2026, 7, 1),
        category: TripCategory.privat,
        note: '',
      ),
      Trip(
        id: '2',
        vehicleId: 'car-2',
        startLocation: 'B',
        destination: 'C',
        kilometers: 20,
        date: DateTime(2026, 7, 2),
        category: TripCategory.arbeit,
        note: '',
      ),
    ];

    expect(service.calculateKilometersByVehicle(trips, 'car-1'), 10);
  });

  test('Tankkosten werden richtig berechnet', () {
    final service = FuelReceiptStorageService();
    final receipts = [
      FuelReceipt(
        id: '1',
        vehicleId: 'car-1',
        date: DateTime(2026, 7, 1),
        stationName: 'Tankstelle A',
        liters: 20,
        totalPrice: 36,
        odometer: 100000,
        receiptText: '',
      ),
      FuelReceipt(
        id: '2',
        vehicleId: 'car-1',
        date: DateTime(2026, 7, 2),
        stationName: 'Tankstelle B',
        liters: 30,
        totalPrice: 54,
        odometer: 100400,
        receiptText: '',
      ),
    ];

    expect(service.calculateTotalFuelCost(receipts), 90);
    expect(service.calculateTotalLiters(receipts), 50);
  });
}
