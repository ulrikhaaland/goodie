import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/model/review.dart';
import 'package:goodie/pages/home/review_list_item_video.dart';
import 'package:goodie/utils/image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';

import '../../bloc/create_review_provider.dart';
import '../../bloc/restaurant_provider.dart';
import '../../model/restaurant.dart';

class ReviewListItem extends StatefulWidget {
  final RestaurantReview review;
  final Restaurant restaurant;
  final RestaurantProvider restaurantProvider;

  const ReviewListItem(
      {super.key,
      required this.review,
      required this.restaurant,
      required this.restaurantProvider});

  @override
  State<ReviewListItem> createState() => _ReviewListItemState();
}

class _ReviewListItemState extends State<ReviewListItem> {
  Restaurant get restaurant => widget.restaurant;

  List<MediaItem> _mediaItems = [];

  bool _isImagesHandled = false;

  bool _isCancelled = false;

  final PreloadPageController _pageController = PreloadPageController();
  int _currentPage = 0;

  ValueNotifier<bool> videoInitializedNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    // ... existing code ...
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isImagesHandled) {
      _handleImages();
      _isImagesHandled = true;
    }
  }

  @override
  void dispose() {
    _isCancelled = true;
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height * 0.9, // 90% of screen height
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture and User Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.restaurant.coverImg ??
                              "https://example.com/default.jpg"),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.review.userId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Add your follow functionality here
                      },
                      child: const Text("Follow"),
                      style: TextButton.styleFrom(
                        primary: Colors.blue, // Text color
                      ),
                    ),
                    const SizedBox(
                        width:
                            10), // Add some spacing between the button and the icon
                    const Icon(Icons.more_horiz),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),
            Expanded(
                child: PreloadPageView.builder(
                    controller: _pageController,
                    itemCount: _mediaItems.length,
                    preloadPagesCount:
                        3, // Adjust this value to control the number of pages to preload
                    itemBuilder: (context, index) {
                      final media = _mediaItems[index];
                      if (media.type == MediaType.Image) {
                        return CachedNetworkImage(
                          imageUrl: media.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const SizedBox.shrink(
                              child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        );
                      } else {
                        return ReviewListItemVideo(
                          key: Key(media.url),
                          item: _mediaItems[index],
                        );
                      }
                    })),

            Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.favorite_border, color: Colors.grey[600]),
                        const SizedBox(width: 15),
                        Icon(Icons.comment_outlined, color: Colors.grey[600]),
                        const SizedBox(width: 15),
                        Icon(Icons.send_outlined, color: Colors.grey[600]),
                      ],
                    ),
                    Icon(Icons.bookmark_border, color: Colors.grey[600]),
                  ],
                ),
                // Dots indicator
                if (_mediaItems.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _mediaItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Likes Count
            Text('${widget.review.likes?.length ?? 0} likes',
                style: const TextStyle(fontWeight: FontWeight.bold)),

            // Review Text (Caption)
            if (widget.review.description != null &&
                widget.review.description!.isNotEmpty) ...[
              Text(
                widget.review.description ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ] else ...[
              const SizedBox(height: 4),
            ],

            // Comments Count
            Text('${widget.review.comments?.length ?? 0} comments',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Future<void> _handleImages() async {
    if (widget.review.media != null && widget.review.media!.isNotEmpty) {
      // Assuming widget.review.media is a list of MediaItem
      _mediaItems = widget.review.media!
          .where((element) => element.url.isNotEmpty && isValidUrl(element.url))
          .toList();
      setState(() {});
    } else {
      if (restaurant.coverImg != null) {
        _mediaItems.add(MediaItem(
            index: _mediaItems.length,
            url: restaurant.coverImg!,
            type: MediaType.Image));
      }

      if (restaurant.dishes.isEmpty) {
        widget.restaurantProvider
            .fetchDishesAndPrecacheImages(restaurant.id, context)
            .then((value) {
          for (var dish in restaurant.dishes) {
            if (_mediaItems.length < 3) {
              _mediaItems.add(MediaItem(
                  url: dish.imgUrl!,
                  type: MediaType.Image,
                  index: _mediaItems.length));
            } else {
              break;
            }
          }
          if (mounted) setState(() {});
        });
      }
    }
  }
}
