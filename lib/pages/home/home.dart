import 'package:flutter/material.dart';
import 'package:goodie/pages/home/review_list_item.dart';
import 'package:provider/provider.dart';
import 'package:goodie/model/review.dart';

import '../../bloc/restaurants.dart';
import '../../bloc/user_reviews.dart'; // Import your RestaurantReview model

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reviews = Provider.of<UserReviewProvider>(context)
        .reviews; // Get the list of reviews

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
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final restaurant = restaurantProvider.restaurants.firstWhere(
                (element) => element.id == review.restaurantId,
              );
              return ReviewListItem(
                review: review,
                restaurant: restaurant,
                restaurantProvider: restaurantProvider,
              ); // Use the ReviewListItem widget
            },
          )),
    );
  }
}
