import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/profile_repository.dart';
import 'onboarding_screen.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';

class ManageProfilesScreen extends StatefulWidget {
  final UserProfile currentActiveProfile;

  const ManageProfilesScreen({super.key, required this.currentActiveProfile});

  @override
  State<ManageProfilesScreen> createState() => _ManageProfilesScreenState();
}

class _ManageProfilesScreenState extends State<ManageProfilesScreen> {
  final ProfileRepository _repository = ProfileRepository();
  List<UserProfile> _profiles = [];
  late String _activeId;

  @override
  void initState() {
    super.initState();
    _activeId = widget.currentActiveProfile.id;
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final list = await _repository.getAllProfiles();
    setState(() {
      _profiles = list;
    });
  }

  void _switchProfile(UserProfile selectedProfile) {
    setState(() {
      _activeId = selectedProfile.id;
    });
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => HomeDashboardScreen(profile: selectedProfile),
      ),
      (route) => false,
    );
  }

  Future<void> _deleteProfile(String id) async {
    if (_profiles.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'कम से कम एक प्रोफ़ाइल होना आवश्यक है / At least one profile is required')),
      );
      return;
    }
    await _repository.deleteProfile(id);
    _loadProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('सदस्य चुनें / Manage Profiles'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'परिवार के सदस्य / Saved Family Profiles:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _profiles.length,
                itemBuilder: (context, index) {
                  final profile = _profiles[index];
                  final isSelected = profile.id == _activeId;

                  return Card(
                    elevation: isSelected ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor:
                            isSelected ? AppColors.primary : AppColors.accent,
                        child: Icon(
                          profile.gender == 'Female' ? Icons.woman : Icons.man,
                          color: isSelected ? Colors.white : AppColors.primary,
                          size: 28,
                        ),
                      ),
                      title: Text(
                        profile.fullName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(
                        'गांव: ${profile.villageName} • ${profile.gender}\nआपातकालीन: ${profile.emergencyContactPhone}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected)
                            const Chip(
                              label: Text('सक्रिय / Active',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11)),
                              backgroundColor: AppColors.primary,
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent),
                              onPressed: () => _switchProfile(profile),
                              child: const Text('चुनें / Select',
                                  style: TextStyle(color: AppColors.primary)),
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.emergencyRed),
                            onPressed: () => _deleteProfile(profile.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text(
                  'नया सदस्य जोड़ें / Add New Member',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const OnboardingScreen(isAddingSubProfile: true),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
