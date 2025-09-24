import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _emailController.text.isNotEmpty && 
                    _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              const Spacer(flex: 1),
              
              // Welcome title
              Text(
                'WELCOME BACK',
                style: AppTextStyles.neonTitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Email input
              NeonInputField(
                hintText: 'Enter campus email',
                labelText: 'Campus Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 24),
              
              // Password input
              NeonInputField(
                hintText: 'Enter password / verification code',
                labelText: 'Password',
                controller: _passwordController,
                obscureText: true,
              ),
              
              const SizedBox(height: 32),
              
              // Login button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'LOGIN',
                  onPressed: _isFormValid ? () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScaffold(),
                      ),
                      (route) => false,
                    );
                  } : () {},
                  color: _isFormValid ? AppColors.neonGreen : AppColors.inactiveGray,
                  isPrimary: _isFormValid,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Forgot password
              TextButton(
                onPressed: () {
                  _showForgotPasswordDialog();
                },
                child: Text(
                  'FORGOT PASSWORD?',
                  style: AppTextStyles.smallText(color: AppColors.inactiveGray),
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
              
              // SSO button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'CONTINUE WITH UNIVERSITY SSO',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScaffold(),
                      ),
                      (route) => false,
                    );
                  },
                  color: AppColors.neonGreen,
                  isPrimary: false,
                  isOutlined: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const Spacer(flex: 2),
              
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
                      'DEMO MODE',
                      style: AppTextStyles.neonButton(color: AppColors.neonGreen).copyWith(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Use any credentials to continue',
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

  void _showForgotPasswordDialog() {
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
                  Icons.mail_outline,
                  color: AppColors.neonGreen,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'PASSWORD RESET',
                  style: AppTextStyles.neonButton(color: AppColors.neonGreen),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Reset link sent to your campus email',
                  style: AppTextStyles.smallText(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'OK',
                    onPressed: () => Navigator.of(context).pop(),
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