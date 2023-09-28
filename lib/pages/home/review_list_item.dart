import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goodie/model/review.dart';
import 'package:provider/provider.dart';

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

  List<String> _images = [];

  bool _isImagesHandled = false;

  bool _isCancelled = false;

  final PageController _pageController = PageController();
  int _currentPage = 0;

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
                      child: Text("Follow"),
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

            // Restaurant Images - Horizontal PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount:
                    _images.where((element) => element.isNotEmpty).length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _images[index],
                    errorBuilder: (context, error, stackTrace) => Container(),
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // Actions like Like, Comment, and Share
            // Actions like Like, Comment, and Share
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
                if (_images.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _images.length,
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

  void _handleImages() {
    if (widget.review.images != null && widget.review.images!.isNotEmpty) {
      _precacheImages(widget.review.images!);
    } else {
      if (restaurant.coverImg != null) {
        _images.add(restaurant.coverImg!);
        setState(() {});
      }

      if (restaurant.dishes.isEmpty) {
        widget.restaurantProvider
            .fetchDishesAndPrecacheImages(restaurant.id, context)
            .then((value) {
          for (var dish in restaurant.dishes) {
            if (_images.length < 2) {
              _images.add(dish.imgUrl!);
            } else {
              break;
            }
          }
          _precacheImages(_images);
        });
      }
    }

    // _precacheImages(_images);
  }

  void _precacheImages(List<String> imageUrls) async {
    if (_isCancelled) return; // Check if widget is disposed

    List<String> successfulUrls = [];

    for (var imageUrl in imageUrls) {
      // Skip invalid URLs
      if (imageUrl.isEmpty || !Uri.parse(imageUrl).hasScheme) {
        print("Skipping invalid URL: $imageUrl");
        continue;
      }

      var completer = Completer<void>();

      if (_isCancelled) return; // Check again before precaching

      precacheImage(NetworkImage(imageUrl), context, onError: (e, stackTrace) {
        print("Failed to precache image: $e");
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }).then((_) {
        if (!completer.isCompleted) {
          successfulUrls.add(imageUrl);
          completer.complete();
        }
      }).catchError((e) {
        print("Error during precaching: $e");
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      });

      try {
        await completer.future;
      } catch (e) {
        print("Skipping image due to error: $e");
      }
    }

    if (!_isCancelled) {
      // Check again before calling setState
      setState(() {
        _images =
            successfulUrls; // Update _images to only contain successful URLs
      });
    }
  }
}
