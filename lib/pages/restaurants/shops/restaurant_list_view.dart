import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../model/restaurant.dart';
import '../restaurant_page.dart';

class RestaurantListView extends StatefulWidget {
  final TextEditingController searchController;
  final List<Restaurant> restaurants;

  const RestaurantListView({
    Key? key,
    required this.searchController,
    required this.restaurants,
  }) : super(key: key);

  @override
  _RestaurantListViewState createState() => _RestaurantListViewState();
}

class _RestaurantListViewState extends State<RestaurantListView>
    with AutomaticKeepAliveClientMixin {
  List<Restaurant> _filteredRestaurants = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filteredRestaurants =
        widget.restaurants; // initialize with the passed restaurants
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (widget.searchController.text.trim().isEmpty) {
        _filteredRestaurants = widget.restaurants;
      } else {
        _filteredRestaurants = widget.restaurants
            .where((restaurant) => restaurant.name
                .toLowerCase()
                .contains(widget.searchController.text.trim().toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: ListView.builder(
        cacheExtent: 500,
        itemCount: _filteredRestaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _filteredRestaurants[index];

          // Pre-cache the restaurant cover image
          precacheImage(NetworkImage(restaurant.coverImg ?? ''), context);

          // Here, we removed the logic to fetch more restaurants since it was
          // based on the total restaurants list from the provider.
          // If you still want to handle pagination, consider modifying this logic
          // based on _filteredRestaurants.

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantPage(restaurant: restaurant),
                ),
              );
            },
            child: _buildRestaurantListItem(context, restaurant),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantListItem(BuildContext context, Restaurant restaurant) {
    return Column(
      children: [
        ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: restaurant.coverImg ?? '',
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
            restaurant.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                restaurant.description ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Space between description and rating
              Row(
                children: [
                  Text('${restaurant.rating ?? 'N/A'} ★'),
                  const SizedBox(
                      width: 10), // Space between rating and price level
                  Text(getPriceLevelSigns(restaurant.priceLevel)),
                ],
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
      ],
    );
  }

  String getPriceLevelSigns(int? priceLevel) {
    switch (priceLevel) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return 'N/A';
    }
  }
}
