import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_list_view.dart';
import 'package:provider/provider.dart';

import '../../bloc/restaurants.dart';
import '../../model/restaurant.dart';

class RestaurantReviewPage extends StatefulWidget {
  const RestaurantReviewPage({super.key});

  @override
  _RestaurantReviewPageState createState() => _RestaurantReviewPageState();
}

class _RestaurantReviewPageState extends State<RestaurantReviewPage>
    with AutomaticKeepAliveClientMixin {
  double ratingFood = 5;
  double ratingService = 5;
  bool dineIn = true;
  String? description;

  @override
  bool get wantKeepAlive => true;

  Future<void> _selectRestaurant(BuildContext context) async {
    // Fetch all restaurants initially.
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    final _allRestaurants = restaurantProvider.restaurants;

    Restaurant? selectedRestaurant = await showModalBottomSheet<Restaurant>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: RestaurantReviewListView(
            restaurants:
                _allRestaurants, // Make sure you have the restaurant list available here
            onSelectRestaurant: (restaurant) {
              Navigator.of(context).pop(restaurant);
            },
          ),
        );
      },
    );

    if (selectedRestaurant != null) {
      // Now you have the selected restaurant's details, you can use this for further processing
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Restaurant Anmeldelse")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Rate the Food"),
          Slider(
            value: ratingFood,
            onChanged: (value) {
              setState(() {
                ratingFood = value;
              });
            },
            min: 0,
            max: 10,
            divisions: 10,
            label: ratingFood.round().toString(),
          ),
          const SizedBox(height: 20),
          const Text("Rate the Service"),
          Slider(
            value: ratingService,
            onChanged: (value) {
              setState(() {
                ratingService = value;
              });
            },
            min: 0,
            max: 10,
            divisions: 10,
            label: ratingService.round().toString(),
          ),
          const SizedBox(height: 20),
          const Text("Dine-In or Takeout?"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ChoiceChip(
                label: const Text("Dine-In"),
                selected: dineIn,
                onSelected: (selected) {
                  setState(() {
                    dineIn = true;
                  });
                },
              ),
              ChoiceChip(
                label: const Text("Takeout"),
                selected: !dineIn,
                onSelected: (selected) {
                  setState(() {
                    dineIn = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: const InputDecoration(labelText: "Description"),
            maxLines: 5,
            onChanged: (value) {
              description = value;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Submit the review
            },
            child: const Text("Submit Review"),
          ),
          ElevatedButton(
            onPressed: () {
              _selectRestaurant(context);
              // After selecting, continue with other parts of the review
            },
            child: Text("Choose Restaurant"),
          ),
        ],
      ),
    );
  }
}
