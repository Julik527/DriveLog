import 'dart:convert';

enum IssueSeverity { niedrig, mittel, hoch, kritisch }
enum IssueStatus { offen, inPruefung, erledigt }

extension IssueSeverityExtension on IssueSeverity {
  String get label {
    switch (this) {
      case IssueSeverity.niedrig:
        return 'Niedrig';
      case IssueSeverity.mittel:
        return 'Mittel';
      case IssueSeverity.hoch:
        return 'Hoch';
      case IssueSeverity.kritisch:
        return 'Kritisch';
    }
  }

  static IssueSeverity fromName(String value) {
    return IssueSeverity.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => IssueSeverity.mittel,
    );
  }
}

extension IssueStatusExtension on IssueStatus {
  String get label {
    switch (this) {
      case IssueStatus.offen:
        return 'Offen';
      case IssueStatus.inPruefung:
        return 'In Prüfung';
      case IssueStatus.erledigt:
        return 'Erledigt';
    }
  }

  static IssueStatus fromName(String value) {
    return IssueStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => IssueStatus.offen,
    );
  }
}

/// Meldung eines Problems am Fahrzeug.
///
/// Beispiel: Fahrer hört nach der Fahrt ein Klackern am Fahrwerk und meldet es
/// direkt mit Kilometerstand und Beschreibung.
class IssueReport {
  final String id;
  final String vehicleId;
  final DateTime date;
  final String title;
  final String component;
  final String description;
  final int? odometer;
  final IssueSeverity severity;
  final IssueStatus status;

  const IssueReport({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.title,
    required this.component,
    required this.description,
    this.odometer,
    this.severity = IssueSeverity.mittel,
    this.status = IssueStatus.offen,
  });

  IssueReport copyWith({
    IssueStatus? status,
  }) {
    return IssueReport(
      id: id,
      vehicleId: vehicleId,
      date: date,
      title: title,
      component: component,
      description: description,
      odometer: odometer,
      severity: severity,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'title': title,
      'component': component,
      'description': description,
      'odometer': odometer,
      'severity': severity.name,
      'status': status.name,
    };
  }

  factory IssueReport.fromJson(Map<String, dynamic> json) {
    return IssueReport(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleId: json['vehicleId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      title: json['title'] as String? ?? '',
      component: json['component'] as String? ?? '',
      description: json['description'] as String? ?? '',
      odometer: (json['odometer'] as num?)?.toInt(),
      severity: IssueSeverityExtension.fromName(json['severity'] as String? ?? 'mittel'),
      status: IssueStatusExtension.fromName(json['status'] as String? ?? 'offen'),
    );
  }

  String encode() => jsonEncode(toJson());
  static IssueReport decode(String source) => IssueReport.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
