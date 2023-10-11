import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:goodie/pages/review/review_rating_total.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth_provider.dart';
import '../../model/restaurant.dart';
import '../../utils/rating.dart';
import '../../widgets/gradient_button.dart';
import 'review_rating_widget.dart';

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

  RestaurantReviewRating get rating => review.rating;

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
                    _buildRating("Smak", currentRating: rating.food, (value) {
                      setState(() {
                        rating.food = value;
                        _setCanSubmit();
                      });
                    }),
                    _buildRating("Pris", currentRating: rating.price, (value) {
                      setState(() {
                        rating.price = value;
                        _setCanSubmit();
                      });
                    }),
                    if (review.dineIn) ...[
                      _buildRating("Service", currentRating: rating.service,
                          (value) {
                        setState(() {
                          rating.service = value;
                          _setCanSubmit();
                        });
                      }),
                      _buildRating("Atmosfære",
                          currentRating: rating.atmosphere, (value) {
                        setState(() {
                          rating.atmosphere = value;
                          _setCanSubmit();
                        });
                      }),
                      _buildRating("Renhold", currentRating: rating.cleanliness,
                          (value) {
                        setState(() {
                          rating.cleanliness = value;
                          _setCanSubmit();
                        });
                      }),
                    ] else ...[
                      _buildRating("Innpakning",
                          currentRating: rating.packaging, (value) {
                        setState(() {
                          rating.packaging = value;
                          _setCanSubmit();
                        });
                      }),
                    ],
                    const SizedBox(height: 20),
                    ReviewRatingTotal(
                      currentRating: _computeOverallRating(),
                    ),
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
  }) {
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
                        "$label:",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                  Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    ' ' +
                        (getRatingData(currentRating?.toDouble())
                                ?.description ??
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
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
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
              child: GradientButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                onPressed: () {
                  setState(() {
                    review.dineIn = true;
                  });
                  _setCanSubmit();
                },
                label: "Dine-In",
                isEnabled: review.dineIn ? true : false,
              ),
            ),
            const SizedBox(width: 10), // Gap between buttons
            Expanded(
              child: GradientButton(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                onPressed: () {
                  setState(() {
                    review.dineIn = false;
                  });
                  _setCanSubmit();
                },
                label: "Takeout",
                isEnabled: !review.dineIn ? true : false,
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
      canSubmit = rating.food != null &&
          rating.service != null &&
          rating.price != null &&
          rating.cleanliness != null &&
          rating.atmosphere != null;
    } else {
      canSubmit = rating.food != null &&
          rating.price != null &&
          rating.packaging != null;
    }

    widget.onCanSubmit(canSubmit);

    if (canSubmit) {
      rating.overall = _computeOverallRating();
    }

    _canSubmit = canSubmit;
  }

  num? _computeOverallRating() {
    num? overallRating;

    if (review.dineIn) {
      if (rating.food != null &&
          rating.service != null &&
          rating.price != null &&
          rating.cleanliness != null &&
          rating.atmosphere != null) {
        overallRating = (rating.food! +
                rating.service! +
                rating.price! +
                rating.cleanliness! +
                rating.atmosphere!) /
            5;
      }
    } else {
      if (rating.food != null &&
          rating.price != null &&
          rating.packaging != null) {
        overallRating = (rating.food! + rating.price! + rating.packaging!) / 3;
      }
    }
    return (overallRating != null
        ? overallRating * 2
        : null); // Return null if not all required ratings are provided
  }
}
