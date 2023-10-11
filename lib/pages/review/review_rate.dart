import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/rating.dart';

class RatingWidget extends StatelessWidget {
  final num? rating;
  final Function(int) onRatingSelected;
  final bool isTotalRating;

  const RatingWidget({
    Key? key,
    required this.rating,
    required this.onRatingSelected,
    this.isTotalRating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: Row(
        children: List.generate(
          5,
          (index) => Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: _buildCircle(index + 1),
          ),
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

    double circleSize = isTotalRating ? 35 : 25;

    return GestureDetector(
      onTap: () => onRatingSelected(circleRating),
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Material(
          color: isColored
              ? Colors.white
              : Colors.grey.shade300, // Important for ShaderMask
          child: isSelected
              ? Center(
                  child: Icon(
                    Icons.star, // Replace with your actual icon
                    color: Colors.white,
                    size: isTotalRating ? 20 : 15,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
