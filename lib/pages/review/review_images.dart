import 'dart:io';
import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_photo_picker.dart';

import '../../model/restaurant.dart';

class RestaurantReviewImages extends StatefulWidget {
  final Restaurant? restaurant;
  final List<File> images;

  const RestaurantReviewImages(
      {super.key, required this.restaurant, required this.images});
  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewImagesState createState() => _RestaurantReviewImagesState();
}

class _RestaurantReviewImagesState extends State<RestaurantReviewImages>
    with AutomaticKeepAliveClientMixin {
  late List<File> _images;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _images =
        List.from(widget.images); // make a modifiable copy of widget.images
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
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
            child: RestaurantReviewPhotoPicker(
              onImagesSelected: (selectedImages) {
                setState(() {
                  _images.addAll(selectedImages);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
