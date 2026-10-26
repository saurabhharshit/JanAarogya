import 'package:flutter/material.dart';
import '../../../core/accessibility/tts_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/triage/triage_rule_engine.dart';

class SymptomCheckerScreen extends StatefulWidget {
  final bool isPregnant;

  const SymptomCheckerScreen({super.key, required this.isPregnant});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final Map<String, bool> _selectedSymptoms = {
    'chest_pain': false,
    'difficulty_breathing': false,
    'loss_of_consciousness': false,
    'severe_vaginal_bleeding': false,
    'high_fever': false,
    'mild_runny_nose': false,
  };

  TriageResult? _triageResult;

  void _runTriage() {
    final activeSymptoms = _selectedSymptoms.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (activeSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया कम से कम एक लक्षण चुनें')),
      );
      return;
    }

    final result = OfflineTriageRuleEngine.evaluate(
      reportedSymptoms: activeSymptoms,
      age: 28,
      isPregnant: widget.isPregnant,
      gender: 'female',
    );

    setState(() {
      _triageResult = result;
    });

    TTSService.instance.speak(result.guidanceText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('लक्षण जांच / Symptom Checker'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mandatory Clinical Safety Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: AppColors.warningAmber),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'यह उपकरण केवल प्रारंभिक जानकारी प्रदान करता है और डॉक्टर का स्थान नहीं लेता है।\n'
                'This tool provides general health information and is not a clinical diagnosis.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'आपके लक्षण चुनें / Select Symptoms:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ..._selectedSymptoms.keys.map((symptomKey) {
              return CheckboxListTile(
                title: Text(symptomKey.replaceAll('_', ' ').toUpperCase()),
                value: _selectedSymptoms[symptomKey],
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _selectedSymptoms[symptomKey] = val ?? false;
                  });
                },
              );
            }),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _runTriage,
                child: const Text('जांच करें / Evaluate Symptoms',
                    style: TextStyle(fontSize: 16)),
              ),
            ),

            if (_triageResult != null) ...[
              const SizedBox(height: 24),
              Card(
                color: _triageResult!.urgency == UrgencyLevel.emergency
                    ? AppColors.emergencyBg
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _triageResult!.urgency == UrgencyLevel.emergency
                        ? AppColors.emergencyRed
                        : AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'श्रेणी / Category: ${_triageResult!.categories.join(', ')}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _triageResult!.guidanceText,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                              _triageResult!.urgency == UrgencyLevel.emergency
                                  ? AppColors.emergencyRed
                                  : AppColors.textPrimary,
                          fontWeight:
                              _triageResult!.urgency == UrgencyLevel.emergency
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
