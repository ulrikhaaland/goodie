import 'package:flutter/material.dart';

Map<String, dynamic> getRatingData(num? rating) {
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
