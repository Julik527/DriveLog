import 'package:shared_preferences/shared_preferences.dart';

import '../models/vehicle.dart';

class VehicleStorageService {
  static const String _storageKey = 'drivelog_vehicles_v2';

  Future<List<Vehicle>> loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_storageKey) ?? [];
    return data.map(Vehicle.decode).toList();
  }

  Future<void> saveVehicles(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, vehicles.map((vehicle) => vehicle.encode()).toList());
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final vehicles = await loadVehicles();
    vehicles.add(vehicle);
    await saveVehicles(vehicles);
  }

  Future<void> updateVehicle(Vehicle updatedVehicle) async {
    final vehicles = await loadVehicles();
    final index = vehicles.indexWhere((vehicle) => vehicle.id == updatedVehicle.id);
    if (index == -1) {
      vehicles.add(updatedVehicle);
    } else {
      vehicles[index] = updatedVehicle;
    }
    await saveVehicles(vehicles);
  }

  Future<void> deleteVehicle(String id) async {
    final vehicles = await loadVehicles();
    vehicles.removeWhere((vehicle) => vehicle.id == id);
    await saveVehicles(vehicles);
  }

  Vehicle? findVehicleById(List<Vehicle> vehicles, String? id) {
    if (id == null) return null;
    for (final vehicle in vehicles) {
      if (vehicle.id == id) return vehicle;
    }
    return null;
  }
}
