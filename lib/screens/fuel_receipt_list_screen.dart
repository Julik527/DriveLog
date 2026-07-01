import 'package:flutter/material.dart';

import '../models/fuel_receipt.dart';
import '../models/vehicle.dart';
import '../services/fuel_receipt_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../utils/date_formatter.dart';
import 'add_fuel_receipt_screen.dart';

/// Übersicht über alle Tankbelege.
class FuelReceiptListScreen extends StatefulWidget {
  const FuelReceiptListScreen({super.key});

  @override
  State<FuelReceiptListScreen> createState() => _FuelReceiptListScreenState();
}

class _FuelReceiptListScreenState extends State<FuelReceiptListScreen> {
  final FuelReceiptStorageService _receiptStorageService = FuelReceiptStorageService();
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();

  List<FuelReceipt> _receipts = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedReceipts = await _receiptStorageService.loadFuelReceipts();
    final loadedVehicles = await _vehicleStorageService.loadVehicles();

    loadedReceipts.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;

    setState(() {
      _receipts = loadedReceipts;
      _vehicles = loadedVehicles;
      _isLoading = false;
    });
  }

  Vehicle? _findVehicle(String vehicleId) {
    return _vehicleStorageService.findVehicleById(_vehicles, vehicleId);
  }

  Future<void> _addReceipt() async {
    final newReceipt = await Navigator.push<FuelReceipt>(
      context,
      MaterialPageRoute(
        builder: (_) => AddFuelReceiptScreen(vehicles: _vehicles),
      ),
    );

    if (newReceipt != null) {
      await _receiptStorageService.addFuelReceipt(newReceipt);
      await _loadData();
    }
  }

  Future<void> _deleteReceipt(FuelReceipt receipt) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tankbeleg löschen?'),
          content: Text('Soll der Tankbeleg von ${receipt.stationName} wirklich gelöscht werden?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _receiptStorageService.deleteFuelReceipt(receipt.id);
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _receiptStorageService.calculateTotalFuelCost(_receipts);
    final totalLiters = _receiptStorageService.calculateTotalLiters(_receipts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tankbelege'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReceipt,
        icon: const Icon(Icons.add),
        label: const Text('Beleg'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Übersicht',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text('Tankbelege: ${_receipts.length}'),
                          Text('Gesamtkosten: ${totalCost.toStringAsFixed(2)} €'),
                          Text('Gesamtliter: ${totalLiters.toStringAsFixed(2)} l'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_receipts.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text(
                          'Noch keine Tankbelege vorhanden.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    )
                  else
                    for (final receipt in _receipts)
                      _FuelReceiptCard(
                        receipt: receipt,
                        vehicle: _findVehicle(receipt.vehicleId),
                        onDelete: () => _deleteReceipt(receipt),
                      ),
                ],
              ),
      ),
    );
  }
}

class _FuelReceiptCard extends StatelessWidget {
  final FuelReceipt receipt;
  final Vehicle? vehicle;
  final VoidCallback onDelete;

  const _FuelReceiptCard({
    required this.receipt,
    required this.vehicle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    receipt.stationName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Löschen',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vehicle == null
                  ? 'Fahrzeug nicht mehr vorhanden'
                  : '${vehicle!.displayName} • ${vehicle!.licensePlate}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReceiptChip(text: formatDate(receipt.date)),
                _ReceiptChip(text: '${receipt.liters.toStringAsFixed(2)} l'),
                _ReceiptChip(text: '${receipt.totalPrice.toStringAsFixed(2)} €'),
                _ReceiptChip(text: '${receipt.pricePerLiter.toStringAsFixed(2)} €/l'),
                _ReceiptChip(text: '${receipt.odometer} km'),
              ],
            ),
            if (receipt.imagePath != null) ...[
              const SizedBox(height: 10),
              Text(
                'Foto: ${receipt.imagePath}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
            if (receipt.receiptText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                receipt.receiptText,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReceiptChip extends StatelessWidget {
  final String text;

  const _ReceiptChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: Colors.white10,
      side: BorderSide.none,
    );
  }
}
