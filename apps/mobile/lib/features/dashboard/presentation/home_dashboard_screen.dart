import 'package:flutter/material.dart';

import '../../../core/accessibility/tts_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/profile_repository.dart';
import '../../auth/presentation/manage_profiles_screen.dart';
import '../../consultations/presentation/doctor_consultation_screen.dart';
import '../../emergency/presentation/emergency_support_screen.dart';
import '../../facilities/presentation/nearby_facilities_screen.dart';
import '../../medicine_reminders/presentation/medicine_reminder_screen.dart';
import '../../pregnancy/presentation/pregnancy_tracker_screen.dart';
import '../../symptom_checker/presentation/symptom_checker_screen.dart';
import '../../vaccination/presentation/vaccination_tracker_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  final UserProfile profile;

  const HomeDashboardScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'जनआरोग्य: ${profile.fullName}',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'गांव: ${profile.villageName}, ${profile.districtName}',
              style: const TextStyle(fontSize: 12, color: AppColors.accent),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.manage_accounts,
                size: 28, color: Colors.white),
            tooltip: 'सदस्य बदलें / Manage Profiles',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ManageProfilesScreen(currentActiveProfile: profile),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28, color: Colors.white),
            tooltip: 'आवाज सुनें / Audio Help',
            onPressed: () async {
              await TTSService.instance.speak(
                'मुख्य पृष्ठ। आपातकालीन सहायता के लिए ऊपर लाल बटन दबाएं।',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- ISOLATED EMERGENCY BUTTON ---
            Card(
              color: AppColors.emergencyBg,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.emergencyRed, width: 2),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EmergencySupportScreen(
                        emergencyPhone: profile.emergencyContactPhone,
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.emergencyRed,
                        child: Icon(Icons.emergency,
                            color: Colors.white, size: 32),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'आपातकालीन सहायता / EMERGENCY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.emergencyRed,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'एम्बुलेंस (108) या आपातकालीन संपर्क को तुरंत कॉल करें',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- FEATURE NAVIGATION GRID ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildDashboardTile(
                  context,
                  title: 'लक्षण जांच\nSymptom Checker',
                  icon: Icons.health_and_safety,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SymptomCheckerScreen(
                        isPregnant: profile.isPregnant,
                      ),
                    ),
                  ),
                ),
                _buildDashboardTile(
                  context,
                  title: 'दवा रिमाइंडर\nMedicine Reminders',
                  icon: Icons.medication,
                  color: AppColors.primaryDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicineReminderScreen(),
                    ),
                  ),
                ),
                _buildDashboardTile(
                  context,
                  title: 'टीकाकरण\nVaccination',
                  icon: Icons.vaccines,
                  color: AppColors.primaryDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VaccinationTrackerScreen(),
                    ),
                  ),
                ),
                if (profile.isPregnant)
                  _buildDashboardTile(
                    context,
                    title: 'गर्भावस्था देखभाल\nPregnancy Tracker',
                    icon: Icons.child_care,
                    color: Colors.pink.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PregnancyTrackerScreen(
                          lmpDateString: profile.lmpDate ??
                              DateTime.now().toIso8601String(),
                        ),
                      ),
                    ),
                  ),
                _buildDashboardTile(
                  context,
                  title: 'डॉक्टर से सलाह\nDoctor Consultation',
                  icon: Icons.medical_services,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DoctorConsultationScreen(),
                    ),
                  ),
                ),
                _buildDashboardTile(
                  context,
                  title: 'पास के अस्पताल\nNearby Hospitals',
                  icon: Icons.local_hospital,
                  color: AppColors.primaryDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NearbyFacilitiesScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 42, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
