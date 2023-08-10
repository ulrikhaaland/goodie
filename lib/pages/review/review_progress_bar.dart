import 'package:flutter/material.dart';

class ReviewProgressBar extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const ReviewProgressBar(
      {super.key, required this.currentIndex, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Stack(
        children: [
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
          FractionallySizedBox(
            widthFactor: (currentIndex / (totalPages - 1)),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
