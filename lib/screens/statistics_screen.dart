import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/trip_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';

/// Einfache Statistikseite.
///
/// Sie zeigt verständliche Kennzahlen statt komplizierter Diagramme.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final TripStorageService _tripStorageService = TripStorageService();
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();

  List<Trip> _trips = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final loadedTrips = await _tripStorageService.loadTrips();
    final loadedVehicles = await _vehicleStorageService.loadVehicles();
    if (!mounted) return;
    setState(() {
      _trips = loadedTrips;
      _vehicles = loadedVehicles;
      _isLoading = false;
    });
  }

  double get _averageKilometers {
    if (_trips.isEmpty) return 0;
    return _tripStorageService.calculateTotalKilometers(_trips) / _trips.length;
  }

  double? get _averageConsumption {
    final consumptions = _trips.map((trip) => trip.averageConsumptionL100km).whereType<double>().toList();
    if (consumptions.isEmpty) return null;
    return consumptions.fold(0.0, (sum, value) => sum + value) / consumptions.length;
  }

  Trip? get _longestTrip {
    if (_trips.isEmpty) return null;
    final sortedTrips = [..._trips]..sort((a, b) => b.kilometers.compareTo(a.kilometers));
    return sortedTrips.first;
  }

  @override
  Widget build(BuildContext context) {
    final totalKilometers = _tripStorageService.calculateTotalKilometers(_trips);
    final longestTrip = _longestTrip;
    final averageSpeed = _tripStorageService.calculateAverageSpeed(_trips);
    final maxSpeed = _tripStorageService.findMaxSpeed(_trips);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(label: 'Gesamtkilometer', value: '${totalKilometers.toStringAsFixed(1)} km', icon: Icons.speed),
                      StatCard(label: 'Ø pro Fahrt', value: '${_averageKilometers.toStringAsFixed(1)} km', icon: Icons.calculate),
                      StatCard(label: 'Ø Geschwindigkeit', value: averageSpeed == null ? '-' : '${averageSpeed.toStringAsFixed(1)} km/h', icon: Icons.av_timer),
                      StatCard(label: 'Höchstgeschwindigkeit', value: maxSpeed == null ? '-' : '${maxSpeed.toStringAsFixed(1)} km/h', icon: Icons.bolt),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_averageConsumption != null) StatCard(label: 'Ø Verbrauch', value: '${_averageConsumption!.toStringAsFixed(1)} l/100km', icon: Icons.local_gas_station),
                  if (longestTrip != null) ...[
                    const SizedBox(height: 12),
                    StatCard(label: 'Längste Fahrt', value: '${longestTrip.kilometers.toStringAsFixed(1)} km', icon: Icons.trending_up, subLabel: '${longestTrip.startLocation} → ${longestTrip.destination}'),
                  ],
                  const SizedBox(height: 14),
                  _StatsPanel(
                    title: 'Kilometer je Kategorie',
                    children: [
                      for (final category in TripCategory.values)
                        _StatisticRow(label: category.label, kilometers: _tripStorageService.calculateKilometersByCategory(_trips, category), totalKilometers: totalKilometers),
                    ],
                  ),
                  if (_vehicles.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _StatsPanel(
                      title: 'Kilometer je Fahrzeug',
                      children: [
                        for (final vehicle in _vehicles)
                          _StatisticRow(label: '${vehicle.displayName} • ${vehicle.licensePlate}', kilometers: _tripStorageService.calculateKilometersByVehicle(_trips, vehicle.id), totalKilometers: totalKilometers),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _StatsPanel extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StatsPanel({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ...children,
        ]),
      ),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String label;
  final double kilometers;
  final double totalKilometers;

  const _StatisticRow({required this.label, required this.kilometers, required this.totalKilometers});

  @override
  Widget build(BuildContext context) {
    final percent = totalKilometers == 0 ? 0.0 : kilometers / totalKilometers;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 10),
          Text('${kilometers.toStringAsFixed(1)} km'),
        ]),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: percent, color: AppTheme.gold, backgroundColor: AppTheme.backgroundSoft),
      ]),
    );
  }
}
