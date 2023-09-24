import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth.dart';
import '../../model/restaurant.dart';
import '../../utils/rating.dart';
import 'review_rate.dart';

class RestaurantReviewRatingPage extends StatefulWidget {
  final Restaurant? restaurant;
  final Function() onBackPressed;
  final Function(bool canSubmit) onCanSubmit;
  final RestaurantReview? review;
  final Widget listItem;

  const RestaurantReviewRatingPage({
    super.key,
    required this.restaurant,
    required this.onBackPressed,
    required this.onCanSubmit,
    required this.review,
    required this.listItem,
  });

  @override
  State<RestaurantReviewRatingPage> createState() =>
      _RestaurantReviewReviewState();
}

class _RestaurantReviewReviewState extends State<RestaurantReviewRatingPage> {
  RestaurantReview get review => widget.review!;

  bool _canSubmit = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 64),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 136,
        child: Column(
          children: [
            widget.listItem,
            const SizedBox(height: 6),
            _buildDineInOrTakeout(),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRating("Smak", currentRating: review.ratingFood,
                        (value) {
                      setState(() {
                        review.ratingFood = value;
                        _setCanSubmit();
                      });
                    }),
                    _buildRating("Pris", currentRating: review.ratingPrice,
                        (value) {
                      setState(() {
                        review.ratingPrice = value;
                        _setCanSubmit();
                      });
                    }),
                    if (review.dineIn) ...[
                      _buildRating("Service",
                          currentRating: review.ratingService, (value) {
                        setState(() {
                          review.ratingService = value;
                          _setCanSubmit();
                        });
                      }),
                      _buildRating("Atmosfære",
                          currentRating: review.ratingAtmosphere, (value) {
                        setState(() {
                          review.ratingAtmosphere = value;
                          _setCanSubmit();
                        });
                      }),
                      _buildRating("Renhold",
                          currentRating: review.ratingCleanliness, (value) {
                        setState(() {
                          review.ratingCleanliness = value;
                          _setCanSubmit();
                        });
                      }),
                    ] else ...[
                      _buildRating("Innpakning",
                          currentRating: review.ratingPackaging, (value) {
                        setState(() {
                          review.ratingPackaging = value;
                          _setCanSubmit();
                        });
                      }),
                    ],
                    const SizedBox(height: 20),
                    _buildRating(
                        "Total${_computeOverallRating() != null ? ': ${_computeOverallRating()!.toStringAsFixed(1)}' : ''}",
                        currentRating: _computeOverallRating(),
                        (p0) => null,
                        isTotal: true)
                  ],
                ),
              ),
            ),

            // TextField(
            //   decoration: const InputDecoration(labelText: "Description"),
            //   maxLines: 5,
            //   onChanged: (value) {
            //     description = value;
            //   },
            // ),
            // const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRating(
    String label,
    Function(num) onRatingChanged, {
    num? currentRating,
    bool isTotal = false,
  }) {
    if (!isTotal) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          label +
                              (isTotal && currentRating != null ? '—' : ":"),
                          style: TextStyle(
                            fontSize: isTotal ? 20 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                    Text(
                      // ignore: prefer_interpolation_to_compose_strings
                      ' ' +
                          (getRatingData(
                                  currentRating?.toDouble())['description'] ??
                              ''),
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.grey, // Use our textColor
                      ),
                    ),
                  ],
                ),
                RatingWidget(
                  key: Key(label),
                  rating: currentRating,
                  onRatingSelected: (selectedRating) {
                    onRatingChanged(selectedRating.toDouble());
                  },
                  isTotalRating: isTotal,
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      );
    } else {
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
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentRating != null) ...[
                      const Text(
                        " — ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (getRatingData(currentRating.toDouble(),
                            isTotalRating: true)['description']),
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

  Widget _buildDineInOrTakeout() {
    return Column(
      children: [
        const Text(
          "Dine-In or Takeout?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5.0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    review.dineIn ? accent1Color : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    review.dineIn = true;
                  });
                  _setCanSubmit();
                },
                child: Text(
                  "Dine-In",
                  style: TextStyle(
                    color: review.dineIn ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10), // Gap between buttons
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5.0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    !review.dineIn ? accent1Color : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    review.dineIn = false;
                  });
                  _setCanSubmit();
                },
                child: Text(
                  "Takeout",
                  style: TextStyle(
                    color: !review.dineIn ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _setCanSubmit() {
    bool canSubmit;
    if (review.dineIn) {
      canSubmit = review.ratingFood != null &&
          review.ratingService != null &&
          review.ratingPrice != null &&
          review.ratingCleanliness != null &&
          review.ratingAtmosphere != null;
    } else {
      canSubmit = review.ratingFood != null &&
          review.ratingPrice != null &&
          review.ratingPackaging != null;
    }

    widget.onCanSubmit(canSubmit);

    if (canSubmit) {
      review.ratingOverall = _computeOverallRating();
    }

    _canSubmit = canSubmit;
  }

  num? _computeOverallRating() {
    num? rating;

    if (review.dineIn) {
      if (review.ratingFood != null &&
          review.ratingService != null &&
          review.ratingPrice != null &&
          review.ratingCleanliness != null &&
          review.ratingAtmosphere != null) {
        rating = (review.ratingFood! +
                review.ratingService! +
                review.ratingPrice! +
                review.ratingCleanliness! +
                review.ratingAtmosphere!) /
            5;
      }
    } else {
      if (review.ratingFood != null &&
          review.ratingPrice != null &&
          review.ratingPackaging != null) {
        rating = (review.ratingFood! +
                review.ratingPrice! +
                review.ratingPackaging!) /
            3;
      }
    }
    return (rating != null
        ? rating * 2
        : null); // Return null if not all required ratings are provided
  }
}
