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
  @override
  Widget build(BuildContext context) {
    return Consumer<FilterProvider>(
      builder: (context, filterProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.drag_handle), // Center drag handle
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                "Valg",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Text("Kategori"),
              SizedBox(
                height: 170,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right:
                            8.0), // A bit of padding to ensure last item isn't flush against the edge
                    child: Column(
                      children: [
                        // First row
                        Wrap(
                          children: filterProvider.uniqueCategories
                              .getRange(
                                  0,
                                  (filterProvider.uniqueCategories.length / 3)
                                      .ceil())
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            String category = entry.value;
                            return _buildCategoryChip(
                                category, filterProvider, idx);
                          }).toList(),
                        ),

                        // Second row
                        Wrap(
                          children: filterProvider.uniqueCategories
                              .getRange(
                                  (filterProvider.uniqueCategories.length / 3)
                                      .ceil(),
                                  ((filterProvider.uniqueCategories.length /
                                              3) *
                                          2)
                                      .ceil())
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            String category = entry.value;
                            return _buildCategoryChip(
                                category, filterProvider, idx);
                          }).toList(),
                        ),

                        // Third row
                        Wrap(
                          children: filterProvider.uniqueCategories
                              .getRange(
                                  ((filterProvider.uniqueCategories.length /
                                              3) *
                                          2)
                                      .ceil(),
                                  filterProvider.uniqueCategories.length)
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) {
                            int idx = entry.key;
                            String category = entry.value;
                            return _buildCategoryChip(
                                category, filterProvider, idx);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Sorter på"),
              Wrap(
                children: FilterCriteria.values.map((criteria) {
                  return ChoiceChip(
                    label: Text(criteria.toString().split('.').last),
                    selected: filterProvider.filter.criteria == criteria,
                    onSelected: (selected) {
                      setState(() {
                        filterProvider.criteria = selected ? criteria : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (filterProvider.filter.isActive) {
                    Navigator.pop(context, filterProvider.filter);
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(filterProvider.filter.isActive
                    ? "Activate Filter"
                    : "Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(
      String category, FilterProvider filterProvider, int index) {
    return Padding(
      padding: EdgeInsets.only(
        left: (index == 0) ? 0 : 8.0, // No left padding if it's the first item
        right: 8.0,
        top: 8.0,
      ),
      child: ChoiceChip(
        label: Text(category),
        selected: filterProvider.filter.categories.contains(category),
        onSelected: (selected) {
          Set<String> categories = filterProvider.filter.categories.toSet();

          if (selected) {
            categories.add(category);
          } else {
            categories.remove(category);
          }
          filterProvider.categories = categories;
        },
      ),
    );
  }
}
