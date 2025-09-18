import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../models/report_models.dart';
import '../models/media_file.dart';
import '../services/case_service.dart';
import '../services/media_service.dart';
import 'shared_widgets.dart';
import 'location_info.dart';

class ModeWitnessForm extends StatefulWidget {
  const ModeWitnessForm({super.key});

  @override
  State<ModeWitnessForm> createState() => _ModeWitnessFormState();
}

class _ModeWitnessFormState extends State<ModeWitnessForm> {
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  
  IncidentCategory? _selectedCategory;
  PrivacyMode _privacyMode = PrivacyMode.anonymous;
  final List<MediaFile> _mediaFiles = [];
  bool _isSubmitting = false;

  Future<void> _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        final mediaFile = await MediaService.saveMedia(image.path);
        setState(() {
          _mediaFiles.add(mediaFile);
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
        final mediaFile = await MediaService.saveMedia(video.path);
        setState(() {
          _mediaFiles.add(mediaFile);
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
        mediaFiles: _mediaFiles.map((m) => m.filePath).toList(),
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
              LocationInfo(color: AppColors.neonAmber),

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
