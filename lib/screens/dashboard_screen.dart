import 'package:flutter/material.dart';

import '../models/fuel_receipt.dart';
import '../models/issue_report.dart';
import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/fuel_receipt_storage_service.dart';
import '../services/issue_report_storage_service.dart';
import '../services/trip_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_tile.dart';
import '../widgets/stat_card.dart';
import 'add_trip_screen.dart';
import 'fuel_receipt_list_screen.dart';
import 'gps_trip_screen.dart';
import 'issue_report_list_screen.dart';
import 'statistics_screen.dart';
import 'trip_list_screen.dart';
import 'vehicle_list_screen.dart';
import 'workshop_nearby_screen.dart';

/// Startseite der App.
///
/// Premium-Dashboard mit Fuhrparkdaten, Warnungen, GPS-Fahrt und Schnellzugriff.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TripStorageService _tripStorageService = TripStorageService();
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();
  final FuelReceiptStorageService _fuelReceiptStorageService = FuelReceiptStorageService();
  final IssueReportStorageService _issueReportStorageService = IssueReportStorageService();

  List<Trip> _trips = [];
  List<Vehicle> _vehicles = [];
  List<FuelReceipt> _fuelReceipts = [];
  List<IssueReport> _issueReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final loadedTrips = await _tripStorageService.loadTrips();
    final loadedVehicles = await _vehicleStorageService.loadVehicles();
    final loadedFuelReceipts = await _fuelReceiptStorageService.loadFuelReceipts();
    final loadedIssueReports = await _issueReportStorageService.loadReports();

    if (!mounted) return;

    setState(() {
      _trips = loadedTrips;
      _vehicles = loadedVehicles;
      _fuelReceipts = loadedFuelReceipts;
      _issueReports = loadedIssueReports;
      _isLoading = false;
    });
  }

  Future<void> _openAddTripScreen() async {
    final newTrip = await Navigator.push<Trip>(context, MaterialPageRoute(builder: (_) => const AddTripScreen()));
    if (newTrip != null) {
      await _tripStorageService.addTrip(newTrip);
      await _loadDashboardData();
    }
  }

  Future<void> _openPage(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final totalKilometers = _tripStorageService.calculateTotalKilometers(_trips);
    final totalFuelCost = _fuelReceiptStorageService.calculateTotalFuelCost(_fuelReceipts);
    final openIssues = _issueReports.where((report) => report.status != IssueStatus.erledigt).length;
    final huWarnings = _vehicles.where((vehicle) => vehicle.huStatus() != HuStatus.ok).length;

    return Scaffold(
      appBar: AppBar(title: const Text('DriveLog')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _HeroPanel(totalKilometers: totalKilometers, vehicleCount: _vehicles.length, openIssues: openIssues),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: [
                        StatCard(icon: Icons.garage, label: 'Fahrzeuge', value: _vehicles.length.toString(), subLabel: huWarnings == 0 ? 'Alles ruhig' : '$huWarnings Hinweis(e)'),
                        StatCard(icon: Icons.route, label: 'Fahrten', value: _trips.length.toString(), subLabel: '${totalKilometers.toStringAsFixed(1)} km'),
                        StatCard(icon: Icons.local_gas_station, label: 'Tankkosten', value: '${totalFuelCost.toStringAsFixed(2)} €', subLabel: '${_fuelReceipts.length} Belege'),
                        StatCard(icon: Icons.report_problem, label: 'Probleme', value: openIssues.toString(), subLabel: openIssues == 0 ? 'Keine offen' : 'Offene Meldungen', iconColor: openIssues == 0 ? AppTheme.success : AppTheme.warning),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (huWarnings > 0 || openIssues > 0) _WarningPanel(vehicles: _vehicles, openIssues: openIssues),
                    const SizedBox(height: 6),
                    ActionTile(
                      important: true,
                      icon: Icons.play_circle,
                      title: 'GPS-Fahrt starten',
                      subtitle: 'Mit Pflicht-Hinweis vor Fahrtbeginn, Geschwindigkeit und Strecke.',
                      onTap: () => _openPage(const GpsTripScreen()),
                    ),
                    ActionTile(
                      icon: Icons.add_road,
                      title: 'Fahrt manuell eintragen',
                      subtitle: 'Start, Ziel, Kilometer, Kategorie und Fahrzeug speichern.',
                      onTap: _openAddTripScreen,
                    ),
                    ActionTile(
                      icon: Icons.garage,
                      title: 'Fuhrpark verwalten',
                      subtitle: 'Fahrzeugdaten, VIN, Kennzeichen, TÜV, Öl und Fahrzeugschein.',
                      onTap: () => _openPage(const VehicleListScreen()),
                    ),
                    ActionTile(
                      icon: Icons.receipt_long,
                      title: 'Tankbelege scannen',
                      subtitle: 'Foto/OCR für Android/iOS plus manuelle Prüfung der Werte.',
                      onTap: () => _openPage(const FuelReceiptListScreen()),
                    ),
                    ActionTile(
                      icon: Icons.report_problem,
                      title: 'Probleme melden',
                      subtitle: 'Fahrwerk, Bremse, Motor, Reifen oder Geräusche dokumentieren.',
                      onTap: () => _openPage(const IssueReportListScreen()),
                    ),
                    ActionTile(
                      icon: Icons.list_alt,
                      title: 'Fahrtenliste',
                      subtitle: 'Suchen, filtern, bearbeiten, löschen und CSV kopieren.',
                      onTap: () => _openPage(const TripListScreen()),
                    ),
                    ActionTile(
                      icon: Icons.build,
                      title: 'Werkstätten in der Nähe',
                      subtitle: 'Werkstattsuche über öffentliche Kartendaten. Standard: Leutkirch.',
                      onTap: () => _openPage(const WorkshopNearbyScreen()),
                    ),
                    ActionTile(
                      icon: Icons.bar_chart,
                      title: 'Statistik',
                      subtitle: 'Kilometer, Geschwindigkeit, Verbrauch und Fahrzeuge auswerten.',
                      onTap: () => _openPage(const StatisticsScreen()),
                    ),
                    const SizedBox(height: 24),
                    _VehiclePreview(vehicles: _vehicles),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final double totalKilometers;
  final int vehicleCount;
  final int openIssues;

  const _HeroPanel({required this.totalKilometers, required this.vehicleCount, required this.openIssues});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.premiumDecoration(highlighted: true),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(999), border: Border.all(color: AppTheme.gold.withOpacity(0.5))),
            child: const Text('FLEET CONTROL', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ),
          const Spacer(),
          const Icon(Icons.bolt, color: AppTheme.gold),
        ]),
        const SizedBox(height: 18),
        Text('DriveLog', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        const Text('Digitales Fahrtenbuch mit Fuhrpark, GPS, Tankbelegen, TÜV-Hinweisen und Problemmanagement.', style: TextStyle(color: AppTheme.mutedText)),
        const SizedBox(height: 18),
        Wrap(spacing: 8, runSpacing: 8, children: [
          Chip(label: Text('${totalKilometers.toStringAsFixed(1)} km')),
          Chip(label: Text('$vehicleCount Fahrzeuge')),
          Chip(label: Text('$openIssues offene Probleme')),
        ]),
      ]),
    );
  }
}

class _WarningPanel extends StatelessWidget {
  final List<Vehicle> vehicles;
  final int openIssues;

  const _WarningPanel({required this.vehicles, required this.openIssues});

  @override
  Widget build(BuildContext context) {
    final warningVehicles = vehicles.where((vehicle) => vehicle.huStatus() != HuStatus.ok).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.warning),
            const SizedBox(width: 10),
            Text('Achtung / Hinweise', style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 10),
          if (openIssues > 0) Text('$openIssues offene Problem-Meldung(en) vorhanden.'),
          for (final vehicle in warningVehicles.take(3)) Text('${vehicle.displayName}: ${vehicle.huStatus().label}'),
        ]),
      ),
    );
  }
}

class _VehiclePreview extends StatelessWidget {
  final List<Vehicle> vehicles;

  const _VehiclePreview({required this.vehicles});

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Tipp: Lege zuerst mindestens ein Fahrzeug mit Marke, Modell, Kennzeichen und VIN an. Danach wirken Fahrten, Tankbelege und GPS sauber wie eine echte Fuhrpark-App.', style: TextStyle(color: AppTheme.mutedText)),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Aktiver Fuhrpark', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          for (final vehicle in vehicles.take(4)) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${vehicle.displayName} • ${vehicle.licensePlate} • ${vehicle.huStatus().label}')),
          if (vehicles.length > 4) Text('+ ${vehicles.length - 4} weitere Fahrzeuge', style: const TextStyle(color: AppTheme.mutedText)),
        ]),
      ),
    );
  }
}
