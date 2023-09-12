import 'package:flutter/material.dart';
import 'package:goodie/bloc/review.dart';
import 'package:goodie/model/restaurant.dart';
import 'package:goodie/pages/review/review_rate.dart';

class RestaurantReviewSummaryPage extends StatefulWidget {
  final RestaurantReviewProvider reviewProvider;
  final Widget listItem;

  const RestaurantReviewSummaryPage({
    super.key,
    required this.reviewProvider,
    required this.listItem,
  });

  @override
  State<RestaurantReviewSummaryPage> createState() =>
      _RestaurantReviewSummaryPageState();
}

class _RestaurantReviewSummaryPageState
    extends State<RestaurantReviewSummaryPage> {
  final TextEditingController _commentController = TextEditingController();

  RestaurantReviewProvider get provider => widget.reviewProvider;

  RestaurantReview get review => provider.getReview()!;

  @override
  void initState() {
    _commentController.text = review.description ?? "";
    _commentController.addListener(() {
      review.description = _commentController.text;
    });
    super.initState();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.listItem,
            // Display selected images
            if (provider.selectedAssetsNotifier.value.isNotEmpty) ...[
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.selectedAssetsNotifier.value.length,
                  itemBuilder: (context, index) {
                    final asset = provider.selectedAssetsNotifier.value[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.memory(
                        provider.thumbnailCache[asset]!,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Display overall rating
            Text(
              "Total Rating: ${review.ratingOverall!.toStringAsPrecision(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            // You can use your RatingWidget here
            RatingWidget(
              rating: review.ratingOverall,
              onRatingSelected: (rating) {},
              isTotalRating: true,
            ),

            const SizedBox(height: 20),

            // Comment field
            const Row(
              children: [
                Text(
                  "Kommentar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  " (valgfritt)",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Del litt om din opplevelse...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
