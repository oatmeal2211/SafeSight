import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_file.dart';
import '../constants/app_theme.dart';

class MediaPreview extends StatelessWidget {
  final MediaFile media;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showPlayIcon;

  const MediaPreview({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.onTap,
    this.showPlayIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.neonGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media preview
              if (media.isPhoto)
                Image.file(
                  File(media.filePath),
                  fit: BoxFit.cover,
                )
              else if (media.thumbnail != null)
                Image.file(
                  File(media.thumbnail!),
                  fit: BoxFit.cover,
                ),
              
              // Play icon overlay for videos
              if (media.isVideo && showPlayIcon)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MediaGallery extends StatelessWidget {
  final List<MediaFile> mediaFiles;
  final double spacing;
  final double runSpacing;
  final int? maxItems;

  const MediaGallery({
    super.key,
    required this.mediaFiles,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.maxItems,
  });

  @override
  Widget build(BuildContext context) {
    final displayItems = maxItems != null ? mediaFiles.take(maxItems!).toList() : mediaFiles;
    final hasMore = maxItems != null && mediaFiles.length > maxItems!;

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        ...displayItems.map((media) => SizedBox(
          width: 100,
          height: 100,
          child: MediaPreview(
            media: media,
            onTap: () => _showFullScreenMedia(context, media),
          ),
        )),
        if (hasMore)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.neonGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '+${mediaFiles.length - maxItems!}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showFullScreenMedia(BuildContext context, MediaFile media) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenMedia(media: media),
      ),
    );
  }
}

class FullScreenMedia extends StatefulWidget {
  final MediaFile media;

  const FullScreenMedia({
    super.key,
    required this.media,
  });

  @override
  State<FullScreenMedia> createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<FullScreenMedia> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.media.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.file(File(widget.media.filePath));
    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: widget.media.isPhoto
          ? Image.file(File(widget.media.filePath))
          : _buildVideoPlayer(),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
        if (!_isPlaying)
          IconButton(
            icon: const Icon(
              Icons.play_arrow,
              size: 50,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isPlaying = true;
                _controller!.play();
              });
            },
          ),
      ],
    );
  }
}
