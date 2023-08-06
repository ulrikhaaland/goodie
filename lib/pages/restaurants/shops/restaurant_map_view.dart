import 'package:flutter/material.dart';

import '../../../model/restaurant.dart';

class RestaurantMapView extends StatefulWidget {
  final TextEditingController searchController;
  final List<Restaurant> restaurants;

  const RestaurantMapView({
    Key? key,
    required this.searchController,
    required this.restaurants,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantMapViewState createState() => _RestaurantMapViewState();
}

class _RestaurantMapViewState extends State<RestaurantMapView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
  }
}
