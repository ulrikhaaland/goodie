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
  List<AssetEntity> _selectedAssets = [];
  AssetEntity? _selectedAsset;

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
    final thumbnailSize =
        ((screenWidth - 20) / 3).floor(); // 10*2 for mainAxisSpacing

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Legg til bilder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        if (_selectedAsset != null)
          AssetThumbnail(
            asset: _selectedAsset!,
            thumbnailSize: ThumbnailSize(thumbnailSize, thumbnailSize),
          ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _recentImages.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_selectedAssets.contains(_recentImages[index])) {
                      _selectedAssets.remove(_recentImages[index]);
                    } else {
                      _selectedAssets.add(_recentImages[index]);
                    }
                    // Setting the most recently picked image as the _selectedAsset
                    _selectedAsset = _recentImages[index];
                  });
                },
                child: buildAssetThumbnailWithSelectionIndicator(
                  _recentImages[index],
                  ThumbnailSize(thumbnailSize, thumbnailSize),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildAssetThumbnailWithSelectionIndicator(
      AssetEntity asset, ThumbnailSize thumbnailSize) {
    int? assetIndex = _selectedAssets.indexOf(asset);
    bool isSelected = assetIndex != -1;

    return Stack(
      children: [
        AssetThumbnail(
          asset: asset,
          thumbnailSize: thumbnailSize,
        ), // Your AssetThumbnail widget

        if (isSelected)
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.blue, // or any desired color
              radius: 12,
              child: Text(
                '${assetIndex + 1}', // +1 because list index starts at 0
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

class AssetThumbnail extends StatelessWidget {
  final AssetEntity asset;
  final double? height;
  final ThumbnailSize thumbnailSize;

  const AssetThumbnail({
    super.key,
    required this.asset,
    this.height,
    required this.thumbnailSize,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(thumbnailSize),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return AspectRatio(
            aspectRatio: 1, // to maintain square aspect ratio
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              height: height,
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
