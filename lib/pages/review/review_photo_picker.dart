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
  AssetEntity? _selectedAsset;
  final ValueNotifier<List<AssetEntity>> _selectedAssetsNotifier =
      ValueNotifier<List<AssetEntity>>([]);
  ValueNotifier<AssetEntity?> _selectedAssetNotifier = ValueNotifier(null);
  final Map<AssetEntity, Uint8List> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _loadRecentImages().then((value) =>
        _selectedAssetNotifier = ValueNotifier<AssetEntity?>(_selectedAsset));
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
        (selectedAssetHeight * 0.8).floor(); // 60% of the width fo

    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _selectedAssetNotifier,
          builder: (context, selectedAsset, child) {
            if (selectedAsset == null) return const SizedBox.shrink();
            return AssetThumbnail(
              asset: selectedAsset,
              width: selectedAssetWidth,
              height: selectedAssetHeight,
              cache: _thumbnailCache,
              fullResolution: true, // set this to true for the selected asset
            );
          },
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
      onTap: () => _handleOnThumbnailTap(asset),
      child: Stack(
        children: [
          AssetThumbnail(
            asset: asset,
            thumbWidth: width,
            thumbHeight: cHeight,
            cache: _thumbnailCache,
          ),
          ValueListenableBuilder<List<AssetEntity>>(
            valueListenable: _selectedAssetsNotifier,
            builder: (context, selectedAssets, child) {
              int assetIndex = selectedAssets.indexOf(asset);
              return Positioned(
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: Stack(
                  children: [
                    if (_selectedAssetNotifier.value == asset)
                      Positioned(
                        left: 0,
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.transparent,
                            border: Border(
                              top: BorderSide(width: 1, color: Colors.white),
                              left: BorderSide(width: 1, color: Colors.white),
                              right: BorderSide(width: 1, color: Colors.white),
                              bottom: BorderSide(width: 1, color: Colors.white),
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: assetIndex != -1
                              ? CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 8,
                                  child: Text(
                                    '${assetIndex + 1}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                )
                              : const CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  radius: 8,
                                )),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleOnThumbnailTap(AssetEntity asset) async {
    final selectedAssets = _selectedAssetsNotifier.value;

    int assetIndex = selectedAssets.indexOf(asset);
    if (assetIndex != -1) {
      _selectedAssetsNotifier.value.removeAt(assetIndex);
      if (selectedAssets.isEmpty) {
        _selectedAssetNotifier.value = _recentImages.first;
      } else {
        _selectedAssetNotifier.value = selectedAssets.last;
      }
    } else {
      final fullResAsset = await _fetchHighResolutionAsset(asset);

      _selectedAssetNotifier.value = fullResAsset;
      _selectedAssetsNotifier.value.add(fullResAsset);

      // _selectedAssetsNotifier.value.add(asset);
    }
    _selectedAssetsNotifier.value =
        List.from(_selectedAssetsNotifier.value); // to trigger a rebuild
  }

  Future<AssetEntity> _fetchHighResolutionAsset(AssetEntity asset) async {
    // Fetch the high resolution of the image here. This might take some time.
    await asset.originBytes;

    return asset;
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final int? width;
  final int? height;
  final int thumbWidth;
  final int thumbHeight;
  final Map<AssetEntity, Uint8List> cache;
  final bool fullResolution;

  const AssetThumbnail({
    super.key,
    required this.asset,
    this.width,
    this.height,
    this.thumbWidth = 200,
    this.thumbHeight = 200,
    required this.cache,
    this.fullResolution = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Check the cache first
    if (cache.containsKey(asset)) {
      return Image.memory(
        cache[asset.originBytes]!,
        width: width?.toDouble() ?? screenWidth / 4.35,
        height: height?.toDouble() ?? 100,
        fit: BoxFit.cover,
      );
    }

    return FutureBuilder<Uint8List?>(
      future: fullResolution
          ? asset.originBytes
          : asset.thumbnailDataWithSize(ThumbnailSize(thumbWidth, thumbHeight)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          // Save to the cache
          asset.originBytes.then((value) => cache[asset] = value!);
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
