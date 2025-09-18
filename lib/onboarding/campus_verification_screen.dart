import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'choose_role_screen.dart';
import 'onboarding_flow_screen.dart';

class CampusVerificationScreen extends StatefulWidget {
  final UserRole selectedRole;
  
  const CampusVerificationScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<CampusVerificationScreen> createState() => _CampusVerificationScreenState();
}

class _CampusVerificationScreenState extends State<CampusVerificationScreen> {
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.neonGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'CAMPUS VERIFICATION REQUIRED',
                style: AppTextStyles.onboardingTitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Primary verification button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'VERIFY WITH UNIVERSITY SSO / .EDU EMAIL',
                  onPressed: () {
                    _showVerificationDialog(context, 'SSO Verification');
                  },
                  isPrimary: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Secondary verification button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'VERIFY VIA CAMPUS WI-FI / GPS',
                  onPressed: () {
                    _showVerificationDialog(context, 'Campus Network Verification');
                  },
                  color: AppColors.neonGreen,
                  isPrimary: false,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Student ID Input (optional)
              NeonInputField(
                hintText: 'Enter Student ID (optional)',
                labelText: 'Student ID',
                controller: _studentIdController,
                keyboardType: TextInputType.text,
              ),
              
              const Spacer(),
              
              // Demo info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'FOR DEMO:',
                      style: AppTextStyles.neonButton(color: AppColors.neonGreen).copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use test@university.edu to continue',
                      style: AppTextStyles.smallText(color: AppColors.neonGreen),
                      textAlign: TextAlign.center,
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

  void _showVerificationDialog(BuildContext context, String method) {
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
                  Icons.check_circle,
                  color: AppColors.neonGreen,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'VERIFICATION SUCCESSFUL',
                  style: AppTextStyles.neonButton(color: AppColors.neonGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Using $method',
                  style: AppTextStyles.smallText(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'CONTINUE',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingFlowScreen(
                            selectedRole: widget.selectedRole,
                          ),
                        ),
                      );
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
}