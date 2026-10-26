import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class EmergencySupportScreen extends StatelessWidget {
  final String emergencyPhone;

  const EmergencySupportScreen({super.key, required this.emergencyPhone});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Fallback direct launch if canLaunchUrl check fails
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('आपातकालीन सहायता / Emergency Support'),
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.emergency,
                size: 80, color: AppColors.emergencyRed),
            const SizedBox(height: 16),
            const Text(
              'आपातकालीन स्थिति में तुरंत मदद लें',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emergencyRed,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.phone_in_talk, size: 28),
                label: const Text('108 एम्बुलेंस को कॉल करें',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () => _makePhoneCall('108'),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                ),
                icon: const Icon(Icons.person_pin, color: AppColors.primary),
                label: Text('आपातकालीन संपर्क ($emergencyPhone)',
                    style: const TextStyle(
                        fontSize: 16, color: AppColors.primary)),
                onPressed: () => _makePhoneCall(emergencyPhone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
