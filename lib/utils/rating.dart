import 'package:flutter/material.dart';

class RatingData {
  final String description;
  final IconData icon;

  RatingData(this.description, this.icon);
}

RatingData? getRatingData(num? rating, {bool isTotalRating = false}) {
  if (rating == null) {
    return null; // Empty map for null rating
  }

  if (isTotalRating) {
    if (rating <= 2) {
      {
        return RatingData('Dårlig', Icons.sentiment_very_dissatisfied_sharp);
      }
    } else if (rating <= 4) {
      return RatingData('Meh', Icons.sentiment_dissatisfied_sharp);
    } else if (rating <= 6) {
      return RatingData('Ok', Icons.sentiment_neutral_rounded);
    } else if (rating <= 8) {
      return RatingData('Bra', Icons.sentiment_satisfied_sharp);
    } else {
      return RatingData('Fantastisk', Icons.sentiment_very_satisfied_sharp);
    }
  } else {
    if (rating < 2) {
      return RatingData('Dårlig', Icons.sentiment_very_dissatisfied_sharp);
    } else if (rating < 3) {
      return RatingData('Meh', Icons.sentiment_dissatisfied_sharp);
    } else if (rating < 4) {
      return RatingData('Ok', Icons.sentiment_neutral_rounded);
    } else if (rating < 5) {
      return RatingData('Bra', Icons.sentiment_satisfied_sharp);
    } else {
      return RatingData('Fantastisk', Icons.sentiment_very_satisfied_sharp);
    }
  }
}
