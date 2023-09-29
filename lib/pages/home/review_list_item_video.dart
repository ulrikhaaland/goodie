import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:goodie/utils/image.dart';

import '../../bloc/create_review_provider.dart';

class ReviewListItemVideo extends StatefulWidget {
  final MediaItem item;
  const ReviewListItemVideo({super.key, required this.item});

  @override
  State<ReviewListItemVideo> createState() => _ReviewListItemVideoState();
}

class _ReviewListItemVideoState extends State<ReviewListItemVideo> {
  MediaItem get item => widget.item;

  VideoController? get controller => item.videoController;

  @override
  void initState() {
    _handleLoadVideo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio:
          item.videoController!.videoPlayerController.value.aspectRatio,
      child: VideoView(
        key: Key(item.url),
        controller: item.videoController!,
      ),
    );
  }

  Future<void> _handleLoadVideo() async {
    final controller = VideoController(
      videoPlayerController: VideoPlayerController.network(item.url),
      videoConfig: videoConfig,
    );

    await controller.initialize();
    item.videoController = controller;
    setState(() {});
  }
}
