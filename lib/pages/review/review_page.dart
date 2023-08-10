import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_images.dart';
import 'package:goodie/pages/review/review_list_view.dart';
import 'package:goodie/pages/review/review_page_buttons.dart';
import 'package:goodie/pages/review/review_progress_bar.dart';
import 'package:goodie/pages/review/review_review.dart';

import '../../model/restaurant.dart';

class RestaurantReviewPage extends StatefulWidget {
  const RestaurantReviewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage>
    with AutomaticKeepAliveClientMixin {
  Restaurant? _selectedRestaurant;
  RestaurantReview? _review;
  List<File> images = [];

  final PageController _pageController = PageController();

  int _pageIndex = 0;

  bool _canSubmit = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Column(
      children: [
        Expanded(
          child: PageView(
            controller: _pageController,
            physics:
                const NeverScrollableScrollPhysics(), // so users can't swipe between them
            children: [
              ResturantReviewSelect(
                onSelectRestaurant: (restaurant) {
                  _onSelectRestaurant(restaurant);
                },
              ),
              RestaurantReviewImages(
                restaurant: _selectedRestaurant,
                restaurantListItem: _buildRestaurantListItem(context),
                images: images,
              ),
              RestaurantReviewReview(
                  restaurant: _selectedRestaurant,
                  restaurantListItem: _buildRestaurantListItem(context),
                  onBackPressed: () => _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut),
                  onCanSubmit: (canSubmit) {
                    _handleOnCanSubmit(canSubmit);
                  },
                  onReviewRestaurant: (review) {
                    _review = review;
                  }),
              // Add the Image review mode here as the third child.
            ],
          ),
        ),
        if (_pageIndex != 0) ...[
          ReviewProgressBar(currentIndex: _pageIndex, totalPages: 4),
          ReviewPageButtons(
            isSubmit: _pageIndex == 3,
            canSubmit: _canSubmit,
            onLeftPressed: () {
              _handleOnLeftPressed();
            },
            onRightPressed: () {
              _handleOnRightPressed();
            },
          ),
        ]
      ],
    );
  }

  void _handleOnLeftPressed() {
    setState(() {
      _pageIndex = _pageIndex - 1;
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _handleOnRightPressed() {
    setState(() {
      _pageIndex = _pageIndex + 1;

      if (_pageIndex == 3) {
        _handleOnReview();
      } else {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      }
    });
  }

  void _onSelectRestaurant(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      images = [];
      _review = null;
      _pageIndex = 1;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget? _buildRestaurantListItem(BuildContext context) {
    if (_selectedRestaurant == null) return null;

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: _selectedRestaurant!.coverImg ?? '',
              placeholder: (context, url) => const SizedBox(
                width: 50, // Set the width
                height: 50, // Set the height
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 50, // Set the width
              height: 50, // Set the height
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            _selectedRestaurant!.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                _selectedRestaurant!.description ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Space between description and rating
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  void _handleOnReview() {}

  void _handleOnCanSubmit(bool canSubmit) {
    _canSubmit = canSubmit;
  }
}
