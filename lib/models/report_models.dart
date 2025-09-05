// Report models for campus safety app

enum ReportType {
  amber,
  witness,
  quickPin,
}

enum PrivacyMode {
  anonymous,
  pseudonymous,
  identified,
}

enum IncidentCategory {
  assault,
  harassment,
  theft,
  suspiciousPerson,
  medical,
  other,
}

enum QuickReportCategory {
  brokenLamp,
  darkCorridor,
  creepyPerson,
  noise,
  other,
}

class ReportCase {
  final String id;
  final ReportType type;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final String? nearestLandmark;
  final String? description;
  final PrivacyMode privacyMode;
  final IncidentCategory? incidentCategory;
  final QuickReportCategory? quickCategory;
  final List<String> mediaFiles;

  ReportCase({
    required this.id,
    required this.type,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.nearestLandmark,
    this.description,
    this.privacyMode = PrivacyMode.anonymous,
    this.incidentCategory,
    this.quickCategory,
    this.mediaFiles = const [],
  });

  ReportCase copyWith({
    String? id,
    ReportType? type,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    String? nearestLandmark,
    String? description,
    PrivacyMode? privacyMode,
    IncidentCategory? incidentCategory,
    QuickReportCategory? quickCategory,
    List<String>? mediaFiles,
  }) {
    return ReportCase(
      id: id ?? this.id,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nearestLandmark: nearestLandmark ?? this.nearestLandmark,
      description: description ?? this.description,
      privacyMode: privacyMode ?? this.privacyMode,
      incidentCategory: incidentCategory ?? this.incidentCategory,
      quickCategory: quickCategory ?? this.quickCategory,
      mediaFiles: mediaFiles ?? this.mediaFiles,
    );
  }
}

extension IncidentCategoryExtension on IncidentCategory {
  String get displayName {
    switch (this) {
      case IncidentCategory.assault:
        return 'Assault';
      case IncidentCategory.harassment:
        return 'Harassment';
      case IncidentCategory.theft:
        return 'Theft';
      case IncidentCategory.suspiciousPerson:
        return 'Suspicious Person';
      case IncidentCategory.medical:
        return 'Medical';
      case IncidentCategory.other:
        return 'Other';
    }
  }
}

extension QuickReportCategoryExtension on QuickReportCategory {
  String get displayName {
    switch (this) {
      case QuickReportCategory.brokenLamp:
        return 'Broken Lamp';
      case QuickReportCategory.darkCorridor:
        return 'Dark Corridor';
      case QuickReportCategory.creepyPerson:
        return 'Creepy Person';
      case QuickReportCategory.noise:
        return 'Noise';
      case QuickReportCategory.other:
        return 'Other';
    }
  }
}

extension PrivacyModeExtension on PrivacyMode {
  String get displayName {
    switch (this) {
      case PrivacyMode.anonymous:
        return 'Anonymous';
      case PrivacyMode.pseudonymous:
        return 'Pseudonymous';
      case PrivacyMode.identified:
        return 'Identified';
    }
  }
}
