import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

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
                icon: const Icon(Icons.bookmark_outline), // Bookmark icon
                onPressed: () {
                  // Your logic for bookmarking the restaurant
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
          ..._buildRestaurantAddress(),
          ..._buildContactInfo(),
          // Address row
        ],
      ),
    );
  }

  List<Widget> _buildContactInfo() {
    if (widget.restaurant.homepage != null || widget.restaurant.phone != null) {
      return [
        ...[
          const SizedBox(height: 24.0),
          const Text(
            'Kontakt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        if (widget.restaurant.homepage != null) ...[
          const SizedBox(
              height: 20.0), // Providing spacing before website and phone
          InkWell(
            onTap: () async {
              Uri uri = Uri.parse(widget.restaurant.homepage!);

              if (widget.restaurant.homepage != null &&
                  await canLaunchUrl(uri)) {
                _launchInBrowser(uri);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.language, // Icon for website
                  color: Colors.black54,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.restaurant.homepage!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (widget.restaurant.phone != null) ...[
          const SizedBox(height: 24.0),
          InkWell(
            onTap: () async {
              Uri uri = Uri(scheme: 'tel', path: widget.restaurant.phone);
              if (widget.restaurant.phone != null && await canLaunchUrl(uri)) {
                launchUrl(uri);
              }
            },
            child: Row(
              children: [
                const Icon(
                  Icons.phone, // Icon for phone
                  color: Colors.black54,
                  size: 24.0,
                ),
                const SizedBox(width: 12.0),
                Text(
                  formatPhoneNumber(widget.restaurant.phone!),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ]
      ];
    }
    return [];
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
              getHourForDay(
                  widget.restaurant.openingHours ?? '', getCurrentDay()),
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            InkWell(
              child: Text(
                _showAllOpeningHours ? "Skjul" : 'Se alle',
                style: const TextStyle(
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
      bool first = false;
      if (days.first == day) first = true;
      return Padding(
        padding: first
            ? const EdgeInsets.only(top: 4.0)
            : const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            const SizedBox(width: 24.0 + 12.0), // space for icon and padding
            SizedBox(
              width: 65.0, // Max width of the days
              child: Text(
                "$day:",
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
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
    return match?.group(1) ?? 'Stengt';
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

  List<Widget> _buildRestaurantAddress() {
    if (widget.restaurant.address != null) {
      return [
        const SizedBox(height: 24.0),
        Row(
          children: [
            Icon(
              Icons.location_on,
              color: Colors.grey[700],
              size: 24.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                formatAddress(widget.restaurant.address!),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            InkWell(
              onTap: () async {},
              child: const Text(
                'Åpne i kart',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
      ];
    }
    return [];
  }

  String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length != 11) {
      return phoneNumber; // Return original if not of expected length
    }

    return '${phoneNumber.substring(3, 5)} ${phoneNumber.substring(5, 7)} ${phoneNumber.substring(7, 9)} ${phoneNumber.substring(9, 11)}';
  }

  String formatAddress(String address) {
    // Use a regex to find the pattern (any number followed by exactly 4 digits at the end)
    return address.replaceAllMapped(
        RegExp(r'(\d)(\d{4} \w+)$'), (Match m) => '${m[1]}, ${m[2]}');
  }
}
