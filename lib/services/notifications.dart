import 'package:flutter/material.dart';

// Notification for SOS creation to trigger map camera animation
class SOSCreatedNotification extends Notification {
  final String caseId;
  final double latitude;
  final double longitude;

  const SOSCreatedNotification({
    required this.caseId,
    required this.latitude,
    required this.longitude,
  });
}

// Notification for general report updates
class ReportUpdatedNotification extends Notification {
  final String caseId;

  const ReportUpdatedNotification({
    required this.caseId,
  });
}
