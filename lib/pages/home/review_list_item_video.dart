import 'dart:async';
import 'dart:ui';

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

  int _playCount = 0;
  bool _showReplayOverlay = false;

  bool get soundOn => widget.soundOnListener.value;

  @override
  void initState() {
    _handleLoadVideo();
    widget.soundOnListener.addListener(_handleOnSoundChange);

    super.initState();
  }

  @override
  void dispose() {
    widget.soundOnListener.removeListener(_handleOnSoundChange);
    controller?.removeListener(_handleOnInitVid);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (controller == null || controller!.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        VisibilityDetector(
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
            onTap: () {
              widget.onTap();
            },
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
        ),
        if (!_showReplayOverlay)
          Positioned(
            bottom: 10,
            right: 10,
            child: ValueListenableBuilder(
              valueListenable: widget.soundOnListener,
              builder: (BuildContext context, value, Widget? child) {
                return GestureDetector(
                  onTap: () => setState(() {
                    widget.onTap();
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.all(4.0), // Padding around the text
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: to round the corners
                    ),
                    child: value
                        ? const Icon(
                            Icons.volume_up,
                            color: Colors.white,
                          )
                        : const Icon(Icons.volume_off, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        if (_showReplayOverlay) ReplayOverlay(onReplay: _handleReplay),
      ],
    );
  }

  Future<void> _handleLoadVideo() async {
    final controller = VideoPlayerController.network(item.url);

    await controller.initialize();
    item.videoController = controller;
    _handleOnSoundChange();
    controller.addListener(_handleOnInitVid);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleOnSoundChange() {
    if (controller != null) {
      if (soundOn) {
        controller!.setVolume(1);
      } else {
        controller!.setVolume(0);
      }
    }
  }

  Future<void> _handleReplay() async {
    controller!.removeListener(_handleOnInitVid);
    _playCount = 0;
    _showReplayOverlay = false;
    await controller!.seekTo(Duration.zero);
    await controller!.play();
    await controller!.setLooping(true);
    setState(() {});
  }

  bool canIncrement = true;

  void _handleOnInitVid() {
    if (canIncrement &&
        (controller!.value.position >=
            Duration(
                milliseconds:
                    controller!.value.duration.inMilliseconds - 400))) {
      canIncrement = false;
      _playCount += 1;
      Timer(const Duration(milliseconds: 500), () => canIncrement = true);
      if (_playCount >= 2) {
        controller!.setLooping(false);
        controller!.pause();
        setState(() {
          _showReplayOverlay = true;
        });
      }
    }
  }
}

class ReplayOverlay extends StatelessWidget {
  final VoidCallback onReplay;

  const ReplayOverlay({required this.onReplay, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onReplay();
      },
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: InkWell(
          onTap: () {
            onReplay();
          },
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.replay,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  'Spill av på nytt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
