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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
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
                // Add more options icon (optional)
                const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 10),

            // Restaurant Images - Horizontal PageView
            Expanded(
              child: PageView.builder(
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
            const SizedBox(height: 10),

            // Likes Count
            Text('${widget.review.likes?.length ?? 0} likes',
                style: const TextStyle(fontWeight: FontWeight.bold)),

            // Review Text (Caption)
            Text(
              widget.review.description ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),

            // Comments Count
            Text('${widget.review.comments?.length ?? 0} comments',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  void _handleImages() async {
    if (widget.review.images != null && widget.review.images!.isNotEmpty) {
      _images = widget.review.images!;
    } else {
      if (restaurant.coverImg != null) {
        _images.add(restaurant.coverImg!);
      }

      if (restaurant.dishes.isEmpty) {
        await widget.restaurantProvider
            .fetchDishesAndPrecacheImages(restaurant.id, context)
            .then((value) {
          for (var dish in restaurant.dishes) {
            if (_images.length < 2) {
              _images.add(dish.imgUrl!);
            } else {
              break;
            }
          }
        });
      }
    }

    _precacheImages(_images);
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
