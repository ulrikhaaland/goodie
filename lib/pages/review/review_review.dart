import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../bloc/auth.dart';
import '../../model/restaurant.dart';
import 'review_rating.dart';

class RestaurantReviewReview extends StatefulWidget {
  final Restaurant? restaurant;
  final Function(RestaurantReview) onReviewRestaurant;

  const RestaurantReviewReview({
    super.key,
    required this.restaurant,
    required this.onReviewRestaurant,
  });

  @override
  State<RestaurantReviewReview> createState() => _RestaurantReviewReviewState();
}

class _RestaurantReviewReviewState extends State<RestaurantReviewReview> {
  double? ratingFood;
  double? ratingService;
  double? ratingPrice;
  double? ratingCleanliness;
  double? ratingPackaging;
  double? ratingAtmosphere;
  bool dineIn = true;
  String? description;

  // This method was misspelled in the original snippet
  @override
  void didUpdateWidget(covariant RestaurantReviewReview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.restaurant != widget.restaurant) {
      ratingFood = null;
      ratingService = null;
      dineIn = true;
      description = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            children: [
              if (widget.restaurant != null)
                _buildRestaurantListItem(context, widget.restaurant!),
              _buildDineInOrTakeout(),
              const SizedBox(height: 20),
              _buildRating("Smak", ratingFood, (value) {
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
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRating(
      String label, double? currentRating, Function(double) onRatingChanged) {
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
    if (ratingFood == null || ratingPrice == null) {
      // maybe show an error to user here or handle this scenario
      return;
    }

    // get user id from auth provider
    final authProvider = context.read<AuthProvider>();

    // Compute average
    int validRatingsCount = 2; // food and price are always there
    double totalRating = ratingFood! + ratingPrice!;

    if (dineIn) {
      if (ratingService != null) {
        validRatingsCount++;
        totalRating += ratingService!;
      }
      if (ratingCleanliness != null) {
        validRatingsCount++;
        totalRating += ratingCleanliness!;
      }
      if (ratingAtmosphere != null) {
        validRatingsCount++;
        totalRating += ratingAtmosphere!;
      }
    } else if (ratingPackaging != null) {
      validRatingsCount++;
      totalRating += ratingPackaging!;
    }

    double ratingOverall = totalRating / validRatingsCount;

    // Submit the review
    widget.onReviewRestaurant(RestaurantReview(
      restaurantId: widget.restaurant!.id,
      userId: authProvider.user!.firebaseUser!.uid,
      description: description,
      ratingFood: ratingFood!,
      ratingService: dineIn ? ratingService : null,
      ratingPrice: ratingPrice!,
      ratingCleanliness: dineIn ? ratingCleanliness : null,
      ratingPackaging: !dineIn ? ratingPackaging : null,
      ratingAtmosphere: dineIn ? ratingAtmosphere : null,
      ratingOverall: ratingOverall,
      timestamp: DateTime.now(),
      dineIn: dineIn,
      images: [], // assuming no images for now
    ));
  }

  Widget _buildRestaurantListItem(BuildContext context, Restaurant restaurant) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(
              imageUrl: restaurant.coverImg ?? '',
              placeholder: (context, url) => const SizedBox(
                width: 50, // Set the width
                height: 50, // Set the height
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 50, // Set the width
              height: 50, // Set the height
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            restaurant.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                restaurant.description ?? '',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2), // Space between description and rating
            ],
          ),
        ),
        const Divider(),
      ],
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
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5.0),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  backgroundColor: MaterialStateProperty.all(
                    dineIn ? Theme.of(context).primaryColor : Colors.grey[200],
                  ),
                ),
                onPressed: () {
                  setState(() {
                    dineIn = true;
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

  Widget _buildSubmitButton() {
    bool canSubmit = _canSubmit();

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
      onPressed: canSubmit ? () => _handleOnSubmit() : null,
      child: const Padding(
        padding: EdgeInsets.symmetric(
            vertical: 12.0, horizontal: 40.0), // More padding to increase size
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

  bool _canSubmit() {
    if (dineIn) {
      return ratingFood != null &&
          ratingService != null &&
          ratingPrice != null &&
          ratingCleanliness != null &&
          ratingAtmosphere != null;
    } else {
      return ratingFood != null &&
          ratingPrice != null &&
          ratingPackaging != null;
    }
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