import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/data/profile_repository.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/dashboard/presentation/home_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final profileRepo = ProfileRepository();
  final activeProfile = await profileRepo.getActiveProfile();

  runApp(JanAarogyaApp(initialProfile: activeProfile));
}

class JanAarogyaApp extends StatelessWidget {
  final UserProfile? initialProfile;

  const JanAarogyaApp({super.key, this.initialProfile});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JanAarogya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
      ],
      home: initialProfile != null
          ? HomeDashboardScreen(profile: initialProfile!)
          : const OnboardingScreen(),
    );
  }
}
