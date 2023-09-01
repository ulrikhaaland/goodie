import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../model/restaurant.dart';
import '../pages/review/review_photo_picker.dart';

class RestaurantReviewProvider with ChangeNotifier {
  Restaurant? selectedRestaurant;
  RestaurantReview? review;
  List<GoodieAsset> recentImages = [];
  final ValueNotifier<List<GoodieAsset>> selectedAssetsNotifier =
      ValueNotifier<List<GoodieAsset>>([]);
  final ValueNotifier<GoodieAsset?> selectedAssetNotifier = ValueNotifier(null);
  final Map<GoodieAsset, Uint8List> thumbnailCache = {};

  RestaurantReviewProvider() {
    loadRecentImages();
  }

  RestaurantReview getReview() {
    if (review != null) return review!;
    return RestaurantReview(
      restaurantId: selectedRestaurant!.id,
      userId: "test",
      images: [],
      dineIn: false,
    );
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
}

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  int? byteLength;
  File? imageFile;

  GoodieAsset({
    required this.asset,
    this.imageFile,
  }) : super(
            id: asset.id,
            typeInt: asset.typeInt,
            width: asset.width,
            height: asset.height);
}
