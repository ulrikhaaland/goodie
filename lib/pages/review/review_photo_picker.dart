import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;

  GoodieAsset({
    required this.asset,
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

  @override
  void initState() {
    super.initState();
    _loadRecentImages();
  }

  Future<void> _loadRecentImages() async {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final recentImages = await recentPath.getAssetListRange(start: 0, end: 10);
    if (mounted) {
      setState(() {
        _recentImages = recentImages
            .map((e) => GoodieAsset(
                  asset: e,
                ))
            .toList();
        _selectedAssetNotifier.value = _recentImages.first;
      });
    }
  }

  @override
  void dispose() {
    _selectedAssetNotifier.dispose();
    _selectedAssetsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final thumbnailSize = (screenWidth / 2.5).floor();
    final selectedAssetHeight = screenWidth.floor();
    final selectedAssetWidth = (selectedAssetHeight * 0.8).floor();

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          snap: true,
          expandedHeight:
              150.0, // Adjust this value to your desired height for _buildRestaurantListItem
          flexibleSpace: FlexibleSpaceBar(
            background: widget.restaurantListItem,
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: selectedAssetHeight.toDouble(),
            width: selectedAssetWidth.toDouble(),
            child: ValueListenableBuilder(
              valueListenable: _selectedAssetNotifier,
              builder: (context, selectedAsset, child) {
                if (selectedAsset == null) return const SizedBox.shrink();
                return AssetThumbnail(
                  key: Key("${selectedAsset.id}full"),
                  asset: selectedAsset,
                  width: selectedAssetWidth,
                  height: selectedAssetHeight,
                  cache: _thumbnailCache,
                  fullResolution: true,
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
              return buildAssetThumbnailWithSelectionIndicator(
                  _recentImages[index], thumbnailSize, thumbnailSize);
            },
            childCount: _recentImages.length,
          ),
        ),
      ],
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

      final fullResAsset = await _fetchHighResolutionAsset(asset);
      _selectedAssetNotifier.value = fullResAsset;
      _selectedAssetsNotifier.value.add(fullResAsset);
    }
    widget.onImagesSelected(_selectedAssetsNotifier.value);

    _selectedAssetsNotifier.value =
        List.from(_selectedAssetsNotifier.value); // to trigger a rebuild
  }

  Future<GoodieAsset> _fetchHighResolutionAsset(GoodieAsset asset) async {
    await asset.originBytes;
    return asset;
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
            controller: controller,
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
      future: widget.fullResolution
          ? widget.asset.originBytes
          : widget.asset.thumbnailDataWithSize(
              ThumbnailSize(widget.thumbWidth, widget.thumbHeight)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          widget.asset.originBytes.then((value) {
            widget.cache[widget.asset] = value!;
            if (widget.fullResolution) {
              setState(() {});
            }
          });
          return _buildCachedImage(screenWidth, snapshot.data!);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
