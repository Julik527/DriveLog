import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptOcrResult {
  final String? imagePath;
  final String text;
  final double? guessedTotalPrice;
  final double? guessedLiters;
  final String? guessedStation;

  const ReceiptOcrResult({
    required this.imagePath,
    required this.text,
    this.guessedTotalPrice,
    this.guessedLiters,
    this.guessedStation,
  });
}

class ReceiptOcrException implements Exception {
  final String message;
  const ReceiptOcrException(this.message);
  @override
  String toString() => message;
}

/// Erkennt Text auf Tankbeleg-Fotos.
///
/// Wichtig für die Präsentation:
/// - image_picker öffnet Kamera oder Galerie.
/// - ML Kit liest Text aus dem Bild.
/// - DriveLog macht nur Vorschläge. Der Nutzer prüft die Werte.
/// - Auf Windows kann ein Bild ausgewählt werden, aber ML-Kit-OCR ist nur
///   zuverlässig auf Android/iOS. Darum gibt es einen sauberen Hinweis.
class ReceiptOcrService {
  final ImagePicker _picker = ImagePicker();

  Future<ReceiptOcrResult?> scanReceipt({required bool useCamera}) async {
    final source = useCamera ? ImageSource.camera : ImageSource.gallery;
    final file = await _picker.pickImage(source: source, imageQuality: 85);
    if (file == null) return null;

    if (!_supportsMlKitOcr) {
      throw ReceiptOcrException(
        'Foto wurde ausgewählt, aber echte ML-Kit-OCR funktioniert in diesem Projekt auf Android/iOS. Auf Windows bitte Belegdaten manuell übernehmen.',
      );
    }

    final inputImage = InputImage.fromFilePath(file.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await recognizer.processImage(inputImage);
      final text = recognizedText.text;
      return ReceiptOcrResult(
        imagePath: file.path,
        text: text,
        guessedTotalPrice: _guessTotalPrice(text),
        guessedLiters: _guessLiters(text),
        guessedStation: _guessStation(text),
      );
    } finally {
      await recognizer.close();
    }
  }

  bool get _supportsMlKitOcr {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;
  }

  double? _guessTotalPrice(String text) {
    final normalized = text.replaceAll(',', '.');
    final moneyMatches = RegExp(r'(\d{1,3}[.]\d{2})').allMatches(normalized).toList();
    if (moneyMatches.isEmpty) return null;
    final values = moneyMatches.map((match) => double.tryParse(match.group(1)!)).whereType<double>().toList();
    if (values.isEmpty) return null;
    values.sort();
    return values.last;
  }

  double? _guessLiters(String text) {
    final normalized = text.replaceAll(',', '.');
    final literPattern = RegExp(r'(\d{1,3}[.]\d{1,3})\s*(l|liter)', caseSensitive: false);
    final match = literPattern.firstMatch(normalized);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  String? _guessStation(String text) {
    final lines = text.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    if (lines.isEmpty) return null;
    return lines.first.length > 40 ? lines.first.substring(0, 40) : lines.first;
  }
}
