import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/bloc/restaurants.dart';
import 'package:goodie/pages/review/review_select_page.dart';
import 'package:goodie/pages/review/review_page_buttons.dart';
import 'package:goodie/pages/review/photo/review_photo_page.dart';
import 'package:goodie/pages/review/review_progress_bar.dart';
import 'package:goodie/pages/review/review_rating_page.dart';
import 'package:goodie/pages/review/review_summary_page.dart';
import 'package:provider/provider.dart';

import '../../bloc/review.dart';
import '../../model/restaurant.dart';

class RestaurantReviewPage extends StatefulWidget {
  const RestaurantReviewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  final RestaurantReviewProvider _reviewProvider = RestaurantReviewProvider();

  late final RestaurantProvider restaurantProvider;

  Restaurant? get _selectedRestaurant => _reviewProvider.selectedRestaurant;

  List<GoodieAsset> get _images => _reviewProvider.selectedAssetsNotifier.value;

  set _selectedRestaurant(Restaurant? restaurant) {
    _reviewProvider.selectedRestaurant = restaurant;
  }

  int _pageIndex = 0;

  bool _canSubmit = false;

  bool showListItem = true;

  bool hasSelectedRestaurant = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    _reviewProvider.restaurants = restaurantProvider.restaurants;

    _reviewProvider.selectedAssetsNotifier.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Stack(children: [
        PageView(
          key: const Key("pageview"),
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            RestaurantReviewPhotoPage(
              key: Key(_selectedRestaurant?.id ?? "picker"),
              restaurantListItem: _buildRestaurantListItem(context),
              reviewProvider: _reviewProvider,
            ),
            ResturantReviewSelectPage(
              restaurants: _reviewProvider.restaurants,
              selectedRestaurant: _selectedRestaurant,
              onSelectRestaurant: (restaurant) {
                _onSelectRestaurant(restaurant);
              },
            ),
            RestaurantReviewRatingPage(
              key: Key(_selectedRestaurant?.id ?? "review"),
              restaurant: _selectedRestaurant,
              onBackPressed: () => _pageController.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut),
              onCanSubmit: (canSubmit) {
                _handleOnCanSubmit(canSubmit);
              },
              review: _reviewProvider.getReview(),
              listItem: _buildRestaurantListItem(context),
            ),
            RestaurantReviewSummaryPage(
              key: Key(_selectedRestaurant?.id ?? "summary"),
              reviewProvider: _reviewProvider,
              listItem: _buildRestaurantListItem(context),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ReviewPageButtons(
            isSubmit: _pageIndex == 2,
            canSubmit: _pageIndex == 2 ? _canSubmit : true,
            rightButtonText: _getRightButtonText(),
            hideLeftButton: _pageIndex == 0,
            hideRightButton: _pageIndex == 1 &&
                (_selectedRestaurant == null || hasSelectedRestaurant == false),
            onLeftPressed: () {
              _handleOnLeftPressed();
            },
            onRightPressed: () {
              _handleOnRightPressed();
            },
          ),
        ),
      ]),
    );
  }

  void _handleOnLeftPressed() {
    _pageIndex = _pageIndex - 1;

    setState(() {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _handleOnRightPressed() {
    if (_pageIndex == 3) {
      _reviewProvider.onShareReview();
      return;
    }

    if (_pageIndex == 2 && _canSubmit == false) {
      return;
    }

    setState(() {
      _pageIndex = _pageIndex + 1;

      if (_pageIndex == 1 &&
          _reviewProvider.selectedRestaurant != null &&
          !hasSelectedRestaurant) {
        _pageController.jumpToPage(2);
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
      if (hasSelectedRestaurant == false) {
        _pageIndex = 2;
        _pageController.nextPage(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut);
      }
    });
    hasSelectedRestaurant = true;
  }

  void _handleListItem() {
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && _pageIndex == 1) {
        setState(() {
          showListItem = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  Widget _buildRestaurantListItem(BuildContext context) {
    if (_selectedRestaurant == null) return Container();

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

  void _handleOnReview() {
    print("Review");
  }

  void _handleOnCanSubmit(bool canSubmit) {
    setState(() {
      _canSubmit = canSubmit;
    });
  }

  String _getRightButtonText() {
    if (_pageIndex == 0) {
      if (_images.isNotEmpty) {
        return "Velg ${_images.length}";
      } else {
        return "Hopp over";
      }
    } else if (_pageIndex == 3) {
      return "Del";
    }
    return "Neste";
  }
}

class LeftOnlyScrollPhysics extends ScrollPhysics {
  const LeftOnlyScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  LeftOnlyScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return LeftOnlyScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // If trying to scroll to the right by a user (non-zero velocity), disallow it
    if (value > position.pixels && position.outOfRange) {
      return value - position.pixels;
    }
    return 0.0;
  }
}
