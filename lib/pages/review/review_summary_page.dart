import 'package:flutter/material.dart';
import 'package:goodie/main.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
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
    extends State<RestaurantReviewSummaryPage> with WidgetsBindingObserver {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _commentFocusNode = FocusNode();
  DateTime? _selectedDate;

  RestaurantReviewProvider get provider => widget.reviewProvider;

  RestaurantReview get review => provider.getReview()!;

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
              Text(
                "Total Rating: ${review.ratingOverall!.toStringAsPrecision(2)}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              RatingWidget(
                rating: review.ratingOverall,
                onRatingSelected: (rating) {},
                isTotalRating: true,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(
                  _selectedDate != null
                      ? DateFormat.yMMMd().format(_selectedDate!)
                      : "Select a date",
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                subtitle: _selectedDate == null
                    ? const Text(
                        "A date must be selected.",
                        style: TextStyle(color: Colors.redAccent),
                      )
                    : null,
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
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
