import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/media_file.dart';

class MediaService {
  static Future<MediaFile> saveMedia(String originalPath) async {
    final ext = path.extension(originalPath).toLowerCase();
    final isVideo = ['.mp4', '.mov', '.avi'].contains(ext);
    final type = isVideo ? MediaType.video : MediaType.photo;
    
    try {
      // Save the file locally
      final savedPath = await MediaFile.saveToLocalStorage(originalPath);
      
      // Generate thumbnail for videos
      String? thumbnail;
      if (isVideo) {
        final thumbnailPath = path.join(
          path.dirname(savedPath),
          'thumb_${path.basename(savedPath)}.jpg'
        );
        thumbnail = await VideoThumbnail.thumbnailFile(
          video: savedPath,
          thumbnailPath: thumbnailPath,
          imageFormat: ImageFormat.JPEG,
          quality: 75,
        );
      }

      return MediaFile(
        id: path.basenameWithoutExtension(savedPath),
        filePath: savedPath,
        type: type,
        timestamp: DateTime.now(),
        thumbnail: thumbnail,
      );
    } catch (e) {
      debugPrint('Error saving media: $e');
      rethrow;
    }
  }

  static Future<void> deleteMedia(MediaFile media) async {
    // Delete main file
    await MediaFile.deleteFromStorage(media.filePath);
    
    // Delete thumbnail if exists
    if (media.thumbnail != null) {
      await MediaFile.deleteFromStorage(media.thumbnail!);
    }
  }

  static Future<void> deleteAllMedia(List<MediaFile> mediaFiles) async {
    for (final media in mediaFiles) {
      await deleteMedia(media);
    }
  }
}
