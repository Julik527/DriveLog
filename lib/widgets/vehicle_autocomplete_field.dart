import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Suchbare und anklickbare Fahrzeugauswahl.
///
/// Statt einer langen Dropdown-Liste kann man Marke, Modell, Kennzeichen oder
/// VIN tippen. Das passt besser zu einem Fuhrpark mit mehreren Fahrzeugen.
class VehicleAutocompleteField extends StatefulWidget {
  final List<Vehicle> vehicles;
  final String? selectedVehicleId;
  final ValueChanged<String?> onChanged;
  final String labelText;
  final bool required;

  const VehicleAutocompleteField({
    super.key,
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onChanged,
    this.labelText = 'Fahrzeug',
    this.required = true,
  });

  @override
  State<VehicleAutocompleteField> createState() => _VehicleAutocompleteFieldState();
}

class _VehicleAutocompleteFieldState extends State<VehicleAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  FormFieldState<String>? _fieldState;

  @override
  void initState() {
    super.initState();
    _syncTextWithSelection();
    _controller.addListener(_handleTextChanged);
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant VehicleAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedVehicleId != widget.selectedVehicleId || oldWidget.vehicles != widget.vehicles) {
      _syncTextWithSelection();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _syncTextWithSelection() {
    final selected = _selectedVehicle;
    final text = selected == null ? '' : _labelFor(selected);
    if (_controller.text != text) {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  Vehicle? get _selectedVehicle {
    for (final vehicle in widget.vehicles) {
      if (vehicle.id == widget.selectedVehicleId) return vehicle;
    }
    return null;
  }

  List<Vehicle> get _visibleVehicles {
    final query = _controller.text.trim().toLowerCase();
    final source = query.isEmpty
        ? widget.vehicles
        : widget.vehicles.where((vehicle) {
            return vehicle.brand.toLowerCase().contains(query) ||
                vehicle.model.toLowerCase().contains(query) ||
                vehicle.licensePlate.toLowerCase().contains(query) ||
                vehicle.vin.toLowerCase().contains(query) ||
                vehicle.fuelType.toLowerCase().contains(query);
          }).toList();
    return source.take(8).toList();
  }

  String _labelFor(Vehicle vehicle) {
    final plate = vehicle.licensePlate.trim().isEmpty ? 'ohne Kennzeichen' : vehicle.licensePlate.trim();
    return '${vehicle.displayName} • $plate';
  }

  void _handleTextChanged() {
    final typed = _controller.text.trim();
    final selected = _selectedVehicle;
    if (selected != null && typed == _labelFor(selected)) return;

    final exactMatch = widget.vehicles.where((vehicle) => _labelFor(vehicle).toLowerCase() == typed.toLowerCase()).toList();
    final newId = exactMatch.isEmpty ? null : exactMatch.first.id;

    if (newId != widget.selectedVehicleId) {
      widget.onChanged(newId);
      _fieldState?.didChange(newId);
    }

    if (mounted) setState(() {});
  }

  void _selectVehicle(Vehicle vehicle) {
    final label = _labelFor(vehicle);
    _controller.text = label;
    _controller.selection = TextSelection.collapsed(offset: label.length);
    widget.onChanged(vehicle.id);
    _fieldState?.didChange(vehicle.id);
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.selectedVehicleId,
      validator: (value) {
        if (!widget.required) return null;
        if (widget.vehicles.isEmpty) return null;
        if (widget.selectedVehicleId == null || widget.selectedVehicleId!.isEmpty) return 'Bitte Fahrzeug auswählen.';
        return null;
      },
      builder: (field) {
        _fieldState = field;
        final showSuggestions = _focusNode.hasFocus && _visibleVehicles.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                labelText: widget.labelText,
                helperText: 'Anklickbare Suche nach Marke, Modell, Kennzeichen, VIN oder Kraftstoff.',
                prefixIcon: const Icon(Icons.directions_car),
                suffixIcon: const Icon(Icons.manage_search),
                errorText: field.errorText,
              ),
            ),
            if (showSuggestions) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.cardBorder),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.20), blurRadius: 18, offset: const Offset(0, 8)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: _visibleVehicles.map((vehicle) {
                      return _VehicleSuggestionRow(
                        vehicle: vehicle,
                        onSelected: () => _selectVehicle(vehicle),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _VehicleSuggestionRow extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onSelected;

  const _VehicleSuggestionRow({
    required this.vehicle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final plate = vehicle.licensePlate.trim().isEmpty ? 'ohne Kennzeichen' : vehicle.licensePlate.trim();
    final vinInfo = vehicle.vin.trim().isEmpty ? 'VIN fehlt' : 'VIN ${vehicle.vin.trim()}';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => onSelected(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.directions_car_filled_outlined, color: AppTheme.gold),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
                    Text('$plate • $vinInfo', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.gold),
            ],
          ),
        ),
      ),
    );
  }
}
