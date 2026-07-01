import 'package:flutter_test/flutter_test.dart';
import 'package:drivelog/services/form_suggestion_service.dart';
import 'package:drivelog/services/place_autocomplete_service.dart';

void main() {
  test('lokale Ortsvorschläge enthalten wichtige Beispielorte', () {
    final titles = PlaceAutocompleteService.localSuggestions.map((item) => item.title).toList();

    expect(titles, contains('Leutkirch im Allgäu'));
    expect(titles, contains('Lindau'));
    expect(titles, contains('Bad Saulgau'));
  });

  test('Formularvorschläge enthalten typische Fuhrparkdaten', () {
    expect(FormSuggestionService.vehicleBrands, contains('Porsche'));
    expect(FormSuggestionService.fuelTypes, contains('Diesel'));
    expect(FormSuggestionService.issueComponents, contains('Fahrwerk'));
    expect(FormSuggestionService.oilSpecifications, contains('5W-30'));
  });

  test('kontextbezogene Fahrzeugvorschläge passen zur Marke', () {
    expect(FormSuggestionService.modelsForBrand('Porsche'), contains('911 Carrera'));
    expect(FormSuggestionService.modelsForBrand('Ford'), contains('Focus Cabrio'));
    expect(FormSuggestionService.oilSpecificationsForVehicle('Porsche', 'Benzin'), contains('Porsche A40'));
  });

  test('Problemvorschläge passen zum Bauteil', () {
    expect(FormSuggestionService.issueTitlesForComponent('Fahrwerk'), contains('Poltern vorne rechts'));
    expect(FormSuggestionService.issueTitlesForComponent('Bremse'), contains('Bremsen quietschen'));
  });
}
