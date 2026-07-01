import 'package:flutter/material.dart';

import '../models/issue_report.dart';
import '../models/vehicle.dart';
import '../services/issue_report_storage_service.dart';
import '../services/form_suggestion_service.dart';
import '../widgets/suggestion_text_form_field.dart';
import '../widgets/vehicle_autocomplete_field.dart';

/// Problem am Fahrzeug melden.
class AddIssueReportScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final String? preselectedVehicleId;

  const AddIssueReportScreen({super.key, required this.vehicles, this.preselectedVehicleId});

  @override
  State<AddIssueReportScreen> createState() => _AddIssueReportScreenState();
}

class _AddIssueReportScreenState extends State<AddIssueReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = IssueReportStorageService();
  final _titleController = TextEditingController();
  final _componentController = TextEditingController(text: 'Fahrwerk');
  final _descriptionController = TextEditingController();
  final _odometerController = TextEditingController();

  String? _selectedVehicleId;
  IssueSeverity _severity = IssueSeverity.mittel;

  @override
  void initState() {
    super.initState();
    _selectedVehicleId = widget.preselectedVehicleId ?? (widget.vehicles.isEmpty ? null : widget.vehicles.first.id);
    _componentController.addListener(_refreshContextSuggestions);
  }

  void _refreshContextSuggestions() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _componentController.removeListener(_refreshContextSuggestions);
    _titleController.dispose();
    _componentController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bitte zuerst ein Fahrzeug anlegen.')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final report = IssueReport(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleId: _selectedVehicleId!,
      date: DateTime.now(),
      title: _titleController.text.trim(),
      component: _componentController.text.trim(),
      description: _descriptionController.text.trim(),
      odometer: int.tryParse(_odometerController.text.trim()),
      severity: _severity,
    );

    await _storageService.addReport(report);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Dieses Feld darf nicht leer sein.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Problem melden')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.vehicles.isEmpty)
                  const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Noch kein Fahrzeug vorhanden.')))
                else
                  VehicleAutocompleteField(
                    vehicles: widget.vehicles,
                    selectedVehicleId: _selectedVehicleId,
                    onChanged: (value) => setState(() => _selectedVehicleId = value),
                  ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _titleController,
                  labelText: 'Kurztitel',
                  hintText: 'z. B. Klackern vorne rechts',
                  prefixIcon: Icons.report_problem,
                  suggestions: FormSuggestionService.issueTitlesForComponent(_componentController.text),
                  validator: _required,
                ),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _componentController,
                  labelText: 'Bauteil / Bereich',
                  hintText: 'Fahrwerk, Bremse, Motor, Reifen ...',
                  prefixIcon: Icons.build,
                  suggestions: FormSuggestionService.issueComponents,
                  validator: _required,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<IssueSeverity>(
                  value: _severity,
                  decoration: const InputDecoration(labelText: 'Dringlichkeit', prefixIcon: Icon(Icons.priority_high)),
                  items: IssueSeverity.values.map((severity) => DropdownMenuItem(value: severity, child: Text(severity.label))).toList(),
                  onChanged: (value) => setState(() => _severity = value ?? IssueSeverity.mittel),
                ),
                const SizedBox(height: 14),
                TextFormField(controller: _odometerController, decoration: const InputDecoration(labelText: 'Kilometerstand optional', suffixText: 'km', prefixIcon: Icon(Icons.speed)), keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                SuggestionTextFormField(
                  controller: _descriptionController,
                  labelText: 'Beschreibung',
                  helperText: 'Was wurde gehört, gesehen oder gefühlt?',
                  prefixIcon: Icons.notes,
                  suggestions: FormSuggestionService.issueDescriptions,
                  maxLines: 5,
                  validator: _required,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Problem speichern')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
