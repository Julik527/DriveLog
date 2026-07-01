import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../services/vehicle_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'add_vehicle_screen.dart';

/// Übersicht aller Fahrzeuge im Fuhrpark.
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final loadedVehicles = await _vehicleStorageService.loadVehicles();
    loadedVehicles.sort((a, b) => a.displayName.compareTo(b.displayName));
    if (!mounted) return;
    setState(() {
      _vehicles = loadedVehicles;
      _isLoading = false;
    });
  }

  Future<void> _addVehicle() async {
    final newVehicle = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );
    if (newVehicle != null) {
      await _vehicleStorageService.addVehicle(newVehicle);
      await _loadVehicles();
    }
  }

  Future<void> _editVehicle(Vehicle vehicle) async {
    final updatedVehicle = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(builder: (_) => AddVehicleScreen(existingVehicle: vehicle)),
    );
    if (updatedVehicle != null) {
      await _vehicleStorageService.updateVehicle(updatedVehicle);
      await _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fahrzeug löschen?'),
        content: Text('Soll ${vehicle.displayName} mit Kennzeichen ${vehicle.licensePlate} wirklich gelöscht werden? Bestehende Fahrten bleiben gespeichert, sind danach aber nicht mehr zugeordnet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _vehicleStorageService.deleteVehicle(vehicle.id);
      await _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fuhrpark')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        icon: const Icon(Icons.add),
        label: const Text('Fahrzeug'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _vehicles.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Noch keine Fahrzeuge vorhanden. Lege zuerst Marke, Modell, Kennzeichen und VIN an.', textAlign: TextAlign.center),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return _VehicleCard(
                        vehicle: vehicle,
                        onEdit: () => _editVehicle(vehicle),
                        onDelete: () => _deleteVehicle(vehicle),
                      );
                    },
                  ),
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({required this.vehicle, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final huStatus = vehicle.huStatus();
    final huColor = switch (huStatus) {
      HuStatus.expired => AppTheme.redAccent,
      HuStatus.dueThisMonth || HuStatus.dueSoon || HuStatus.unknown => AppTheme.warning,
      HuStatus.ok => AppTheme.success,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.directions_car, color: Colors.black),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.displayName, style: Theme.of(context).textTheme.titleLarge),
                      Text(vehicle.displayDetails, style: const TextStyle(color: AppTheme.mutedText)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'edit', child: Text('Bearbeiten')),
                    PopupMenuItem(value: 'delete', child: Text('Löschen')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _VehicleChip(text: vehicle.licensePlate.isEmpty ? 'Kein Kennzeichen' : vehicle.licensePlate),
                _VehicleChip(text: huStatus.label, color: huColor),
                if (vehicle.fuelType.isNotEmpty) _VehicleChip(text: vehicle.fuelType),
                if (vehicle.maxSpeedKmh != null) _VehicleChip(text: '${vehicle.maxSpeedKmh} km/h Spitze'),
              ],
            ),
            const SizedBox(height: 12),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(top: 6),
              title: const Text('Digitaler Fahrzeugschein'),
              subtitle: const Text('Reifen, Gewichte, Maße, Öl und TÜV'),
              children: [
                _InfoRow(label: 'Nächste HU/TÜV', value: vehicle.huDueDate == null ? 'Nicht eingetragen' : formatDate(vehicle.huDueDate!)),
                _InfoRow(label: 'Reifen', value: vehicle.tireSizes.isEmpty ? 'Nicht eingetragen' : vehicle.tireSizes),
                _InfoRow(label: 'Gewichte', value: vehicle.weightLabel),
                _InfoRow(label: 'Maße', value: vehicle.sizeLabel),
                _InfoRow(label: 'Öl', value: vehicle.oilSpecification.isEmpty ? 'Nicht eingetragen' : '${vehicle.oilSpecification}${vehicle.oilCapacityLiters == null ? '' : ' • ${vehicle.oilCapacityLiters!.toStringAsFixed(1)} l'}'),
                if (vehicle.registrationDocumentText.isNotEmpty) _InfoRow(label: 'Notizen', value: vehicle.registrationDocumentText),
                if (vehicle.knownDamage.isNotEmpty) _InfoRow(label: 'Bekannte Probleme', value: vehicle.knownDamage),
              ],
            ),
            if (vehicle.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(vehicle.note, style: const TextStyle(color: AppTheme.mutedText)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(color: AppTheme.mutedText, fontWeight: FontWeight.w800))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  final String text;
  final Color? color;

  const _VehicleChip({required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      avatar: color == null ? null : Icon(Icons.circle, size: 12, color: color),
    );
  }
}
