import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'shared_widgets.dart';

class WitnessSuccessPage extends StatelessWidget {
  final String caseId;

  const WitnessSuccessPage({super.key, required this.caseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScanlineBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success check icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neonGreen,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.neonGreen,
                    size: 60,
                  ),
                ),

                const SizedBox(height: 40),

                // Success message
                Text(
                  'Report submitted',
                  style: AppTextStyles.neonTitle().copyWith(fontSize: 32),
                ),

                const SizedBox(height: 16),

                Text(
                  'Security has been notified.',
                  style: AppTextStyles.bodyText().copyWith(fontSize: 18),
                ),

                const SizedBox(height: 40),

                // Case ID
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.neonGreen.withOpacity(0.3),
                      width: 1,
                    ),
                    color: AppColors.neonGreen.withOpacity(0.05),
                  ),
                  child: Text(
                    caseId,
                    style: AppTextStyles.neonButton().copyWith(
                      fontSize: 20,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Back to map button
                SizedBox(
                  width: double.infinity,
                  child: NeonButton(
                    text: 'Back to Map',
                    color: AppColors.neonGreen,
                    filled: false,
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
