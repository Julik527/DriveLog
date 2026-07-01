import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/gps_tracking_service.dart';
import '../services/trip_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/location_autocomplete_field.dart';
import '../widgets/pre_trip_check_dialog.dart';
import '../widgets/vehicle_autocomplete_field.dart';
import 'add_issue_report_screen.dart';

/// GPS-Fahrt starten und beenden.
///
/// Die Seite misst Distanz, Dauer, Durchschnittsgeschwindigkeit und maximale
/// Geschwindigkeit. Vor dem Start muss der Fahrer die Hinweise bestätigen.
class GpsTripScreen extends StatefulWidget {
  const GpsTripScreen({super.key});

  @override
  State<GpsTripScreen> createState() => _GpsTripScreenState();
}

class _GpsTripScreenState extends State<GpsTripScreen> {
  final _gpsService = GpsTrackingService();
  final _vehicleStorageService = VehicleStorageService();
  final _tripStorageService = TripStorageService();
  final _startController = TextEditingController(text: 'Leutkirch');
  final _destinationController = TextEditingController();
  final _noteController = TextEditingController();
  final _fuelUsedController = TextEditingController();

  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  TripCategory _category = TripCategory.privat;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastPosition;
  DateTime? _startTime;
  Timer? _timer;
  Duration _duration = Duration.zero;
  double _distanceMeters = 0;
  double _maxSpeedKmh = 0;
  bool _isLoading = true;
  bool _isTracking = false;
  String? _statusText;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    _startController.dispose();
    _destinationController.dispose();
    _noteController.dispose();
    _fuelUsedController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final loaded = await _vehicleStorageService.loadVehicles();
    if (!mounted) return;
    setState(() {
      _vehicles = loaded;
      _selectedVehicleId = loaded.isEmpty ? null : loaded.first.id;
      _isLoading = false;
    });
  }

  Vehicle? get _selectedVehicle => _vehicleStorageService.findVehicleById(_vehicles, _selectedVehicleId);

  Future<void> _startTracking() async {
    final vehicle = _selectedVehicle;
    if (vehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte zuerst ein Fahrzeug auswählen.')));
      return;
    }

    final confirmed = await PreTripCheckDialog.show(context, vehicle);
    if (!confirmed) return;

    try {
      await _gpsService.ensurePermission();
      _positionSubscription?.cancel();
      _lastPosition = null;
      setState(() {
        _isTracking = true;
        _startTime = DateTime.now();
        _duration = Duration.zero;
        _distanceMeters = 0;
        _maxSpeedKmh = 0;
        _statusText = 'GPS-Fahrt läuft ...';
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted || _startTime == null) return;
        setState(() => _duration = DateTime.now().difference(_startTime!));
      });

      _positionSubscription = _gpsService.positionStream().listen(
        (position) {
          final last = _lastPosition;
          if (last != null) {
            final meters = _gpsService.distanceMeters(last, position);
            if (meters > 0 && meters < 1000) {
              _distanceMeters += meters;
            }
          }

          final speedKmh = (position.speed * 3.6).clamp(0, 400).toDouble();
          if (speedKmh > _maxSpeedKmh) _maxSpeedKmh = speedKmh;
          _lastPosition = position;

          if (mounted) setState(() {});
        },
        onError: (_) {
          if (!mounted) return;
          setState(() => _statusText = 'GPS-Tracking hat einen Fehler gemeldet.');
        },
      );
    } on GpsTrackingException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GPS konnte nicht gestartet werden.')));
    }
  }

  Future<void> _stopAndSave() async {
    if (!_isTracking) return;

    await _positionSubscription?.cancel();
    _timer?.cancel();

    final kilometers = _distanceMeters / 1000;
    if (kilometers <= 0.02) {
      setState(() {
        _isTracking = false;
        _statusText = 'Fahrt beendet, aber Strecke war zu kurz. Nicht gespeichert.';
      });
      return;
    }

    final fuelText = _fuelUsedController.text.trim().replaceAll(',', '.');
    final fuelUsed = fuelText.isEmpty ? null : double.tryParse(fuelText);

    final trip = Trip(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startLocation: _startController.text.trim().isEmpty ? 'GPS-Start' : _startController.text.trim(),
      destination: _destinationController.text.trim().isEmpty ? 'GPS-Ziel' : _destinationController.text.trim(),
      kilometers: kilometers,
      date: DateTime.now(),
      category: _category,
      note: _noteController.text.trim(),
      vehicleId: _selectedVehicleId,
      durationSeconds: _duration.inSeconds,
      maxSpeedKmh: _maxSpeedKmh,
      fuelUsedLiters: fuelUsed,
      createdByGps: true,
    );

    await _tripStorageService.addTrip(trip);

    if (!mounted) return;
    setState(() {
      _isTracking = false;
      _statusText = 'GPS-Fahrt gespeichert: ${kilometers.toStringAsFixed(2)} km.';
    });

    final reportProblem = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Problem nach der Fahrt?'),
        content: const Text('Falls der Fahrer ein ungewöhnliches Geräusch, Fahrwerksproblem oder eine Beschädigung bemerkt hat, kann er es direkt melden.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Nein')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Problem melden')),
        ],
      ),
    );

    if (reportProblem == true && mounted && _selectedVehicle != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AddIssueReportScreen(vehicles: _vehicles, preselectedVehicleId: _selectedVehicleId)),
      );
    }
  }

  String get _durationLabel {
    final minutes = _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = _duration.inHours;
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  double get _kilometers => _distanceMeters / 1000;

  double? get _averageSpeed {
    if (_duration.inSeconds <= 0 || _kilometers <= 0) return null;
    return _kilometers / (_duration.inSeconds / 3600);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GPS-Fahrt')),
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
                          Text('Live Tracking', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          const Text('Vor dem Start erscheint eine Sicherheitsmeldung mit TÜV, Beschädigungskontrolle und Fahrzeugdaten.', style: TextStyle(color: AppTheme.mutedText)),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _LiveMetric(label: 'Strecke', value: '${_kilometers.toStringAsFixed(2)} km'),
                              _LiveMetric(label: 'Dauer', value: _durationLabel),
                              _LiveMetric(label: 'Ø Speed', value: _averageSpeed == null ? '-' : '${_averageSpeed!.toStringAsFixed(1)} km/h'),
                              _LiveMetric(label: 'Max Speed', value: '${_maxSpeedKmh.toStringAsFixed(1)} km/h'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_vehicles.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Text('Noch kein Fahrzeug vorhanden. GPS-Fahrten brauchen ein Fahrzeug.', style: TextStyle(color: AppTheme.mutedText)),
                      ),
                    )
                  else
                    AbsorbPointer(
                      absorbing: _isTracking,
                      child: VehicleAutocompleteField(
                        vehicles: _vehicles,
                        selectedVehicleId: _selectedVehicleId,
                        onChanged: (value) => setState(() => _selectedVehicleId = value),
                      ),
                    ),
                  const SizedBox(height: 14),
                  LocationAutocompleteField(
                    controller: _startController,
                    labelText: 'Startort',
                    helperText: 'Tippe z. B. L für Leutkirch oder Lindau.',
                    prefixIcon: Icons.trip_origin,
                    enabled: !_isTracking,
                  ),
                  const SizedBox(height: 14),
                  LocationAutocompleteField(
                    controller: _destinationController,
                    labelText: 'Ziel / Zweck',
                    helperText: 'Auch GPS-Fahrten können ein Ziel mit Vorschlag bekommen.',
                    prefixIcon: Icons.flag,
                    enabled: !_isTracking,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<TripCategory>(
                    value: _category,
                    decoration: const InputDecoration(labelText: 'Kategorie', prefixIcon: Icon(Icons.category)),
                    items: TripCategory.values.map((category) => DropdownMenuItem(value: category, child: Text(category.label))).toList(),
                    onChanged: _isTracking ? null : (value) => setState(() => _category = value ?? TripCategory.privat),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _fuelUsedController,
                    enabled: !_isTracking,
                    decoration: const InputDecoration(labelText: 'Verbrauchte Liter optional', helperText: 'Damit wird der Durchschnittsverbrauch der Fahrt berechnet.', suffixText: 'l', prefixIcon: Icon(Icons.local_gas_station)),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  TextField(controller: _noteController, enabled: !_isTracking, decoration: const InputDecoration(labelText: 'Notiz optional', prefixIcon: Icon(Icons.note_alt)), maxLines: 3),
                  const SizedBox(height: 18),
                  if (_statusText != null) Text(_statusText!, style: const TextStyle(color: AppTheme.mutedText)),
                  const SizedBox(height: 14),
                  _isTracking
                      ? ElevatedButton.icon(onPressed: _stopAndSave, icon: const Icon(Icons.stop), label: const Text('Fahrt beenden und speichern'))
                      : ElevatedButton.icon(onPressed: _vehicles.isEmpty ? null : _startTracking, icon: const Icon(Icons.play_arrow), label: const Text('Hinweis bestätigen und GPS-Fahrt starten')),
                ],
              ),
      ),
    );
  }
}

class _LiveMetric extends StatelessWidget {
  final String label;
  final String value;

  const _LiveMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.backgroundSoft, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppTheme.cardBorder)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.mutedText)),
      ]),
    );
  }
}
