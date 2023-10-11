import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../model/restaurant.dart';
import '../../../widgets/gradient_circular_progress.dart';

class DishListView extends StatefulWidget {
  final List<Dish> dishes;

  const DishListView({Key? key, required this.dishes}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DishListViewState createState() => _DishListViewState();
}

class _DishListViewState extends State<DishListView>
    with AutomaticKeepAliveClientMixin {
  List<Dish> _filteredDishes = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _filteredDishes = widget.dishes;
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    String searchQuery = _searchController.text;
    if (searchQuery.isEmpty) {
      setState(() {
        _filteredDishes = widget.dishes;
      });
    } else {
      List<Dish> tempDishes = widget.dishes.where((dish) {
        return dish.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (dish.description != null &&
                dish.description!
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()));
      }).toList();
      setState(() {
        _filteredDishes = tempDishes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search dishes',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredDishes.length,
            itemBuilder: (context, index) {
              final dish = _filteredDishes[index];
              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(dish.name,
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 16.0),
                              Text(dish.description ?? "",
                                  style: const TextStyle(fontSize: 14.0)),
                              const SizedBox(height: 14.0),
                              Text('kr ${dish.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        dish.imgUrl != null && dish.imgUrl!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: dish.imgUrl ?? '',
                                  placeholder: (context, url) => const Center(
                                    child: GradientCircularProgressIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  width: 120, // Set the width
                                  height: 100, // Set the height
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(), // Empty container when there's no image
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1.0,
                    indent: 16.0,
                    endIndent: 16.0,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
