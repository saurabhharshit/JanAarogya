// apps/mobile/lib/core/triage/triage_rule_engine.dart

enum UrgencyLevel { emergency, urgent, routine, selfCare }

class TriageResult {
  final UrgencyLevel urgency;
  final List<String> categories;
  final List<String> warningSigns;
  final String guidanceText;

  TriageResult({
    required this.urgency,
    required this.categories,
    required this.warningSigns,
    required this.guidanceText,
  });
}

class OfflineTriageRuleEngine {
  /// Evaluates symptoms deterministically offline using clinical safety circuit breakers.
  static TriageResult evaluate({
    required List<String> reportedSymptoms,
    required int age,
    required bool isPregnant,
    required String gender,
  }) {
    final normalizedSymptoms = reportedSymptoms
        .map((s) => s.toLowerCase().trim())
        .toList();
    List<String> triggeredWarningSigns = [];

    // --- CIRCUIT BREAKER 1: RED-FLAG EMERGENCY CHECK ---
    if (normalizedSymptoms.contains('chest_pain') ||
        normalizedSymptoms.contains('difficulty_breathing') ||
        normalizedSymptoms.contains('loss_of_consciousness') ||
        normalizedSymptoms.contains('seizures')) {
      triggeredWarningSigns.add(
        'Critical acute symptom detected requiring immediate resuscitation care.',
      );

      return TriageResult(
        urgency: UrgencyLevel.emergency,
        categories: ['Acute Medical Emergency'],
        warningSigns: triggeredWarningSigns,
        guidanceText: 'IMMEDIATE ACTION REQUIRED: Contact emergency services (108) or go to the nearest emergency hospital immediately. Do not wait.',
      );
    }

    // --- CIRCUIT BREAKER 2: MATERNAL RED-FLAGS ---
    if (isPregnant) {
      if (normalizedSymptoms.contains('severe_vaginal_bleeding') ||
          normalizedSymptoms.contains('severe_abdominal_pain') ||
          normalizedSymptoms.contains('blurriness_vision')) {
        triggeredWarningSigns.add('High-risk pregnancy red flag detected.');

        return TriageResult(
          urgency: UrgencyLevel.emergency,
          categories: ['Maternal Obstetric Emergency'],
          warningSigns: triggeredWarningSigns,
          guidanceText: 'SEEK URGENT MATERNAL CARE: Heavy bleeding or severe abdominal pain during pregnancy is a critical warning sign. Transport patient to a district hospital immediately.',
        );
      }
    }

    // --- ROUTINE / URGENT FALLBACK RULES ---
    if (normalizedSymptoms.contains('high_fever') && age < 5) {
      return TriageResult(
        urgency: UrgencyLevel.urgent,
        categories: ['Pediatric Febrile Illness'],
        warningSigns: [
          'High fever in children under 5 years requires medical evaluation within 24 hours.',
        ],
        guidanceText: 'Keep the child hydrated and cool with lukewarm sponges. Visit the nearest primary health center (PHC) today.',
      );
    }

    return TriageResult(
      urgency: UrgencyLevel.selfCare,
      categories: ['General Self-Care Information'],
      warningSigns: [],
      guidanceText: 'Rest, maintain adequate fluid intake, and monitor symptoms. If symptoms worsen or persist past 48 hours, consult a healthcare provider.',
    );
  }
}
