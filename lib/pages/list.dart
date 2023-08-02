import 'package:flutter/material.dart';

import '../data/migration.dart';

const String supabaseUrl = 'https://xossbtgfgksqdmetvguv.supabase.co';
const String supabaseApiKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhvc3NidGdmZ2tzcWRtZXR2Z3V2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODMyODYzNjcsImV4cCI6MTk5ODg2MjM2N30.-S8-AMyJetyf17YNZ1WS9MtmmSzNJZLUP9xrMr5f_2I'; // Replace this with your actual key

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  bool isMapView = false; // to toggle between map and list view

  @override
  void initState() {
    runMigration();
    super.initState();
  }

  void runMigration() async {
    var migration = DataMigration(supabaseUrl, supabaseApiKey);

    List<Restaurant> restaurants = await migration.fetchRestaurants();

    await migration.uploadRestaurantsToFirestore(restaurants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
            hintStyle: TextStyle(color: Colors.grey),
            icon: Icon(Icons.search, color: Colors.grey),
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

  Widget _buildListView() {
    // Build the list view of restaurants
    return Container(); // placeholder for now
  }

  Widget _buildMapView() {
    // Build the map view of restaurants
    return Container(); // placeholder for now
  }
}
