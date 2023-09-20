import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';
import '../model/restaurant.dart';
import '../utils/distance.dart';
import '../utils/image.dart';

class RestaurantReviewProvider with ChangeNotifier {
  Restaurant? selectedRestaurant;
  List<Restaurant> restaurants = [];
  RestaurantReview? review;
  List<GoodieAsset> recentImages = [];
  final ValueNotifier<List<GoodieAsset>> selectedAssetsNotifier =
      ValueNotifier<List<GoodieAsset>>([]);
  final ValueNotifier<GoodieAsset?> selectedAssetNotifier = ValueNotifier(null);
  final Map<GoodieAsset, Uint8List> thumbnailCache = {};

  RestaurantReviewProvider() {
    loadRecentImages();
    selectedAssetsNotifier.addListener(() {
      _handleSelectedRestaurant();
    });
  }

  RestaurantReview? getReview() {
    if (selectedRestaurant == null) {
      return null;
    } else if (review != null) {
      return review!;
    } else {
      review = RestaurantReview(
        restaurantId: selectedRestaurant!.id,
        userId: "test",
        images: [],
        dineIn: true,
      );
      return review;
    }
  }

  Future<void> loadRecentImages() async {
    try {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          onlyAll: true, pathFilterOption: PMPathFilter());
      final AssetPathEntity recentPath = paths.first;
      recentPath.getAssetListRange(start: 0, end: 100).then((value) {
        recentImages = value
            .map((e) => GoodieAsset(
                  asset: e,
                ))
            .toList();
        selectedAssetNotifier.value = recentImages.first;

        recentImages.forEach((element) async {
          element.originFile.then((value) {
            if (value != null) {
              value.readAsBytes().then((value) {
                element.byteLength = value.lengthInBytes;
              });
            }
          });
        });
      });
    } catch (e) {
      print("Error loading recent images: $e");
    }
  }

  Future<void> _handleSelectedRestaurant() async {
    final assets = selectedAssetsNotifier.value;

    final assetRestaurants = assets
        .where((element) => element.restaurant != null)
        .map((e) => e.restaurant!)
        .toList();

    final assetsCopy = List.from(assets);

    Map<DateTime, int> dateCounts = {};
    DateTime? mostCommonDate;

    for (var asset
        in assetsCopy.where((element) => element.restaurant == null)) {
      final assetss = asset;
      final image = assetss.imageFile ?? await assetss.file;

      final data = await extractLocationAndDate(image!);
      if (data?['latitude'] != null && data?['longitude'] != null) {
        int? distance;

        restaurants.where((e) => e.position != null).forEach((restaurant) {
          int dist = getDistance(data?['latitude'], data?['longitude'],
                  restaurant.position!.latitude, restaurant.position!.longitude)
              .toInt();

          distance ??= dist;

          if (dist < distance!) {
            distance = dist;
            asset.restaurant = restaurant;
          }
        });
      }

      DateTime? date = data?['date'];
      if (date != null) {
        // Check if the date is within the last 24 months
        if (date.isAfter(DateTime.now().subtract(const Duration(days: 730)))) {
          dateCounts.update(date, (count) => count + 1, ifAbsent: () => 1);

          if (mostCommonDate == null ||
              dateCounts[date]! > dateCounts[mostCommonDate]!) {
            mostCommonDate = date;
          }
        }
      }
    }

    // Select restaurant that appears the most in assetRestaurant or if there is only one
    if (assetRestaurants.isNotEmpty) {
      final restaurant = assetRestaurants.reduce((value, element) =>
          assetRestaurants.where((e) => e.id == value.id).length >
                  assetRestaurants.where((e) => e.id == element.id).length
              ? value
              : element);
      selectedRestaurant = restaurant;
    } else if (assets.isNotEmpty && assets.first.restaurant != null) {
      selectedRestaurant = assets.first.restaurant;
    }

    if (mostCommonDate != null) {
      review!.timestamp = mostCommonDate;
    }
  }

  Future<Map<String, dynamic>?> extractLocationAndDate(File imageFile) async {
    final Map<String, IfdTag> data =
        await readExifFromBytes(await imageFile.readAsBytes());

    if (data.isEmpty) {
      print("No EXIF information found");
      return null;
    }

    DateTime? date;
    if (data.containsKey('Image DateTime')) {
      try {
        date = DateTime.parse(data['Image DateTime']!.printable);
      } catch (e) {
        print("Error parsing date: $e");
      }
    }

    if (!data.containsKey('GPS GPSLatitude') ||
        !data.containsKey('GPS GPSLongitude')) {
      return {'date': date};
    }

    final lat = _convertToDecimal(
        data['GPS GPSLatitude']!.values, data['GPS GPSLatitudeRef']!.printable);
    final lon = _convertToDecimal(data['GPS GPSLongitude']!.values,
        data['GPS GPSLongitudeRef']!.printable);

    return {'latitude': lat, 'longitude': lon, 'date': date};
  }

  double _convertToDecimal(IfdValues idf, String ref) {
    final values = idf.toList();

    if (values.length < 3) {
      throw ArgumentError('Expected at least 3 values.');
    }

    double degrees = values[0].denominator != 0
        ? values[0].numerator / values[0].denominator
        : 0;
    double minutes = values[1].denominator != 0
        ? values[1].numerator / values[1].denominator
        : 0;
    double seconds = values.length > 2 && values[2].denominator != 0
        ? values[2].numerator / values[2].denominator
        : 0;

    double res = degrees + (minutes / 60) + (seconds / 3600);

    if (ref == 'S' || ref == 'W') {
      res = -res;
    }

    return res;
  }

  void onShareReview() async {
    if (review == null) {
      print("Review is null. Cannot upload to Firestore.");
      return;
    }

    List<String> imageUrls = [];

    // Upload images to Firebase Storage from selectedAssetsNotifier
    for (GoodieAsset asset in selectedAssetsNotifier.value) {
      // Get the File from the GoodieAsset
      File imageFile = (asset.imageFile ?? await asset.asset.file)!;

      // Generate a unique path for the image
      String path =
          'reviews/${review!.restaurantId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Upload the image and get the download URL
      String imageUrl = await uploadImageToFirebaseStorage(imageFile, path);
      imageUrls.add(imageUrl);
    }

    // Convert the RestaurantReview object to a Map
    Map<String, dynamic> reviewMap = {
      'restaurantId': review!.restaurantId,
      'userId': review!.userId,
      'dineIn': review!.dineIn,
      'ratingFood': review!.ratingFood,
      'ratingService': review!.ratingService,
      'ratingPrice': review!.ratingPrice,
      'ratingAtmosphere': review!.ratingAtmosphere,
      'ratingCleanliness': review!.ratingCleanliness,
      'ratingPackaging': review!.ratingPackaging,
      'ratingOverall': review!.ratingOverall,
      'description': review!.description,
      'timestamp': review!.timestamp,
      'images': imageUrls, // Store the image URLs in the review document
    };

    // Upload to Firestore
    CollectionReference reviews =
        FirebaseFirestore.instance.collection('reviews');
    if (review!.id == null) {
      // If the review doesn't have an ID, add a new document
      await reviews.add(reviewMap);
    } else {
      // If the review has an ID, update the existing document
      await reviews.doc(review!.id).set(reviewMap);
    }

    print("Review and images uploaded to Firestore and Firebase Storage.");
  }
}

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  int? byteLength;
  File? imageFile;
  Restaurant? restaurant;
  VideoPlayerController? videoPlayerController;

  GoodieAsset({
    required this.asset,
    this.imageFile,
    this.videoPlayerController,
  }) : super(
          id: asset.id,
          typeInt: asset.typeInt,
          width: asset.width,
          height: asset.height,
          duration: asset.duration,
        );
}
