import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:goodie/utils/image.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../bloc/create_review_provider.dart';

class ReviewListItemVideo extends StatefulWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final ValueListenable soundOnListener;
  const ReviewListItemVideo(
      {super.key,
      required this.item,
      required this.onTap,
      required this.soundOnListener});

  @override
  State<ReviewListItemVideo> createState() => _ReviewListItemVideoState();
}

class _ReviewListItemVideoState extends State<ReviewListItemVideo> {
  MediaItem get item => widget.item;

  VideoPlayerController? get controller => item.videoController;

  @override
  void initState() {
    _handleLoadVideo();
    widget.soundOnListener.addListener(_handleOnSoundChange);

    super.initState();
  }

  @override
  void dispose() {
    widget.soundOnListener.removeListener(_handleOnSoundChange);
    super.dispose();
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
          controller!.setLooping(true);
        }
        setState(() {});
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: SizedBox(
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
      ),
    );
  }

  Future<void> _handleLoadVideo() async {
    final controller = VideoPlayerController.network(item.url);

    controller.initialize().then((value) {
      item.videoController = controller;
      _handleOnSoundChange();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleOnSoundChange() {
    if (controller != null) {
      if (widget.soundOnListener.value) {
        controller!.setVolume(1);
      } else {
        controller!.setVolume(0);
      }
    }
  }
}
