import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:goodie/bloc/auth_provider.dart';
import 'package:goodie/data/review_gesture_data.dart';
import 'package:goodie/main.dart';
import 'package:goodie/utils/image.dart';
import 'package:preload_page_view/preload_page_view.dart';

import '../../bloc/restaurant_provider.dart';
import '../../bloc/user_review_provider.dart';
import '../../model/restaurant.dart';
import '../../model/user.dart';
import 'feed_media_item.dart';
import 'feed_restaurant_info.dart';

const _animationForwardValue = 0.5;

class ReviewListItem extends StatefulWidget {
  final RestaurantReview review;
  final Restaurant restaurant;
  final RestaurantProvider restaurantProvider;
  final UserReviewProvider reviewProvider;
  final User user;

  const ReviewListItem({
    super.key,
    required this.review,
    required this.restaurant,
    required this.restaurantProvider,
    required this.reviewProvider,
    required this.user,
  });

  @override
  State<ReviewListItem> createState() => _ReviewListItemState();
}

class _ReviewListItemState extends State<ReviewListItem>
    with TickerProviderStateMixin {
  Restaurant get restaurant => widget.restaurant;

  List<MediaItem> _mediaItems = [];

  bool _isImagesHandled = false;

  bool isLiked = false;

  bool isBookmarked = false;

  final PreloadPageController _pageController = PreloadPageController();
  int _currentPage = 0;

  ValueNotifier<bool> videoInitializedNotifier = ValueNotifier<bool>(false);

  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;
  late final Animation<double> _opacityAnimation;

  User get user => widget.user;

  String? reviewUsername;

  @override
  void initState() {
    isLiked = user.favoriteReviews.contains(widget.review.id);
    isBookmarked = user.bookmarkedReviews.contains(widget.review.id);

    _fetchReviewUsername();

    _initAnimation();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
    super.initState();
  }

  Future<void> _fetchReviewUsername() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(widget.review.userId).get();

      if (userDoc.exists) {
        setState(() {
          reviewUsername = userDoc['username'];
        });
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching username: $e");
    }
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
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture and User Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.restaurant.coverImg ??
                        "https://example.com/default.jpg"),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    reviewUsername ?? "brukernavn",
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
                    style: TextButton.styleFrom(
                      foregroundColor: accent2Color, // Text color
                    ),
                    child: const Text("Follow"),
                  ),
                  const SizedBox(
                      width:
                          10), // Add some spacing between the button and the icon
                  const Icon(Icons.more_horiz),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PreloadPageView.builder(
                  controller: _pageController,
                  itemCount: _mediaItems.length,
                  preloadPagesCount:
                      3, // Adjust this value to control the number of pages to preload
                  itemBuilder: (context, index) {
                    final media = _mediaItems[index];
                    return FeedMediaItem(
                        mediaItem: media,
                        reviewProvider: widget.reviewProvider,
                        onDoubleTap: () => _handleOnLike(isDoubleTap: true));
                  }),
              if (_mediaItems.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.all(8.0), // Padding around the text
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(
                          8.0), // Optional: to round the corners
                    ),
                    child: Text(
                        "${(_currentPage + 1).toString()}/${_mediaItems.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Positioned(
                    top: 0,
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _sizeAnimation
                            .drive(Tween<double>(begin: 0, end: 1)),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                accent2Color,
                                amberColor.withOpacity(0.7)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child:
                              const Icon(Icons.favorite, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _handleOnLike,
                            child: StreamBuilder<int>(
                              stream: getLikeCount(widget.review.id!),
                              builder: (context, snapshot) {
                                int likeCount = 0;
                                if (snapshot.hasData) {
                                  likeCount = snapshot.data!;
                                }

                                if (likeCount == 0) {
                                  if (isLiked) {
                                    likeCount = 1;
                                  }
                                } else if (likeCount == 1) {
                                  if (!isLiked) {
                                    likeCount = 0;
                                  }
                                }

                                return AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      return Row(
                                        children: [
                                          Icon(
                                            isLiked
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isLiked
                                                ? accent2Color
                                                : Colors.grey[600],
                                          ),
                                          Text(
                                            ' $likeCount',
                                            style: TextStyle(
                                                color: isLiked
                                                    ? accent2Color
                                                    : Colors.grey[600]),
                                          ),
                                        ],
                                      );
                                    });
                              },
                            ),
                          ),

                          const SizedBox(width: 15),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline,
                                  color: Colors.grey[600]),
                              Text(' ${widget.review.comments?.length ?? 0}',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                          //TODO: Add share functionality
                          // const SizedBox(width: 15),
                          // Icon(Icons.send_outlined,
                          //     color: Colors.grey[600]),
                        ],
                      ),
                      GestureDetector(
                        onTap: _handleOnBookmark,
                        child: StreamBuilder<int>(
                            stream: getBookmarkCount(widget.review.id!),
                            builder: (context, snapshot) {
                              int bookmarkCount = 0;
                              if (snapshot.hasData) {
                                bookmarkCount = snapshot.data!;
                              }

                              if (bookmarkCount == 0) {
                                if (isBookmarked) {
                                  bookmarkCount = 1;
                                }
                              } else if (bookmarkCount == 1) {
                                if (!isBookmarked) {
                                  bookmarkCount = 0;
                                }
                              }
                              return Row(
                                children: [
                                  Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? amberColor
                                        : Colors.grey[600],
                                  ),
                                  Text(' $bookmarkCount',
                                      style: TextStyle(
                                          color: isBookmarked
                                              ? amberColor
                                              : Colors.grey[600]))
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                  // Dots indicator
                  _buildPageCountIndicator(),
                ],
              ),

              const SizedBox(height: 10),

              // Review Text (Caption)
              if (widget.review.description != null &&
                  widget.review.description!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            text: "${reviewUsername ?? "brukernavn"} ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text: widget.review.description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else ...[
                // const SizedBox(height: 4),
              ],
              FeedRestaurantInfo(
                restaurant: restaurant,
                review: widget.review,
              ),
              const Divider(),
            ],
          ),
        )
      ],
    );
  }

  Stream<int> getLikeCount(String reviewId) {
    // Reference to the "likes" subcollection for the given review
    CollectionReference likesRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .collection('likes');
    // Listen to the collection and count the number of documents (likes)
    return likesRef.snapshots().map((snapshot) => snapshot.docs.length);
  }

  Stream<int> getBookmarkCount(String reviewId) {
    CollectionReference bookmarksRef = FirebaseFirestore.instance
        .collection('reviews')
        .doc(reviewId)
        .collection('bookmarks');
    return bookmarksRef.snapshots().map((snapshot) => snapshot.docs.length);
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
    }
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    );

    _sizeAnimation = Tween<double>(begin: 1, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildPageCountIndicator() {
    if (_mediaItems.length > 1) {
      return Padding(
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
                color: _currentPage == index ? primaryColor : Colors.grey,
              ),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  void _handleOnLike({bool isDoubleTap = false}) {
    bool previous = isLiked;
    bool liked = isDoubleTap ? true : !isLiked;

    setState(() {
      isLiked = liked;
    });

    if (liked) {
      _controller.forward(from: _animationForwardValue).then((_) {
        _controller.reverse();
      });

      if (previous == false) likeReview(widget.review.id!, user);
    } else {
      unlikeReview(widget.review.id!, user);
    }
  }

  void _handleOnBookmark() {
    bool previous = isBookmarked;
    bool bookmarked = !isBookmarked;

    setState(() {
      isBookmarked = bookmarked;
    });

    if (bookmarked) {
      if (previous == false) bookmarkReview(widget.review.id!, user);
    } else {
      unbookmarkReview(widget.review.id!, user);
    }
  }
}
