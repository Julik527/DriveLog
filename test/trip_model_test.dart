import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/models/trip.dart';

void main() {
  test('Trip kann zu JSON und zurück umgewandelt werden', () {
    final trip = Trip(
      id: '1',
      vehicleId: 'vehicle-1',
      startLocation: 'Leutkirch',
      destination: 'Ravensburg',
      kilometers: 42.5,
      date: DateTime(2026, 7, 1),
      category: TripCategory.schule,
      note: 'Schulweg',
    );

    final jsonText = trip.encode();
    final decodedTrip = Trip.decode(jsonText);

    expect(decodedTrip.id, '1');
    expect(decodedTrip.vehicleId, 'vehicle-1');
    expect(decodedTrip.startLocation, 'Leutkirch');
    expect(decodedTrip.destination, 'Ravensburg');
    expect(decodedTrip.kilometers, 42.5);
    expect(decodedTrip.category, TripCategory.schule);
    expect(decodedTrip.note, 'Schulweg');
  });

  test('Unbekannte Kategorie wird als Sonstiges geladen', () {
    final category = TripCategoryExtension.fromName('unbekannt');

    expect(category, TripCategory.sonstiges);
  });
}
