import 'dart:io';
import 'package:flutter/material.dart';
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
                itemCount: 6, // Always show 6 items
                itemBuilder: (context, index) {
                  if (index < widget.images.length) {
                    return Image.file(widget.images[index], fit: BoxFit.cover);
                  }
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.add, color: Colors.grey[400]),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Add Image"),
            ),
            const SizedBox(height: 20),
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

  _pickImage() async {
    if (widget.images.length < 6) {
      // Ensure not more than 6 images are added
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          widget.images.add(File(pickedFile.path));
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 6 images only!")));
    }
  }
}
