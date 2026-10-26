// apps/mobile/test/triage_rule_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/triage/triage_rule_engine.dart';

void main() {
  group('OfflineTriageRuleEngine Unit Tests', () {
    test('Should return EMERGENCY urgency when chest pain is reported', () {
      final result = OfflineTriageRuleEngine.evaluate(
        reportedSymptoms: ['chest_pain', 'mild_headache'],
        age: 45,
        isPregnant: false,
        gender: 'male',
      );

      expect(result.urgency, UrgencyLevel.emergency);
      expect(result.categories, contains('Acute Medical Emergency'));
    });

    test(
        'Should trigger maternal emergency for pregnant woman with severe bleeding',
        () {
      final result = OfflineTriageRuleEngine.evaluate(
        reportedSymptoms: ['severe_vaginal_bleeding'],
        age: 26,
        isPregnant: true,
        gender: 'female',
      );

      expect(result.urgency, UrgencyLevel.emergency);
      expect(result.categories, contains('Maternal Obstetric Emergency'));
    });

    test('Should return self-care for non-critical symptoms', () {
      final result = OfflineTriageRuleEngine.evaluate(
        reportedSymptoms: ['mild_runny_nose'],
        age: 22,
        isPregnant: false,
        gender: 'female',
      );

      expect(result.urgency, UrgencyLevel.selfCare);
    });
  });
}
