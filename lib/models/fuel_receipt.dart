import 'dart:convert';

/// Datenmodell für einen Tankbeleg.
///
/// OCR kann den Rohtext aus dem Foto speichern. Die wichtigen Werte werden
/// trotzdem in klare Felder übernommen, damit die Auswertung zuverlässig bleibt.
class FuelReceipt {
  final String id;
  final String vehicleId;
  final DateTime date;
  final String stationName;
  final double liters;
  final double totalPrice;
  final int odometer;
  final String receiptText;
  final String? imagePath;
  final String ocrRawText;

  const FuelReceipt({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.stationName,
    required this.liters,
    required this.totalPrice,
    required this.odometer,
    required this.receiptText,
    this.imagePath,
    this.ocrRawText = '',
  });

  double get pricePerLiter => liters <= 0 ? 0 : totalPrice / liters;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'stationName': stationName,
      'liters': liters,
      'totalPrice': totalPrice,
      'odometer': odometer,
      'receiptText': receiptText,
      'imagePath': imagePath,
      'ocrRawText': ocrRawText,
    };
  }

  factory FuelReceipt.fromJson(Map<String, dynamic> json) {
    return FuelReceipt(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleId: json['vehicleId'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      stationName: json['stationName'] as String? ?? '',
      liters: (json['liters'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      odometer: (json['odometer'] as num?)?.toInt() ?? 0,
      receiptText: json['receiptText'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      ocrRawText: json['ocrRawText'] as String? ?? '',
    );
  }

  String encode() => jsonEncode(toJson());
  static FuelReceipt decode(String source) => FuelReceipt.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
