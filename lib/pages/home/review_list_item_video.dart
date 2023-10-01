import 'package:flutter/material.dart';
import 'package:goodie/utils/image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../bloc/create_review_provider.dart';

class ReviewListItemVideo extends StatefulWidget {
  final MediaItem item;
  const ReviewListItemVideo({super.key, required this.item});

  @override
  State<ReviewListItemVideo> createState() => _ReviewListItemVideoState();
}

class _ReviewListItemVideoState extends State<ReviewListItemVideo> {
  MediaItem get item => widget.item;

  VideoPlayerController? get controller => item.videoController;

  @override
  void initState() {
    _handleLoadVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return VisibilityDetector(
      key: Key(item.url),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction < 0.5) {
          controller!.pause();
        } else if (visibilityInfo.visibleFraction > 0.5) {
          controller!.play();
        }
      },
      child: AspectRatio(
        aspectRatio: controller!.value.aspectRatio,
        child: Container(
          width: screenWidth, // Set the width to the screen width
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller!.value.size.height,
              child: VideoPlayer(
                controller!,
                key: Key(item.url),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLoadVideo() async {
    final controller = VideoPlayerController.network(item.url);

    controller.initialize().then((value) {
      item.videoController = controller;
      if (mounted) {
        setState(() {});
      }
    });
  }
}
