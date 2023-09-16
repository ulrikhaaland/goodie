import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../bloc/review.dart';

class AssetThumbnail extends StatefulWidget {
  final GoodieAsset asset;
  final int? width;
  final int? height;
  final int thumbWidth;
  final int thumbHeight;
  final Map<GoodieAsset, Uint8List> cache;
  final bool fullResolution;

  const AssetThumbnail({
    Key? key,
    required this.asset,
    this.width,
    this.height,
    this.thumbWidth = 200,
    this.thumbHeight = 200,
    required this.cache,
    this.fullResolution = false,
  }) : super(key: key);

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  MemoryImage? editImage;
  PhotoViewController? controller;

  @override
  void initState() {
    if (widget.fullResolution) {
      controller = PhotoViewController(
          initialPosition: widget.asset.offset ?? Offset.zero,
          initialScale: widget.asset.scale ?? 1.0);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return widget.cache.containsKey(widget.asset)
        ? _buildCachedImage(screenWidth, widget.cache[widget.asset]!)
        : _buildFutureImage(screenWidth);
  }

  MemoryImage? createMemoryImage(Uint8List data) {
    try {
      return MemoryImage(data);
    } catch (e) {
      print("Error creating MemoryImage: $e");
      return null;
    }
  }

  Widget _buildCachedImage(double screenWidth, Uint8List imageBytes) {
    if (widget.asset.type == AssetType.video &&
        widget.asset.videoPlayerController != null &&
        widget.fullResolution) {
      return GestureDetector(
        onTap: _toggleVideoPlayback,
        child: SizedBox(
          width: widget.width!.toDouble(),
          height: widget.height!.toDouble(),
          child: ClipRect(
            child: Stack(
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: widget.asset.videoPlayerController!.value.size.width,
                    height:
                        widget.asset.videoPlayerController!.value.size.height,
                    child: VideoPlayer(widget.asset.videoPlayerController!),
                  ),
                ),
                if (!widget.asset.videoPlayerController!.value.isPlaying)
                  const Center(
                    child: Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 50),
                  ),
              ],
            ),
          ),
        ),
      );
    } else {
      if (widget.fullResolution) {
        return SizedBox(
          width: widget.width!.toDouble(),
          height: widget.height!.toDouble(),
          child: ClipRect(
            child: PhotoView(
              key: Key(widget.asset.id),
              controller: controller!,
              imageProvider: createMemoryImage(imageBytes),
              minScale: PhotoViewComputedScale.covered,
              maxScale: PhotoViewComputedScale.covered * 2,
              initialScale: widget.asset.scale,
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              basePosition: Alignment.center,
              onScaleEnd: (context, details, controllerValue) {
                widget.asset.scale = controllerValue.scale;
                widget.asset.offset = controllerValue.position;
              },
            ),
          ),
        );
      } else {
        return Image.memory(
          imageBytes,
          width: widget.width?.toDouble() ?? screenWidth / 4.35,
          height: widget.height?.toDouble() ?? 100,
          fit: BoxFit.cover,
        );
      }
    }
  }

  Widget _buildFutureImage(double screenWidth) {
    if (widget.asset.type == AssetType.video) {
      return FutureBuilder<File?>(
        future: widget.asset.file,
        builder: (context, fileSnapshot) {
          if (fileSnapshot.connectionState == ConnectionState.done &&
              fileSnapshot.data != null) {
            widget.asset.videoPlayerController ??=
                VideoPlayerController.file(fileSnapshot.data!)
                  ..initialize().then((_) {
                    if (mounted) setState(() {});
                  });
            return FutureBuilder<Uint8List?>(
              future: VideoThumbnail.thumbnailData(
                video: fileSnapshot.data!.path,
                imageFormat: ImageFormat.JPEG,
                maxWidth: (widget.width?.toInt() ?? screenWidth.toInt()),
                maxHeight:
                    (widget.height?.toInt() ?? screenWidth * 0.75).toInt(),
                quality: 100,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  widget.cache[widget.asset] = snapshot.data!;
                  return _buildCachedImage(screenWidth, snapshot.data!);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      );
    } else {
      return FutureBuilder<Uint8List?>(
        future:
            widget.asset.imageFile?.readAsBytes() ?? widget.asset.originBytes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            widget.cache[widget.asset] = snapshot.data!;
            return _buildCachedImage(screenWidth, snapshot.data!);
          }
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
  }

  void _toggleVideoPlayback() {
    if (widget.asset.videoPlayerController!.value.isPlaying) {
      widget.asset.videoPlayerController!.pause();
    } else {
      widget.asset.videoPlayerController!.play();
    }
    setState(() {}); // This will trigger a rebuild to update the UI.
  }
}