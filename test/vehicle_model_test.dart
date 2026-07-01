import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/models/vehicle.dart';

void main() {
  test('Vehicle kann zu JSON und zurück umgewandelt werden', () {
    final vehicle = Vehicle(
      id: 'vehicle-1',
      brand: 'Ford',
      model: 'Focus Cabrio',
      licensePlate: 'RV AB 123',
      vin: 'WF0ABCDEFG1234567',
      note: 'Schulprojekt-Fahrzeug',
    );

    final decodedVehicle = Vehicle.decode(vehicle.encode());

    expect(decodedVehicle.id, 'vehicle-1');
    expect(decodedVehicle.brand, 'Ford');
    expect(decodedVehicle.model, 'Focus Cabrio');
    expect(decodedVehicle.licensePlate, 'RV AB 123');
    expect(decodedVehicle.vin, 'WF0ABCDEFG1234567');
    expect(decodedVehicle.displayName, 'Ford Focus Cabrio');
  });
}
