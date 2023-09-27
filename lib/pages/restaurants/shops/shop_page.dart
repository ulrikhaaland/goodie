import 'package:flutter/material.dart';
import 'package:goodie/bloc/location_provider.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_list_view.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_map_view.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../../bloc/filter_provider.dart';
import '../../../bloc/restaurant_provider.dart';
import '../../../model/restaurant.dart';
import 'filter_bottom_sheet.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  bool isMapView = false;
  final TextEditingController _searchController = TextEditingController();
  List<Restaurant> _filteredRestaurants = [];
  LocationData? userLocation;
  late final FilterProvider _filterProvider;
  RestaurantFilter get _filter => _filterProvider.filter;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Fetch all restaurants initially.
    final restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    restaurantProvider.addListener(() {
      setState(() {
        _filteredRestaurants = restaurantProvider.restaurants;
      });
    });

    userLocation ??=
        Provider.of<LocationProvider>(context, listen: false).currentLocation;

    _searchController.addListener(_onSearchChanged);
    _filterProvider = Provider.of<FilterProvider>(context, listen: false);
    _filterProvider.addListener(_updateFilteredRestaurants);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final allRestaurants =
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;

    if (_searchController.text.trim().isEmpty) {
      _filterProvider.name = null;
      _filteredRestaurants = allRestaurants;
    } else {
      _filterProvider.name = _searchController.text.trim();
      _filteredRestaurants = allRestaurants
          .where((restaurant) => restaurant.name
              .toLowerCase()
              .contains(_searchController.text.trim().toLowerCase()))
          .toList();
    }
    _updateFilteredRestaurants(searchFilteredRestaurants: _filteredRestaurants);
  }

  void _updateFilteredRestaurants(
      {List<Restaurant>? searchFilteredRestaurants}) {
    final restaurants = searchFilteredRestaurants ??
        Provider.of<RestaurantProvider>(context, listen: false).restaurants;

    if (_searchController.text.trim().isEmpty &&
        (!_filter.isActive ||
            (_filter.categories.isEmpty &&
                _filter.criteria == FilterCriteria.anbefalt))) {
      _filteredRestaurants = restaurants;
    } else {
      _filteredRestaurants =
          _filterProvider.applyFilter(restaurants, userLocation);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
              isMapView = !isMapView;
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
            icon: Icon(Icons.filter_list,
                color: _filter.isActive &&
                        (_filter.categories.isNotEmpty ||
                            _filter.criteria != FilterCriteria.anbefalt)
                    ? Colors.blueAccent
                    : Colors.black),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
      ),
      body: isMapView
          ? RestaurantMapView(restaurants: _filteredRestaurants)
          : RestaurantListView(restaurants: _filteredRestaurants),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return const FilterBottomSheet();
      },
    );
  }
}
