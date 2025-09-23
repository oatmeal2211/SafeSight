import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'choose_role_screen.dart';
import 'login_screen.dart';

enum OnboardingStep { campusSetup, languagePreference, privacyDefaults }
enum Language { english, malay, chinese, hindi }
enum PrivacyMode { anonymous, pseudonymous, identified }

class OnboardingFlowScreen extends StatefulWidget {
  final UserRole selectedRole;
  
  const OnboardingFlowScreen({
    super.key,
    required this.selectedRole,
  });

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  OnboardingStep _currentStep = OnboardingStep.campusSetup;
  Language _selectedLanguage = Language.english;
  PrivacyMode _selectedPrivacyMode = PrivacyMode.anonymous;
  final TextEditingController _universityController = TextEditingController();

  @override
  void dispose() {
    _universityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      switch (_currentStep) {
        case OnboardingStep.campusSetup:
          _currentStep = OnboardingStep.languagePreference;
          break;
        case OnboardingStep.languagePreference:
          _currentStep = OnboardingStep.privacyDefaults;
          break;
        case OnboardingStep.privacyDefaults:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
          break;
      }
    });
  }

  void _previousStep() {
    setState(() {
      switch (_currentStep) {
        case OnboardingStep.campusSetup:
          Navigator.pop(context);
          break;
        case OnboardingStep.languagePreference:
          _currentStep = OnboardingStep.campusSetup;
          break;
        case OnboardingStep.privacyDefaults:
          _currentStep = OnboardingStep.languagePreference;
          break;
      }
    });
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
          onPressed: _previousStep,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildCurrentStep(),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case OnboardingStep.campusSetup:
        return _buildCampusSetup();
      case OnboardingStep.languagePreference:
        return _buildLanguagePreference();
      case OnboardingStep.privacyDefaults:
        return _buildPrivacyDefaults();
    }
  }

  Widget _buildCampusSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Title
        Text(
          'CAMPUS SETUP',
          style: AppTextStyles.onboardingTitle(),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 32),
        
        // Auto-detect message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.neonGreen,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Auto-detecting campus via GPS...',
                  style: AppTextStyles.onboardingSubtitle(color: AppColors.neonGreen),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Search input
        NeonInputField(
          hintText: 'Search your university...',
          labelText: 'University Name',
          controller: _universityController,
        ),
        
        const SizedBox(height: 32),
        
        // Mock campus map
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neonGreen, width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        color: AppColors.neonGreen.withOpacity(0.6),
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CAMPUS MAP',
                        style: AppTextStyles.neonButton(color: AppColors.neonGreen),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'AEDs • Dorms • Blue-light phones',
                        style: AppTextStyles.smallText(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'CONTINUE',
            onPressed: _nextStep,
            isPrimary: true,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLanguagePreference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Title
        Text(
          'PREFERRED LANGUAGE',
          style: AppTextStyles.onboardingTitle(),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Language options
        _buildLanguageOption('ENGLISH', Language.english),
        _buildLanguageOption('MALAY', Language.malay),
        _buildLanguageOption('中文', Language.chinese),
        _buildLanguageOption('हिंदी', Language.hindi),
        
        const Spacer(),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'CONTINUE',
            onPressed: _nextStep,
            isPrimary: true,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLanguageOption(String text, Language language) {
    final isSelected = _selectedLanguage == language;
    final color = isSelected ? AppColors.neonGreen : AppColors.inactiveGray;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.neonGreen.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: color,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.neonGreen.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLanguage = language;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: AppTextStyles.neonButton(color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyDefaults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        
        // Title
        Text(
          'YOUR PRIVACY MODE',
          style: AppTextStyles.onboardingTitle(),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 40),
        
        // Privacy options
        _buildPrivacyOption('🔒 ANONYMOUS', PrivacyMode.anonymous, 'Reports are completely anonymous'),
        _buildPrivacyOption('🟡 PSEUDONYMOUS', PrivacyMode.pseudonymous, 'Reports use a nickname'),
        _buildPrivacyOption('🟢 IDENTIFIED', PrivacyMode.identified, 'Reports show your name'),
        
        const SizedBox(height: 32),
        
        Text(
          'Change anytime in Settings',
          style: AppTextStyles.smallText(),
          textAlign: TextAlign.center,
        ),
        
        const Spacer(),
        
        // Continue button
        SizedBox(
          width: double.infinity,
          child: NeonButton(
            text: 'COMPLETE SETUP',
            onPressed: _nextStep,
            isPrimary: true,
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPrivacyOption(String text, PrivacyMode mode, String description) {
    final isSelected = _selectedPrivacyMode == mode;
    final color = isSelected ? AppColors.neonGreen : AppColors.inactiveGray;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.neonGreen.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: color,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected ? [
          BoxShadow(
            color: AppColors.neonGreen.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPrivacyMode = mode;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: AppTextStyles.neonButton(color: color),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.smallText(color: color.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}