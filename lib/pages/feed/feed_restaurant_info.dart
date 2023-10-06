import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:goodie/model/restaurant.dart';
import 'package:goodie/utils/location.dart';

import '../../utils/date.dart';
import '../../utils/rating.dart';
import '../restaurants/restaurant/restaurant_page.dart';

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

  RestaurantReview get review => widget.review;

  RestaurantReviewRating get rating => review.rating;

  String? get city => extractCity(restaurant.address!);

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // restaurant name
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Icon(
                    review.dineIn
                        ? Icons.location_on_outlined
                        : Icons.takeout_dining_outlined,
                    color: textColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        // push restaurant page view
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RestaurantPage(
                              restaurant: restaurant,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        overflow: _expanded
                            ? TextOverflow.clip
                            : TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (city != null)
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.grey[600],
                  ),
                  Text(
                    "${city!}, Norway",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
          ],
        ),
        // restaurant rating
        Row(
          children: [
            Icon(
              Icons.star_outline_outlined,
              color: Colors.amber[600],
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
            // rating data description
            // const SizedBox(
            //   width: 8,
            // ),
            // Text(
            //   getRatingData(restaurant.rating)?.description ?? "",
            //   style: TextStyle(
            //     color: Colors.grey[600],
            //     fontSize: 14,
            //   ),
            // ),
          ],
        ),
        Row(
          children: [
            Icon(
              Icons.access_time_outlined,
              color: Colors.grey[600],
            ),
            const SizedBox(
              width: 8,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0.0),
              child: Text(
                formatTimestamp(review.timestamp!),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        // expand to see more
        if (!_expanded) _buildMinimized(),
        if (_expanded) _buildExpanded(),
      ],
    );
  }

  Widget _buildMinimized() {
    return InkWell(
      onTap: () {
        setState(() {
          _expanded = true;
        });
      },
      child: const Row(
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
    );
  }

  Widget _buildExpanded() {
    // show less
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   "Vurderinger:",
          //   style: TextStyle(
          //     fontWeight: FontWeight.bold,
          //     fontSize: 16,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Wrap(
              runSpacing: 8,
              spacing: 36,
              children: [
                // taste rating
                _buildRatingItem(
                  "Smak",
                  rating.food!,
                  Icons.restaurant_outlined,
                ),
                if (review.dineIn)
                  _buildRatingItem(
                      "Service", rating.service!, Icons.room_service_outlined),
                _buildRatingItem("Verdi", rating.price!, Icons.wallet_outlined),
                if (review.dineIn)
                  _buildRatingItem(
                      "Atmosfære", rating.atmosphere!, Icons.mood_outlined),
                if (review.dineIn)
                  _buildRatingItem("Renhold", rating.cleanliness!,
                      Icons.cleaning_services_outlined),
                if (!review.dineIn)
                  _buildRatingItem(
                      "Innpakning", rating.packaging!, Icons.wrap_text),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _expanded = false;
              });
            },
            child: const Row(
              children: [
                Icon(
                  Icons.expand_less,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Vis mindre',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingItem(String name, num rating, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 16,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              (rating * 2).toString(),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 16,
              ),
            ),
            // rating data description
            // const SizedBox(
            //   width: 8,
            // ),
            // Text(
            //   getRatingData(restaurant.rating)?.description ?? "",
            //   style: TextStyle(
            //     color: Colors.grey[600],
            //     fontSize: 14,
            //   ),
            // ),
          ],
        ),
        // name
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
