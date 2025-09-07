import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import '../constants/app_theme.dart';
import '../services/case_service.dart';
import 'shared_widgets.dart';

class ModeAmberConfirm extends StatelessWidget {
  final String caseId;

  const ModeAmberConfirm({super.key, required this.caseId});

  Future<void> _sendAmberAlert(BuildContext context) async {
    // Haptic feedback and vibration
    HapticFeedback.heavyImpact();
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 200);
    }

    try {
      // Create amber case
      final caseId = await CaseService.createAmberCase();
      
      // Show toast
      Fluttertoast.showToast(
        msg: "Amber alert sent",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppColors.neonAmber,
        textColor: AppColors.background,
        fontSize: 16.0,
      );

      // Navigate to details page
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/report/amber/details',
          arguments: caseId,
        );
      }
    } catch (e) {
      // Show error toast
      Fluttertoast.showToast(
        msg: "Failed to send alert. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.neonRed,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.neonRed,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'AMBER ALERT',
                        style: AppTextStyles.neonTitle(color: AppColors.neonRed).copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Location info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.neonRed.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: AppColors.neonRed.withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Near Library • 40.7306° N, 73.9352° W',
                        style: AppTextStyles.cctvText(color: AppColors.neonRed),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Send\nAmber Alert?',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.neonTitle(color: AppColors.neonRed).copyWith(
                          fontSize: 48,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'This action is irreversible and will immediately notify campus security.',
                        style: AppTextStyles.bodyText(
                          color: AppColors.white.withOpacity(0.8),
                        ).copyWith(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 80),
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          text: 'Send Amber Alert',
                          color: AppColors.neonRed,
                          filled: true,
                          onPressed: () => _sendAmberAlert(context),
                          icon: Icons.emergency,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          text: 'Cancel',
                          color: AppColors.inactiveGray,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
