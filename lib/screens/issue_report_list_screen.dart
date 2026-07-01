import 'package:flutter/material.dart';

import '../models/issue_report.dart';
import '../models/vehicle.dart';
import '../services/issue_report_storage_service.dart';
import '../services/vehicle_storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'add_issue_report_screen.dart';

/// Übersicht über gemeldete Fahrzeugprobleme.
class IssueReportListScreen extends StatefulWidget {
  const IssueReportListScreen({super.key});

  @override
  State<IssueReportListScreen> createState() => _IssueReportListScreenState();
}

class _IssueReportListScreenState extends State<IssueReportListScreen> {
  final _issueStorageService = IssueReportStorageService();
  final _vehicleStorageService = VehicleStorageService();

  List<IssueReport> _reports = [];
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final reports = await _issueStorageService.loadReports();
    final vehicles = await _vehicleStorageService.loadVehicles();
    reports.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _vehicles = vehicles;
      _isLoading = false;
    });
  }

  Vehicle? _vehicleFor(String id) => _vehicleStorageService.findVehicleById(_vehicles, id);

  Future<void> _addReport() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => AddIssueReportScreen(vehicles: _vehicles)));
    await _loadData();
  }

  Future<void> _setStatus(IssueReport report, IssueStatus status) async {
    await _issueStorageService.updateReport(report.copyWith(status: status));
    await _loadData();
  }

  Future<void> _delete(IssueReport report) async {
    await _issueStorageService.deleteReport(report.id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final openReports = _reports.where((report) => report.status != IssueStatus.erledigt).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Probleme')),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addReport, icon: const Icon(Icons.add), label: const Text('Meldung')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Schadens- und Problemübersicht', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text('$openReports offene Meldungen • ${_reports.length} insgesamt', style: const TextStyle(color: AppTheme.mutedText)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_reports.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(18), child: Text('Noch keine Probleme gemeldet.', style: TextStyle(color: AppTheme.mutedText))))
                  else
                    for (final report in _reports) _IssueCard(report: report, vehicle: _vehicleFor(report.vehicleId), onStatus: (status) => _setStatus(report, status), onDelete: () => _delete(report)),
                ],
              ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IssueReport report;
  final Vehicle? vehicle;
  final ValueChanged<IssueStatus> onStatus;
  final VoidCallback onDelete;

  const _IssueCard({required this.report, required this.vehicle, required this.onStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (report.severity) {
      IssueSeverity.kritisch => AppTheme.redAccent,
      IssueSeverity.hoch => AppTheme.warning,
      IssueSeverity.mittel => AppTheme.gold,
      IssueSeverity.niedrig => AppTheme.success,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.report_problem, color: severityColor),
            const SizedBox(width: 10),
            Expanded(child: Text(report.title, style: Theme.of(context).textTheme.titleMedium)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
          ]),
          const SizedBox(height: 8),
          Text(vehicle == null ? 'Fahrzeug nicht mehr vorhanden' : '${vehicle!.displayName} • ${vehicle!.licensePlate}', style: const TextStyle(color: AppTheme.mutedText)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            Chip(label: Text(formatDate(report.date))),
            Chip(label: Text(report.component)),
            Chip(label: Text(report.severity.label)),
            Chip(label: Text(report.status.label)),
            if (report.odometer != null) Chip(label: Text('${report.odometer} km')),
          ]),
          const SizedBox(height: 10),
          Text(report.description),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => onStatus(IssueStatus.inPruefung), child: const Text('In Prüfung')),
            TextButton(onPressed: () => onStatus(IssueStatus.erledigt), child: const Text('Erledigt')),
          ]),
        ]),
      ),
    );
  }
}
