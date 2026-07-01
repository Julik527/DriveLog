import 'package:flutter/material.dart';

import '../models/fuel_receipt.dart';
import '../models/vehicle.dart';
import '../services/receipt_ocr_service.dart';
import '../services/form_suggestion_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/suggestion_text_form_field.dart';
import '../widgets/vehicle_autocomplete_field.dart';

/// Seite zum Erfassen eines Tankbelegs.
///
/// OCR liest Tankbeleg-Fotos auf Android/iOS. Die erkannten Werte werden nur
/// vorgeschlagen, damit der Nutzer sie prüfen kann.
class AddFuelReceiptScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const AddFuelReceiptScreen({
    super.key,
    required this.vehicles,
  });

  @override
  State<AddFuelReceiptScreen> createState() => _AddFuelReceiptScreenState();
}

class _AddFuelReceiptScreenState extends State<AddFuelReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stationController = TextEditingController();
  final _litersController = TextEditingController();
  final _totalPriceController = TextEditingController();
  final _odometerController = TextEditingController();
  final _receiptTextController = TextEditingController();
  final _ocrService = ReceiptOcrService();

  DateTime _selectedDate = DateTime.now();
  String? _selectedVehicleId;
  String? _imagePath;
  String _ocrRawText = '';
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.isNotEmpty) {
      _selectedVehicleId = widget.vehicles.first.id;
    }
  }

  @override
  void dispose() {
    _stationController.dispose();
    _litersController.dispose();
    _totalPriceController.dispose();
    _odometerController.dispose();
    _receiptTextController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  Future<void> _scanReceipt({required bool useCamera}) async {
    setState(() => _isScanning = true);
    try {
      final result = await _ocrService.scanReceipt(useCamera: useCamera);
      if (result == null || !mounted) return;

      setState(() {
        _imagePath = result.imagePath;
        _ocrRawText = result.text;
        _receiptTextController.text = result.text;
        if (result.guessedStation != null && _stationController.text.trim().isEmpty) {
          _stationController.text = result.guessedStation!;
        }
        if (result.guessedLiters != null && _litersController.text.trim().isEmpty) {
          _litersController.text = result.guessedLiters!.toStringAsFixed(2);
        }
        if (result.guessedTotalPrice != null && _totalPriceController.text.trim().isEmpty) {
          _totalPriceController.text = result.guessedTotalPrice!.toStringAsFixed(2);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OCR-Vorschläge wurden übernommen. Bitte Zahlen prüfen.')),
      );
    } on ReceiptOcrException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beleg konnte nicht erkannt werden. Bitte manuell eintragen.')),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _saveReceipt() {
    if (widget.vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte zuerst ein Fahrzeug anlegen.')));
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final liters = double.parse(_litersController.text.replaceAll(',', '.'));
    final totalPrice = double.parse(_totalPriceController.text.replaceAll(',', '.'));
    final odometer = int.parse(_odometerController.text.trim());

    final receipt = FuelReceipt(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleId: _selectedVehicleId!,
      date: _selectedDate,
      stationName: _stationController.text.trim(),
      liters: liters,
      totalPrice: totalPrice,
      odometer: odometer,
      receiptText: _receiptTextController.text.trim(),
      imagePath: _imagePath,
      ocrRawText: _ocrRawText,
    );

    Navigator.pop(context, receipt);
  }

  String? _validateRequiredText(String? value) {
    if (value == null || value.trim().isEmpty) return 'Dieses Feld darf nicht leer sein.';
    return null;
  }

  String? _validatePositiveDouble(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bitte eine Zahl eintragen.';
    final parsedValue = double.tryParse(value.replaceAll(',', '.'));
    if (parsedValue == null) return 'Bitte eine gültige Zahl eintragen.';
    if (parsedValue <= 0) return 'Wert muss größer als 0 sein.';
    return null;
  }

  String? _validatePositiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bitte Kilometerstand eintragen.';
    final parsedValue = int.tryParse(value.trim());
    if (parsedValue == null) return 'Bitte eine ganze Zahl eintragen.';
    if (parsedValue <= 0) return 'Kilometerstand muss größer als 0 sein.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tankbeleg erfassen')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.document_scanner, color: AppTheme.gold),
                            const SizedBox(width: 10),
                            Text('OCR-Belegscan', style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Foto machen oder Bild auswählen. Die App erkennt Text und schlägt Tankstelle, Liter und Preis vor. Werte müssen geprüft werden.',
                          style: TextStyle(color: AppTheme.mutedText),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isScanning ? null : () => _scanReceipt(useCamera: true),
                                icon: const Icon(Icons.photo_camera),
                                label: const Text('Foto'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isScanning ? null : () => _scanReceipt(useCamera: false),
                                icon: const Icon(Icons.image),
                                label: const Text('Bild'),
                              ),
                            ),
                          ],
                        ),
                        if (_isScanning) ...[
                          const SizedBox(height: 10),
                          const LinearProgressIndicator(),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (widget.vehicles.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text('Noch kein Fahrzeug vorhanden. Tankbelege können erst gespeichert werden, wenn ein Fahrzeug angelegt wurde.', style: TextStyle(color: Colors.white70)),
                    ),
                  )
                else
                  VehicleAutocompleteField(
                    vehicles: widget.vehicles,
                    selectedVehicleId: _selectedVehicleId,
                    onChanged: (value) => setState(() => _selectedVehicleId = value),
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
                SuggestionTextFormField(
                  controller: _stationController,
                  labelText: 'Tankstelle',
                  hintText: 'z. B. Aral Leutkirch',
                  prefixIcon: Icons.local_gas_station,
                  suggestions: FormSuggestionService.fuelStationsForRegion('Leutkirch'),
                  validator: _validateRequiredText,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _litersController,
                  decoration: const InputDecoration(labelText: 'Liter', suffixText: 'l', prefixIcon: Icon(Icons.water_drop)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validatePositiveDouble,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _totalPriceController,
                  decoration: const InputDecoration(labelText: 'Gesamtpreis', suffixText: '€', prefixIcon: Icon(Icons.euro)),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: _validatePositiveDouble,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _odometerController,
                  decoration: const InputDecoration(labelText: 'Kilometerstand', suffixText: 'km', prefixIcon: Icon(Icons.speed)),
                  keyboardType: TextInputType.number,
                  validator: _validatePositiveInt,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _receiptTextController,
                  decoration: const InputDecoration(labelText: 'OCR-Rohtext / Belegnummer', helperText: 'Hier steht der erkannte oder manuell übernommene Belegtext.', prefixIcon: Icon(Icons.article)),
                  maxLines: 5,
                ),
                if (_imagePath != null) ...[
                  const SizedBox(height: 8),
                  Text('Foto gespeichert: $_imagePath', style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                ],
                const SizedBox(height: 22),
                ElevatedButton.icon(onPressed: _saveReceipt, icon: const Icon(Icons.save), label: const Text('Tankbeleg speichern')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
