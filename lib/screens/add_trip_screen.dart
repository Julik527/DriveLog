import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../services/route_distance_service.dart';
import '../services/vehicle_storage_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/location_autocomplete_field.dart';
import '../widgets/vehicle_autocomplete_field.dart';

/// Seite zum Erstellen oder Bearbeiten einer Fahrt.
class AddTripScreen extends StatefulWidget {
  final Trip? existingTrip;

  const AddTripScreen({
    super.key,
    this.existingTrip,
  });

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();
  final _kilometersController = TextEditingController();
  final _noteController = TextEditingController();
  final RouteDistanceService _routeDistanceService = RouteDistanceService();
  final VehicleStorageService _vehicleStorageService = VehicleStorageService();

  DateTime _selectedDate = DateTime.now();
  TripCategory _selectedCategory = TripCategory.privat;
  List<Vehicle> _vehicles = [];
  String? _selectedVehicleId;
  bool _isLoadingVehicles = true;
  bool _isCalculatingDistance = false;
  String? _distanceStatusText;

  bool get _isEditMode => widget.existingTrip != null;

  @override
  void initState() {
    super.initState();

    final trip = widget.existingTrip;
    if (trip != null) {
      _startController.text = trip.startLocation;
      _destinationController.text = trip.destination;
      _kilometersController.text = trip.kilometers.toStringAsFixed(1);
      _noteController.text = trip.note;
      _selectedDate = trip.date;
      _selectedCategory = trip.category;
      _selectedVehicleId = trip.vehicleId;
    } else {
      // Für euer Projekt ist Leutkirch der Standard-Startort.
      // Der Nutzer kann den Ort trotzdem jederzeit ändern.
      _startController.text = 'Leutkirch';
    }

    _loadVehicles();
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    _kilometersController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    final loadedVehicles = await _vehicleStorageService.loadVehicles();

    if (!mounted) return;

    setState(() {
      _vehicles = loadedVehicles;
      _isLoadingVehicles = false;

      final existingVehicleStillExists = _vehicles.any(
        (vehicle) => vehicle.id == _selectedVehicleId,
      );

      if (!existingVehicleStillExists && _vehicles.isNotEmpty) {
        _selectedVehicleId = _vehicles.first.id;
      }
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _calculateKilometersAutomatically() async {
    final start = _startController.text.trim();
    final destination = _destinationController.text.trim();

    if (start.isEmpty || destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Startort und Zielort eintragen.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isCalculatingDistance = true;
      _distanceStatusText = 'Strecke wird berechnet ...';
    });

    try {
      final result = await _routeDistanceService.calculateDrivingDistance(
        startLocation: start,
        destination: destination,
      );

      if (!mounted) return;

      setState(() {
        _kilometersController.text = result.kilometers.toStringAsFixed(1);
        _distanceStatusText =
            'Automatisch berechnet: ${result.kilometers.toStringAsFixed(1)} km, ca. ${result.durationMinutes} Min.';
      });
    } on DistanceCalculationException catch (error) {
      if (!mounted) return;

      setState(() {
        _distanceStatusText = error.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;

      const message = 'Kilometer konnten nicht automatisch berechnet werden. Bitte Internet prüfen.';

      setState(() {
        _distanceStatusText = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCalculatingDistance = false;
        });
      }
    }
  }

  void _saveTrip() {
    if (_vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte zuerst ein Fahrzeug im Fuhrpark anlegen.'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Komma wird ersetzt, damit auch Eingaben wie "12,5" funktionieren.
    final kilometersText = _kilometersController.text.replaceAll(',', '.');
    final kilometers = double.parse(kilometersText);

    final trip = Trip(
      id: widget.existingTrip?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      startLocation: _startController.text.trim(),
      destination: _destinationController.text.trim(),
      kilometers: kilometers,
      date: _selectedDate,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      vehicleId: _selectedVehicleId,
    );

    Navigator.pop(context, trip);
  }

  String? _validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Dieses Feld darf nicht leer sein.';
    }
    return null;
  }

  String? _validateKilometers(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bitte Kilometer eintragen.';
    }

    final parsedValue = double.tryParse(value.replaceAll(',', '.'));
    if (parsedValue == null) {
      return 'Bitte eine gültige Zahl eintragen.';
    }

    if (parsedValue <= 0) {
      return 'Kilometer müssen größer als 0 sein.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Fahrt bearbeiten' : 'Neue Fahrt'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isLoadingVehicles)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Fahrzeuge werden geladen ...'),
                        ],
                      ),
                    ),
                  )
                else if (_vehicles.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'Noch kein Fahrzeug vorhanden. Lege zuerst im Dashboard ein Fahrzeug an, damit die Fahrt eindeutig zugeordnet werden kann.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  VehicleAutocompleteField(
                    vehicles: _vehicles,
                    selectedVehicleId: _selectedVehicleId,
                    onChanged: (value) {
                      setState(() {
                        _selectedVehicleId = value;
                      });
                    },
                  ),
                const SizedBox(height: 14),
                LocationAutocompleteField(
                  controller: _startController,
                  labelText: 'Startort',
                  helperText: 'Tippe z. B. L: Leutkirch, Lindau, Leutkirch im Allgäu ...',
                  prefixIcon: Icons.trip_origin,
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                LocationAutocompleteField(
                  controller: _destinationController,
                  labelText: 'Zielort',
                  helperText: 'Ortsvorschläge funktionieren ähnlich wie bei Maps.',
                  prefixIcon: Icons.flag,
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _kilometersController,
                  decoration: const InputDecoration(
                    labelText: 'Kilometer',
                    helperText: 'Manuell eintragen oder automatisch berechnen lassen.',
                    prefixIcon: Icon(Icons.speed),
                    suffixText: 'km',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateKilometers,
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _isCalculatingDistance ? null : _calculateKilometersAutomatically,
                  icon: _isCalculatingDistance
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: const Text('Kilometer automatisch berechnen'),
                ),
                if (_distanceStatusText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _distanceStatusText!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
                const SizedBox(height: 14),
                DropdownButtonFormField<TripCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategorie',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: TripCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('Datum'),
                    subtitle: Text(formatDate(_selectedDate)),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Notiz optional',
                    prefixIcon: Icon(Icons.note_alt),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _saveTrip,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditMode ? 'Änderungen speichern' : 'Fahrt speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
