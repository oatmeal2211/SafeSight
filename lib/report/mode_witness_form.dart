import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../models/report_models.dart';
import '../services/case_service.dart';
import 'shared_widgets.dart';

class ModeWitnessForm extends StatefulWidget {
  const ModeWitnessForm({Key? key}) : super(key: key);

  @override
  State<ModeWitnessForm> createState() => _ModeWitnessFormState();
}

class _ModeWitnessFormState extends State<ModeWitnessForm> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  
  IncidentCategory? _selectedCategory;
  PrivacyMode _privacyMode = PrivacyMode.anonymous;
  List<String> _mediaFiles = [];
  bool _isSubmitting = false;

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          _mediaFiles.add(image.path);
        });
        Fluttertoast.showToast(
          msg: "Photo captured",
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to capture photo",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
      if (video != null) {
        setState(() {
          _mediaFiles.add(video.path);
        });
        Fluttertoast.showToast(
          msg: "Video recorded",
          backgroundColor: AppColors.neonGreen,
          textColor: AppColors.background,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to record video",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );
    }
  }

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
      HapticFeedback.mediumImpact();
      
      final caseId = await CaseService.createWitnessCase(
        category: _selectedCategory!,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        privacyMode: _privacyMode,
        mediaFiles: _mediaFiles,
      );

      Fluttertoast.showToast(
        msg: "Security notified - stay away",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context, 
          '/report/witness/success',
          arguments: caseId,
        );
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
                          color: AppColors.neonAmber,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.neonAmber,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'SERIOUS INCIDENT REPORT',
                        style: AppTextStyles.neonTitle(color: AppColors.neonAmber).copyWith(
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
                      color: AppColors.neonAmber.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.videocam,
                        color: AppColors.neonAmber.withValues(alpha: 0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Near Library • 40.7306° N, 73.9352° W',
                        style: AppTextStyles.cctvText(color: AppColors.neonAmber),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeonDropdown<IncidentCategory>(
                        label: 'Category *',
                        value: _selectedCategory,
                        color: AppColors.neonAmber,
                        items: IncidentCategory.values,
                        itemToString: (category) => category.displayName,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Description
                      NeonTextField(
                        label: 'Description',
                        hint: 'Add details (clothing, vehicle plate, direction, etc.)',
                        controller: _descriptionController,
                        maxLines: 4,
                        color: AppColors.neonAmber,
                      ),

                      const SizedBox(height: 24),

                      // Media row
                      MediaRow(
                        mediaFiles: _mediaFiles,
                        onAddPhoto: _pickPhoto,
                        onAddVideo: _pickVideo,
                      ),

                      const SizedBox(height: 24),

                      // Privacy mode
                      Text(
                        'Privacy Mode',
                        style: AppTextStyles.bodyText(color: AppColors.neonAmber),
                      ),
                      const SizedBox(height: 8),
                      NeonSegmented<PrivacyMode>(
                        value: _privacyMode,
                        options: PrivacyMode.values,
                        optionToString: (mode) {
                          switch (mode) {
                            case PrivacyMode.anonymous:
                              return 'Anonymous';
                            case PrivacyMode.pseudonymous:
                              return 'Pseudo';
                            case PrivacyMode.identified:
                              return 'Identified';
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            _privacyMode = value;
                          });
                        },
                        color: AppColors.neonAmber,
                      ),

                      const SizedBox(height: 40),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          text: _isSubmitting ? 'Submitting...' : 'Submit Report',
                          color: AppColors.neonAmber,
                          filled: true,
                          onPressed: _isSubmitting ? null : _submitReport,
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
    _descriptionController.dispose();
    super.dispose();
  }
}
