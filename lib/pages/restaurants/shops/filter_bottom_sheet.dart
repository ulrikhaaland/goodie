import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../bloc/filter.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RestaurantFilter _localFilter;

  @override
  void initState() {
    super.initState();
    final filterProvider = Provider.of<FilterProvider>(context, listen: false);
    _localFilter = filterProvider.filter;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start, // To left-align titles
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(), // Placeholder for alignment purposes
                  CircleAvatar(
                    backgroundColor:
                        Colors.grey[300], // You can adjust this color as needed
                    radius: 20, // Adjust radius for size of the circle
                    child: IconButton(
                      iconSize: 24,
                      icon: const Icon(Icons.close,
                          color: Colors
                              .black), // Adjust color to contrast with background
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
              const Text(
                "Valg",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Kategori",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First row
                    Wrap(
                      children:
                          getCategoryForRow(1, filterProvider.uniqueCategories)
                              .map((category) {
                        return _buildCategoryChip(category, filterProvider,
                            filterProvider.uniqueCategories.indexOf(category));
                      }).toList(),
                    ),

// Second row
                    Wrap(
                      children:
                          getCategoryForRow(2, filterProvider.uniqueCategories)
                              .map((category) {
                        return _buildCategoryChip(category, filterProvider,
                            filterProvider.uniqueCategories.indexOf(category));
                      }).toList(),
                    ),

// Third row
                    Wrap(
                      children:
                          getCategoryForRow(3, filterProvider.uniqueCategories)
                              .map((category) {
                        return _buildCategoryChip(category, filterProvider,
                            filterProvider.uniqueCategories.indexOf(category));
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                "Sorter på",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: FilterCriteria.values.map((criteria) {
                    return _buildCriteriaChip(criteria, filterProvider);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, // Making the button full width
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Applying border radius
                    ),
                  ),
                  onPressed: () {
                    if (_localFilter.categories.isNotEmpty ||
                        _localFilter.criteria != null) {
                      filterProvider.categories = _localFilter.categories;
                      filterProvider.criteria = _localFilter.criteria;
                      filterProvider.name = _localFilter.name;
                      filterProvider.ratingThreshold =
                          _localFilter.ratingThreshold;
                      filterProvider.active = true;

                      Navigator.pop(context, _localFilter);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    (filterProvider.filter.categories.isNotEmpty ||
                            filterProvider.filter.criteria != null)
                        ? "Bruk"
                        : "Close",
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> getCategoryForRow(int rowNumber, List<String> uniqueCategories) {
    List<String> result = [];
    for (int i = rowNumber - 1; i < uniqueCategories.length; i += 3) {
      result.add(uniqueCategories[i]);
    }
    return result;
  }

  Widget _buildCategoryChip(
      String category, FilterProvider filterProvider, int index) {
    return Padding(
      padding: EdgeInsets.only(
        left: (index == 0) ? 0 : 4.0, // Increased gap for visual comfort
        right: 4.0,
      ),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: filterProvider.filter.categories.contains(category)
                ? Colors.white
                : Colors.black,
          ),
        ),
        selected: filterProvider.filter.categories.contains(category),
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _localFilter.categories.add(category);
            } else {
              _localFilter.categories.remove(category);
            }
          });
        },

        selectedColor: Colors.blueAccent, // Vivid color to signify selection
        backgroundColor:
            Colors.grey[200], // Soft background for unselected state
        elevation: filterProvider.filter.categories.contains(category)
            ? 6.0
            : 0, // Elevation only when selected
      ),
    );
  }

  Widget _buildCriteriaChip(
      FilterCriteria criteria, FilterProvider filterProvider) {
    String capitalizeFirstLetter(String text) {
      if (text.isEmpty) {
        return text;
      }
      return text[0].toUpperCase() + text.substring(1);
    }

    final selected = filterProvider.filter.criteria == null
        ? criteria == FilterCriteria.anbefalt
        : filterProvider.filter.criteria == criteria;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(
          capitalizeFirstLetter(criteria.toString().split('.').last),
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
        selected: selected,
        onSelected: (selected) {
          setState(() {
            _localFilter.criteria = selected ? criteria : null;
          });
        },
        selectedColor: Colors.blueAccent,
        backgroundColor: Colors.grey[200],
        elevation: selected ? 6.0 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      ),
    );
  }
}
