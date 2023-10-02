import 'package:flutter/material.dart';
import 'package:goodie/pages/home/review_list_item.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../bloc/restaurant_provider.dart';
import '../../bloc/user_review_provider.dart';
import '../../model/restaurant.dart'; // Import your RestaurantReview model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final GlobalKey<LiquidPullToRefreshState> _refreshIndicatorKey =
      GlobalKey<LiquidPullToRefreshState>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reviewProvider = Provider.of<UserReviewProvider>(context);

    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Goodie',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 8,
        centerTitle: true,
      ),
      body: LiquidPullToRefresh(
        key: _refreshIndicatorKey,
        onRefresh: () async {
          await Provider.of<UserReviewProvider>(context, listen: false)
              .fetchReviews();
        },
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder(
              valueListenable: reviewProvider.reviews,
              builder: (BuildContext context, List<RestaurantReview> value,
                  Widget? child) {
                return ListView.builder(
                  itemCount: value.length,
                  cacheExtent: 10000,
                  itemBuilder: (context, index) {
                    final review = value[index];
                    final restaurant =
                        restaurantProvider.restaurants.firstWhereOrNull(
                      (element) => element.id == review.restaurantId,
                    );

                    if (restaurant == null) {
                      return const SizedBox.shrink();
                    } else {
                      return ReviewListItem(
                        key: Key(restaurant.id),
                        review: review,
                        restaurant: restaurant,
                        restaurantProvider: restaurantProvider,
                        reviewProvider: reviewProvider,
                      ); // Use the ReviewListItem widget
                    }
                  },
                );
              },
            )),
      ),
    );
  }
}
