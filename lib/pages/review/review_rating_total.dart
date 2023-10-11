import 'package:flutter/material.dart';
import 'package:goodie/pages/review/review_rating_widget.dart';

import '../../utils/rating.dart';

class ReviewRatingTotal extends StatefulWidget {
  final num? currentRating;
  const ReviewRatingTotal({super.key, this.currentRating});

  @override
  State<ReviewRatingTotal> createState() => _ReviewRatingTotalState();
}

class _ReviewRatingTotalState extends State<ReviewRatingTotal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.currentRating != null) ...[
                    const Text(
                      " — ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      (getRatingData(widget.currentRating!.toDouble(),
                                  isTotalRating: true)
                              ?.description ??
                          ""),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[600], // Use our textColor
                      ),
                    ),
                  ]
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
