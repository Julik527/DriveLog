import 'package:flutter/material.dart';

import '../models/workshop.dart';
import '../services/place_autocomplete_service.dart';
import '../services/workshop_search_service.dart';
import '../widgets/location_autocomplete_field.dart';

/// Seite für Werkstätten in der Nähe.
///
/// Die Suche nutzt öffentliche OpenStreetMap-Daten und braucht Internet.
class WorkshopNearbyScreen extends StatefulWidget {
  const WorkshopNearbyScreen({super.key});

  @override
  State<WorkshopNearbyScreen> createState() => _WorkshopNearbyScreenState();
}

class _WorkshopNearbyScreenState extends State<WorkshopNearbyScreen> {
  final TextEditingController _locationController = TextEditingController(text: 'Leutkirch');
  final WorkshopSearchService _workshopSearchService = WorkshopSearchService();

  List<Workshop> _workshops = [];
  bool _isSearching = false;
  String? _statusText;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _searchWorkshops() async {
    final location = _locationController.text.trim();

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Ort eintragen.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _statusText = 'Werkstätten werden gesucht ...';
      _workshops = [];
    });

    try {
      final results = await _workshopSearchService.searchNearbyWorkshops(location: location);

      if (!mounted) return;

      setState(() {
        _workshops = results;
        _statusText = results.isEmpty
            ? 'Keine Werkstätten gefunden. Versuche einen größeren Ort in der Nähe.'
            : '${results.length} Werkstätten gefunden.';
      });
    } on WorkshopSearchException catch (error) {
      if (!mounted) return;

      setState(() {
        _statusText = error.message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;

      const message = 'Werkstattsuche fehlgeschlagen. Bitte Internetverbindung prüfen.';

      setState(() {
        _statusText = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Werkstätten in der Nähe'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LocationAutocompleteField(
              controller: _locationController,
              labelText: 'Ort',
              helperText: 'Standard: Leutkirch. Tippe z. B. L für Leutkirch oder Lindau.',
              prefixIcon: Icons.location_on,
              validator: (value) => value == null || value.trim().isEmpty ? 'Bitte Ort eintragen.' : null,
              autocompleteContext: PlaceAutocompleteContext.workshop,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchWorkshops,
              icon: _isSearching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: const Text('Werkstätten suchen'),
            ),
            if (_statusText != null) ...[
              const SizedBox(height: 12),
              Text(
                _statusText!,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 16),
            for (final workshop in _workshops)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(workshop.address),
                      if (workshop.phone.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Telefon: ${workshop.phone}'),
                      ],
                      if (workshop.latitude != null && workshop.longitude != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Koordinaten: ${workshop.latitude!.toStringAsFixed(5)}, ${workshop.longitude!.toStringAsFixed(5)}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
