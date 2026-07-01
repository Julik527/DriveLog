import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/models/fuel_receipt.dart';

void main() {
  test('FuelReceipt kann zu JSON und zurück umgewandelt werden', () {
    final receipt = FuelReceipt(
      id: 'receipt-1',
      vehicleId: 'vehicle-1',
      date: DateTime(2026, 7, 1),
      stationName: 'Aral Leutkirch',
      liters: 40,
      totalPrice: 72,
      odometer: 150000,
      receiptText: 'Belegnummer 123',
    );

    final decodedReceipt = FuelReceipt.decode(receipt.encode());

    expect(decodedReceipt.id, 'receipt-1');
    expect(decodedReceipt.vehicleId, 'vehicle-1');
    expect(decodedReceipt.stationName, 'Aral Leutkirch');
    expect(decodedReceipt.liters, 40);
    expect(decodedReceipt.totalPrice, 72);
    expect(decodedReceipt.odometer, 150000);
    expect(decodedReceipt.pricePerLiter, 1.8);
  });
}
