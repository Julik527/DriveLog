/// Zentrale lokale Vorschläge für Formularfelder.
///
/// Diese Datei ist bewusst simpel gehalten: Es sind Listen und kleine
/// Hilfsfunktionen. Dadurch können Schüler gut erklären, warum in bestimmten
/// Feldern passende Vorschläge erscheinen.
class FormSuggestionService {
  static const List<String> vehicleBrands = [
    'Audi',
    'BMW',
    'Ford',
    'Mercedes-Benz',
    'Opel',
    'Porsche',
    'Škoda',
    'Tesla',
    'Toyota',
    'Volkswagen',
    'Volvo',
  ];

  static const List<String> vehicleModels = [
    'Focus Cabrio',
    'Focus Turnier',
    'Golf',
    'Passat',
    'C-Klasse',
    'E-Klasse',
    '3er',
    '5er',
    'A4',
    'A6',
    '911 Carrera',
    'Cayenne',
    'Panamera',
    'Model 3',
    'Octavia',
  ];

  static const Map<String, List<String>> _modelsByBrand = {
    'ford': ['Focus Cabrio', 'Focus Turnier', 'Fiesta', 'Kuga', 'Transit Custom'],
    'porsche': ['911 Carrera', '911 Turbo', 'Cayenne', 'Panamera', 'Macan', 'Taycan'],
    'volkswagen': ['Golf', 'Passat', 'Tiguan', 'Transporter T6', 'ID.4'],
    'vw': ['Golf', 'Passat', 'Tiguan', 'Transporter T6', 'ID.4'],
    'bmw': ['3er', '5er', 'X3', 'X5', 'i4'],
    'mercedes': ['C-Klasse', 'E-Klasse', 'Sprinter', 'Vito', 'GLE'],
    'mercedes-benz': ['C-Klasse', 'E-Klasse', 'Sprinter', 'Vito', 'GLE'],
    'audi': ['A3', 'A4', 'A6', 'Q5', 'Q7'],
    'tesla': ['Model 3', 'Model Y', 'Model S', 'Model X'],
    'skoda': ['Octavia', 'Superb', 'Kodiaq', 'Fabia'],
    'šKoda': ['Octavia', 'Superb', 'Kodiaq', 'Fabia'],
    'opel': ['Astra', 'Corsa', 'Insignia', 'Vivaro'],
    'toyota': ['Corolla', 'Yaris', 'RAV4', 'Proace'],
    'volvo': ['XC40', 'XC60', 'XC90', 'V60'],
  };

  static List<String> modelsForBrand(String brand) {
    final normalized = _normalize(brand);
    final specific = _modelsByBrand[normalized] ?? const <String>[];
    return _mergeUnique([...specific, ...vehicleModels]);
  }

  static const List<String> fuelTypes = [
    'Benzin',
    'Diesel',
    'Hybrid',
    'Plug-in-Hybrid',
    'Elektro',
    'E10',
    'Super Plus',
  ];

  static const List<String> tireSizes = [
    '195/65 R15',
    '205/55 R16',
    '215/55 R16',
    '225/45 R17',
    '225/40 R18',
    '235/35 R19',
    '255/35 R20',
    '275/35 R20',
    '315/30 R21',
  ];

  static List<String> tireSizesForVehicle(String brand, String model) {
    final text = _normalize('$brand $model');
    if (text.contains('porsche') || text.contains('911') || text.contains('cayenne') || text.contains('panamera')) {
      return _mergeUnique(['235/40 R19', '265/40 R20', '275/35 R20', '315/30 R21', ...tireSizes]);
    }
    if (text.contains('focus')) {
      return _mergeUnique(['205/55 R16', '215/50 R17', '225/40 R18', ...tireSizes]);
    }
    if (text.contains('transit') || text.contains('sprinter') || text.contains('vito')) {
      return _mergeUnique(['215/65 R16C', '235/65 R16C', '235/60 R17C', ...tireSizes]);
    }
    return tireSizes;
  }

  static const List<String> oilSpecifications = [
    '5W-30',
    '5W-40',
    '0W-30',
    '0W-40',
    'VW 504 00 / 507 00',
    'MB 229.51',
    'BMW Longlife-04',
    'Ford WSS-M2C913-C',
    'Ford WSS-M2C913-D',
    'Porsche C30',
    'Porsche A40',
  ];

  static List<String> oilSpecificationsForVehicle(String brand, String fuelType) {
    final brandText = _normalize(brand);
    final fuelText = _normalize(fuelType);
    final result = <String>[];

    if (brandText.contains('ford')) result.addAll(['Ford WSS-M2C913-C', 'Ford WSS-M2C913-D', '5W-30']);
    if (brandText.contains('porsche')) result.addAll(['Porsche C30', 'Porsche A40', '0W-40', '5W-40']);
    if (brandText.contains('volkswagen') || brandText.contains('vw') || brandText.contains('audi') || brandText.contains('skoda')) {
      result.addAll(['VW 504 00 / 507 00', '5W-30']);
    }
    if (brandText.contains('bmw')) result.addAll(['BMW Longlife-04', '5W-30']);
    if (brandText.contains('mercedes')) result.addAll(['MB 229.51', '5W-30']);
    if (fuelText.contains('diesel')) result.addAll(['5W-30 Diesel-Freigabe prüfen', 'Low SAPS / DPF geeignet']);
    if (fuelText.contains('elektro')) result.add('Kein Motoröl nötig, Wartungsplan prüfen');

    return _mergeUnique([...result, ...oilSpecifications]);
  }

  static const List<String> fuelStations = [
    'Aral Leutkirch',
    'Shell Leutkirch',
    'AVIA Leutkirch',
    'JET Leutkirch',
    'TotalEnergies',
    'Agip / Eni',
    'Esso',
    'Freie Tankstelle',
  ];

  static List<String> fuelStationsForRegion(String region) {
    final text = _normalize(region);
    if (text.contains('leutkirch')) {
      return _mergeUnique(['Aral Leutkirch', 'Shell Leutkirch', 'AVIA Leutkirch', 'JET Leutkirch', ...fuelStations]);
    }
    return fuelStations;
  }

  static const List<String> issueTitles = [
    'Klackern vorne rechts',
    'Lenkung zieht zur Seite',
    'Bremsen quietschen',
    'Motor ruckelt',
    'Reifendruck auffällig',
    'Ölverlust sichtbar',
    'Licht funktioniert nicht',
    'Poltern beim Überfahren von Unebenheiten',
    'Warnleuchte im Display',
  ];

  static const List<String> issueComponents = [
    'Fahrwerk',
    'Bremse',
    'Motor',
    'Reifen',
    'Lenkung',
    'Beleuchtung',
    'Karosserie',
    'Elektronik',
    'Innenraum',
  ];

  static List<String> issueTitlesForComponent(String component) {
    final text = _normalize(component);
    if (text.contains('fahrwerk')) {
      return _mergeUnique(['Poltern vorne rechts', 'Klackern beim Lenken', 'Fahrzeug liegt unruhig', ...issueTitles]);
    }
    if (text.contains('bremse')) {
      return _mergeUnique(['Bremsen quietschen', 'Bremspedal vibriert', 'Bremsweg wirkt länger', ...issueTitles]);
    }
    if (text.contains('motor')) {
      return _mergeUnique(['Motor ruckelt', 'Ölverlust sichtbar', 'Warnleuchte Motor', ...issueTitles]);
    }
    if (text.contains('reifen')) {
      return _mergeUnique(['Reifendruck auffällig', 'Reifen beschädigt', 'Unwucht / Vibration', ...issueTitles]);
    }
    if (text.contains('lenkung')) {
      return _mergeUnique(['Lenkung zieht zur Seite', 'Lenkung schwergängig', 'Knacken beim Einschlagen', ...issueTitles]);
    }
    return issueTitles;
  }

  static const List<String> damageNotes = [
    'Kratzer vorne rechts',
    'Felge vorne links beschädigt',
    'Reifenprofil prüfen',
    'Licht vorne prüfen',
    'Steinschlag in der Frontscheibe',
    'Fahrwerk nach Geräusch prüfen',
    'Ölverlust kontrollieren',
  ];

  static const List<String> issueDescriptions = [
    'Geräusch tritt beim Überfahren von Unebenheiten auf.',
    'Geräusch tritt beim Bremsen auf.',
    'Fahrzeug zieht während der Fahrt leicht zur Seite.',
    'Warnleuchte erschien nach der Fahrt im Display.',
    'Nach der Fahrt wurde ein Flüssigkeitsverlust bemerkt.',
    'Problem ist sicherheitsrelevant und sollte vor der nächsten Fahrt geprüft werden.',
  ];

  static const List<String> registrationNotes = [
    'Höchstgeschwindigkeit laut Fahrzeugschein eintragen.',
    'Zulässige Reifengrößen aus CoC/Fahrzeugschein übernehmen.',
    'Zulässige Anhängelast gebremst/ungebremst eintragen.',
    'Zulässiges Gesamtgewicht eintragen.',
    'Öl-Freigabe aus Handbuch oder Herstellerdaten prüfen.',
  ];

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue').replaceAll('ß', 'ss');
  }

  static List<String> _mergeUnique(List<String> values) {
    final result = <String>[];
    final used = <String>{};
    for (final value in values) {
      final cleaned = value.trim();
      if (cleaned.isEmpty) continue;
      if (used.add(_normalize(cleaned))) result.add(cleaned);
    }
    return result;
  }
}
