import 'package:flutter/material.dart';
import 'package:goodie/bloc/review.dart';

class RestaurantReviewSummaryPage extends StatefulWidget {
  final RestaurantReviewProvider reviewProvider;
  const RestaurantReviewSummaryPage({super.key, required this.reviewProvider});

  @override
  State<RestaurantReviewSummaryPage> createState() =>
      _RestaurantReviewSummaryPageState();
}

class _RestaurantReviewSummaryPageState
    extends State<RestaurantReviewSummaryPage> {
  final TextEditingController _commentController = TextEditingController();

  RestaurantReviewProvider get provider => widget.reviewProvider;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 80,
            ),
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
              const SizedBox(height: 16),
            ],

            // Display overall rating
            const Text(
              "Overall Rating:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            // You can use your RatingWidget here
            // RatingWidget(
            //   rating: provider.getReview()?.rating,
            //   onRatingSelected: (rating) {},
            // ),

            const SizedBox(height: 16),

            // Comment field
            const Text(
              "Comment:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Share your experience...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
