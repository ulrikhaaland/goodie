import 'package:flutter/material.dart';
import 'package:goodie/model/review.dart';

import '../../model/restaurant.dart'; // Import your RestaurantReview model

class ReviewListItem extends StatelessWidget {
  final RestaurantReview review;
  final Restaurant restaurant;

  const ReviewListItem(
      {super.key, required this.review, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture and User Info (Dummy Data)
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(restaurant!.coverImg ??
                        "https://firebasestorage.googleapis.com/v0/b/goodie-8814a.appspot.com/o/reviews%2F1947-gandhi%2F1695624291647.jpg?alt=media&token=94780007-27cb-43d0-b53b-37b747a3d2d7"), // Dummy URL
                  ),
                  const SizedBox(width: 10),
                  Text(
                    review.userId, // Use userId for now
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Restaurant Images - Horizontal Scrollable
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images?.length ??
                      0, // Use the length of the images list
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        right:
                            index < (review.images?.length ?? 0) - 1 ? 8.0 : 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        review.images?[index] ?? '', // Use the image URL
                        fit: BoxFit.cover,
                        height: 200,
                        width: 200,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Restaurant Name and Rating (Dummy Data)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    restaurant.name, // Use restaurantId for now
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${review.ratingOverall?.toStringAsPrecision(2)}/10', // Use ratingOverall
                    style: const TextStyle(
                        color: Colors.blue, // Replace with your accent color
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Review Text
              Text(
                review.description ?? '', // Use the review description
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),

              // Actions like Like and Comment
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.grey[600]),
                      const SizedBox(width: 5),
                      Text(
                          '${review.likes?.length ?? 0} Likes'), // Use the length of the likes list
                    ],
                  ),
                  Text(
                      '${review.comments?.length ?? 0} Comments'), // Use the length of the comments list
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
