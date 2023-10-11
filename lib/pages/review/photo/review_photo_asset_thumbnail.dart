import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../bloc/create_review_provider.dart';
import '../../../widgets/gradient_circular_progress.dart';

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

  VideoPlayerController? get _videoController =>
      widget.asset.videoPlayerController;

  @override
  void initState() {
    if (widget.fullResolution && widget.asset.type == AssetType.image) {
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

    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: widget.cache.containsKey(widget.asset)
          ? _buildCachedImage(screenWidth, widget.cache[widget.asset]!)
          : _buildFutureImage(screenWidth),
    );
  }

  Widget _buildCachedImage(double screenWidth, Uint8List imageBytes) {
    if (widget.asset.type == AssetType.video &&
        widget.asset.videoPlayerController != null &&
        widget.fullResolution) {
      final double videoAspectRatio = _videoController!.value.aspectRatio;

      return GestureDetector(
        onTap: _handleOnTapVideo,
        child: Container(
          width: widget.width?.toDouble(),
          height: widget.height?.toDouble(),
          color: Colors.white,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: videoAspectRatio,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _videoController!.value.size.width,
                      height: _videoController!.value.size.height,
                      child: VideoPlayer(
                        _videoController!,
                        key: Key(widget.asset.id),
                      ),
                    ),
                  ),
                ),
              ),
              if (!_videoController!.value.isPlaying) ...[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox.shrink(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.grey[300],
                      size: 80,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      );
    } else {
      if (widget.fullResolution) {
        final maxScale = PhotoViewComputedScale.covered * 2;
        const minScale = PhotoViewComputedScale.covered;

        return SizedBox(
          width: widget.width!.toDouble(),
          height: widget.height!.toDouble(),
          child: ClipRect(
            child: PhotoView(
              key: Key(widget.asset.id),
              controller: controller!,
              imageProvider: MemoryImage(imageBytes),
              minScale: minScale,
              maxScale: maxScale,
              initialScale: widget.asset.scale,
              tightMode: true,
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
      if (widget.asset.imageFile != null) {
        return buildVideoView(widget.asset.imageFile!, screenWidth);
      } else {
        return FutureBuilder<File?>(
          future: widget.asset.file,
          builder: (context, fileSnapshot) {
            if (fileSnapshot.connectionState == ConnectionState.done &&
                fileSnapshot.data != null) {
              return buildVideoView(fileSnapshot.data!, screenWidth);
            } else {
              return const Center(child: GradientCircularProgressIndicator());
            }
          },
        );
      }
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
          return const Center(child: GradientCircularProgressIndicator());
        },
      );
    }
  }

  Widget buildVideoView(File file, double screenWidth) {
    return FutureBuilder<Uint8List?>(
      future: VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: (widget.width?.toInt() ?? screenWidth.toInt()),
        maxHeight: (widget.height?.toInt() ?? screenWidth * 0.75).toInt(),
        quality: 100,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          widget.cache[widget.asset] = snapshot.data!;
          return _buildCachedImage(screenWidth, snapshot.data!);
        } else {
          return const Center(child: GradientCircularProgressIndicator());
        }
      },
    );
  }

  void _handleOnTapVideo() {
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    setState(() {});
  }
}

class VideoWithPanAndZoom extends StatefulWidget {
  final Widget videoView; // Replace this with your VideoView widget

  VideoWithPanAndZoom({required this.videoView});

  @override
  _VideoWithPanAndZoomState createState() => _VideoWithPanAndZoomState();
}

class _VideoWithPanAndZoomState extends State<VideoWithPanAndZoom> {
  Offset offset = Offset.zero;
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform(
          transform: Matrix4.identity()
            ..translate(offset.dx, offset.dy)
            ..scale(scale),
          child: widget.videoView,
        ),
        Positioned.fill(
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                scale = scale * details.scale;
                scale = scale.clamp(
                    1.0, 2.0); // Replace with your min and max scale

                // Update the offset for panning
                offset = offset +
                    details.focalPoint -
                    Offset(context.size!.width / 2, context.size!.height / 2);
              });
            },
          ),
        ),
      ],
    );
  }
}
