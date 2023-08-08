import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../model/restaurant.dart';
import '../restaurants/restaurant/restaurant_page.dart';

class RestaurantReviewListView extends StatefulWidget {
  final List<Restaurant> restaurants;
  final Function(Restaurant)? onSelectRestaurant;

  const RestaurantReviewListView({
    Key? key,
    required this.restaurants,
    this.onSelectRestaurant,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewListViewState createState() =>
      _RestaurantReviewListViewState();
}

class _RestaurantReviewListViewState extends State<RestaurantReviewListView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _filteredRestaurants = [];

  @override
  void initState() {
    super.initState();

    _filteredRestaurants = widget.restaurants;

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().isEmpty) {
      _filteredRestaurants = widget.restaurants;
    } else {
      _filteredRestaurants = widget.restaurants
          .where((restaurant) => restaurant.name
              .toLowerCase()
              .contains(_searchController.text.trim().toLowerCase()))
          .toList();
    }
    setState(() {}); // This will trigger a rebuild of the widget
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Column(
        children: [
          // Only show the TextField in selectMode
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Restaurants...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0)),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              cacheExtent: 500,
              itemCount: _filteredRestaurants.length, // Use the filtered list
              itemBuilder: (context, index) {
                final restaurant = _filteredRestaurants[index];

                precacheImage(NetworkImage(restaurant.coverImg ?? ''), context);
                return InkWell(
                  onTap: () {
                    widget.onSelectRestaurant?.call(restaurant);
                  },
                  child: _buildRestaurantListItem(context, restaurant),
                );
              },
            ),
          ),
        ],
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
                  Text(
                      '${restaurant.rating.toString().length == 1 ? "${restaurant.rating}.0" : restaurant.rating ?? 'N/A'} ★'),
                  const SizedBox(
                      width: 10), // Space between rating and price level
                  Text(getPriceLevelSigns(restaurant.priceLevel)),
                  const Spacer(),
                  ...restaurant.categories
                      .take(2)
                      .map((
                        category,
                      ) =>
                          Text(
                            category +
                                (restaurant.categories.first == category
                                    ? ", "
                                    : ""),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.blueAccent),
                          ))
                      .toList(),
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
