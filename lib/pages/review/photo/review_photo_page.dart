import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:goodie/pages/review/photo/review_photo_asset_thumbnail.dart';
import 'package:goodie/pages/review/photo/review_photo_selection_indicator.dart';
import 'package:goodie/pages/review/photo/review_photo_sliver_head_delegate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:video_player/video_player.dart';
import '../../../bloc/review.dart';

// ignore: must_be_immutable

class RestaurantReviewPhotoPage extends StatefulWidget {
  final Widget restaurantListItem;
  final RestaurantReviewProvider reviewProvider;

  const RestaurantReviewPhotoPage({
    Key? key,
    required this.restaurantListItem,
    required this.reviewProvider,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPhotoPageState createState() =>
      _RestaurantReviewPhotoPageState();
}

class _RestaurantReviewPhotoPageState extends State<RestaurantReviewPhotoPage>
    with AutomaticKeepAliveClientMixin {
  bool showListItem = false;

  ValueNotifier<GoodieAsset?> get _selectedAssetNotifier =>
      widget.reviewProvider.selectedAssetNotifier;

  ValueNotifier<List<GoodieAsset>> get _selectedAssetsNotifier =>
      widget.reviewProvider.selectedAssetsNotifier;

  Map<GoodieAsset, Uint8List> get _thumbnailCache =>
      widget.reviewProvider.thumbnailCache;

  List<GoodieAsset> get _recentImages => widget.reviewProvider.recentImages;

  bool _scrollable = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showListItem = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final thumbnailSize = (screenWidth / 2.5).floor();
    final selectedAssetHeight = screenWidth.floor();
    final selectedAssetWidth = (selectedAssetHeight * 0.8).floor();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: screenHeight,
        child: CustomScrollView(
          physics: _scrollable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          slivers: [
            const SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              floating: true, // Add this line
              expandedHeight: 78,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    SizedBox(height: 24.0),
                    Text(
                      'Legg til bilder fra besøket',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate(
                minHeight: selectedAssetHeight.toDouble(),
                maxHeight: selectedAssetHeight.toDouble(),
                child: ValueListenableBuilder(
                  valueListenable: _selectedAssetNotifier,
                  builder: (context, selectedAsset, child) {
                    if (selectedAsset == null) return const SizedBox.shrink();

                    if (selectedAsset.type == AssetType.video &&
                        selectedAsset.videoPlayerController != null) {
                      return AssetThumbnail(
                        key: Key("${selectedAsset.id}full"),
                        asset: selectedAsset,
                        width: selectedAssetWidth,
                        height: selectedAssetHeight,
                        cache: _thumbnailCache,
                        fullResolution: true,
                      );
                    } else {
                      return Listener(
                        onPointerDown: (_) {
                          setState(() {
                            _scrollable = false;
                          });
                        },
                        onPointerUp: (_) {
                          setState(() {
                            _scrollable = true;
                          });
                        },
                        child: AssetThumbnail(
                          key: Key("${selectedAsset.id}full"),
                          asset: selectedAsset,
                          width: selectedAssetWidth,
                          height: selectedAssetHeight,
                          cache: _thumbnailCache,
                          fullResolution: true,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.775,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                mainAxisExtent: 101,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  // If the index is 0, return the "Open Camera Roll" item
                  if (index == 0) {
                    return _buildPickImage();
                  }

                  // Adjust the index to account for the additional item
                  index = index - 1;

                  return buildAssetThumbnailWithSelectionIndicator(
                      _recentImages[index], thumbnailSize, thumbnailSize);
                },
                childCount: _recentImages.length +
                    1, // Add 1 for the "Open Camera Roll" item
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAssetThumbnailWithSelectionIndicator(
      GoodieAsset asset, int width, int height) {
    final cHeight = (height * 0.6).toInt();

    return GestureDetector(
      onTap: () => _handleOnThumbnailTap(asset),
      child: Stack(
        children: [
          AssetThumbnail(
            key: Key("${asset.id}thumbnail"),
            asset: asset,
            thumbWidth: width,
            thumbHeight: cHeight,
            cache: _thumbnailCache,
          ),
          if (asset.type == AssetType.video)
            const Positioned(
              bottom: 10,
              right: 10,
              child:
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 24),
            ),
          SelectionIndicator(
            asset: asset,
            selectedAssetsNotifier: _selectedAssetsNotifier,
            currentAssetNotifier: _selectedAssetNotifier,
          ),
        ],
      ),
    );
  }

  Future<void> _handleOnThumbnailTap(GoodieAsset asset) async {
    final selectedAssets = _selectedAssetsNotifier.value;

    int assetIndex = selectedAssets.indexOf(asset);
    if (assetIndex != -1) {
      if (_selectedAssetNotifier.value?.id != asset.id) {
        setState(() {
          _selectedAssetNotifier.value = asset;
        });
        if (asset.type == AssetType.video &&
            asset.videoPlayerController != null) {
          await asset.videoPlayerController!.initialize();
          asset.videoPlayerController!.play();
        }

        return;
      }
      _selectedAssetsNotifier.value.removeAt(assetIndex);
      _selectedAssetNotifier.value =
          selectedAssets.isEmpty ? _recentImages.first : selectedAssets.last;
    } else {
      // Check the lower limit here
      // Remove first item if the limit is reached
      if (selectedAssets.length >= 10) {
        _selectedAssetsNotifier.value.removeAt(0);
      }

      _selectedAssetNotifier.value = asset;
      _selectedAssetsNotifier.value.add(asset);
    }

    _selectedAssetsNotifier.value =
        List.from(_selectedAssetsNotifier.value); // to trigger a rebuild

    if (asset.type == AssetType.video && asset.videoPlayerController != null) {
      await asset.videoPlayerController!.initialize();
      asset.videoPlayerController!.play();
    }
  }

  Widget _buildPickImage() {
    return GestureDetector(
      onTap: () async {
        final List<XFile> pickedFiles = await ImagePicker().pickMultipleMedia();
        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            final Uint8List pickedImageDataTemp = await file.readAsBytes();

            final byteLength = pickedImageDataTemp.lengthInBytes;

            GoodieAsset? asset;

            asset = _recentImages.firstWhereOrNull((element) =>
                element.byteLength != null && element.byteLength == byteLength);

            bool isRecent = asset != null;

            if (asset == null) {
              asset = xFileToAssetEntity(file);
            } else {
              final isSelected = _selectedAssetsNotifier.value.firstWhereOrNull(
                    (element) => element.byteLength == byteLength,
                  ) !=
                  null;

              if (isSelected) {
                continue;
              }
            }
            if (!isRecent) {
              _recentImages.insert(0, asset);
            }
            _selectedAssetNotifier.value = asset;
            final oldList = _selectedAssetsNotifier.value;
            final newList = List<GoodieAsset>.from(oldList)..add(asset);
            _selectedAssetsNotifier.value = newList;
          }
        }
      },
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_roll), // Use any appropriate icon
          Text("Åpne kamera-rull", textAlign: TextAlign.center),
        ],
      ),
    );
  }

  GoodieAsset xFileToAssetEntity(XFile file) {
    AssetEntity asset = AssetEntity(
        id: file.name,
        typeInt: 1,
        width: 1,
        height: 1,
        relativePath: file.path);

    return GoodieAsset(
      asset: asset,
      imageFile: File(file.path),
    );
  }
}