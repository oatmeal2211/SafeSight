import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../models/report_models.dart';
import '../services/case_service.dart';
import '../services/location_service.dart';
import 'shared_widgets.dart';

class ModeAmberDetails extends StatefulWidget {
  final String caseId;

  const ModeAmberDetails({Key? key, required this.caseId}) : super(key: key);

  @override
  State<ModeAmberDetails> createState() => _ModeAmberDetailsState();
}

class _ModeAmberDetailsState extends State<ModeAmberDetails> {
  final _noteController = TextEditingController();
  final _picker = ImagePicker();
  
  PrivacyMode _privacyMode = PrivacyMode.anonymous;
  List<String> _mediaFiles = [];
  Map<String, dynamic>? _locationData;
  
  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    final data = await LocationService.getLocationData();
    setState(() {
      _locationData = data;
    });
  }

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

  Future<void> _saveDetails() async {
    try {
      await CaseService.updateAmberCase(
        widget.caseId,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        privacy: _privacyMode,
        mediaFiles: _mediaFiles,
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
      appBar: AppBar(
        title: Text(
          'Amber Alert Details',
          style: AppTextStyles.neonTitle(color: AppColors.neonRed),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.neonRed),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MetaStrip(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto-filled information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonRed.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      color: AppColors.neonRed.withValues(alpha: 0.05),
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
                    optionToString: (mode) => mode.toString().split('.').last,
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
          ],
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
