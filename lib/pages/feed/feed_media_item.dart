import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/bloc/create_review_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../bloc/user_review_provider.dart';
import '../../utils/image.dart';
import '../../widgets/gradient_circular_progress.dart';
import 'feed_video_media_item.dart';

class FeedMediaItem extends StatefulWidget {
  final dynamic mediaItem;
  final UserReviewProvider reviewProvider;
  final VoidCallback onDoubleTap;
  final bool isLocalReview;

  const FeedMediaItem({
    super.key,
    required this.mediaItem,
    required this.reviewProvider,
    required this.onDoubleTap,
    required this.isLocalReview,
  }) : assert(mediaItem != null);

  @override
  State<FeedMediaItem> createState() => _FeedMediaItemState();
}

class _FeedMediaItemState extends State<FeedMediaItem>
    with TickerProviderStateMixin {
  late AnimationController _animationControllerSoundOn;
  late Animation<double> _opacityAnimationSoundOn;

  late AnimationController _animationControllerSoundOff;
  late Animation<double> _opacityAnimationSoundOff;

  dynamic get mediaItem => widget.mediaItem;

  late final MediaType mediaType;

  @override
  void initState() {
    _setMediaType();
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
          _buildMedia(mediaItem),
          if (mediaType == MediaType.Video) ...[
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

  Widget _buildMedia(dynamic mediaItem) {
    final isImage = mediaType == MediaType.Image;

    if (isImage) {
      if (widget.isLocalReview) {
        return Image.file(
          (mediaItem as GoodieAsset).imageFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error);
          },
        );
      } else {
        return CachedNetworkImage(
          key: Key(mediaItem.url),
          imageUrl: (mediaItem as MediaItem).url,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: GradientCircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        );
      }
    } else {
      String key =
          widget.isLocalReview ? mediaItem.imageFile.path : mediaItem.url;
      return ReviewListItemVideo(
        key: Key(key),
        item: mediaItem,
        soundOnListener: widget.reviewProvider.soundOn,
        isLocalReview: widget.isLocalReview,
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

  void _setMediaType() {
    if (widget.isLocalReview) {
      mediaType = (mediaItem as GoodieAsset).type == AssetType.image
          ? MediaType.Image
          : MediaType.Video;
    } else {
      mediaType = (mediaItem as MediaItem).type;
    }
  }
}
