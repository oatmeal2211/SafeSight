import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'verification_code_screen.dart';
import 'choose_role_screen.dart';

class RegistrationOptionsScreen extends StatefulWidget {
  const RegistrationOptionsScreen({super.key});

  @override
  State<RegistrationOptionsScreen> createState() => _RegistrationOptionsScreenState();
}

class _RegistrationOptionsScreenState extends State<RegistrationOptionsScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text;
    setState(() {
      _isEmailValid = email.contains('@') && email.contains('.edu');
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Title
              Text(
                'CREATE YOUR ACCOUNT',
                style: AppTextStyles.onboardingTitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Email Input
              NeonInputField(
                hintText: 'Enter campus email (@university.edu)',
                labelText: 'Campus Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 24),
              
              // Send Code Button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'SEND CODE',
                  onPressed: _isEmailValid ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerificationCodeScreen(
                          email: _emailController.text,
                        ),
                      ),
                    );
                  } : () {},
                  color: _isEmailValid ? AppColors.neonGreen : AppColors.inactiveGray,
                  isPrimary: _isEmailValid,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.inactiveGray.withOpacity(0.3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: AppTextStyles.onboardingSubtitle(),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: AppColors.inactiveGray.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // SSO Button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'CONTINUE WITH UNIVERSITY SSO',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChooseRoleScreen(),
                      ),
                    );
                  },
                  color: AppColors.neonGreen,
                  isPrimary: false,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const Spacer(),
              
              // Subtext
              Text(
                'Only verified campus accounts may join the network',
                style: AppTextStyles.smallText(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}