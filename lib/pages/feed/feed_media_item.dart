import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../bloc/user_review_provider.dart';
import '../../utils/image.dart';
import '../../widgets/gradient_circular_progress.dart';
import 'feed_video_media_item.dart';

class FeedMediaItem extends StatefulWidget {
  final MediaItem mediaItem;
  final UserReviewProvider reviewProvider;
  final VoidCallback onDoubleTap;

  const FeedMediaItem(
      {super.key,
      required this.mediaItem,
      required this.reviewProvider,
      required this.onDoubleTap});

  @override
  State<FeedMediaItem> createState() => _FeedMediaItemState();
}

class _FeedMediaItemState extends State<FeedMediaItem>
    with TickerProviderStateMixin {
  late AnimationController _animationControllerSoundOn;
  late Animation<double> _opacityAnimationSoundOn;

  late AnimationController _animationControllerSoundOff;
  late Animation<double> _opacityAnimationSoundOff;

  MediaItem get mediaItem => widget.mediaItem;

  @override
  void initState() {
    _animationControllerSoundOn = AnimationController(
        duration: const Duration(milliseconds: 500), // Set duration to 1 second
        vsync: this,
        value: 0);

    _animationControllerSoundOff = AnimationController(
        duration: const Duration(milliseconds: 500), // Set duration to 1 second
        vsync: this,
        value: 0);

    _opacityAnimationSoundOn =
        Tween<double>(begin: 0, end: 1).animate(_animationControllerSoundOn);

    _opacityAnimationSoundOff =
        Tween<double>(begin: 0, end: 1).animate(_animationControllerSoundOff);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleOnTap,
      onDoubleTap: widget.onDoubleTap,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          _buildMedia(widget.mediaItem),
          if (mediaItem.type == MediaType.Video) ...[
            IgnorePointer(
              child: FadeTransition(
                opacity: _opacityAnimationSoundOn,
                child: Icon(
                  Icons.volume_up,
                  color: Colors.grey[300],
                  size: 80,
                ),
              ),
            ),
            IgnorePointer(
              child: FadeTransition(
                opacity: _opacityAnimationSoundOff,
                child: Icon(
                  Icons.volume_mute,
                  color: Colors.grey[300],
                  size: 80,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildMedia(MediaItem mediaItem) {
    final isImage = mediaItem.type == MediaType.Image;

    if (isImage) {
      return CachedNetworkImage(
        imageUrl: mediaItem.url,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: GradientCircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      return ReviewListItemVideo(
        key: Key(mediaItem.url),
        item: mediaItem,
        soundOnListener: widget.reviewProvider.soundOn,
      );
    }
  }

  void _handleOnTap() {
    if (widget.reviewProvider.soundOn.value) {
      widget.reviewProvider.soundOn.value = false;
      _animationControllerSoundOn.reset();
      _animationControllerSoundOff
          .forward()
          .whenComplete(() => _animationControllerSoundOff.reverse());
    } else {
      widget.reviewProvider.soundOn.value = true;
      _animationControllerSoundOff.reset();

      _animationControllerSoundOn
          .forward()
          .whenComplete(() => _animationControllerSoundOn.reverse());
    }
  }
}
