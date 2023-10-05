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
  final ValueListenable soundOnListener;
  const ReviewListItemVideo(
      {super.key, required this.item, required this.soundOnListener});

  @override
  State<ReviewListItemVideo> createState() => _ReviewListItemVideoState();
}

class _ReviewListItemVideoState extends State<ReviewListItemVideo>
    with TickerProviderStateMixin {
  MediaItem get item => widget.item;

  late final VideoPlayerController controller;

  int _playCount = 0;
  bool _showReplayOverlay = false;

  bool _showDurationOverlay = false;

  bool get soundOn => widget.soundOnListener.value;

  late final AnimationController _animationControllerDuration;
  late final Animation<double> _opacityAnimationDuration;

  final ValueNotifier<bool> durationUpdater = ValueNotifier<bool>(false);

  @override
  void initState() {
    controller = VideoPlayerController.network(item.url);

    _animationControllerDuration = AnimationController(
        duration: const Duration(milliseconds: 500), // Set duration to 1 second
        vsync: this,
        value: 0);

    _opacityAnimationDuration =
        Tween<double>(begin: 0, end: 1).animate(_animationControllerDuration);

    _handleLoadVideo();
    widget.soundOnListener.addListener(_handleOnSoundChange);

    super.initState();
  }

  @override
  void dispose() {
    widget.soundOnListener.removeListener(_handleOnSoundChange);
    controller.removeListener(_handleOnInitVid);
    controller.dispose();
    durationUpdater.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (controller.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.passthrough,
      children: [
        VisibilityDetector(
          key: Key(item.url),
          onVisibilityChanged: (visibilityInfo) {
            if (visibilityInfo.visibleFraction < 0.5) {
              controller.pause();
            } else if (visibilityInfo.visibleFraction > 0.5 &&
                !_showReplayOverlay) {
              controller.play();
              handleDurationElapsed();
              controller.setLooping(true);
            }
            setState(() {});
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: controller.value.size.height,
            ),
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: SizedBox(
                width: screenWidth, // Set the width to the screen width
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(
                      controller,
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
                return Container(
                  padding: const EdgeInsets.all(4.0), // Padding around the text
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
                );
              },
            ),
          ),
        if (_showReplayOverlay) ReplayOverlay(onReplay: _handleReplay),
        Positioned(
          bottom: 10,
          left: 10,
          child: FadeTransition(
            opacity: _opacityAnimationDuration,
            child: Container(
              padding: const EdgeInsets.all(4.0), // Padding around the text
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(
                    8.0), // Optional: to round the corners
              ),
              child: ValueListenableBuilder(
                  valueListenable: durationUpdater,
                  builder: (context, value, child) {
                    controller.value.position;
                    final duration =
                        controller.value.duration - controller.value.position;

                    final minutes = duration.inMinutes;
                    final seconds = (duration.inSeconds % 60)
                        .toString()
                        .padLeft(2, '0'); // Ensure seconds is two digits
                    return Text(
                      '$minutes:$seconds',
                      style: const TextStyle(color: Colors.white),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleLoadVideo() async {
    await controller.initialize();
    controller.seekTo(Duration.zero);
    item.videoController = controller;
    _handleOnSoundChange();
    controller.addListener(_handleOnInitVid);

    if (mounted) {
      setState(() {});
    }
  }

  void _handleOnSoundChange() {
    handleDurationElapsed();

    if (soundOn) {
      controller.setVolume(1);
    } else {
      controller.setVolume(0);
    }
  }

  Future<void> _handleReplay() async {
    controller.removeListener(_handleOnInitVid);
    _playCount = 0;
    _showReplayOverlay = false;
    handleDurationElapsed();
    controller.seekTo(Duration.zero).then((value) =>
        controller.play().then((value) => controller.setLooping(true)));
    // controller.play();
    // controller.setLooping(true);
    setState(() {});
  }

  bool canIncrement = true;

  void _handleOnInitVid() {
    if (canIncrement &&
        (controller.value.position >=
            Duration(
                milliseconds:
                    controller.value.duration.inMilliseconds - 500))) {
      canIncrement = false;
      _playCount += 1;
      // durationAnimation
      if (_playCount == 1) {
        handleDurationElapsed();
      }

      Timer(const Duration(milliseconds: 500), () => canIncrement = true);
      if (_playCount >= 2) {
        controller.setLooping(false);

        Timer.periodic(const Duration(milliseconds: 50), (timer) {
          if (controller.value.isCompleted ||
              controller.value.isPlaying == false) {
            timer.cancel();
            setState(() {
              _showReplayOverlay = true;
            });
            controller.seekTo(Duration.zero);
          }
        });

        // controller.seekTo(Duration.zero);

        // controller.setLooping(false);
        // controller.pause();
        // setState(() {
        //   _showReplayOverlay = true;
        // });
      }
    }
  }

  void handleDurationElapsed() {
    final Stopwatch stopwatch = Stopwatch();

    void updateDuration() {
      _animationControllerDuration.forward(from: 1);

      stopwatch.start();
      durationUpdater.value = !durationUpdater.value;
      if (stopwatch.elapsed.inMilliseconds >= 2250) {
        _animationControllerDuration.reverse();
        controller.removeListener(updateDuration);
      }
    }

    controller.addListener(updateDuration);
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
