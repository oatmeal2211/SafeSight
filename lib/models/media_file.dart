import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum MediaType {
  photo,
  video
}

class MediaFile {
  final String id;
  final String filePath;
  final MediaType type;
  final DateTime timestamp;
  final String? thumbnail;

  const MediaFile({
    required this.id,
    required this.filePath,
    required this.type,
    required this.timestamp,
    this.thumbnail,
  });

  bool get isPhoto => type == MediaType.photo;
  bool get isVideo => type == MediaType.video;

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'type': type.toString(),
    'timestamp': timestamp.toIso8601String(),
    'thumbnail': thumbnail,
  };

  factory MediaFile.fromJson(Map<String, dynamic> json) => MediaFile(
    id: json['id'],
    filePath: json['filePath'],
    type: MediaType.values.firstWhere(
      (e) => e.toString() == json['type'],
      orElse: () => MediaType.photo,
    ),
    timestamp: DateTime.parse(json['timestamp']),
    thumbnail: json['thumbnail'],
  );

  static Future<String> saveToLocalStorage(String originalPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${appDir.path}/media');
    await mediaDir.create(recursive: true);

    final ext = path.extension(originalPath);
    final newFileName = '${const Uuid().v4()}$ext';
    final newPath = '${mediaDir.path}/$newFileName';

    await File(originalPath).copy(newPath);
    return newPath;
  }

  static Future<void> deleteFromStorage(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
