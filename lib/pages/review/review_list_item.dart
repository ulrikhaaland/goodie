import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../model/restaurant.dart';

class RestaurantReviewListItem extends StatelessWidget {
  final Restaurant? selectedRestaurant;

  const RestaurantReviewListItem({Key? key, this.selectedRestaurant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (selectedRestaurant == null) return Container();

    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: selectedRestaurant!.coverImg ?? '',
              placeholder: (context, url) => const SizedBox(
                width: 50, // Set the width
                height: 50, // Set the height
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 50, // Set the width
              height: 50, // Set the height
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            selectedRestaurant!.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                selectedRestaurant!.description ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Space between description and rating
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }
}
