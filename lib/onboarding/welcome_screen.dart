import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'registration_options_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Main Title with Neon Glow
              Text(
                'SAFE SIGHT',
                style: AppTextStyles.neonTitle().copyWith(
                  fontSize: 48,
                  letterSpacing: 3.0,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Subtitle
              Text(
                'SEE DANGER. SHARE SAFETY.',
                style: AppTextStyles.onboardingSubtitle(
                  color: AppColors.inactiveGray,
                ).copyWith(
                  fontSize: 18,
                  letterSpacing: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 3),
              
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'GET STARTED',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationOptionsScreen(),
                      ),
                    );
                  },
                  isPrimary: true,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Login Button for existing users
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'LOGIN',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  color: AppColors.neonGreen,
                  isPrimary: false,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Subtext
              Text(
                'Campus-verified safety network',
                style: AppTextStyles.smallText(),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}