import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_theme.dart';
import '../models/report_models.dart';
import '../services/case_service.dart';
import 'shared_widgets.dart';

class ModeQuickPin extends StatefulWidget {
  const ModeQuickPin({Key? key}) : super(key: key);

  @override
  State<ModeQuickPin> createState() => _ModeQuickPinState();
}

class _ModeQuickPinState extends State<ModeQuickPin> {
  final _noteController = TextEditingController();
  
  QuickReportCategory? _selectedCategory;
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (_selectedCategory == null) {
      Fluttertoast.showToast(
        msg: "Please select a category",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      HapticFeedback.lightImpact();
      
      await CaseService.createQuickPin(
        category: _selectedCategory!,
        description: _noteController.text.trim().isEmpty 
            ? null 
            : _noteController.text.trim(),
      );

      Fluttertoast.showToast(
        msg: "Thanks! Your report helps make campus safer.",
        backgroundColor: AppColors.neonGreen,
        textColor: AppColors.background,
        toastLength: Toast.LENGTH_LONG,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to submit report",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildCategoryChip(QuickReportCategory category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.neonGreen : AppColors.inactiveGray,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.neonGreen.withOpacity(0.1) : null,
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.neonGreen.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getCategoryIcon(category),
              color: isSelected ? AppColors.neonGreen : AppColors.inactiveGray,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category.displayName,
              style: AppTextStyles.bodyText(
                color: isSelected ? AppColors.neonGreen : AppColors.inactiveGray,
              ).copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                shadows: isSelected ? neonGlow(AppColors.neonGreen, blur: 6) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(QuickReportCategory category) {
    switch (category) {
      case QuickReportCategory.brokenLamp:
        return Icons.lightbulb_outline;
      case QuickReportCategory.darkCorridor:
        return Icons.visibility_off;
      case QuickReportCategory.creepyPerson:
        return Icons.person_outline;
      case QuickReportCategory.noise:
        return Icons.volume_up;
      case QuickReportCategory.other:
        return Icons.more_horiz;
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
                          color: AppColors.neonGreen,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.neonGreen,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.videocam,
                            color: AppColors.neonGreen.withOpacity(0.6),
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Near Library\n40.7306° N, 73.9352° W',
                            style: AppTextStyles.cctvText(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'REPORT ISSUE',
                    style: AppTextStyles.neonTitle().copyWith(fontSize: 32),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category selection
                      Text(
                        'Category',
                        style: AppTextStyles.bodyText(color: AppColors.neonGreen),
                      ),
                      const SizedBox(height: 12),
                      
                      // Category chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: QuickReportCategory.values
                            .map(_buildCategoryChip)
                            .toList(),
                      ),

                      const SizedBox(height: 32),

                      NeonTextField(
                        label: 'Description (optional)',
                        hint: 'Add additional details...',
                        controller: _noteController,
                        maxLines: 3,
                        color: AppColors.neonGreen,
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          text: _isSubmitting ? 'Submitting...' : 'Submit',
                          color: AppColors.neonGreen,
                          filled: false,
                          onPressed: _isSubmitting ? null : _submitReport,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Info text
                      Center(
                        child: Text(
                          'Thanks! Your report helps make\ncampus safer.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText(
                            color: AppColors.white.withOpacity(0.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
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

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
