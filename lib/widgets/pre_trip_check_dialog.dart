import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../theme/app_theme.dart';

/// Dialog vor einer GPS-Fahrt.
///
/// Der Fahrer sieht Fahrzeughinweise, TÜV-Status, Beschädigungsprüfung und
/// Ölinformationen. Die Fahrt kann erst gestartet werden, wenn der Hinweis
/// bewusst bestätigt wurde.
class PreTripCheckDialog extends StatelessWidget {
  final Vehicle vehicle;

  const PreTripCheckDialog({super.key, required this.vehicle});

  static Future<bool> show(BuildContext context, Vehicle vehicle) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PreTripCheckDialog(vehicle: vehicle),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    final warnings = vehicle.preTripWarnings();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppTheme.gold),
          const SizedBox(width: 10),
          Expanded(child: Text('Hinweis vor der Fahrt', style: Theme.of(context).textTheme.titleLarge)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vehicle.displayName, style: const TextStyle(fontWeight: FontWeight.w900)),
            Text(vehicle.displayDetails, style: const TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 14),
            const Text(
              'Vor Fahrtbeginn bestätigen:',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18, color: AppTheme.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(warning)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Hinweis: Die App ersetzt keine echte technische Prüfung. Sie erinnert nur an wichtige Kontrollen.',
              style: TextStyle(color: AppTheme.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Abbrechen'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.verified),
          label: const Text('Okay, geprüft'),
        ),
      ],
    );
  }
}
