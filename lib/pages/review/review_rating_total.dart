import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/rating.dart';

class ModernSliderTrackShape extends RoundedRectSliderTrackShape {
  final double sliderValue;

  ModernSliderTrackShape(
      {required this.sliderValue}); // Add this line to hold the slider value.

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
    Offset? secondaryOffset,
  }) {
    // Customize the active and inactive track colors and height
    final double trackHeight =
        sliderTheme.trackHeight! + additionalActiveTrackHeight;

    final Paint activeTrackPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          amberColor.withOpacity(0.2),
          amberColor
              .withOpacity(sliderValue / 10) // Assuming max slider value is 10.
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, thumbCenter.dx, trackHeight));

    final Paint inactiveTrackPaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.blue.shade100;

    // Call the parent's paint method to paint the track
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    // Paint the active and inactive track segments
    final Rect activeTrackRect = Rect.fromLTRB(
      offset.dx,
      thumbCenter.dy - trackHeight / 2,
      thumbCenter.dx,
      thumbCenter.dy + trackHeight / 2,
    );
    context.canvas.drawRect(activeTrackRect, activeTrackPaint);

    final Rect inactiveTrackRect = Rect.fromLTRB(
      thumbCenter.dx,
      thumbCenter.dy - trackHeight / 2,
      offset.dx + parentBox.size.width,
      thumbCenter.dy + trackHeight / 2,
    );
    context.canvas.drawRect(inactiveTrackRect, inactiveTrackPaint);
  }
}

class ModernSliderThumbShape extends RoundSliderThumbShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size.fromRadius(
        12.0); // Update this size to match the thumb radius used in the paint method.
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
    Thumb? thumb,
    bool? isPressed,
  }) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()..color = Colors.white;
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Calculate the thumb radius using the provided sizeWithOverflow
    final double thumbRadius = sizeWithOverflow.width / 2.0;

    // Paint shadow
    final Offset shadowOffset = Offset(center.dx, center.dy + 4);
    canvas.drawCircle(shadowOffset, thumbRadius, shadowPaint);

    // Paint thumb
    canvas.drawCircle(center, thumbRadius, paint);
  }
}

class ReviewRatingTotal extends StatefulWidget {
  final num? currentRating;
  final Function(double) onTotalRatingChanged;

  const ReviewRatingTotal({
    super.key,
    this.currentRating,
    required this.onTotalRatingChanged,
  });

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
                    "Total: ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.currentRating != null) ...[
                    Text(
                      (getRatingData(widget.currentRating!.toDouble(),
                                  isTotalRating: true)
                              ?.description ??
                          ""),
                      style: TextStyle(
                        fontSize: 20,
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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
                // Custom track shape
                trackShape: ModernSliderTrackShape(
                    sliderValue: widget.currentRating?.toDouble() ?? 0.0),
                // Custom thumb shape, replace with your own if needed
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12.0),
                activeTrackColor: Colors.amber.withOpacity(0.2),
                inactiveTrackColor: Colors.grey.shade300,
                thumbColor: primaryColor, // Thumb color
                overlayColor: accent1Color),
            child: Slider(
              min: 0,
              max: 10,
              divisions: 10,
              value: widget.currentRating?.toDouble() ?? 0.0,
              onChanged: widget.onTotalRatingChanged,
            ),
          ),
        ],
      ),
    );
  }
}
