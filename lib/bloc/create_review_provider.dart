import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_view/flutter_video_view.dart';
import 'package:photo_manager/photo_manager.dart';
// ignore: depend_on_referenced_packages
import '../model/restaurant.dart';
import '../utils/distance.dart';
import '../utils/image.dart';

final _videoConfig = VideoConfig(
  autoInitialize: true,
  canChangeVolumeOrBrightness: false,
  useRootNavigator: false,
  panEnabled: true,
  scaleEnabled: true,
  volume: 0.3,
  minScale: 1,
  maxScale: 3,
  // canBack: false,
  canChangeProgress: false,
  // // autoPlay: true,
  // showControls: (context, isFullScreen) => false,
  // aspectRatio:
  //     widget.asset.videoPlayerController!.value.aspectRatio,
  // topActionsBuilder: (context, isFullScreen) => [
  //   const SizedBox(),
  // ],
);

class CreateRestaurantReviewProvider with ChangeNotifier {
  Restaurant? _selectedRestaurant;
  List<Restaurant> restaurants = [];
  RestaurantReview review = RestaurantReview(
    restaurantId: "",
    userId: "test",
    dineIn: true,
  );
  List<GoodieAsset> recentImages = [];
  final ValueNotifier<List<GoodieAsset>> selectedAssetsNotifier =
      ValueNotifier<List<GoodieAsset>>([]);
  final ValueNotifier<GoodieAsset?> selectedAssetNotifier = ValueNotifier(null);
  final Map<GoodieAsset, Uint8List> thumbnailCache = {};

  CreateRestaurantReviewProvider() {
    loadRecentImages();
    selectedAssetsNotifier.addListener(() {
      _handleSelectedRestaurant();
    });
  }

  set selectedRestaurant(Restaurant? restaurant) {
    _selectedRestaurant = restaurant;

    review = RestaurantReview(
      restaurantId: selectedRestaurant!.id,
      userId: "test",
      dineIn: true,
      timestamp: review.timestamp,
    );
  }

  Restaurant? get selectedRestaurant => _selectedRestaurant;

  Future<void> loadRecentImages() async {
    try {
      final List<AssetPathEntity> paths =
          await PhotoManager.getAssetPathList(onlyAll: true);
      final AssetPathEntity recentPath = paths.first;
      recentPath.getAssetListRange(start: 0, end: 100).then((value) {
        recentImages = value
            .map((e) => GoodieAsset(
                  asset: e,
                ))
            .toList();
        selectedAssetNotifier.value = recentImages.first;

        recentImages
            .where((media) => media.asset.type == AssetType.video)
            .forEach((video) async {
          video.originFile.then((value) {
            video.videoPlayerController = VideoController(
              videoPlayerController: VideoPlayerController.file(value!),
              videoConfig: _videoConfig,
            );
            video.videoPlayerController!.initialize();
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

    for (GoodieAsset asset
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

      DateTime? date = data?['date'] ?? asset.asset.createDateTime;
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
      review.timestamp = mostCommonDate;
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

  void _resetReview() {
    selectedAssetsNotifier.value = [];
    selectedAssetNotifier.value =
        recentImages.isNotEmpty ? recentImages.first : null;
    _selectedRestaurant = null;
    review = RestaurantReview(
      restaurantId: "",
      userId: "test",
      dineIn: true,
    );
  }

  void onShareReview() async {
    RestaurantReview shareReview = review;
    List<GoodieAsset> assets = [...selectedAssetsNotifier.value];
    // reset assets
    _resetReview();

    List<String> assetUrls = [];

    // Upload assets to Firebase Storage from selectedAssetsNotifier
    for (GoodieAsset asset in assets) {
      // Get the File from the GoodieAsset
      File assetFile = (asset.imageFile ?? await asset.asset.file)!;

      // Determine the file extension
      String fileExtension = asset.type == AssetType.video ? '.mp4' : '.jpg';

      // Generate a unique path for the asset
      String path =
          'reviews/${shareReview.restaurantId}/${DateTime.now().millisecondsSinceEpoch}$fileExtension';

      // Upload the asset and get the download URL
      String assetUrl = await uploadAssetToFirebaseStorage(assetFile, path);
      assetUrls.add(assetUrl);
    }

    // Convert the RestaurantReview object to a Map
    Map<String, dynamic> reviewMap = {
      'restaurantId': shareReview.restaurantId,
      'userId': shareReview.userId,
      'dineIn': shareReview.dineIn,
      'ratingFood': shareReview.ratingFood,
      'ratingService': shareReview.ratingService,
      'ratingPrice': shareReview.ratingPrice,
      'ratingAtmosphere': shareReview.ratingAtmosphere,
      'ratingCleanliness': shareReview.ratingCleanliness,
      'ratingPackaging': shareReview.ratingPackaging,
      'ratingOverall': shareReview.ratingOverall,
      'description': shareReview.description,
      'timestamp': shareReview.timestamp,
      'images': assetUrls, // Store the image URLs in the review document
    };

    // Upload to Firestore
    CollectionReference reviews =
        FirebaseFirestore.instance.collection('reviews');
    if (shareReview.id == null) {
      // If the review doesn't have an ID, add a new document
      await reviews.add(reviewMap);
    } else {
      // If the review has an ID, update the existing document
      await reviews.doc(shareReview.id).set(reviewMap);
    }

    print("Review and images uploaded to Firestore and Firebase Storage.");
  }
}

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  File? imageFile;
  Restaurant? restaurant;
  VideoController? videoPlayerController;

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
