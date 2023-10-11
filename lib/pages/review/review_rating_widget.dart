import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:goodie/main.dart';

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
    return Stack(
      children: [
        CustomPaint(
          size:
              const Size(160, 30), // Width should be (circleSize + padding) * 5
          painter: CirclePainter(
            rating: rating,
            colors: [amberColor.withOpacity(0.2), amberColor],
          ),
        ),
        Row(
          children: List.generate(
            5,
            (index) => _buildCircle(context, index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCircle(BuildContext context, int circleRating) {
    bool isFilled = rating != null && circleRating <= rating!;

    return InkWell(
      onTap: () {
        onRatingSelected(circleRating);

        // make linearly haptic feedback based on circle rating values 1-5

        switch (circleRating) {
          case 1:
            HapticFeedback.lightImpact();
            break;
          case 2:
            HapticFeedback.mediumImpact();
            break;
          case 3:
            HapticFeedback.heavyImpact();
            break;
          case 4:
            HapticFeedback.vibrate();
            break;
          case 5:
            HapticFeedback.selectionClick();
            break;
        }
      },
      borderRadius: BorderRadius.circular(50),
      splashColor: isFilled ? primaryColor : Colors.grey.shade300,
      child: Padding(
        padding: EdgeInsets.only(
            left: circleRating == ((rating ?? 0) + 1) ? 0 : 2.0),
        child: Container(
          width: 30, // Circle size
          height: 30, // Circle size
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final num? rating;
  final List<Color> colors;

  CirclePainter({this.rating, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: colors,
      ).createShader(
          Rect.fromPoints(const Offset(0, 0), Offset(size.width, 0)));

    for (int i = 0; i < (rating ?? 0); i++) {
      final circleCenter = Offset((30 + 2) * i + 15, size.height / 2);
      canvas.drawCircle(circleCenter, 15, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
