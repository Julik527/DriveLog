import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/trip_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../widgets/trip_card.dart';
import 'add_trip_screen.dart';

/// Seite mit allen gespeicherten Fahrten.
///
/// Hier kann gesucht, gefiltert, bearbeitet, gelöscht und als CSV kopiert werden.
class TripListScreen extends StatefulWidget {
  const TripListScreen({super.key});

  @override
  State<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends State<TripListScreen> {
  final TripStorageService _tripStorageService = TripStorageService();
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Trip> _trips = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  TripCategory? _selectedCategoryFilter;
  String? _selectedVehicleFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final loadedTrips = await _tripStorageService.loadTrips();
    final loadedVehicles = await _vehicleStorageService.loadVehicles();

    loadedTrips.sort((a, b) => b.date.compareTo(a.date));

    if (!mounted) return;

    setState(() {
      _trips = loadedTrips;
      _vehicles = loadedVehicles;
      _isLoading = false;
    });
  }

  Vehicle? _findVehicle(String? vehicleId) {
    return _vehicleStorageService.findVehicleById(_vehicles, vehicleId);
  }

  List<Trip> get _filteredTrips {
    final searchText = _searchController.text.trim().toLowerCase();

    return _trips.where((trip) {
      final vehicle = _findVehicle(trip.vehicleId);
      final matchesCategory = _selectedCategoryFilter == null || trip.category == _selectedCategoryFilter;
      final matchesVehicle = _selectedVehicleFilter == null || trip.vehicleId == _selectedVehicleFilter;

      final searchableText = [
        trip.startLocation,
        trip.destination,
        trip.category.label,
        trip.note,
        vehicle?.displayName ?? '',
        vehicle?.licensePlate ?? '',
        vehicle?.vin ?? '',
      ].join(' ').toLowerCase();

      final matchesSearch = searchText.isEmpty || searchableText.contains(searchText);

      return matchesCategory && matchesVehicle && matchesSearch;
    }).toList();
  }

  Future<void> _deleteTrip(Trip trip) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Fahrt löschen?'),
          content: Text(
            'Soll die Fahrt von ${trip.startLocation} nach ${trip.destination} wirklich gelöscht werden?',
          ),
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
      await _tripStorageService.deleteTrip(trip.id);
      await _loadData();
    }
  }

  Future<void> _editTrip(Trip trip) async {
    final updatedTrip = await Navigator.push<Trip>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTripScreen(existingTrip: trip),
      ),
    );

    if (updatedTrip != null) {
      await _tripStorageService.updateTrip(updatedTrip);
      await _loadData();
    }
  }

  Future<void> _copyCsvToClipboard() async {
    final csvText = _tripStorageService.buildCsv(_trips, vehicles: _vehicles);
    await Clipboard.setData(ClipboardData(text: csvText));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV-Daten wurden in die Zwischenablage kopiert.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrips = _filteredTrips;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fahrtenliste'),
        actions: [
          IconButton(
            onPressed: _trips.isEmpty ? null : _copyCsvToClipboard,
            icon: const Icon(Icons.file_copy),
            tooltip: 'CSV kopieren',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Suche nach Ort, Fahrzeug, Kennzeichen, VIN oder Notiz',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: DropdownButtonFormField<String?>(
                      value: _selectedVehicleFilter,
                      decoration: const InputDecoration(
                        labelText: 'Fahrzeug filtern',
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Alle Fahrzeuge'),
                        ),
                        ..._vehicles.map(
                          (vehicle) => DropdownMenuItem<String?>(
                            value: vehicle.id,
                            child: Text('${vehicle.displayName} • ${vehicle.licensePlate}'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicleFilter = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: DropdownButtonFormField<TripCategory?>(
                      value: _selectedCategoryFilter,
                      decoration: const InputDecoration(
                        labelText: 'Kategorie filtern',
                        prefixIcon: Icon(Icons.filter_alt),
                      ),
                      items: [
                        const DropdownMenuItem<TripCategory?>(
                          value: null,
                          child: Text('Alle Kategorien'),
                        ),
                        ...TripCategory.values.map(
                          (category) => DropdownMenuItem<TripCategory?>(
                            value: category,
                            child: Text(category.label),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryFilter = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: filteredTrips.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Keine passenden Fahrten gefunden.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTrips.length,
                            itemBuilder: (context, index) {
                              final trip = filteredTrips[index];

                              return TripCard(
                                trip: trip,
                                vehicle: _findVehicle(trip.vehicleId),
                                onDelete: () => _deleteTrip(trip),
                                onEdit: () => _editTrip(trip),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
