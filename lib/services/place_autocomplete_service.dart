import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Kontext für Ortsvorschläge.
///
/// Dadurch zeigt die App nicht einfach irgendeine Liste, sondern passende
/// Vorschläge je nach Feld: Fahrt, Werkstatt, Tankstelle oder allgemein.
enum PlaceAutocompleteContext {
  trip,
  workshop,
  fuel,
  general,
}

/// Ein Vorschlag für ein Ortsfeld.
///
/// title ist der sichtbare Name, subtitle liefert zusätzliche Orientierung.
/// So wirkt die Eingabe ähnlich wie bei Karten-Apps, bleibt aber einfach erklärbar.
class PlaceSuggestion {
  final String title;
  final String subtitle;
  final double? latitude;
  final double? longitude;

  const PlaceSuggestion({
    required this.title,
    required this.subtitle,
    this.latitude,
    this.longitude,
  });

  String get valueForInput => title;
}

/// Autocomplete für Orte.
///
/// Die App nutzt zuerst lokale Beispielorte, damit sofort Vorschläge kommen.
/// Ab 2 Zeichen werden zusätzlich echte Orte über Nominatim gesucht.
class PlaceAutocompleteService {
  static const String _userAgent = 'DriveLogSchulprojekt/5.0';

  static const List<PlaceSuggestion> localSuggestions = [
    PlaceSuggestion(title: 'Leutkirch im Allgäu', subtitle: 'Standard-Startort / Allgäu'),
    PlaceSuggestion(title: 'Leutkirch Bahnhof', subtitle: 'Leutkirch im Allgäu'),
    PlaceSuggestion(title: 'Leutkirch Gewerbegebiet', subtitle: 'Fuhrpark / Arbeit'),
    PlaceSuggestion(title: 'Bad Saulgau', subtitle: 'Landkreis Sigmaringen'),
    PlaceSuggestion(title: 'Ravensburg', subtitle: 'Schule / Stadt'),
    PlaceSuggestion(title: 'Ravensburg Berufsschule', subtitle: 'Schule / Ausbildung'),
    PlaceSuggestion(title: 'Aulendorf Bahnhof', subtitle: 'Oberschwaben'),
    PlaceSuggestion(title: 'Kißlegg', subtitle: 'Allgäu'),
    PlaceSuggestion(title: 'Lindau', subtitle: 'Bodensee'),
    PlaceSuggestion(title: 'Lindau Insel', subtitle: 'Bodensee'),
    PlaceSuggestion(title: 'Wangen im Allgäu', subtitle: 'Allgäu'),
    PlaceSuggestion(title: 'Memmingen', subtitle: 'Bayern'),
    PlaceSuggestion(title: 'Ulm', subtitle: 'Baden-Württemberg'),
    PlaceSuggestion(title: 'Friedrichshafen Hafen', subtitle: 'Bodensee'),
    PlaceSuggestion(title: 'Konstanz', subtitle: 'Bodensee'),
    PlaceSuggestion(title: 'München', subtitle: 'Bayern'),
    PlaceSuggestion(title: 'Stuttgart', subtitle: 'Baden-Württemberg'),
  ];

  static const List<PlaceSuggestion> workshopSuggestions = [
    PlaceSuggestion(title: 'Werkstatt Leutkirch', subtitle: 'Werkstattsuche im Umkreis'),
    PlaceSuggestion(title: 'Autohaus Leutkirch', subtitle: 'Service / Wartung'),
    PlaceSuggestion(title: 'Reifenservice Leutkirch', subtitle: 'Reifen / Räder'),
    PlaceSuggestion(title: 'Karosserie Leutkirch', subtitle: 'Schaden / Unfall'),
    PlaceSuggestion(title: 'Werkstatt Wangen im Allgäu', subtitle: 'Umkreis'),
    PlaceSuggestion(title: 'Werkstatt Ravensburg', subtitle: 'Umkreis'),
  ];

  static const List<PlaceSuggestion> fuelSuggestions = [
    PlaceSuggestion(title: 'Aral Leutkirch', subtitle: 'Tankstelle'),
    PlaceSuggestion(title: 'Shell Leutkirch', subtitle: 'Tankstelle'),
    PlaceSuggestion(title: 'AVIA Leutkirch', subtitle: 'Tankstelle'),
    PlaceSuggestion(title: 'JET Leutkirch', subtitle: 'Tankstelle'),
  ];

  final Map<String, List<PlaceSuggestion>> _cache = {};

  Future<List<PlaceSuggestion>> search(
    String query, {
    PlaceAutocompleteContext context = PlaceAutocompleteContext.trip,
  }) async {
    final cleaned = query.trim();
    final localBase = _localSuggestionsFor(context);

    if (cleaned.isEmpty) return localBase.take(6).toList();

    final local = _localMatches(cleaned, localBase);
    if (cleaned.length < 2) return local.take(6).toList();

    final cacheKey = '${context.name}:${cleaned.toLowerCase()}';
    if (_cache.containsKey(cacheKey)) return _merge(local, _cache[cacheKey]!);

    try {
      final remote = await _searchOnline(cleaned, context).timeout(const Duration(seconds: 8));
      _cache[cacheKey] = remote;
      return _merge(local, remote);
    } catch (_) {
      // Keine Internetverbindung oder Dienst nicht erreichbar: lokale Vorschläge bleiben nutzbar.
      return local.take(6).toList();
    }
  }

  List<PlaceSuggestion> _localSuggestionsFor(PlaceAutocompleteContext context) {
    switch (context) {
      case PlaceAutocompleteContext.workshop:
        return [...workshopSuggestions, ...localSuggestions];
      case PlaceAutocompleteContext.fuel:
        return [...fuelSuggestions, ...localSuggestions];
      case PlaceAutocompleteContext.general:
      case PlaceAutocompleteContext.trip:
        return localSuggestions;
    }
  }

  List<PlaceSuggestion> _localMatches(String query, List<PlaceSuggestion> source) {
    final lower = _normalize(query);
    return source.where((suggestion) {
      return _normalize(suggestion.title).contains(lower) || _normalize(suggestion.subtitle).contains(lower);
    }).toList();
  }


  String _searchTextForContext(String query, PlaceAutocompleteContext context) {
    switch (context) {
      case PlaceAutocompleteContext.workshop:
        return '$query Werkstatt Deutschland';
      case PlaceAutocompleteContext.fuel:
        return '$query Tankstelle Deutschland';
      case PlaceAutocompleteContext.general:
      case PlaceAutocompleteContext.trip:
        return '$query Deutschland';
    }
  }

  Future<List<PlaceSuggestion>> _searchOnline(String query, PlaceAutocompleteContext context) async {
    final searchText = _searchTextForContext(query, context);

    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': searchText,
      'format': 'jsonv2',
      'addressdetails': '1',
      'limit': '6',
    });

    final response = await http.get(uri, headers: {'User-Agent': _userAgent});
    if (response.statusCode != 200) return const [];

    final results = jsonDecode(response.body) as List<dynamic>;
    return results.map((item) {
      final map = item as Map<String, dynamic>;
      final displayName = (map['display_name'] as String? ?? '').trim();
      final address = map['address'] as Map<String, dynamic>? ?? {};

      final city = _firstNonEmpty([
        address['city'],
        address['town'],
        address['village'],
        address['municipality'],
        address['county'],
      ]);
      final state = _firstNonEmpty([address['state'], address['country']]);
      final title = city.isEmpty ? _shortenDisplayName(displayName) : city;
      final subtitle = displayName.isEmpty ? state : displayName;

      return PlaceSuggestion(
        title: title.isEmpty ? query : title,
        subtitle: subtitle,
        latitude: double.tryParse(map['lat'] as String? ?? ''),
        longitude: double.tryParse(map['lon'] as String? ?? ''),
      );
    }).where((suggestion) => suggestion.title.trim().isNotEmpty).toList();
  }

  List<PlaceSuggestion> _merge(List<PlaceSuggestion> local, List<PlaceSuggestion> remote) {
    final merged = <PlaceSuggestion>[];
    final used = <String>{};

    for (final suggestion in [...local, ...remote]) {
      final key = _normalize('${suggestion.title}|${suggestion.subtitle}');
      if (used.add(key)) merged.add(suggestion);
      if (merged.length == 8) break;
    }

    return merged;
  }

  static String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = (value as String?)?.trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _shortenDisplayName(String displayName) {
    if (displayName.isEmpty) return '';
    return displayName.split(',').first.trim();
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll('ä', 'ae').replaceAll('ö', 'oe').replaceAll('ü', 'ue').replaceAll('ß', 'ss');
  }
}
