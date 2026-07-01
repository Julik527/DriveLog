import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_receipt.dart';

/// Speichert und berechnet Tankbelege.
class FuelReceiptStorageService {
  static const String _storageKey = 'drivelog_fuel_receipts_v3';
  static const String _legacyStorageKey = 'drivelog_fuel_receipts_v2';

  Future<List<FuelReceipt>> loadFuelReceipts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? prefs.getStringList(_legacyStorageKey) ?? [];
    return data.map(FuelReceipt.decode).toList();
  }

  Future<void> saveFuelReceipts(List<FuelReceipt> receipts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, receipts.map((receipt) => receipt.encode()).toList());
  }

  Future<void> addFuelReceipt(FuelReceipt receipt) async {
    final receipts = await loadFuelReceipts();
    receipts.add(receipt);
    await saveFuelReceipts(receipts);
  }

  Future<void> deleteFuelReceipt(String id) async {
    final receipts = await loadFuelReceipts();
    receipts.removeWhere((receipt) => receipt.id == id);
    await saveFuelReceipts(receipts);
  }

  // Alias-Methoden, damit ältere Screens/Tests weiterhin funktionieren.
  Future<List<FuelReceipt>> loadReceipts() => loadFuelReceipts();
  Future<void> saveReceipts(List<FuelReceipt> receipts) => saveFuelReceipts(receipts);
  Future<void> addReceipt(FuelReceipt receipt) => addFuelReceipt(receipt);
  Future<void> deleteReceipt(String id) => deleteFuelReceipt(id);

  double calculateTotalFuelCost(List<FuelReceipt> receipts) {
    return receipts.fold(0, (sum, receipt) => sum + receipt.totalPrice);
  }

  double calculateTotalFuelCosts(List<FuelReceipt> receipts) => calculateTotalFuelCost(receipts);

  double calculateTotalLiters(List<FuelReceipt> receipts) {
    return receipts.fold(0, (sum, receipt) => sum + receipt.liters);
  }

  double? calculateRoughConsumption({required double kilometers, required double liters}) {
    if (kilometers <= 0 || liters <= 0) return null;
    return (liters / kilometers) * 100;
  }
}
