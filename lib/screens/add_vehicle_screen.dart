import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../services/form_suggestion_service.dart';
import '../widgets/suggestion_text_form_field.dart';

/// Seite zum Erstellen oder Bearbeiten eines Fahrzeugs.
class AddVehicleScreen extends StatefulWidget {
  final Vehicle? existingVehicle;

  const AddVehicleScreen({
    super.key,
    this.existingVehicle,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _vinController = TextEditingController();
  final _noteController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _maxSpeedController = TextEditingController();
  final _tireSizesController = TextEditingController();
  final _trailerLoadController = TextEditingController();
  final _grossWeightController = TextEditingController();
  final _emptyWeightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _oilSpecificationController = TextEditingController();
  final _oilCapacityController = TextEditingController();
  final _registrationTextController = TextEditingController();
  final _knownDamageController = TextEditingController();

  DateTime? _huDueDate;
  bool _requiresDamageCheck = true;

  bool get _isEditMode => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();

    final vehicle = widget.existingVehicle;
    if (vehicle != null) {
      _brandController.text = vehicle.brand;
      _modelController.text = vehicle.model;
      _licensePlateController.text = vehicle.licensePlate;
      _vinController.text = vehicle.vin;
      _noteController.text = vehicle.note;
      _fuelTypeController.text = vehicle.fuelType;
      _maxSpeedController.text = vehicle.maxSpeedKmh?.toString() ?? '';
      _tireSizesController.text = vehicle.tireSizes;
      _trailerLoadController.text = vehicle.trailerLoadKg?.toString() ?? '';
      _grossWeightController.text = vehicle.grossVehicleWeightKg?.toString() ?? '';
      _emptyWeightController.text = vehicle.emptyWeightKg?.toString() ?? '';
      _lengthController.text = vehicle.lengthMm?.toString() ?? '';
      _widthController.text = vehicle.widthMm?.toString() ?? '';
      _heightController.text = vehicle.heightMm?.toString() ?? '';
      _oilSpecificationController.text = vehicle.oilSpecification;
      _oilCapacityController.text = vehicle.oilCapacityLiters?.toStringAsFixed(1) ?? '';
      _registrationTextController.text = vehicle.registrationDocumentText;
      _knownDamageController.text = vehicle.knownDamage;
      _huDueDate = vehicle.huDueDate;
      _requiresDamageCheck = vehicle.requiresDamageCheck;
    }

    _brandController.addListener(_refreshDependentSuggestions);
    _modelController.addListener(_refreshDependentSuggestions);
    _fuelTypeController.addListener(_refreshDependentSuggestions);
  }

  void _refreshDependentSuggestions() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _brandController.removeListener(_refreshDependentSuggestions);
    _modelController.removeListener(_refreshDependentSuggestions);
    _fuelTypeController.removeListener(_refreshDependentSuggestions);
    _brandController.dispose();
    _modelController.dispose();
    _licensePlateController.dispose();
    _vinController.dispose();
    _noteController.dispose();
    _fuelTypeController.dispose();
    _maxSpeedController.dispose();
    _tireSizesController.dispose();
    _trailerLoadController.dispose();
    _grossWeightController.dispose();
    _emptyWeightController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _oilSpecificationController.dispose();
    _oilCapacityController.dispose();
    _registrationTextController.dispose();
    _knownDamageController.dispose();
    super.dispose();
  }

  Future<void> _pickHuDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _huDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _huDueDate = picked);
    }
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = Vehicle(
      id: widget.existingVehicle?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      vin: _vinController.text.trim().toUpperCase(),
      note: _noteController.text.trim(),
      huDueDate: _huDueDate,
      fuelType: _fuelTypeController.text.trim(),
      maxSpeedKmh: _parseInt(_maxSpeedController.text),
      tireSizes: _tireSizesController.text.trim(),
      trailerLoadKg: _parseInt(_trailerLoadController.text),
      grossVehicleWeightKg: _parseInt(_grossWeightController.text),
      emptyWeightKg: _parseInt(_emptyWeightController.text),
      lengthMm: _parseInt(_lengthController.text),
      widthMm: _parseInt(_widthController.text),
      heightMm: _parseInt(_heightController.text),
      oilSpecification: _oilSpecificationController.text.trim(),
      oilCapacityLiters: _parseDouble(_oilCapacityController.text),
      registrationDocumentText: _registrationTextController.text.trim(),
      knownDamage: _knownDamageController.text.trim(),
      requiresDamageCheck: _requiresDamageCheck,
    );

    Navigator.pop(context, vehicle);
  }

  int? _parseInt(String value) {
    final cleaned = value.trim();
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  double? _parseDouble(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  String? _validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Dieses Feld darf nicht leer sein.';
    return null;
  }

  String? _validateVin(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return 'Bitte VIN / Fahrgestellnummer eintragen.';
    if (cleaned.length < 8) return 'VIN wirkt zu kurz. Bitte prüfen.';
    return null;
  }

  String? _validateOptionalInt(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return null;
    final parsed = int.tryParse(cleaned);
    if (parsed == null) return 'Bitte eine ganze Zahl eintragen.';
    if (parsed < 0) return 'Wert darf nicht negativ sein.';
    return null;
  }

  String? _validateOptionalDouble(String? value) {
    final cleaned = (value ?? '').trim().replaceAll(',', '.');
    if (cleaned.isEmpty) return null;
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return 'Bitte eine gültige Zahl eintragen.';
    if (parsed < 0) return 'Wert darf nicht negativ sein.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Fahrzeug bearbeiten' : 'Fahrzeug anlegen'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(title: 'Basisdaten', subtitle: 'Damit jede Fahrt eindeutig einem Fahrzeug zugeordnet wird.'),
                SuggestionTextFormField(
                  controller: _brandController,
                  labelText: 'Marke',
                  hintText: 'z. B. Ford, Porsche, Volkswagen',
                  prefixIcon: Icons.directions_car,
                  suggestions: FormSuggestionService.vehicleBrands,
                  textCapitalization: TextCapitalization.words,
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _modelController,
                  labelText: 'Modell',
                  hintText: 'z. B. Focus Cabrio, Golf, Cayenne',
                  prefixIcon: Icons.badge,
                  suggestions: FormSuggestionService.modelsForBrand(_brandController.text),
                  textCapitalization: TextCapitalization.words,
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _licensePlateController,
                  decoration: const InputDecoration(labelText: 'Kennzeichen', hintText: 'z. B. RV AB 123', prefixIcon: Icon(Icons.pin)),
                  textCapitalization: TextCapitalization.characters,
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _vinController,
                  decoration: const InputDecoration(
                    labelText: 'VIN / Fahrgestellnummer',
                    helperText: 'Die VIN macht das Fahrzeug eindeutig.',
                    prefixIcon: Icon(Icons.fingerprint),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: _validateVin,
                ),
                _SectionTitle(title: 'Fahrzeugschein', subtitle: 'Werte aus Zulassungsbescheinigung, Handbuch oder Herstellerdaten übernehmen.'),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_available, color: AppTheme.gold),
                    title: const Text('Nächste HU / TÜV'),
                    subtitle: Text(_huDueDate == null ? 'Nicht eingetragen' : formatDate(_huDueDate!)),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: _pickHuDate,
                  ),
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _fuelTypeController,
                  labelText: 'Kraftstoffart',
                  hintText: 'Diesel, Benzin, Hybrid, Elektro ...',
                  prefixIcon: Icons.local_gas_station,
                  suggestions: FormSuggestionService.fuelTypes,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _maxSpeedController,
                  decoration: const InputDecoration(labelText: 'Höchstgeschwindigkeit', suffixText: 'km/h', prefixIcon: Icon(Icons.speed)),
                  keyboardType: TextInputType.number,
                  validator: _validateOptionalInt,
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _tireSizesController,
                  labelText: 'Zugelassene Reifen',
                  hintText: 'z. B. 225/45 R17 91W',
                  prefixIcon: Icons.tire_repair,
                  suggestions: FormSuggestionService.tireSizesForVehicle(_brandController.text, _modelController.text),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _trailerLoadController,
                  decoration: const InputDecoration(labelText: 'Anhängelast', suffixText: 'kg', prefixIcon: Icon(Icons.rv_hookup)),
                  keyboardType: TextInputType.number,
                  validator: _validateOptionalInt,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emptyWeightController,
                        decoration: const InputDecoration(labelText: 'Leergewicht', suffixText: 'kg'),
                        keyboardType: TextInputType.number,
                        validator: _validateOptionalInt,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _grossWeightController,
                        decoration: const InputDecoration(labelText: 'Gesamtgewicht', suffixText: 'kg'),
                        keyboardType: TextInputType.number,
                        validator: _validateOptionalInt,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _NumberField(controller: _lengthController, label: 'Länge', suffix: 'mm', validator: _validateOptionalInt)),
                    const SizedBox(width: 8),
                    Expanded(child: _NumberField(controller: _widthController, label: 'Breite', suffix: 'mm', validator: _validateOptionalInt)),
                    const SizedBox(width: 8),
                    Expanded(child: _NumberField(controller: _heightController, label: 'Höhe', suffix: 'mm', validator: _validateOptionalInt)),
                  ],
                ),
                _SectionTitle(title: 'Öl & Wartung', subtitle: 'Praktisch, wenn unterwegs Öl nachgefüllt werden muss.'),
                SuggestionTextFormField(
                  controller: _oilSpecificationController,
                  labelText: 'Zugelassene Öl-Spezifikation',
                  hintText: 'z. B. VW 504 00 / 507 00, 5W-30',
                  prefixIcon: Icons.oil_barrel,
                  suggestions: FormSuggestionService.oilSpecificationsForVehicle(_brandController.text, _fuelTypeController.text),
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _oilCapacityController,
                  decoration: const InputDecoration(labelText: 'Ölmenge optional', suffixText: 'l', prefixIcon: Icon(Icons.water_drop)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateOptionalDouble,
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: _requiresDamageCheck,
                  title: const Text('Vor jeder Fahrt Beschädigungskontrolle anzeigen'),
                  subtitle: const Text('Erinnert Fahrer an Reifen, Licht, Kratzer und auffällige Geräusche.'),
                  onChanged: (value) => setState(() => _requiresDamageCheck = value),
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _knownDamageController,
                  labelText: 'Bekannte Beschädigungen / Hinweise',
                  hintText: 'z. B. Kratzer vorne, Reifen prüfen, Fahrwerk kontrollieren',
                  prefixIcon: Icons.report_problem,
                  suggestions: FormSuggestionService.damageNotes,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _registrationTextController,
                  labelText: 'Digitaler Fahrzeugschein / Notizen',
                  helperText: 'Vorschläge übernehmen und danach mit echten Fahrzeugschein-Daten ergänzen.',
                  prefixIcon: Icons.article,
                  suggestions: FormSuggestionService.registrationNotes,
                  maxLines: 5,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Sonstige Notiz optional', prefixIcon: Icon(Icons.note_alt)),
                  maxLines: 3,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: _saveVehicle,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditMode ? 'Änderungen speichern' : 'Fahrzeug speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppTheme.mutedText)),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final String? Function(String?) validator;

  const _NumberField({required this.controller, required this.label, required this.suffix, required this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, suffixText: suffix),
      keyboardType: TextInputType.number,
      validator: validator,
    );
  }
}
