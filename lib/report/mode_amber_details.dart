import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../models/report_models.dart';
import '../models/media_file.dart';
import '../services/case_service.dart';
import '../services/location_service.dart';
import '../services/media_service.dart';
import 'shared_widgets.dart';
import 'location_info.dart';

class ModeAmberDetails extends StatefulWidget {
  final String caseId;

  const ModeAmberDetails({super.key, required this.caseId});

  @override
  State<ModeAmberDetails> createState() => _ModeAmberDetailsState();
}

class _ModeAmberDetailsState extends State<ModeAmberDetails> {
  final _noteController = TextEditingController();
  final _picker = ImagePicker();
  
  PrivacyMode _privacyMode = PrivacyMode.anonymous;
  List<MediaFile> _mediaFiles = [];
  Map<String, dynamic>? _locationData;
  
  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final data = await LocationService.getLocationData();
    if (mounted) {
      setState(() {
        _locationData = data;
      });
    }
  }

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

  Future<void> _saveDetails() async {
    try {
      await CaseService.updateAmberCase(
        widget.caseId,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        privacy: _privacyMode,
        mediaFiles: _mediaFiles.map((m) => m.filePath).toList(),
      );

      Fluttertoast.showToast(
        msg: "Details saved",
        backgroundColor: AppColors.neonGreen,
        textColor: AppColors.background,
      );

      if (mounted) {
        // Return to main screen
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to save details",
        backgroundColor: AppColors.neonRed,
        textColor: AppColors.white,
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodyText(color: AppColors.neonGreen),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyText(),
            ),
          ),
        ],
      ),
    );
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
                        'AMBER ALERT DETAILS',
                        style: AppTextStyles.neonTitle(color: AppColors.neonRed).copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Location info
              LocationInfo(color: AppColors.neonRed),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Auto-filled information
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.neonRed.withOpacity(0.3),
                            width: 1,
                          ),
                          color: AppColors.neonRed.withOpacity(0.05),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUTO-FILLED INFO',
                              style: AppTextStyles.neonButton(color: AppColors.neonRed).copyWith(
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_locationData != null) ...[
                              _buildInfoRow('Time', _locationData!['timestamp']),
                              _buildInfoRow('Coordinates', _locationData!['coordinates']),
                              _buildInfoRow('Nearest landmark', _locationData!['landmark']),
                            ] else ...[
                              const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.neonRed,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Optional description
                      Text(
                        'Describe why you feel unsafe...',
                        style: AppTextStyles.bodyText(color: AppColors.neonRed),
                      ),
                      const SizedBox(height: 8),
                      NeonTextField(
                        label: 'Additional Details',
                        hint: 'Optional additional details',
                        controller: _noteController,
                        maxLines: 3,
                        color: AppColors.neonRed,
                      ),
                      const SizedBox(height: 24),
                      // Media row
                      MediaRow(
                        mediaFiles: _mediaFiles,
                        onAddPhoto: _pickPhoto,
                        onAddVideo: _pickVideo,
                        onRemove: (index) {
                          setState(() {
                            _mediaFiles.removeAt(index);
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      // Privacy mode
                      Text(
                        'Privacy Mode',
                        style: AppTextStyles.bodyText(color: AppColors.neonRed),
                      ),
                      const SizedBox(height: 8),
                      NeonSegmented<PrivacyMode>(
                        value: _privacyMode,
                        options: [PrivacyMode.anonymous, PrivacyMode.pseudonymous, PrivacyMode.identified],
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
                        color: AppColors.neonRed,
                      ),
                      const SizedBox(height: 40),
                      // Save button
                      SizedBox(
                        width: double.infinity,
                        child: NeonButton(
                          text: 'Save',
                          color: AppColors.neonRed,
                          filled: true,
                          onPressed: _saveDetails,
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
