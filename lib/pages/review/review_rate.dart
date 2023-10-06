import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/rating.dart';

class RatingWidget extends StatelessWidget {
  final num? rating;
  final Function(int) onRatingSelected;
  final bool isTotalRating;

  const RatingWidget(
      {super.key,
      required this.rating,
      required this.onRatingSelected,
      this.isTotalRating = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: _buildCircle(index + 1),
        ),
      ),
    );
  }

  Widget _buildCircle(int circleRating) {
    bool isColored = rating != null && circleRating <= rating!;
    bool isSelected = circleRating == rating;

    if (isTotalRating) {
      final trunc = rating?.truncate();
      isSelected = circleRating == trunc;
    }

    Color getCircleColor(num? rating) {
      if (rating == null) return bgColor; // Use bgColor for null rating
      if (rating < 2) {
        return highlightColor; // Use highlightColor for low rating
      }
      if (rating < 3) {
        return secondaryColor; // Use secondaryColor for medium-low rating
      }
      if (rating < 4) return accent1Color; // Use accent1Color for medium rating
      if (rating < 5) {
        return primaryColor; // Use accent2Color for medium-high rating
      }
      return accent2Color; // Use primaryColor for high rating
    }

    double circleSize =
        isTotalRating ? 35 : 25; // Increased size for total rating

    return GestureDetector(
      onTap: () => onRatingSelected(circleRating),
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isColored ? getCircleColor(rating) : Colors.grey.shade300,
        ),
        child: isSelected
            ? Center(
                child: Icon(
                  getRatingData(circleRating.toDouble())?.icon,
                  color: Colors.white,
                  size: isTotalRating ? 20 : 15, // Adjust icon size
                ),
              )
            : null,
      ),
    );
  }
}
