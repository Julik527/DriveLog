import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../models/vehicle.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final Vehicle? vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TripCard({
    super.key,
    required this.trip,
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: trip.createdByGps ? AppTheme.gold.withOpacity(0.20) : AppTheme.backgroundSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: trip.createdByGps ? AppTheme.gold : AppTheme.cardBorder),
                  ),
                  child: Text(
                    trip.createdByGps ? 'GPS-Fahrt' : trip.category.label,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                ),
                const Spacer(),
                Text(formatDate(trip.date), style: const TextStyle(color: AppTheme.mutedText)),
              ],
            ),
            const SizedBox(height: 12),
            Text('${trip.startLocation} → ${trip.destination}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(vehicle == null ? 'Kein Fahrzeug zugeordnet' : '${vehicle!.displayName} • ${vehicle!.licensePlate}', style: const TextStyle(color: AppTheme.mutedText)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(icon: Icons.route, text: '${trip.kilometers.toStringAsFixed(1)} km'),
                if (trip.averageSpeedKmh != null) _MetricChip(icon: Icons.speed, text: 'Ø ${trip.averageSpeedKmh!.toStringAsFixed(1)} km/h'),
                if (trip.maxSpeedKmh != null) _MetricChip(icon: Icons.bolt, text: 'Max ${trip.maxSpeedKmh!.toStringAsFixed(1)} km/h'),
                if (trip.averageConsumptionL100km != null) _MetricChip(icon: Icons.local_gas_station, text: '${trip.averageConsumptionL100km!.toStringAsFixed(1)} l/100km'),
              ],
            ),
            if (trip.note.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(trip.note, style: const TextStyle(color: AppTheme.mutedText)),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit), label: const Text('Bearbeiten')),
                TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_outline), label: const Text('Löschen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetricChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.gold),
      label: Text(text),
    );
  }
}
