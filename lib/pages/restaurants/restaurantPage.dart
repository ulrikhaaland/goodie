// ignore: file_names
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../model/restaurant.dart';

class RestaurantPage extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantPage({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.pink[300],
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          body: Stack(
            children: [
              Column(
                children: [
                  // Cover Image occupying 1/3 of the screen
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: restaurant.coverImg ?? '',
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Colors.pink,
                    indicatorPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    tabs: [
                      Tab(text: 'Restaurant'),
                      Tab(text: 'Dishes'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildRestaurantDetails(),
                        const Text('Dishes content goes here.'),
                        const Text('Reviews content goes here.'),
                      ],
                    ),
                  ),
                ],
              ),
              // Back button and '...' button
              _buildTopButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border), // Heart icon
                onPressed: () {
                  // Your logic for liking the restaurant
                },
              ),
            ],
          ),
          Text(
            restaurant.description ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          // You can continue adding more widgets here as needed
        ],
      ),
    );
  }

  Widget _buildTopButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Back button with circular container
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Spacer(), // Pushes the next child to the end
            // '...' button
            Container(
              width: 36.0,
              height: 36.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon:
                    const Icon(Icons.more_vert, color: Colors.white, size: 20),
                onPressed: () {
                  // Your logic here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
