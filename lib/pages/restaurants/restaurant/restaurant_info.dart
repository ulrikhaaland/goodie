import 'package:flutter/material.dart';

import '../../../model/restaurant.dart';
import '../../../utils/date.dart';

class RestaurantInfo extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantInfo({super.key, required this.restaurant});

  @override
  State<RestaurantInfo> createState() => _RestaurantInfoState();
}

class _RestaurantInfoState extends State<RestaurantInfo> {
  bool _showAllOpeningHours = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: _buildRestaurantDetails());
  }

  Widget _buildRestaurantDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.restaurant.name,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline), // Heart icon
                onPressed: () {
                  // Your logic for liking the restaurant
                },
              ),
            ],
          ),
          Text(
            widget.restaurant.description ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Icon(_getRatingData(widget.restaurant.rating ?? 0)['icon'],
                  color: Colors.grey[700], size: 24.0),
              const SizedBox(width: 12.0),
              Text(
                widget.restaurant.rating == null
                    ? 'Ingen rangering'
                    : _getRatingData(
                        widget.restaurant.rating ?? 0)['description'],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              if (widget.restaurant.rating != null) ...[
                const SizedBox(width: 6.0),
                Text(
                  '${widget.restaurant.rating.toString().length == 1 ? "${widget.restaurant.rating}.0" : widget.restaurant.rating} ★',
                  style: const TextStyle(fontSize: 16),
                ),
              ]
            ],
          ),
          const SizedBox(height: 24.0),
          _buildOpeningHours(),
        ],
      ),
    );
  }

  Widget _buildOpeningHours() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.access_time,
              color: Colors.black54,
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Text(
              "${getCurrentDay()}:",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6.0),
            Text(
              getTodayOpeningHours(widget.restaurant.openingHours ?? ''),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            InkWell(
              child: Text(
                _showAllOpeningHours ? "Skjul" : 'Se alle',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
              onTap: () {
                setState(() {
                  _showAllOpeningHours = !_showAllOpeningHours;
                });
              },
            )
          ],
        ),
        if (_showAllOpeningHours)
          ..._buildAllOpeningHours(widget.restaurant.openingHours ?? ''),
      ],
    );
  }

  List<Widget> _buildAllOpeningHours(String openingHours) {
    var days = [
      'Mandag',
      'Tirsdag',
      'Onsdag',
      'Torsdag',
      'Fredag',
      'Lørdag',
      'Søndag'
    ];

    var currentDay = getCurrentDay();
    days.remove(currentDay);

    var splits = openingHours.split(RegExp(r'\d{2}:\d{2}–\d{2}:\d{2}'));
    splits.removeLast(); // Remove the last empty item

    return days.map((day) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            SizedBox(width: 24.0 + 12.0), // space for icon and padding
            Text(
              "$day:",
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(width: 6.0),
            Expanded(
              child: Text(
                getHourForDay(openingHours, day),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String getHourForDay(String openingHours, String day) {
    var regex = RegExp('$day(\\d{2}:\\d{2}–\\d{2}:\\d{2})');
    var match = regex.firstMatch(openingHours);
    return match?.group(1) ?? '';
  }

  Map<String, dynamic> _getRatingData(num rating) {
    if (rating < 6) {
      return {'description': 'Meh', 'icon': Icons.sentiment_dissatisfied};
    } else if (rating < 7) {
      return {'description': 'Ok', 'icon': Icons.sentiment_neutral};
    } else if (rating < 8) {
      return {'description': 'Bra', 'icon': Icons.sentiment_satisfied};
    } else if (rating < 9) {
      return {
        'description': 'Veldig bra',
        'icon': Icons.sentiment_very_satisfied
      };
    } else {
      return {
        'description': 'Fantastisk',
        'icon': Icons.sentiment_very_satisfied
      };
    }
  }
}
