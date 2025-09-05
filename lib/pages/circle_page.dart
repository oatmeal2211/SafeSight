import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

// Data models for the prototype
class TrustedContact {
  final String name;
  final String status; // 'Safe', 'Missed', etc.
  final Color statusColor;

  TrustedContact({
    required this.name,
    required this.status,
    required this.statusColor,
  });
}

class CheckInHistory {
  final String time;
  final String date;

  CheckInHistory({required this.time, required this.date});
}

class ReportSummary {
  final String type;
  final String description;
  final String time;
  final String location;
  final Color statusColor;

  ReportSummary({
    required this.type,
    required this.description,
    required this.time,
    required this.location,
    required this.statusColor,
  });
}

class CirclePage extends StatefulWidget {
  const CirclePage({super.key});

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage> {
  // Sample data for the prototype
  final List<TrustedContact> trustedContacts = [
    TrustedContact(name: 'Emma Johnson', status: 'Safe', statusColor: AppColors.neonGreen),
    TrustedContact(name: 'Alex Smith', status: 'Missed', statusColor: AppColors.neonRed),
    TrustedContact(name: 'Sarah Williams', status: 'Safe', statusColor: AppColors.neonGreen),
    TrustedContact(name: 'David Brown', status: 'Safe', statusColor: AppColors.neonGreen),
  ];

  final List<CheckInHistory> checkInHistory = [
    CheckInHistory(time: '9:15 PM', date: 'Today'),
    CheckInHistory(time: '6:25 PM', date: 'Today'),
  ];

  // Sample report data for the prototype
  final List<ReportSummary> recentReports = [
    ReportSummary(
      type: 'Amber Alert',
      description: 'Suspicious person near library',
      time: '2 hours ago',
      location: 'Main Library',
      statusColor: AppColors.neonAmber,
    ),
    ReportSummary(
      type: 'Quick Pin',
      description: 'Broken lamp in parking lot',
      time: '4 hours ago',
      location: 'Lot B',
      statusColor: AppColors.neonBlue,
    ),
    ReportSummary(
      type: 'Witness Report',
      description: 'Incident witnessed',
      time: '1 day ago',
      location: 'Student Center',
      statusColor: AppColors.neonRed,
    ),
  ];

  bool _isCheckingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'CIRCLE',
          style: AppTextStyles.neonButton(color: AppColors.neonBlue),
        ),
        centerTitle: true,
      ),
      body: ScanlineBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Send Check-In Now Button
              _buildCheckInButton(),
              
              const SizedBox(height: 24),
              
              // Trusted Contacts List
              _buildTrustedContacts(),
              
              const SizedBox(height: 24),
              
              // Auto Check-Ins Section
              _buildAutoCheckIns(),
              
              const SizedBox(height: 24),
              
              // Recent Reports Section
              _buildRecentReports(),
              
              const SizedBox(height: 24),
              
              // Check-In History
              _buildCheckInHistory(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckInButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: _isCheckingIn ? null : _sendCheckIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: AppColors.neonGreen,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isCheckingIn
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Sending...',
                    style: AppTextStyles.neonButton(color: AppColors.neonGreen),
                  ),
                ],
              )
            : Text(
                'Send Check-In Now',
                style: AppTextStyles.neonButton(color: AppColors.neonGreen),
              ),
      ),
    );
  }

  Widget _buildTrustedContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trusted Contacts',
          style: AppTextStyles.neonSubtitle(color: AppColors.neonBlue),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 300, // Set a maximum height for the contacts list
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: trustedContacts.length,
            itemBuilder: (context, index) {
              final contact = trustedContacts[index];
              return _buildContactCard(contact);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(TrustedContact contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.inactiveGray.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neonGreen,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person,
              color: AppColors.neonGreen,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Contact Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: AppTextStyles.bodyText(color: AppColors.neonGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.status,
                  style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
                ),
              ],
            ),
          ),
          
          // Status Indicator
          Text(
            contact.status,
            style: AppTextStyles.neonButton(color: contact.statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCheckIns() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Auto Check-Ins',
          style: AppTextStyles.neonSubtitle(color: AppColors.neonBlue),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.inactiveGray.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 hour ago',
                    style: AppTextStyles.bodyText(color: AppColors.neonAmber),
                  ),
                  Icon(
                    Icons.access_time,
                    color: AppColors.neonAmber,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last auto check-in completed successfully',
                style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: AppTextStyles.neonSubtitle(color: AppColors.neonBlue),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recentReports.length,
            itemBuilder: (context, index) {
              final report = recentReports[index];
              return _buildReportCard(report);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(ReportSummary report) {
    IconData getReportIcon() {
      switch (report.type) {
        case 'Amber Alert':
          return Icons.warning;
        case 'Quick Pin':
          return Icons.push_pin;
        case 'Witness Report':
          return Icons.visibility;
        default:
          return Icons.report;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.inactiveGray.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Report Type Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: report.statusColor.withValues(alpha: 0.2),
              border: Border.all(
                color: report.statusColor,
                width: 1.5,
              ),
            ),
            child: Icon(
              getReportIcon(),
              color: report.statusColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Report Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      report.type,
                      style: AppTextStyles.bodyText(color: report.statusColor),
                    ),
                    Text(
                      report.time,
                      style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  report.description,
                  style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppColors.inactiveGray,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      report.location,
                      style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Check-Ins',
          style: AppTextStyles.neonButton(color: AppColors.inactiveGray),
        ),
        const SizedBox(height: 12),
        ...checkInHistory.map((history) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${history.date}, ${history.time}',
                style: AppTextStyles.cctvText(color: AppColors.inactiveGray),
              ),
              Icon(
                Icons.check_circle_outline,
                color: AppColors.neonGreen,
                size: 16,
              ),
            ],
          ),
        )),
      ],
    );
  }

  void _sendCheckIn() {
    setState(() {
      _isCheckingIn = true;
    });

    // Simulate network call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCheckingIn = false;
          // Add new check-in to history
          checkInHistory.insert(0, CheckInHistory(
            time: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} ${DateTime.now().hour >= 12 ? 'PM' : 'AM'}',
            date: 'Today',
          ));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Check-in sent to your safety circle',
              style: AppTextStyles.bodyText(color: AppColors.background),
            ),
            backgroundColor: AppColors.neonGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}
