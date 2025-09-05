import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import 'shared_widgets.dart';

class ReportHome extends StatelessWidget {
  const ReportHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SAFETY REPORT',
          style: AppTextStyles.neonTitle(),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MetaStrip(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'SELECT REPORT TYPE',
                    style: AppTextStyles.neonSubtitle(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  NeonTile(
                    title: 'AMBER ALERT',
                    subtitle: 'Emergency situation requiring immediate response',
                    icon: Icons.emergency,
                    color: AppColors.neonRed,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pushNamed(context, '/report/amber');
                    },
                  ),
                  NeonTile(
                    title: 'SERIOUS INCIDENT',
                    subtitle: 'Witnessed crime, suspicious activity, or safety concern',
                    icon: Icons.report_problem,
                    color: AppColors.neonAmber,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pushNamed(context, '/report/witness');
                    },
                  ),
                  NeonTile(
                    title: 'QUICK PIN',
                    subtitle: 'Mark location of interest for security awareness',
                    icon: Icons.location_on,
                    color: AppColors.neonGreen,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamed(context, '/report/quick');
                    },
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.neonGreen.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          color: AppColors.neonGreen.withValues(alpha: 0.6),
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All reports are confidential and processed by campus security',
                          style: AppTextStyles.bodyText(
                            color: AppColors.inactiveGray,
                          ).copyWith(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
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
