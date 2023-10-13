import 'package:flutter/material.dart';
import 'package:goodie/bloc/restaurant_provider.dart';
import 'package:goodie/bloc/user_review_provider.dart';
import 'package:goodie/pages/review/review_list_item.dart';
import 'package:goodie/pages/review/review_select_page.dart';
import 'package:goodie/pages/review/review_page_buttons.dart';
import 'package:goodie/pages/review/photo/review_photo_page.dart';
import 'package:goodie/pages/review/review_rating_page.dart';
import 'package:goodie/pages/review/review_summary_page.dart';
import 'package:provider/provider.dart';

import '../../bloc/create_review_provider.dart';
import '../../model/restaurant.dart';
import '../../utils/image.dart';

class RestaurantReviewPage extends StatefulWidget {
  const RestaurantReviewPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage>
    with AutomaticKeepAliveClientMixin {
  final PageController _pageController = PageController();
  late final CreateRestaurantReviewProvider _reviewProvider;

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

  int _selectRestaurantId = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _reviewProvider =
        Provider.of<CreateRestaurantReviewProvider>(context, listen: false);
    restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    _reviewProvider.restaurants = restaurantProvider.restaurants;

    _reviewProvider.selectedAssetsNotifier.addListener(_rebuild);
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
              key: const Key("picker"),
              restaurantListItem: RestaurantReviewListItem(
                  key: Key(_selectedRestaurant?.id ?? "listitem"),
                  selectedRestaurant: _selectedRestaurant),
              reviewProvider: _reviewProvider,
              isCurrentPage: _pageIndex == 0,
            ),
            ResturantReviewSelectPage(
              key: Key(_selectRestaurantId.toString()),
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
              review: _reviewProvider.review,
              listItem: RestaurantReviewListItem(
                  key: Key(_selectedRestaurant?.id ?? "listitem"),
                  selectedRestaurant: _selectedRestaurant),
            ),
            RestaurantReviewSummaryPage(
              key: Key(_selectedRestaurant?.id ?? "summary"),
              reviewProvider: _reviewProvider,
              onDatePick: () {
                setState(() {});
              },
              listItem: RestaurantReviewListItem(
                  key: Key(_selectedRestaurant?.id ?? "listitem"),
                  selectedRestaurant: _selectedRestaurant),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ReviewPageButtons(
            isSubmit: _pageIndex == 2,
            canSubmit: _getCanSubmit(),
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
      _handleOnReview();
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

  @override
  void dispose() {
    _pageController.dispose();
    _reviewProvider.selectedAssetsNotifier.removeListener(_rebuild);

    super.dispose();
  }

  void _handleOnReview() {
    // TODO: Add review to feed list
    UserReviewProvider userReviewProvider =
        Provider.of<UserReviewProvider>(context, listen: false);

    _canSubmit = false;
    _selectRestaurantId++;
    _pageIndex = 0;
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    _reviewProvider.onShareReview(userReviewProvider);
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

  _getCanSubmit() {
    if (_pageIndex == 2) return _canSubmit;

    if (_pageIndex == 3) {
      if (_reviewProvider.review.timestamp != null) return true;
      return false;
    }

    return true;
  }

  void _rebuild() {
    setState(() {});
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
