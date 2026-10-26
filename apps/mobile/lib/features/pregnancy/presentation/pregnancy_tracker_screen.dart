import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PregnancyTrackerScreen extends StatelessWidget {
  final String lmpDateString; // ISO String YYYY-MM-DD

  const PregnancyTrackerScreen({super.key, required this.lmpDateString});

  int get currentGestationalWeeks {
    try {
      final lmp = DateTime.parse(lmpDateString);
      final difference = DateTime.now().difference(lmp).inDays;
      final weeks = (difference / 7).floor();
      return weeks < 0 ? 0 : weeks;
    } catch (_) {
      return 0;
    }
  }

  String get estimatedDeliveryDate {
    try {
      final lmp = DateTime.parse(lmpDateString);
      final edd =
          lmp.add(const Duration(days: 280)); // Naegele's rule (+280 days)
      return '${edd.day}/${edd.month}/${edd.year}';
    } catch (_) {
      return 'N/A';
    }
  }

  String get currentTrimester {
    final weeks = currentGestationalWeeks;
    if (weeks <= 12) return 'प्रथम तिमाही / 1st Trimester';
    if (weeks <= 27) return 'द्वितीय तिमाही / 2nd Trimester';
    return 'तृतीय तिमाही / 3rd Trimester';
  }

  @override
  Widget build(BuildContext context) {
    final weeks = currentGestationalWeeks;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('गर्भावस्था देखभाल / Pregnancy Care'),
        backgroundColor: Colors.pink.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Overview Card
            Card(
              color: Colors.pink.shade50,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'गर्भावस्था सप्ताह / Current Gestational Age',
                      style:
                          TextStyle(fontSize: 14, color: Colors.pink.shade900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$weeks सप्ताह (Weeks)',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: Colors.pink.shade200),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('अनुमानित प्रसव तिथि / EDD:'),
                        Text(
                          estimatedDeliveryDate,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TAILORED HEALTH GUIDANCE CARDS
            _buildGuidanceCard(
              title: 'आहार और पोषण / Diet & Nutrition',
              icon: Icons.restaurant,
              color: Colors.green.shade700,
              bgColor: Colors.green.shade50,
              content: weeks <= 12
                  ? '• फोलिक एसिड टैबलेट (Folic Acid) प्रतिदिन लें।\n'
                      '• हरी पत्तेदार सब्जियां, दालें और फल खाएं।\n'
                      '• पर्याप्त पानी (3-4 लीटर) पिएं।'
                  : weeks <= 27
                      ? '• आयरन (Iron) और कैल्शियम (Calcium) की गोलियां लें।\n'
                          '• दूध, दही, पनीर और प्रोटीन युक्त भोजन शामिल करें।\n'
                          '• हल्का और ताजा खाना खाएं।'
                      : '• भोजन को छोटे-छोटे टुकड़ों में दिन में 5-6 बार खाएं।\n'
                          '• ज्यादा नमक और तला हुआ भोजन न खाएं।\n'
                          '• डॉक्टर द्वारा दी गई सभी दवाएं नियमित लें।',
            ),

            const SizedBox(height: 16),

            _buildGuidanceCard(
              title: 'व्यायाम और योग / Exercise & Activity',
              icon: Icons.fitness_center,
              color: Colors.orange.shade800,
              bgColor: Colors.orange.shade50,
              content: weeks <= 12
                  ? '• सुबह-शाम 15-20 मिनट हल्की सैर करें।\n'
                      '• भारी सामान उठाने से बचें।'
                  : weeks <= 27
                      ? '• प्रतिदिन 20-30 मिनट टहलें।\n'
                          '• डॉक्टर की सलाह से तितली आसन (Butterfly Pose) करें।'
                      : '• केवल धीमी गति से टहलें।\n'
                          '• पेल्विक फ्लोर व्यायाम (Kegel Exercise) करें।',
            ),

            const SizedBox(height: 16),

            _buildGuidanceCard(
              title: 'विश्राम और देखभाल / Rest & Sleep',
              icon: Icons.king_bed,
              color: Colors.indigo.shade700,
              bgColor: Colors.indigo.shade50,
              content:
                  '• रात में 8-9 घंटे की नींद लें और दोपहर में 1-2 घंटे आराम करें।\n'
                  '• बाईं करवट (Left side) सोएं, इससे बच्चे को ऑक्सीजन अच्छी मिलती है।\n'
                  '• मानसिक तनाव से दूर रहें।',
            ),

            const SizedBox(height: 24),

            // RED-FLAG WARNING BOX (Fixed with Expanded)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.emergencyBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.emergencyRed, width: 2),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: AppColors.emergencyRed, size: 28),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'खतरे के लक्षण / High-Risk Warning Signs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emergencyRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'यदि इनमें से कोई भी लक्षण हो, तो तुरंत अस्पताल जाएं:\n'
                    '• तेज रक्तस्राव (Heavy Vaginal Bleeding)\n'
                    '• पेट में तेज दर्द (Severe Abdominal Pain)\n'
                    '• चक्कर आना या आंखों के सामने धुंधलापन (Blurred Vision/Seizures)\n'
                    '• शिशु की हलचल बंद होना (Loss of Fetal Movement)',
                    style: TextStyle(
                        fontSize: 14, color: Colors.black87, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String content,
  }) {
    return Card(
      color: bgColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              content,
              style: const TextStyle(
                  fontSize: 14, height: 1.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
