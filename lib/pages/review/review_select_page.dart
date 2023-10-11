import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:provider/provider.dart';

import '../../../model/restaurant.dart';
import '../../bloc/restaurant_provider.dart';
import '../../widgets/gradient_circular_progress.dart';

class ResturantReviewSelectPage extends StatefulWidget {
  final Function(Restaurant) onSelectRestaurant;
  final List<Restaurant> restaurants;
  final Restaurant? selectedRestaurant;

  const ResturantReviewSelectPage({
    Key? key,
    required this.onSelectRestaurant,
    required this.restaurants,
    required this.selectedRestaurant,
  }) : super(key: key);

  @override
  _ResturantReviewSelectPageState createState() =>
      _ResturantReviewSelectPageState();
}

class _ResturantReviewSelectPageState extends State<ResturantReviewSelectPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _filteredRestaurants = [];
  final FocusNode _searchFocusNode = FocusNode();
  List<Restaurant> _allRestaurants = [];

  @override
  void initState() {
    super.initState();
    _allRestaurants = widget.restaurants;
    _filteredRestaurants = _allRestaurants;

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
      _filteredRestaurants = _allRestaurants;
    } else {
      _filteredRestaurants = _allRestaurants
          .where((restaurant) => restaurant.name
              .toLowerCase()
              .contains(_searchController.text.trim().toLowerCase()))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24.0),
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                'Hvilken restaurant vil du anmelde?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                focusNode: _searchFocusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Søk',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                cacheExtent: 500,
                itemCount: _filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = _filteredRestaurants[index];
                  precacheImage(
                      NetworkImage(restaurant.coverImg ?? ''), context);
                  return InkWell(
                    onTap: () {
                      widget.onSelectRestaurant.call(restaurant);
                      _searchFocusNode.unfocus();
                    },
                    child: _buildRestaurantListItem(context, restaurant),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantListItem(BuildContext context, Restaurant restaurant) {
    bool isSelected = widget.selectedRestaurant == restaurant;

    return Column(
      children: [
        if (isSelected)
          Card(
            elevation: 3.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            color: Colors.grey[50], // subtle off-white
            child: _listTileContent(restaurant),
          )
        else
          _listTileContent(restaurant),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(),
        ),
      ],
    );
  }

  Widget _listTileContent(Restaurant restaurant) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: restaurant.coverImg ?? '',
          placeholder: (context, url) => const SizedBox(
              width: 50,
              height: 50,
              child: GradientCircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: 50,
          height: 50,
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
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                  '${restaurant.rating.toString().length == 1 ? "${restaurant.rating}.0" : restaurant.rating ?? 'N/A'} ★'),
              const SizedBox(width: 10),
              Text(getPriceLevelSigns(restaurant.priceLevel)),
              const Spacer(),
              ...restaurant.categories
                  .take(2)
                  .map((category) => Text(
                        category +
                            (restaurant.categories.first == category
                                ? ", "
                                : ""),
                        style: const TextStyle(fontSize: 12, color: textColor),
                      ))
                  .toList(),
            ],
          ),
        ],
      ),
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
