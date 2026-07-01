import 'dart:convert';

/// Status der Hauptuntersuchung.
enum HuStatus { ok, dueSoon, dueThisMonth, expired, unknown }

extension HuStatusExtension on HuStatus {
  String get label {
    switch (this) {
      case HuStatus.ok:
        return 'TÜV gültig';
      case HuStatus.dueSoon:
        return 'TÜV bald fällig';
      case HuStatus.dueThisMonth:
        return 'TÜV diesen Monat';
      case HuStatus.expired:
        return 'TÜV abgelaufen';
      case HuStatus.unknown:
        return 'TÜV unbekannt';
    }
  }
}

/// Datenmodell für ein Fahrzeug im Fuhrpark.
///
/// Neben Marke, Modell, Kennzeichen und VIN enthält das Modell auch digitale
/// Fahrzeugschein-Daten wie Reifen, Anhängelast, Gewicht, Maße und Öl.
/// Diese Daten werden manuell aus Fahrzeugschein, Handbuch oder Herstellerdaten
/// übernommen. Die App "errät" keine rechtlich wichtigen Fahrzeugdaten.
class Vehicle {
  final String id;
  final String brand;
  final String model;
  final String licensePlate;
  final String vin;
  final String note;

  final DateTime? huDueDate;
  final String fuelType;
  final int? maxSpeedKmh;
  final String tireSizes;
  final int? trailerLoadKg;
  final int? grossVehicleWeightKg;
  final int? emptyWeightKg;
  final int? lengthMm;
  final int? widthMm;
  final int? heightMm;
  final String oilSpecification;
  final double? oilCapacityLiters;
  final String registrationDocumentText;
  final String knownDamage;
  final bool requiresDamageCheck;

  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.licensePlate,
    required this.vin,
    required this.note,
    this.huDueDate,
    this.fuelType = '',
    this.maxSpeedKmh,
    this.tireSizes = '',
    this.trailerLoadKg,
    this.grossVehicleWeightKg,
    this.emptyWeightKg,
    this.lengthMm,
    this.widthMm,
    this.heightMm,
    this.oilSpecification = '',
    this.oilCapacityLiters,
    this.registrationDocumentText = '',
    this.knownDamage = '',
    this.requiresDamageCheck = true,
  });

  String get displayName {
    final text = '$brand $model'.trim();
    return text.isEmpty ? 'Unbekanntes Fahrzeug' : text;
  }

  String get displayDetails {
    final parts = [
      if (licensePlate.trim().isNotEmpty) licensePlate.trim(),
      if (vin.trim().isNotEmpty) 'VIN: ${vin.trim()}',
    ];
    return parts.isEmpty ? 'Keine Fahrzeugdaten hinterlegt' : parts.join(' • ');
  }

  String get sizeLabel {
    final parts = [
      if (lengthMm != null) 'L ${lengthMm} mm',
      if (widthMm != null) 'B ${widthMm} mm',
      if (heightMm != null) 'H ${heightMm} mm',
    ];
    return parts.isEmpty ? 'Maße nicht eingetragen' : parts.join(' • ');
  }

  String get weightLabel {
    final parts = [
      if (emptyWeightKg != null) 'Leer ${emptyWeightKg} kg',
      if (grossVehicleWeightKg != null) 'Zul. Gesamt ${grossVehicleWeightKg} kg',
      if (trailerLoadKg != null) 'Anhänger ${trailerLoadKg} kg',
    ];
    return parts.isEmpty ? 'Gewichte nicht eingetragen' : parts.join(' • ');
  }

  bool get hasRegistrationData {
    return maxSpeedKmh != null ||
        tireSizes.trim().isNotEmpty ||
        trailerLoadKg != null ||
        grossVehicleWeightKg != null ||
        emptyWeightKg != null ||
        lengthMm != null ||
        widthMm != null ||
        heightMm != null ||
        oilSpecification.trim().isNotEmpty ||
        registrationDocumentText.trim().isNotEmpty;
  }

  HuStatus huStatus({DateTime? today}) {
    final dueDate = huDueDate;
    if (dueDate == null) return HuStatus.unknown;

    final now = DateTime(today?.year ?? DateTime.now().year, today?.month ?? DateTime.now().month, today?.day ?? DateTime.now().day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (due.isBefore(now)) return HuStatus.expired;
    if (due.year == now.year && due.month == now.month) return HuStatus.dueThisMonth;
    final oneMonthLimit = DateTime(now.year, now.month + 1, now.day);
    if (!due.isAfter(oneMonthLimit)) return HuStatus.dueSoon;
    return HuStatus.ok;
  }

  List<String> preTripWarnings({DateTime? today}) {
    final warnings = <String>[];
    final status = huStatus(today: today);

    if (status == HuStatus.expired) {
      warnings.add('TÜV ist abgelaufen. Fahrzeug vor Nutzung prüfen und Termin klären.');
    } else if (status == HuStatus.dueThisMonth) {
      warnings.add('TÜV ist diesen Monat fällig. Termin rechtzeitig planen.');
    } else if (status == HuStatus.dueSoon) {
      warnings.add('TÜV ist innerhalb eines Monats fällig. Bitte im Blick behalten.');
    } else if (status == HuStatus.unknown) {
      warnings.add('TÜV-Datum ist nicht hinterlegt. Fahrzeugschein oder Fahrzeugakte prüfen.');
    }

    if (requiresDamageCheck) {
      warnings.add('Vor Fahrtbeginn Fahrzeug auf Beschädigungen, Reifen, Licht und auffällige Geräusche kontrollieren.');
    }

    if (knownDamage.trim().isNotEmpty) {
      warnings.add('Bekannte Beschädigung/Problem: ${knownDamage.trim()}');
    }

    if (oilSpecification.trim().isNotEmpty) {
      final capacity = oilCapacityLiters == null ? '' : ' (${oilCapacityLiters!.toStringAsFixed(1)} l)';
      warnings.add('Öl bei Bedarf nur passend nachfüllen: ${oilSpecification.trim()}$capacity.');
    }

    return warnings;
  }

  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    String? licensePlate,
    String? vin,
    String? note,
    DateTime? huDueDate,
    bool clearHuDueDate = false,
    String? fuelType,
    int? maxSpeedKmh,
    String? tireSizes,
    int? trailerLoadKg,
    int? grossVehicleWeightKg,
    int? emptyWeightKg,
    int? lengthMm,
    int? widthMm,
    int? heightMm,
    String? oilSpecification,
    double? oilCapacityLiters,
    String? registrationDocumentText,
    String? knownDamage,
    bool? requiresDamageCheck,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      note: note ?? this.note,
      huDueDate: clearHuDueDate ? null : (huDueDate ?? this.huDueDate),
      fuelType: fuelType ?? this.fuelType,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      tireSizes: tireSizes ?? this.tireSizes,
      trailerLoadKg: trailerLoadKg ?? this.trailerLoadKg,
      grossVehicleWeightKg: grossVehicleWeightKg ?? this.grossVehicleWeightKg,
      emptyWeightKg: emptyWeightKg ?? this.emptyWeightKg,
      lengthMm: lengthMm ?? this.lengthMm,
      widthMm: widthMm ?? this.widthMm,
      heightMm: heightMm ?? this.heightMm,
      oilSpecification: oilSpecification ?? this.oilSpecification,
      oilCapacityLiters: oilCapacityLiters ?? this.oilCapacityLiters,
      registrationDocumentText: registrationDocumentText ?? this.registrationDocumentText,
      knownDamage: knownDamage ?? this.knownDamage,
      requiresDamageCheck: requiresDamageCheck ?? this.requiresDamageCheck,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'licensePlate': licensePlate,
      'vin': vin,
      'note': note,
      'huDueDate': huDueDate?.toIso8601String(),
      'fuelType': fuelType,
      'maxSpeedKmh': maxSpeedKmh,
      'tireSizes': tireSizes,
      'trailerLoadKg': trailerLoadKg,
      'grossVehicleWeightKg': grossVehicleWeightKg,
      'emptyWeightKg': emptyWeightKg,
      'lengthMm': lengthMm,
      'widthMm': widthMm,
      'heightMm': heightMm,
      'oilSpecification': oilSpecification,
      'oilCapacityLiters': oilCapacityLiters,
      'registrationDocumentText': registrationDocumentText,
      'knownDamage': knownDamage,
      'requiresDamageCheck': requiresDamageCheck,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: json['brand'] as String? ?? '',
      model: json['model'] as String? ?? '',
      licensePlate: json['licensePlate'] as String? ?? '',
      vin: json['vin'] as String? ?? '',
      note: json['note'] as String? ?? '',
      huDueDate: DateTime.tryParse(json['huDueDate'] as String? ?? ''),
      fuelType: json['fuelType'] as String? ?? '',
      maxSpeedKmh: (json['maxSpeedKmh'] as num?)?.toInt(),
      tireSizes: json['tireSizes'] as String? ?? '',
      trailerLoadKg: (json['trailerLoadKg'] as num?)?.toInt(),
      grossVehicleWeightKg: (json['grossVehicleWeightKg'] as num?)?.toInt(),
      emptyWeightKg: (json['emptyWeightKg'] as num?)?.toInt(),
      lengthMm: (json['lengthMm'] as num?)?.toInt(),
      widthMm: (json['widthMm'] as num?)?.toInt(),
      heightMm: (json['heightMm'] as num?)?.toInt(),
      oilSpecification: json['oilSpecification'] as String? ?? '',
      oilCapacityLiters: (json['oilCapacityLiters'] as num?)?.toDouble(),
      registrationDocumentText: json['registrationDocumentText'] as String? ?? '',
      knownDamage: json['knownDamage'] as String? ?? '',
      requiresDamageCheck: json['requiresDamageCheck'] as bool? ?? true,
    );
  }

  String encode() => jsonEncode(toJson());

  static Vehicle decode(String source) {
    return Vehicle.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
