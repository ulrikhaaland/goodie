import 'package:flutter/material.dart';
import 'package:goodie/bloc/location.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_list_view.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_map_view.dart';
import 'package:provider/provider.dart';

import '../../../bloc/filter.dart';
import '../../../bloc/restaurants.dart';
import '../../../model/restaurant.dart';
import 'filter_bottom_sheet.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  bool isMapView = false; // to toggle between map and list view
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _filteredRestaurants = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    filterProvider.name = _searchController.text;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    super.build(context);

    final allRestaurants = Provider.of<RestaurantProvider>(context).restaurants;
    final filterProvider = context.watch<FilterProvider>();

    final userLocation = Provider.of<LocationProvider>(context).currentLocation;

    if (filterProvider.filter.isActive) {
      _filteredRestaurants =
          filterProvider.applyFilter(allRestaurants, userLocation);
    } else {
      _filteredRestaurants = allRestaurants;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        leading: IconButton(
          icon: Icon(
            isMapView ? Icons.list : Icons.map,
            color: Colors.black,
          ),
          onPressed: () {
            setState(() {
              isMapView = !isMapView; // toggle map/list view
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search for restaurants...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white),
            icon: Icon(Icons.search, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: isMapView
          ? RestaurantMapView(
              restaurants: _filteredRestaurants,
              searchController: _searchController)
          : RestaurantListView(
              restaurants: _filteredRestaurants,
              searchController: _searchController),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FilterBottomSheet();
      },
    );
  }
}
