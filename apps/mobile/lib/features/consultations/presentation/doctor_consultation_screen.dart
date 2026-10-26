import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/consultation_repository.dart';

class DoctorConsultationScreen extends StatefulWidget {
  const DoctorConsultationScreen({super.key});

  @override
  State<DoctorConsultationScreen> createState() =>
      _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  final _notesController = TextEditingController();
  final ConsultationRepository _repository = ConsultationRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('डॉक्टर से सलाह / Consultation'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'अपनी समस्या लिखें / Describe your symptoms for the doctor:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'उदाहरण: 2 दिनों से सिरदर्द और बुखार...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_notesController.text.isNotEmpty) {
                    await _repository
                        .submitRequest(_notesController.text.trim());
                    _notesController.clear();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('अनुरोध कतार में जोड़ा गया (Queued for Sync)'),
                      ),
                    );
                  }
                },
                child: const Text('अनुरोध भेजें / Send Request'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
