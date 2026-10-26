import 'package:flutter/material.dart';

import '../../../core/accessibility/tts_service.dart';
import '../../../core/constants/app_colors.dart';
import '../data/profile_repository.dart';
import '../../dashboard/presentation/home_dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isAddingSubProfile;

  const OnboardingScreen({super.key, this.isAddingSubProfile = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _phoneController = TextEditingController();
  final _allergiesController = TextEditingController();

  String _gender = 'Female';
  final String _language = 'hi';
  bool _isPregnant = false;
  DateTime? _lmpDate;
  final DateTime _selectedDob = DateTime(1998, 1, 1);

  final ProfileRepository _repository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    TTSService.instance.speak(
      'जनआरोग्य में आपका स्वागत है। कृपया अपनी जानकारी भरें।',
    );
  }

  Future<void> _selectLmpDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _lmpDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime.now()
          .subtract(const Duration(days: 280)), // Max ~40 weeks back
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lmpDate = picked;
      });
    }
  }

  Future<void> _submitOnboarding() async {
    if (_formKey.currentState!.validate()) {
      if (_gender == 'Female' && _isPregnant && _lmpDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'कृपया अंतिम माहवारी तिथि (LMP Date) चुनें / Please select LMP Date'),
          ),
        );
        return;
      }
      final profile = UserProfile(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        fullName: _nameController.text.trim(),
        dateOfBirth: _selectedDob.toIso8601String().split('T')[0],
        gender: _gender,
        villageName: _villageController.text.trim(),
        districtName: _districtController.text.trim(),
        preferredLanguage: _language,
        emergencyContactPhone: _phoneController.text.trim(),
        knownAllergies: _allergiesController.text.isNotEmpty
            ? _allergiesController.text.split(',').map((e) => e.trim()).toList()
            : [],
        existingConditions: [],
        isPregnant: _isPregnant,
        lmpDate: _isPregnant && _lmpDate != null
            ? _lmpDate!.toIso8601String().split('T')[0]
            : null,
      );

      await _repository.saveProfileLocally(profile);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => HomeDashboardScreen(profile: profile),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isAddingSubProfile
              ? 'नया सदस्य जोड़ें / Add Member'
              : 'स्वास्थ्य प्रोफ़ाइल बनाएं / Profile Setup',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 28),
            onPressed: () => TTSService.instance.speak(
              'कृपया अपना नाम, गांव और आपातकालीन फोन नंबर भरें।',
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'आपकी जानकारी / Basic Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: 'पूरा नाम / Full Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'कृपया नाम भरें' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(
                        labelText: 'गांव / Village *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'गांव भरें' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _districtController,
                      decoration: const InputDecoration(
                        labelText: 'जिला / District *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'जिला भरें' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'आपातकालीन नंबर / Emergency Contact *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: AppColors.emergencyRed),
                ),
                validator: (val) => val == null || val.length < 10
                    ? 'वैध नंबर दर्ज करें'
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(
                  labelText: 'लिंग / Gender',
                  border: OutlineInputBorder(),
                ),
                items: ['Female', 'Male', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val!),
              ),
              const SizedBox(height: 12),
              if (_gender == 'Female')
                CheckboxListTile(
                  title: const Text('क्या आप गर्भवती हैं? / Are you pregnant?'),
                  value: _isPregnant,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _isPregnant = val ?? false;
                      if (!_isPregnant) _lmpDate = null;
                    });
                  },
                ),
              if (_isPregnant) ...[
                const SizedBox(height: 8),
                ListTile(
                  tileColor: Colors.pink.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.pink.shade200),
                  ),
                  leading: const Icon(Icons.calendar_month, color: Colors.pink),
                  title: const Text(
                      'गर्भावस्था की शुरुआत / Last Menstrual Period (LMP) Date *'),
                  subtitle: Text(
                    _lmpDate == null
                        ? 'तिथि चुनें / Select Date'
                        : '${_lmpDate!.day}/${_lmpDate!.month}/${_lmpDate!.year}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _selectLmpDate(context),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submitOnboarding,
                  child: const Text(
                    'सहेजें और आगे बढ़ें / Save Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
