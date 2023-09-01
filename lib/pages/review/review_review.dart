import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth.dart';
import '../../model/restaurant.dart';
import 'review_rating.dart';

class RestaurantReviewReview extends StatefulWidget {
  final Restaurant? restaurant;
  final Function() onBackPressed;
  final Function(bool canSubmit) onCanSubmit;
  final RestaurantReview review;

  const RestaurantReviewReview({
    super.key,
    required this.restaurant,
    required this.onBackPressed,
    required this.onCanSubmit,
    required this.review,
  });

  @override
  State<RestaurantReviewReview> createState() => _RestaurantReviewReviewState();
}

class _RestaurantReviewReviewState extends State<RestaurantReviewReview> {
  RestaurantReview get review => widget.review;

  bool _canSubmit = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
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
              _buildRating("Smak", review.ratingFood, (value) {
                setState(() {
                  ratingFood = value;
                });
              }),
              _buildRating("Pris", ratingPrice, (value) {
                setState(() {
                  ratingPrice = value;
                });
              }),
              if (dineIn) ...[
                _buildRating("Service", ratingService, (value) {
                  setState(() {
                    ratingService = value;
                  });
                }),
                _buildRating("Atmosfære", ratingAtmosphere, (value) {
                  setState(() {
                    ratingAtmosphere = value;
                  });
                }),
                _buildRating("Renhold", ratingCleanliness, (value) {
                  setState(() {
                    ratingCleanliness = value;
                  });
                }),
              ] else
                _buildRating("Innpakning", ratingPackaging, (value) {
                  setState(() {
                    ratingPackaging = value;
                  });
                }),
              const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildLeftButton() {
    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(8.0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        backgroundColor: MaterialStateProperty.all(
          Theme.of(context).colorScheme.secondary,
        ),
      ),
      onPressed: () => widget.onBackPressed(),
      child: const Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 12.0), // Adjusted padding
        child: Text(
          "Tilbake",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRightButton() {
    _setCanSubmit();

    return ElevatedButton(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(8.0), // Increased shadow depth
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade300; // Disabled color
            }
            return Theme.of(context)
                .colorScheme
                .secondary; // Use secondary color from colorScheme
          },
        ),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade600; // Foreground when disabled
            }
            return Colors.white; // Regular foreground color
          },
        ),
      ),
      onPressed: _canSubmit ? () => _handleOnSubmit() : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 12.0), // Adjusted padding
        child: Row(
          mainAxisSize: MainAxisSize
              .min, // To ensure the Row takes only as much space as required
          children: [
            Icon(Icons.check), // An icon for emphasis
            SizedBox(width: 8.0), // Gap between icon and text
            Text(
              "Submit Review",
              style: TextStyle(
                fontSize: 18, // Slightly larger font size
                fontWeight: FontWeight.bold, // Bold font weight
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRating(
      String label, num? currentRating, Function(num) onRatingChanged) {
    return Column(
      children: [
        Align(
            alignment: Alignment.topLeft,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
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
                    color: dineIn ? Colors.white : Colors.black,
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
                    !dineIn ? Theme.of(context).primaryColor : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    dineIn = false;
                  });
                },
                child: Text(
                  "Takeout",
                  style: TextStyle(
                    color: !dineIn ? Colors.white : Colors.black,
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
    if (dineIn) {
      canSubmit = ratingFood != null &&
          ratingService != null &&
          ratingPrice != null &&
          ratingCleanliness != null &&
          ratingAtmosphere != null;
    } else {
      canSubmit =
          ratingFood != null && ratingPrice != null && ratingPackaging != null;
    }

    if (_canSubmit != canSubmit) widget.onCanSubmit(canSubmit);

    if (canSubmit) _handleOnSubmit();

    _canSubmit = canSubmit;
  }

  double? _computeOverallRating() {
    if (dineIn) {
      if (ratingFood != null &&
          ratingService != null &&
          ratingPrice != null &&
          ratingCleanliness != null &&
          ratingAtmosphere != null) {
        return (ratingFood! +
                ratingService! +
                ratingPrice! +
                ratingCleanliness! +
                ratingAtmosphere!) /
            5;
      }
    } else {
      if (ratingFood != null &&
          ratingPrice != null &&
          ratingPackaging != null) {
        return (ratingFood! + ratingPrice! + ratingPackaging!) / 3;
      }
    }
    return null; // Return null if not all required ratings are provided
  }
}
