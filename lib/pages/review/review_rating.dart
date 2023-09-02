import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth.dart';
import '../../model/restaurant.dart';
import 'review_rate.dart';

class RestaurantReviewRating extends StatefulWidget {
  final Restaurant? restaurant;
  final Function() onBackPressed;
  final Function(bool canSubmit) onCanSubmit;
  final RestaurantReview? review;

  const RestaurantReviewRating({
    super.key,
    required this.restaurant,
    required this.onBackPressed,
    required this.onCanSubmit,
    required this.review,
  });

  @override
  State<RestaurantReviewRating> createState() => _RestaurantReviewReviewState();
}

class _RestaurantReviewReviewState extends State<RestaurantReviewRating> {
  RestaurantReview get review => widget.review!;

  bool _canSubmit = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 100,
        left: 16,
        right: 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 136,
        child: Column(
          children: [
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
                        "Total",
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
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 20 : 16,
                fontWeight: FontWeight.w500,
              ),
            )),
        const SizedBox(height: 16),
        RatingWidget(
          key: Key(label),
          rating: currentRating?.toInt(),
          onRatingSelected: (selectedRating) {
            onRatingChanged(selectedRating.toDouble());
          },
          isTotalRating: isTotal,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  _handleOnSubmit() {
    if (review.ratingFood == null || review.ratingPrice == null) {
      // maybe show an error to user here or handle this scenario
      return;
    }

    // get user id from auth provider
    final authProvider = context.read<AuthProvider>();

    // Compute average
    int validRatingsCount = 2; // food and price are always there
    num totalRating = review.ratingFood! + review.ratingPrice!;

    if (review.dineIn) {
      if (review.ratingService != null) {
        validRatingsCount++;
        totalRating += review.ratingService!;
      }
      if (review.ratingCleanliness != null) {
        validRatingsCount++;
        totalRating += review.ratingCleanliness!;
      }
      if (review.ratingAtmosphere != null) {
        validRatingsCount++;
        totalRating += review.ratingAtmosphere!;
      }
    } else if (review.ratingPackaging != null) {
      validRatingsCount++;
      totalRating += review.ratingPackaging!;
    }

    double ratingOverall = totalRating / validRatingsCount;
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
                    review.dineIn
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    review.dineIn = true;
                  });
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
                    !review.dineIn
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    review.dineIn = false;
                  });
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

    if (_canSubmit != canSubmit) widget.onCanSubmit(canSubmit);

    if (canSubmit) _handleOnSubmit();

    _canSubmit = canSubmit;
  }

  double? _computeOverallRating() {
    if (review.dineIn) {
      if (review.ratingFood != null &&
          review.ratingService != null &&
          review.ratingPrice != null &&
          review.ratingCleanliness != null &&
          review.ratingAtmosphere != null) {
        return (review.ratingFood! +
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
        return (review.ratingFood! +
                review.ratingPrice! +
                review.ratingPackaging!) /
            3;
      }
    }
    return null; // Return null if not all required ratings are provided
  }
}
