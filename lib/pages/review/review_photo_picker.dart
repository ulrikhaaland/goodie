import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class RestaurantReviewPhotoPicker extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  const RestaurantReviewPhotoPicker(
      {super.key, required this.onImagesSelected});
  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPhotoPickerState createState() =>
      _RestaurantReviewPhotoPickerState();
}

class _RestaurantReviewPhotoPickerState
    extends State<RestaurantReviewPhotoPicker> {
  List<AssetEntity> _recentImages = [];
  final List<AssetEntity> _selectedAssets = [];
  AssetEntity? _selectedAsset;
  final ValueNotifier<List<AssetEntity>> _selectedAssetsNotifier =
      ValueNotifier<List<AssetEntity>>([]);

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final recentImages = await recentPath.getAssetListRange(
        start: 0, end: 10); // Fetching the 10 most recent images
    setState(() {
      _recentImages = recentImages;
      _selectedAsset = recentImages
          .first; // Set the most recent image as selected by default
    });
  }

  @override
  Widget build(BuildContext context) {
    // Compute the thumbnail size based on the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final thumbnailSize = ((screenWidth) / 2.5).floor();

    final selectedAssetHeight =
        screenWidth.floor(); // Full width for the selected asset
    final selectedAssetWidth =
        (selectedAssetHeight * 0.8).floor(); // 60% of the width for the height
    return Column(
      children: [
        if (_selectedAsset != null)
          if (_selectedAsset != null)
            AssetThumbnail(
              asset: _selectedAsset!,
              width: selectedAssetWidth, // specify the desired width
              height: selectedAssetHeight, // specify a smaller desired height
              // thumbWidth:
              //     selectedAssetThumbnailSize, // value larger than display width for clarity
              // thumbHeight:
              //     selectedAssetThumbnailSize, // value larger than display height for clarity
            ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio:
                    0.775, // adjusted for a little more height based on the aspect ratio
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                mainAxisExtent: 101),
            itemCount: _recentImages.length,
            itemBuilder: (context, index) {
              return buildAssetThumbnailWithSelectionIndicator(
                  _recentImages[index], thumbnailSize, thumbnailSize);
            },
          ),
        ),
      ],
    );
  }

  Widget buildAssetThumbnailWithSelectionIndicator(
      AssetEntity asset, int width, int height) {
    final cHeight = (height * 0.6).toInt();

    return GestureDetector(
      onTap: () {
        int assetIndex = _selectedAssetsNotifier.value.indexOf(asset);
        if (assetIndex != -1) {
          _selectedAssetsNotifier.value.removeAt(assetIndex);
        } else {
          _selectedAssetsNotifier.value.add(asset);
        }
        _selectedAssetsNotifier.value =
            List.from(_selectedAssetsNotifier.value); // to notify the change
        _selectedAsset = asset; // if needed
      },
      child: Stack(
        children: [
          AssetThumbnail(
            asset: asset,
            thumbWidth: width,
            thumbHeight: cHeight,
          ),
          ValueListenableBuilder<List<AssetEntity>>(
            valueListenable: _selectedAssetsNotifier,
            builder: (context, selectedAssets, child) {
              int assetIndex = selectedAssets.indexOf(asset);
              if (assetIndex == -1) return const SizedBox.shrink();
              return Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 8,
                  child: Text(
                    '${assetIndex + 1}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final int? width;
  final int? height;
  final int thumbWidth;
  final int thumbHeight;

  const AssetThumbnail({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.thumbWidth = 200,
    this.thumbHeight = 200,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder<Uint8List?>(
      future:
          asset.thumbnailDataWithSize(ThumbnailSize(thumbWidth, thumbHeight)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width?.toDouble() ?? screenWidth / 4.35,
            height: height?.toDouble() ?? 100,
            fit: BoxFit.cover,
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
