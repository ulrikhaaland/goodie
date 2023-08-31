import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:collection/collection.dart';

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

class RestaurantReviewPhotoPicker extends StatefulWidget {
  final Function(List<GoodieAsset>) onImagesSelected;
  final ScrollController scrollController;
  final Widget restaurantListItem;

  const RestaurantReviewPhotoPicker({
    Key? key,
    required this.onImagesSelected,
    required this.scrollController,
    required this.restaurantListItem,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _RestaurantReviewPhotoPickerState createState() =>
      _RestaurantReviewPhotoPickerState();
}

class _RestaurantReviewPhotoPickerState
    extends State<RestaurantReviewPhotoPicker> {
  List<GoodieAsset> _recentImages = [];
  final ValueNotifier<List<GoodieAsset>> _selectedAssetsNotifier =
      ValueNotifier<List<GoodieAsset>>([]);
  final ValueNotifier<GoodieAsset?> _selectedAssetNotifier =
      ValueNotifier(null);
  final Map<GoodieAsset, Uint8List> _thumbnailCache = {};
  bool showListItem = false;

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showListItem = true;
        });
      }
    });
  }

  Future<void> _loadRecentImages() async {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    recentPath.getAssetListRange(start: 0, end: 100).then((recentImages) {
      if (mounted) {
        setState(() {
          _recentImages = recentImages
              .map((e) => GoodieAsset(
                    asset: e,
                  ))
              .toList();
          _selectedAssetNotifier.value = _recentImages.first;
        });

        _recentImages.forEach((element) async {
          element.originFile.then((value) {
            if (value != null) {
              value.readAsBytes().then((value) {
                element.byteLength = value.lengthInBytes;
              });
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _selectedAssetNotifier.dispose();
    _selectedAssetsNotifier.dispose();
    super.dispose();
  }

  bool _scrollable = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final thumbnailSize = (screenWidth / 2.5).floor();
    final selectedAssetHeight = screenWidth.floor();
    final selectedAssetWidth = (selectedAssetHeight * 0.8).floor();

    return SizedBox(
      height: screenHeight,
      child: CustomScrollView(
        controller: widget.scrollController,
        physics: _scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true, // Add this line
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              background:
                  showListItem ? widget.restaurantListItem : Container(),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverHeaderDelegate(
              minHeight: selectedAssetHeight.toDouble(),
              maxHeight: selectedAssetHeight.toDouble(),
              child: ValueListenableBuilder(
                valueListenable: _selectedAssetNotifier,
                builder: (context, selectedAsset, child) {
                  if (selectedAsset == null) return const SizedBox.shrink();

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
    widget.onImagesSelected(_selectedAssetsNotifier.value);

    _selectedAssetsNotifier.value =
        List.from(_selectedAssetsNotifier.value); // to trigger a rebuild
  }

  Future<GoodieAsset> _fetchHighResolutionAsset(GoodieAsset asset) async {
    await asset.originBytes;
    return asset;
  }

  Widget _buildPickImage() {
    return GestureDetector(
      onTap: () async {
        final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
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
            _selectedAssetsNotifier.value.add(asset);
            _selectedAssetNotifier.value = asset;
          }
          widget.onImagesSelected(_selectedAssetsNotifier.value);
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

  String extractId(String input) {
    final RegExp regExp = RegExp(r'image_picker_([\w-]+)\.jpg');
    final match = regExp.firstMatch(input);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!; // This will return the ID
    }
    return ''; // Return an empty string or handle it as you need if no match is found
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class SelectionIndicator extends StatelessWidget {
  final GoodieAsset asset;
  final ValueNotifier<List<GoodieAsset>> selectedAssetsNotifier;
  final ValueNotifier<GoodieAsset?> currentAssetNotifier;

  const SelectionIndicator({
    super.key,
    required this.asset,
    required this.selectedAssetsNotifier,
    required this.currentAssetNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GoodieAsset>>(
      valueListenable: selectedAssetsNotifier,
      builder: (context, selectedAssets, child) {
        int assetIndex = selectedAssets.indexOf(asset);
        return Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: Stack(
            children: [
              if (currentAssetNotifier.value == asset)
                Positioned.fill(
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(width: 1, color: Colors.white),
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
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AssetThumbnail extends StatefulWidget {
  final GoodieAsset asset;
  final int? width;
  final int? height;
  final int thumbWidth;
  final int thumbHeight;
  final Map<GoodieAsset, Uint8List> cache;
  final bool fullResolution;

  const AssetThumbnail({
    Key? key,
    required this.asset,
    this.width,
    this.height,
    this.thumbWidth = 200,
    this.thumbHeight = 200,
    required this.cache,
    this.fullResolution = false,
  }) : super(key: key);

  @override
  State<AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<AssetThumbnail> {
  MemoryImage? editImage;

  PhotoViewController? controller;

  @override
  void initState() {
    if (widget.fullResolution) {
      controller = PhotoViewController(
          initialPosition: widget.asset.offset ?? Offset.zero,
          initialScale: widget.asset.scale ?? 1.0);
    }
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return widget.cache.containsKey(widget.asset)
        ? _buildCachedImage(screenWidth, widget.cache[widget.asset]!)
        : _buildFutureImage(screenWidth);
  }

  Widget _buildCachedImage(
    double screenWidth,
    Uint8List imageBytes,
  ) {
    if (widget.fullResolution) {
      return SizedBox(
        width: widget.width!.toDouble(),
        height: widget.height!.toDouble(),
        child: ClipRect(
          child: PhotoView(
            key: Key(widget.asset.id),
            controller: controller!,
            imageProvider:
                MemoryImage(widget.cache[widget.asset] ?? imageBytes),
            minScale: PhotoViewComputedScale.covered,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: widget.asset.scale,
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            basePosition: Alignment.center,
            onScaleEnd: (context, details, controllerValue) {
              widget.asset.scale = controllerValue.scale;
              widget.asset.offset = controllerValue.position;
            },
          ),
        ),
      );
    } else {
      return Image.memory(
        widget.cache[widget.asset] ?? imageBytes,
        width: widget.width?.toDouble() ?? screenWidth / 4.35,
        height: widget.height?.toDouble() ?? 100,
        fit: BoxFit.cover,
      );
    }
  }

  Widget _buildFutureImage(double screenWidth) {
    return FutureBuilder<Uint8List?>(
      future: widget.asset.imageFile?.readAsBytes() ?? widget.asset.originBytes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          if (widget.asset.imageFile != null) {}
          // widget.asset.originBytes.then((value) {
          widget.cache[widget.asset] = snapshot.data!;
          if (widget.fullResolution) {
            // setState(() {});
          }
          // });
          return _buildCachedImage(screenWidth, snapshot.data!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
