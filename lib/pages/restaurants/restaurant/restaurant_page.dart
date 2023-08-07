// ignore: file_names
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/pages/restaurants/restaurant/restaurant_info.dart';
import 'package:provider/provider.dart';

import '../../../bloc/restaurants.dart';
import '../../../model/restaurant.dart';
import 'dish_list_view.dart';

class RestaurantPage extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantPage({super.key, required this.restaurant});

  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  int _currentIndex = 0;
  late Future<void> _fetchDishesFuture;

  void _handleIndexChanged(int i) {
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDishesFuture = Provider.of<RestaurantProvider>(context, listen: false)
        .fetchDishesAndPrecacheImages(widget.restaurant.id, context);
  }

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
                      imageUrl: widget.restaurant.coverImg ?? '',
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
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.black54,
                    indicatorColor: Colors.pink,
                    indicatorPadding:
                        const EdgeInsets.symmetric(horizontal: 8.0),
                    onTap: _handleIndexChanged,
                    tabs: const [
                      Tab(text: 'Info'),
                      Tab(text: 'Retter'),
                      Tab(text: 'Anmeldelser'),
                    ],
                  ),
                  Expanded(
                    child: IndexedStack(
                      index: _currentIndex,
                      children: [
                        // First tab view: Info
                        RestaurantInfo(restaurant: widget.restaurant),
                        // Second tab view: Dishes
                        FutureBuilder(
                          future: _fetchDishesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error loading dishes'));
                            } else {
                              return DishListView(
                                  dishes: widget.restaurant.dishes);
                            }
                          },
                        ),
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
                  widget.restaurant.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline), // Heart icon
                onPressed: () {
                  // Your logic for liking the restaurant
                },
              ),
            ],
          ),
          Text(
            widget.restaurant.description ?? '',
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
