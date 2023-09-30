import 'package:flutter/material.dart';
import 'package:goodie/utils/image.dart';
import 'package:video_player/video_player.dart';

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
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return AspectRatio(
      aspectRatio: item.videoController!.value.aspectRatio,
      child: VideoPlayer(
        controller!,
        key: Key(item.url),
      ),
    );
  }

  Future<void> _handleLoadVideo() async {
    final controller = VideoPlayerController.network(item.url);

    controller.initialize().then((value) {
      item.videoController = controller;
      setState(() {});
    });
  }
}
