import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_photo_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/restaurant.dart';

class RestaurantReviewImages extends StatefulWidget {
  final Restaurant? restaurant;
  final Widget? restaurantListItem;
  final List<File> images;

  const RestaurantReviewImages(
      {super.key,
      required this.restaurant,
      this.restaurantListItem,
      required this.images});
  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewImagesState createState() => _RestaurantReviewImagesState();
}

class _RestaurantReviewImagesState extends State<RestaurantReviewImages> {
  final ImagePicker _picker = ImagePicker();
  late List<File> _images;

  @override
  void initState() {
    super.initState();
    _images =
        List.from(widget.images); // make a modifiable copy of widget.images
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.restaurantListItem != null) widget.restaurantListItem!,
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Del noen bilder av besøket ditt",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 1, // Always show 6 items
                itemBuilder: (context, index) {
                  if (index < _images.length) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.file(_images[index], fit: BoxFit.cover),
                    );
                  }
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Legg til bilder',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(Icons.add, color: Colors.grey[400]),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (widget.images.isNotEmpty)
              ElevatedButton(
                onPressed: () => Navigator.pop(context, widget.images),
                child: const Text("Submit Images"),
              ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _pickImages() async {
    if (_images.length < 6) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.83, // This means 90% of screen height
            child: RestaurantReviewPhotoPicker(
              onImagesSelected: (selectedImages) {
                setState(() {
                  _images.addAll(selectedImages);
                });
              },
              // you can pass other required parameters if any
            ),
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 6 images only!")));
    }
  }
}
