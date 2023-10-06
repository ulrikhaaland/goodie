import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:goodie/bloc/create_review_provider.dart';
import 'package:goodie/model/restaurant.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../utils/rating.dart';

class RestaurantReviewSummaryPage extends StatefulWidget {
  final CreateRestaurantReviewProvider reviewProvider;
  final Widget listItem;
  final VoidCallback onDatePick;
  const RestaurantReviewSummaryPage({
    super.key,
    required this.reviewProvider,
    required this.listItem,
    required this.onDatePick,
  });

  @override
  State<RestaurantReviewSummaryPage> createState() =>
      _RestaurantReviewSummaryPageState();
}

class _RestaurantReviewSummaryPageState
    extends State<RestaurantReviewSummaryPage> with WidgetsBindingObserver {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  DateTime? _selectedDate;

  CreateRestaurantReviewProvider get provider => widget.reviewProvider;

  RestaurantReview get review => provider.review;

  @override
  void initState() {
    super.initState();

    _selectedDate = review.timestamp;
    _commentController.text = review.description ?? "";
    _commentController.addListener(() {
      review.description = _commentController.text;
    });

    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: (365 * 2))),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: const ColorScheme.light(primary: primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        review.timestamp = pickedDate;
      });
      widget.onDatePick();
    }
  }

  @override
  void didChangeMetrics() {
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _commentFocusNode.unfocus();
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 84.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.listItem,
              const SizedBox(height: 1),
              if (provider.selectedAssetsNotifier.value.isNotEmpty) ...[
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.selectedAssetsNotifier.value.length,
                    itemBuilder: (context, index) {
                      final asset =
                          provider.selectedAssetsNotifier.value[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              provider.thumbnailCache[asset]!,
                              fit: BoxFit.cover,
                            ),
                            if (asset.type ==
                                AssetType
                                    .video) // Replace with your condition for video
                              const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 40.0,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                const Divider()
              ],
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Total Rating: ${review.ratingOverall?.toStringAsFixed(1)}",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              " — ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              (getRatingData(review.ratingOverall ?? 0,
                                          isTotalRating: true)
                                      ?.description ??
                                  ""),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600], // Use our textColor
                              ),
                            ),
                          ]),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              InkWell(
                onTap: () => _selectDate(context),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDate != null
                                  ? DateFormat.yMMMd().format(_selectedDate!)
                                  : "Velg besøksdato",
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        if (_selectedDate == null) ...[
                          const SizedBox(height: 4), // Add some spacing (4px
                          const Row(
                            children: [
                              SizedBox(width: 32),
                              Text(
                                "En besøksdato må velges",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 12),
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
                focusNode: _commentFocusNode,
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
      ),
    );
  }
}
