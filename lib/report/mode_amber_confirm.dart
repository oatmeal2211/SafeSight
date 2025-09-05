import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vibration/vibration.dart';
import '../constants/app_theme.dart';
import '../services/case_service.dart';
import 'shared_widgets.dart';

class ModeAmberConfirm extends StatelessWidget {
  const ModeAmberConfirm({Key? key}) : super(key: key);

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
      appBar: AppBar(
        title: Text(
          'AMBER ALERT',
          style: AppTextStyles.neonTitle(color: AppColors.neonRed),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.neonRed),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MetaStrip(showRecording: true),
            Padding(
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
                    'This will notify security &\nnearby students.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ).copyWith(fontSize: 18),
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
          ],
        ),
      ),
    );
  }
}
