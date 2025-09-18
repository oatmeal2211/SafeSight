import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'campus_verification_screen.dart';

enum UserRole { student, faculty, security }

class ChooseRoleScreen extends StatefulWidget {
  const ChooseRoleScreen({super.key});

  @override
  State<ChooseRoleScreen> createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  UserRole _selectedRole = UserRole.student;

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
                'SELECT YOUR ROLE',
                style: AppTextStyles.onboardingTitle(),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Role selection buttons
              RoleSelectionButton(
                title: 'STUDENT',
                icon: Icons.school,
                isSelected: _selectedRole == UserRole.student,
                onPressed: () {
                  setState(() {
                    _selectedRole = UserRole.student;
                  });
                },
              ),
              
              RoleSelectionButton(
                title: 'FACULTY / STAFF',
                icon: Icons.person,
                isSelected: _selectedRole == UserRole.faculty,
                onPressed: () {
                  setState(() {
                    _selectedRole = UserRole.faculty;
                  });
                },
              ),
              
              RoleSelectionButton(
                title: 'CAMPUS SECURITY',
                icon: Icons.security,
                isSelected: _selectedRole == UserRole.security,
                onPressed: () {
                  setState(() {
                    _selectedRole = UserRole.security;
                  });
                },
              ),
              
              const SizedBox(height: 32),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: NeonButton(
                  text: 'CONTINUE',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CampusVerificationScreen(
                          selectedRole: _selectedRole,
                        ),
                      ),
                    );
                  },
                  isPrimary: true,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              
              const Spacer(),
              
              // Subtext
              Text(
                'Role affects what you can see/do in the app',
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