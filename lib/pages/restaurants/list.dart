import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goodie/model/restaurant.dart';
import 'package:goodie/pages/restaurants/restaurantPage.dart';
import 'package:provider/provider.dart';

import '../../bloc/restaurants.dart';
import '../../data/migration.dart';

const String supabaseUrl = 'https://xossbtgfgksqdmetvguv.supabase.co';
const String supabaseApiKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhvc3NidGdmZ2tzcWRtZXR2Z3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODMyODYzNjcsImV4cCI6MTk5ODg2MjM2N30.-S8-AMyJetyf17YNZ1WS9MtmmSzNJZLUP9xrMr5f_2I'; // Replace this with your actual key

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>
    with AutomaticKeepAliveClientMixin {
  bool isMapView = false; // to toggle between map and list view

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // runMigration();
    super.initState();
  }

  void runMigration() async {
    var migration = DataMigration(supabaseUrl, supabaseApiKey);

    List<Restaurant> restaurants = await migration.fetchRestaurants();

    await migration.uploadRestaurantsToFirestore(restaurants);
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
              isMapView = !isMapView; // toggle map/list view
            });
          },
        ),
        title: const TextField(
          decoration: InputDecoration(
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
              // logic to open filter options
            },
          ),
        ],
      ),
      body: isMapView ? _buildMapView() : _buildListView(),
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

  Widget _buildListView() {
    return Consumer<RestaurantProvider>(
      builder: (context, restaurantProvider, child) {
        final restaurants = restaurantProvider.restaurants;

        return ListView.builder(
          cacheExtent: 500,
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];

            // Pre-cache the restaurant cover image
            precacheImage(NetworkImage(restaurant.coverImg ?? ''), context);

            // If approaching the end of the list, load more
            if (index == restaurants.length - 10) {
              restaurantProvider.fetchMoreRestaurants();
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantPage(restaurant: restaurant),
                  ),
                );
              },
              child: Column(
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
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        width: 50, // Set the width
                        height: 50, // Set the height
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      restaurant.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          restaurant.description ?? '',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                            height: 2), // Space between description and rating
                        Row(
                          children: [
                            Text('${restaurant.rating ?? 'N/A'} ★'),
                            const SizedBox(
                                width:
                                    10), // Space between rating and price level
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMapView() {
    // Build the map view of restaurants
    return Container(); // placeholder for now
  }
}
