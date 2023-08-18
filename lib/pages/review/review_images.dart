import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_photo_picker.dart';

import '../../model/restaurant.dart';

class RestaurantReviewImages extends StatefulWidget {
  final Function(List<GoodieAsset>) onImagesSelected;
  final Restaurant? selectedRestaurant;
  final ScrollController scrollController;
  final Widget restaurantListItem;

  const RestaurantReviewImages({
    super.key,
    required this.onImagesSelected,
    this.selectedRestaurant,
    required this.scrollController,
    required this.restaurantListItem,
  });
  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewImagesState createState() => _RestaurantReviewImagesState();
}

class _RestaurantReviewImagesState extends State<RestaurantReviewImages>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant RestaurantReviewImages oldWidget) {
    if (oldWidget.selectedRestaurant?.id != widget.selectedRestaurant?.id) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: RestaurantReviewPhotoPicker(
        key: Key(widget.selectedRestaurant?.id ?? "picker"),
        scrollController: widget.scrollController,
        restaurantListItem: widget.restaurantListItem,
        onImagesSelected: (selectedImages) {
          widget.onImagesSelected(selectedImages);
        },
      ),
    );
  }
}
