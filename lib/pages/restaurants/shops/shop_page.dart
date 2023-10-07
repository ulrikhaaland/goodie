import 'package:flutter/material.dart';
import 'package:goodie/bloc/location_provider.dart';
import 'package:goodie/main.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_list_view.dart';
import 'package:goodie/pages/restaurants/shops/restaurant_map_view.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../../bloc/bottom_nav_provider.dart';
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

  final ScrollController _listViewScrollController = ScrollController();

  late final BottomNavigationProvider bottomNavigationProvider;
  late final RestaurantProvider restaurantProvider;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);

    bottomNavigationProvider.onTapCurrentTabListener
        .addListener(_handleOnTapTab);

    // Fetch all restaurants initially.
    restaurantProvider =
        Provider.of<RestaurantProvider>(context, listen: false);

    restaurantProvider.addListener(_updateFilteredRestaurants);

    userLocation ??=
        Provider.of<LocationProvider>(context, listen: false).currentLocation;

    _searchController.addListener(_onSearchChanged);
    _filterProvider = Provider.of<FilterProvider>(context, listen: false);
    _filterProvider.addListener(_updateFilteredRestaurants);

    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _listViewScrollController.dispose();
    restaurantProvider.removeListener(_updateFilteredRestaurants);

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
        backgroundColor: primaryColor,
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
          : RestaurantListView(
              restaurants: _filteredRestaurants,
              scrollController: _listViewScrollController,
            ),
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

  void _handleOnTapTab() {
    if (bottomNavigationProvider.currentIndexListener.value == 1) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
      } else {
        _listViewScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }
}
