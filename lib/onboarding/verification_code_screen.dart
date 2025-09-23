import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import 'choose_role_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  
  const VerificationCodeScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _code = '';

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() => _updateCode());
    }
  }

  void _updateCode() {
    setState(() {
      _code = _controllers.map((controller) => controller.text).join();
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
                'ENTER VERIFICATION CODE',
                style: AppTextStyles.onboardingTitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Email display
              Text(
                'Code sent to ${widget.email}',
                style: AppTextStyles.onboardingSubtitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Code input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 60,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _controllers[index].text.isNotEmpty 
                              ? AppColors.neonGreen 
                              : AppColors.inactiveGray.withOpacity(0.5),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _controllers[index].text.isNotEmpty ? [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ] : null,
                      ),
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: AppTextStyles.neonButton(color: AppColors.white).copyWith(fontSize: 24),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: "",
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 40),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'VERIFY CODE',
                  onPressed: _code.length == 6 ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChooseRoleScreen(),
                      ),
                    );
                  } : () {},
                  color: _code.length == 6 ? AppColors.neonGreen : AppColors.inactiveGray,
                  isPrimary: _code.length == 6,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Resend button
              TextButton(
                onPressed: () {
                  // Mock resend functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'New code sent to ${widget.email}',
                        style: AppTextStyles.bodyText(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.neonGreen.withOpacity(0.2),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Text(
                  'RESEND CODE',
                  style: AppTextStyles.neonButton(color: AppColors.inactiveGray),
                ),
              ),
              
              const Spacer(),
              
              // Demo hint
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neonGreen.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'For demo: Use any 6-digit code',
                  style: AppTextStyles.smallText(color: AppColors.neonGreen),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}