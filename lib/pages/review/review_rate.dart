import 'package:flutter/material.dart';

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
      children: [
        Row(
          children: List.generate(
              5,
              (index) => Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: _buildCircle(index + 1),
                  )),
        ),
        const SizedBox(width: 8),
        Text(
          (_getRatingData(rating?.toDouble())['description'] ?? ''),
          style: const TextStyle(
            fontWeight: FontWeight.normal,
          ),
        )
      ],
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
      if (rating == null) return Colors.grey.shade300;
      if (rating < 2) return Colors.red;
      if (rating < 3) return Colors.orange;
      if (rating < 4) return Colors.yellow;
      if (rating < 5) return Colors.lightGreen;
      return Colors.green;
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
                  _getRatingData(circleRating.toDouble())['icon'],
                  color: Colors.white,
                  size: isTotalRating ? 20 : 15, // Adjust icon size
                ),
              )
            : null,
      ),
    );
  }

  Map<String, dynamic> _getRatingData(num? rating) {
    if (rating == null) {
      return {}; // Empty map for null rating
    }

    if (rating < 2) {
      return {
        'description': 'Dårlig',
        'icon': Icons.sentiment_very_dissatisfied_sharp
      };
    } else if (rating < 3) {
      return {'description': 'Meh', 'icon': Icons.sentiment_dissatisfied_sharp};
    } else if (rating < 4) {
      return {'description': 'Ok', 'icon': Icons.sentiment_neutral_rounded};
    } else if (rating < 5) {
      return {'description': 'Bra', 'icon': Icons.sentiment_satisfied_sharp};
    } else {
      return {
        'description': 'Fantastisk',
        'icon': Icons.sentiment_very_satisfied_sharp
      };
    }
  }
}
