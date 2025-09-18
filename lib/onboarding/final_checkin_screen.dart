import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../main.dart';

class FinalCheckinScreen extends StatelessWidget {
  const FinalCheckinScreen({super.key});

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
              
              // Success icon with glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.neonGreen, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AppColors.neonGreen.withOpacity(0.3),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.check,
                    color: AppColors.neonGreen,
                    size: 60,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Success title
              Text(
                'REGISTRATION COMPLETE ✅',
                style: AppTextStyles.neonTitle().copyWith(
                  fontSize: 32,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Welcome message
              Text(
                'Welcome to your campus safety network',
                style: AppTextStyles.onboardingSubtitle(),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 2),
              
              // Check-in button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'SEND FIRST CHECK-IN',
                  onPressed: () {
                    _showCheckInDialog(context);
                  },
                  isPrimary: true,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Skip button
              TextButton(
                onPressed: () {
                  _enterMainApp(context);
                },
                child: Text(
                  'SKIP FOR NOW',
                  style: AppTextStyles.smallText(color: AppColors.inactiveGray),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Info panel
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppColors.neonGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your safety network is now active',
                            style: AppTextStyles.onboardingSubtitle(color: AppColors.neonGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Quick emergency reporting\n• Real-time campus alerts\n• Anonymous safety sharing\n• 24/7 security connection',
                      style: AppTextStyles.smallText(),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showCheckInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.neonGreen, width: 1),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neonGreen.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.neonGreen,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'CHECK-IN SENT',
                  style: AppTextStyles.neonButton(color: AppColors.neonGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your location has been shared with your safety circle',
                  style: AppTextStyles.smallText(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'ENTER APP',
                    onPressed: () {
                      Navigator.of(context).pop();
                      _enterMainApp(context);
                    },
                    isPrimary: true,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _enterMainApp(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScaffold(),
      ),
      (route) => false,
    );
  }
}