import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_list_view.dart';
import 'package:goodie/pages/review/review_review.dart';

import '../../model/restaurant.dart';

class RestaurantReviewPage extends StatefulWidget {
  const RestaurantReviewPage({super.key});

  @override
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage>
    with AutomaticKeepAliveClientMixin {
  Restaurant? _selectedRestaurant;
  RestaurantReview? review;

  PageController _pageController = PageController();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PageView(
      controller: _pageController,
      physics:
          const NeverScrollableScrollPhysics(), // so users can't swipe between them
      children: [
        ResturantReviewSelect(
          onSelectRestaurant: (restaurant) {
            _onSelectRestaurant(restaurant);
          },
        ),
        RestaurantReviewReview(
            restaurant: _selectedRestaurant,
            onReviewRestaurant: (review) {
              _onReviewRestaurant(review);
            }),
        // Add the Image review mode here as the third child.
      ],
    );
  }

  void _onSelectRestaurant(Restaurant restaurant) {
    setState(() {
      _selectedRestaurant = restaurant;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  void _onReviewRestaurant(RestaurantReview review) {
    setState(() {
      this.review = review;
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
