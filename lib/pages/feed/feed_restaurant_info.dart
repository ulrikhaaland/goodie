import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:goodie/model/restaurant.dart';
import 'package:goodie/utils/location.dart';

class FeedRestaurantInfo extends StatefulWidget {
  final Restaurant restaurant;
  final RestaurantReview review;
  const FeedRestaurantInfo(
      {super.key, required this.restaurant, required this.review});

  @override
  State<FeedRestaurantInfo> createState() => _FeedRestaurantInfoState();
}

class _FeedRestaurantInfoState extends State<FeedRestaurantInfo> {
  Restaurant get restaurant => widget.restaurant;

  String? get city => extractCity(restaurant.address!);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // restaurant name
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant,
                  color: textColor,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  restaurant.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (city != null)
              Text(
                "${city!}, Norway",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
          ],
        ),
        // restaurant rating
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              restaurant.rating.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
        // expand to see more
        const Row(
          children: [
            Icon(
              Icons.expand_more,
              color: Colors.grey,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Vis mer',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
