import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_theme.dart';
import '../services/safe_word_service.dart';

class SafeWordConfigPage extends StatefulWidget {
  const SafeWordConfigPage({super.key});

  @override
  State<SafeWordConfigPage> createState() => _SafeWordConfigPageState();
}

class _SafeWordConfigPageState extends State<SafeWordConfigPage> {
  final TextEditingController _customWordController = TextEditingController();
  String? _selectedWord;
  List<String> _recordings = [];
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  bool _isProcessing = false;

  final List<String> _predefinedWords = [
    'Guardian',
    'Sentinel',
    'Beacon',
    'Shield',
    'Haven',
  ];

  @override
  void initState() {
    super.initState();
    _handleMicrophonePermission();
  }

  @override
  void dispose() {
    _customWordController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      // This triggers the native Android dialog
      status = await Permission.microphone.request();
    }

    if (status.isGranted) {
      debugPrint("🎤 Microphone permission granted!");
    } else if (status.isPermanentlyDenied) {
      // User selected "Don't ask again"
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Microphone Permission Required',
            style: AppTextStyles.neonTitle(color: AppColors.neonRed),
          ),
          content: Text(
            'Please enable microphone access in Settings to use the safe word feature.',
            style: AppTextStyles.bodyText(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyText(color: AppColors.neonRed),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: Colors.black,
              ),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _startRecording() async {
    if (_selectedWord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select or enter a safe word first',
            style: AppTextStyles.bodyText(color: AppColors.neonRed),
          ),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }

    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _recordingDuration++;
        });
        if (_recordingDuration >= 3) {
          _stopRecording();
        }
      },
    );

    // Start actual recording
    await SafeWordService.startRecording();
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
    });

    final recordingPath = await SafeWordService.stopRecording();
    if (recordingPath != null) {
      setState(() {
        _recordings.add(recordingPath);
      });
    }

    if (_recordings.length == 3) {
      setState(() {
        _isProcessing = true;
      });
      
      try {
        await SafeWordService.processSafeWord(
          word: _selectedWord!,
          recordings: _recordings,
        );
        
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Safe word configured successfully!',
              style: AppTextStyles.bodyText(color: AppColors.neonGreen),
            ),
            backgroundColor: Colors.black,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error configuring safe word: $e',
              style: AppTextStyles.bodyText(color: AppColors.neonRed),
            ),
            backgroundColor: Colors.black,
          ),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SAFE WORD SETUP',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.neonGreen.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HOW IT WORKS',
                    style: AppTextStyles.neonTitle(color: AppColors.neonGreen),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Choose a safe word or enter your own\n'
                    '2. Record your safe word 3 times\n'
                    '3. In an emergency, say your safe word to trigger SOS\n'
                    '4. The app will capture audio, photos, and video',
                    style: AppTextStyles.bodyText(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Predefined words
            Text(
              'SELECT A SAFE WORD',
              style: AppTextStyles.neonSubtitle(color: AppColors.neonGreen),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _predefinedWords.map((word) {
                final isSelected = _selectedWord == word;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedWord = word;
                      _customWordController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.neonGreen.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? AppColors.neonGreen : AppColors.neonGreen.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      word,
                      style: AppTextStyles.bodyText(
                        color: isSelected ? AppColors.neonGreen : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Custom word input
            Text(
              'OR ENTER YOUR OWN',
              style: AppTextStyles.neonSubtitle(color: AppColors.neonGreen),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customWordController,
              style: AppTextStyles.bodyText(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter custom safe word',
                hintStyle: AppTextStyles.bodyText(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.neonGreen.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.neonGreen,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _selectedWord = value.isNotEmpty ? value : null;
                });
              },
            ),
            const SizedBox(height: 32),
            
            // Recording section
            if (_selectedWord != null) ...[
              Text(
                'RECORD YOUR SAFE WORD',
                style: AppTextStyles.neonSubtitle(color: AppColors.neonGreen),
              ),
              const SizedBox(height: 8),
              Text(
                'Record "${_selectedWord}" ${3 - _recordings.length} more times',
                style: AppTextStyles.bodyText(color: Colors.white),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTapDown: (_) => _startRecording(),
                  onTapUp: (_) => _stopRecording(),
                  onTapCancel: () => _stopRecording(),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? AppColors.neonRed : Colors.transparent,
                      border: Border.all(
                        color: _isRecording ? AppColors.neonRed : AppColors.neonGreen,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? AppColors.neonRed : AppColors.neonGreen).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.white : AppColors.neonGreen,
                      size: 32,
                    ),
                  ),
                ),
              ),
              if (_isRecording)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Recording: $_recordingDuration seconds',
                    style: AppTextStyles.bodyText(color: AppColors.neonRed),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final isRecorded = index < _recordings.length;
                  return Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecorded ? AppColors.neonGreen : Colors.transparent,
                      border: Border.all(
                        color: AppColors.neonGreen.withOpacity(0.3),
                      ),
                    ),
                  );
                }),
              ),
            ],
            
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.neonGreen),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MicrophonePermissionDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: Color(0xFF39FF14), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic,
              color: Color(0xFF39FF14),
              size: 48.0,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Microphone Permission',
              textAlign: TextAlign.center,
              style: AppTextStyles.neonTitle(color: AppColors.neonGreen).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            Text(
              'SafeSight needs microphone access to set up your safe word for voice activation.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText(color: Colors.white),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Deny',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF39FF14),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Allow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionPermanentlyDeniedDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.neonRed, width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.mic_off,
              color: AppColors.neonRed,
              size: 48.0,
            ),
            const SizedBox(height: 24.0),
            Text(
              'Permission Denied',
              textAlign: TextAlign.center,
              style: AppTextStyles.neonTitle(color: AppColors.neonRed).copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            Text(
              'You have permanently denied microphone access. To use this feature, please enable it in your device settings.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText(color: Colors.white),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonRed,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
