import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../model/restaurant.dart';
import '../utils/distance.dart';

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
  }

  void onShareReview() {}

  Future<void> _handleSelectedRestaurant() async {
    final assets = selectedAssetsNotifier.value;

    final assetRestaurants = assets
        .where((element) => element.restaurant != null)
        .map((e) => e.restaurant!)
        .toList();

    final assetsCopy = List.from(assets);

    for (var asset
        in assetsCopy.where((element) => element.restaurant == null)) {
      final assetss = asset;
      final image = assetss.imageFile ?? await assetss.file;

      final location = await extractLocation(image!);
      if (location != null &&
          location['latitude'] != 0 &&
          location['longitude'] != 0) {
        int? distance;

        restaurants.where((e) => e.position != null).forEach((restaurant) {
          int dist = getDistance(location['latitude']!, location['longitude']!,
                  restaurant.position!.latitude, restaurant.position!.longitude)
              .toInt();

          distance ??= dist;

          if (dist < distance!) {
            distance = dist;
            asset.restaurant = restaurant;
          }
        });
      } else {
        continue;
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
    } else if (assets.isNotEmpty) {
      selectedRestaurant = assets.first.restaurant;
    } else {
      selectedRestaurant = null;
    }
  }

  Future<Map<String, double>?> extractLocation(File imageFile) async {
    final Map<String, IfdTag> data =
        await readExifFromBytes(await imageFile.readAsBytes());

    if (data.isEmpty ||
        !data.containsKey('GPS GPSLatitude') ||
        !data.containsKey('GPS GPSLongitude')) {
      print("No EXIF information found");
      return null;
    }

    final lat = _convertToDecimal(
        data['GPS GPSLatitude']!.values, data['GPS GPSLatitudeRef']!.printable);
    final lon = _convertToDecimal(data['GPS GPSLongitude']!.values,
        data['GPS GPSLongitudeRef']!.printable);

    return {'latitude': lat, 'longitude': lon};
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
}

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  int? byteLength;
  File? imageFile;
  Restaurant? restaurant;

  GoodieAsset({
    required this.asset,
    this.imageFile,
  }) : super(
            id: asset.id,
            typeInt: asset.typeInt,
            width: asset.width,
            height: asset.height);
}
