import 'dart:convert';

/// Kategorien für eine Fahrt.
enum TripCategory { privat, schule, arbeit, sonstiges }

extension TripCategoryExtension on TripCategory {
  String get label {
    switch (this) {
      case TripCategory.privat:
        return 'Privat';
      case TripCategory.schule:
        return 'Schule';
      case TripCategory.arbeit:
        return 'Arbeit';
      case TripCategory.sonstiges:
        return 'Sonstiges';
    }
  }

  static TripCategory fromName(String value) {
    return TripCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => TripCategory.sonstiges,
    );
  }
}

/// Datenmodell für eine einzelne Fahrt.
///
/// Neben den normalen Fahrtenbuchdaten kann eine Fahrt auch GPS-Messwerte
/// enthalten: Dauer, Durchschnittsgeschwindigkeit und Höchstgeschwindigkeit.
class Trip {
  final String id;
  final String startLocation;
  final String destination;
  final double kilometers;
  final DateTime date;
  final TripCategory category;
  final String note;
  final String? vehicleId;

  /// Optionale GPS-/Statistikwerte.
  final int? durationSeconds;
  final double? maxSpeedKmh;
  final double? fuelUsedLiters;
  final bool createdByGps;

  const Trip({
    required this.id,
    required this.startLocation,
    required this.destination,
    required this.kilometers,
    required this.date,
    required this.category,
    required this.note,
    this.vehicleId,
    this.durationSeconds,
    this.maxSpeedKmh,
    this.fuelUsedLiters,
    this.createdByGps = false,
  });

  double? get averageSpeedKmh {
    if (durationSeconds == null || durationSeconds! <= 0 || kilometers <= 0) {
      return null;
    }
    return kilometers / (durationSeconds! / 3600);
  }

  double? get averageConsumptionL100km {
    if (fuelUsedLiters == null || fuelUsedLiters! <= 0 || kilometers <= 0) {
      return null;
    }
    return (fuelUsedLiters! / kilometers) * 100;
  }

  String get durationLabel {
    if (durationSeconds == null || durationSeconds! <= 0) return 'nicht gemessen';
    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;
    if (hours > 0) return '${hours}h ${minutes}min';
    if (minutes > 0) return '${minutes}min ${seconds}s';
    return '${seconds}s';
  }

  Trip copyWith({
    String? id,
    String? startLocation,
    String? destination,
    double? kilometers,
    DateTime? date,
    TripCategory? category,
    String? note,
    String? vehicleId,
    int? durationSeconds,
    double? maxSpeedKmh,
    double? fuelUsedLiters,
    bool? createdByGps,
  }) {
    return Trip(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      destination: destination ?? this.destination,
      kilometers: kilometers ?? this.kilometers,
      date: date ?? this.date,
      category: category ?? this.category,
      note: note ?? this.note,
      vehicleId: vehicleId ?? this.vehicleId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      fuelUsedLiters: fuelUsedLiters ?? this.fuelUsedLiters,
      createdByGps: createdByGps ?? this.createdByGps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startLocation': startLocation,
      'destination': destination,
      'kilometers': kilometers,
      'date': date.toIso8601String(),
      'category': category.name,
      'note': note,
      'vehicleId': vehicleId,
      'durationSeconds': durationSeconds,
      'maxSpeedKmh': maxSpeedKmh,
      'fuelUsedLiters': fuelUsedLiters,
      'createdByGps': createdByGps,
    };
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'] as String,
      startLocation: json['startLocation'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      kilometers: (json['kilometers'] as num?)?.toDouble() ?? 0,
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      category: TripCategoryExtension.fromName(json['category'] as String? ?? 'sonstiges'),
      note: json['note'] as String? ?? '',
      vehicleId: json['vehicleId'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
      maxSpeedKmh: (json['maxSpeedKmh'] as num?)?.toDouble(),
      fuelUsedLiters: (json['fuelUsedLiters'] as num?)?.toDouble(),
      createdByGps: json['createdByGps'] as bool? ?? false,
    );
  }

  String encode() => jsonEncode(toJson());

  static Trip decode(String source) {
    return Trip.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}
