import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

enum ReportType {
  amber,
  witness,
  quickPin
}

class Report {
  final String id;
  final ReportType type;
  final double latitude;
  final double longitude;
  final String description;
  final DateTime timestamp;

  Report({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.timestamp,
  });

  Color get markerColor {
    switch (type) {
      case ReportType.amber:
        return AppColors.neonRed;
      case ReportType.witness:
        return AppColors.neonAmber;
      case ReportType.quickPin:
        return AppColors.neonGreen;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString(),
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    type: ReportType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => ReportType.quickPin,
    ),
    latitude: json['latitude'],
    longitude: json['longitude'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

enum PrivacyMode {
  anonymous,
  pseudonymous,
  identified,
}

enum IncidentCategory {
  suspiciousActivity,
  theft,
  vandalism,
  harassment,
  assault,
  other,
}

extension IncidentCategoryExtension on IncidentCategory {
  String get displayName {
    switch (this) {
      case IncidentCategory.suspiciousActivity:
        return 'Suspicious Activity';
      case IncidentCategory.theft:
        return 'Theft / Robbery';
      case IncidentCategory.vandalism:
        return 'Vandalism';
      case IncidentCategory.harassment:
        return 'Harassment';
      case IncidentCategory.assault:
        return 'Assault';
      case IncidentCategory.other:
        return 'Other';
    }
  }
}

enum QuickReportCategory {
  hazard,
  brokenLight,
  suspiciousVehicle,
  unsafeArea,
  other,
}

extension QuickReportCategoryExtension on QuickReportCategory {
  String get displayName {
    switch (this) {
      case QuickReportCategory.hazard:
        return 'General Hazard';
      case QuickReportCategory.brokenLight:
        return 'Broken Light';
      case QuickReportCategory.suspiciousVehicle:
        return 'Suspicious Vehicle';
      case QuickReportCategory.unsafeArea:
        return 'Unsafe Area';
      case QuickReportCategory.other:
        return 'Other';
    }
  }
}

class ReportCase {
  final String id;
  final ReportType type;
  final DateTime timestamp;
  final Map<String, dynamic> location;
  final String? note;
  final List<String>? mediaFiles;
  final PrivacyMode? privacy;
  final IncidentCategory? incidentCategory;
  final QuickReportCategory? quickReportCategory;

  ReportCase({
    required this.id,
    required this.type,
    required this.timestamp,
    required this.location,
    this.note,
    this.mediaFiles,
    this.privacy,
    this.incidentCategory,
    this.quickReportCategory,
  });

  ReportCase copyWith({
    String? id,
    ReportType? type,
    DateTime? timestamp,
    Map<String, dynamic>? location,
    String? note,
    List<String>? mediaFiles,
    PrivacyMode? privacy,
    IncidentCategory? incidentCategory,
    QuickReportCategory? quickReportCategory,
  }) {
    return ReportCase(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      note: note ?? this.note,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      privacy: privacy ?? this.privacy,
      incidentCategory: incidentCategory ?? this.incidentCategory,
      quickReportCategory: quickReportCategory ?? this.quickReportCategory,
    );
  }
}