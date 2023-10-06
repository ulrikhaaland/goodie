import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth_provider.dart';
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
                                    isTotalRating: true)
                                ?.description ??
                            ""),
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
