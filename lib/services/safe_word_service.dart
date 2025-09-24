import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/report_models.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafeWordService {
  static final _audioPlayer = AudioPlayer();
  static String? _currentRecordingPath;
  static bool _isListening = false;
  static Timer? _sosTimer;
  static const _uuid = Uuid();
  static const String _storageKey = 'report_cases';
  static Map<String, ReportCase> _cases = {};
  static bool _isInitialized = false;

  static Future<void> _initializeFromStorage() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? casesJson = prefs.getString(_storageKey);
    
    if (casesJson != null) {
      final List<dynamic> casesList = jsonDecode(casesJson);
      _cases = {
        for (var caseData in casesList)
          caseData['id']: ReportCase.fromJson(caseData)
      };
    }
    
    _isInitialized = true;
  }

  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final casesList = _cases.values.map((c) => c.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(casesList));
  }
  
  // Initialize background listening service
  static Future<void> initializeBackgroundService() async {
    final micPermission = await Permission.microphone.request();
    final notificationPermission = await Permission.notification.request();
    
    if (micPermission.isGranted && notificationPermission.isGranted) {
      // Initialize background service here
      // This will vary based on platform (Android/iOS)
      // You'll need to implement platform-specific code
    }
  }

  // Start recording for safe word setup
  static Future<void> startRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    _currentRecordingPath = '${directory.path}/safeword_${DateTime.now().millisecondsSinceEpoch}.wav';
    
    // Create an empty file to simulate recording
    await File(_currentRecordingPath!).writeAsBytes([]);
  }

  // Stop recording for safe word setup
  static Future<String?> stopRecording() async {
    return _currentRecordingPath;
  }

  // Process and save safe word configuration
  static Future<void> processSafeWord({
    required String word,
    required List<String> recordings,
  }) async {
    // Here you would:
    // 1. Process the recordings to create a voice model
    // 2. Save the model and word for future detection
    // This is a placeholder for the actual implementation
    await Future.delayed(const Duration(seconds: 2));
  }

  // Start background listening
  static Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;
    
    // Implement continuous audio processing here
    // This would involve platform-specific code for background audio processing
  }

  // Stop background listening
  static Future<void> stopListening() async {
    _isListening = false;
    // Clean up any background processes
  }

  // Handle SOS trigger
  static Future<void> triggerSOS() async {
    // Start a 30-second countdown
    _sosTimer = Timer(const Duration(seconds: 30), () async {
      // If not cancelled, proceed with emergency capture
      await _captureEmergencyData();
    });
  }

  // Cancel SOS countdown
  static void cancelSOS() {
    _sosTimer?.cancel();
  }

  // Capture emergency data (photos, video, audio)
  static Future<void> _captureEmergencyData() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now();
      final reportId = _uuid.v4();
      
      // Create report directory
      final reportDir = Directory('${directory.path}/reports/$reportId');
      await reportDir.create(recursive: true);

      // Record 10s audio
      final audioPath = '${reportDir.path}/audio.m4a';
      await _recordEmergencyAudio(audioPath);

      // Take photos
      final frontPhotoPath = '${reportDir.path}/front.jpg';
      final backPhotoPath = '${reportDir.path}/back.jpg';
      await _takePhoto(frontCamera, frontPhotoPath);
      await _takePhoto(backCamera, backPhotoPath);

      // Record videos
      final frontVideoPath = '${reportDir.path}/front.mp4';
      final backVideoPath = '${reportDir.path}/back.mp4';
      await _recordVideo(frontCamera, frontVideoPath);
      await _recordVideo(backCamera, backVideoPath);

      // Create and save report
      final mediaFiles = [
        audioPath,
        frontPhotoPath,
        backPhotoPath,
        frontVideoPath,
        backVideoPath,
      ];

      await _initializeFromStorage();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final report = ReportCase(
        id: reportId,
        type: ReportType.amber,
        timestamp: timestamp,
        location: {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        note: 'Voice-triggered SOS',
        mediaFiles: mediaFiles,
      );

      _cases[report.id] = report;
      await _saveToStorage();
    } catch (e) {
      debugPrint('Error capturing emergency data: $e');
    }
  }

  static Future<void> _recordEmergencyAudio(String path) async {
    try {
      // Create an empty file to simulate recording
      await File(path).writeAsBytes([]);
      await Future.delayed(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error recording emergency audio: $e');
    }
  }

  static Future<void> _takePhoto(CameraDescription camera, String path) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    final image = await controller.takePicture();
    await image.saveTo(path);
    await controller.dispose();
  }

  static Future<void> _recordVideo(CameraDescription camera, String path) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    await controller.startVideoRecording();
    await Future.delayed(const Duration(seconds: 5));
    final video = await controller.stopVideoRecording();
    await video.saveTo(path);
    await controller.dispose();
  }
}
