import 'package:flutter/material.dart';

import '../../../model/restaurant.dart';

class RestaurantInfo extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantInfo({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return _buildRestaurantDetails();
  }

  Widget _buildRestaurantDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  restaurant.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline), // Heart icon
                onPressed: () {
                  // Your logic for liking the restaurant
                },
              ),
            ],
          ),
          Text(
            restaurant.description ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Icon(_getRatingData(restaurant.rating ?? 0)['icon'],
                  color: Colors.yellow, size: 24.0),
              SizedBox(width: 8.0),
              Text(
                _getRatingData(restaurant.rating ?? 0)['description'],
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                '${restaurant.rating}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getRatingData(num rating) {
    if (rating < 6) {
      return {'description': 'meh', 'icon': Icons.sentiment_dissatisfied};
    } else if (rating < 7) {
      return {'description': 'ok', 'icon': Icons.sentiment_neutral};
    } else if (rating < 8) {
      return {'description': 'bra', 'icon': Icons.sentiment_satisfied};
    } else if (rating < 9) {
      return {
        'description': 'veldig bra',
        'icon': Icons.sentiment_very_satisfied
      };
    } else {
      return {
        'description': 'fantastisk',
        'icon': Icons.sentiment_very_satisfied
      };
    }
  }
}
