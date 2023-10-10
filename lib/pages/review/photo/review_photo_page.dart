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
import '../../../bloc/create_review_provider.dart';

// ignore: must_be_immutable

class RestaurantReviewPhotoPage extends StatefulWidget {
  final Widget restaurantListItem;
  final CreateRestaurantReviewProvider reviewProvider;
  final bool isCurrentPage;

  const RestaurantReviewPhotoPage({
    Key? key,
    required this.restaurantListItem,
    required this.reviewProvider,
    required this.isCurrentPage,
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
    _selectedAssetNotifier.addListener(_onSelectedAssetChange);
    super.initState();
  }

  @override
  void dispose() {
    _selectedAssetNotifier.removeListener(_onSelectedAssetChange);

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RestaurantReviewPhotoPage oldWidget) {
    // pause all videos if widget.iscurrentpage == false
    if (!widget.isCurrentPage) {
      _pauseAllVideos();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final thumbnailSize = (screenWidth / 2.5).floor();
    final selectedAssetHeight = screenWidth.floor();
    final selectedAssetWidth = (selectedAssetHeight * 0.8).floor();

    final ThemeData themeData = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SizedBox(
        height: screenHeight,
        child: CustomScrollView(
          physics: _scrollable
              ? const AlwaysScrollableScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: themeData.scaffoldBackgroundColor,
              elevation: 0,
              floating: true, // Add this line
              expandedHeight: 54,
              flexibleSpace: const FlexibleSpaceBar(
                background: Column(
                  children: [
                    SizedBox(height: 12.0),
                    Text(
                      'Ny anmeldelse',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
            Positioned(
              right: 5,
              bottom: 5,
              child: Builder(
                builder: (context) {
                  final duration = Duration(seconds: asset.duration);
                  final minutes = duration.inMinutes;
                  final seconds = (duration.inSeconds % 60)
                      .toString()
                      .padLeft(2, '0'); // Ensure seconds is two digits
                  return Text(
                    '$minutes:$seconds',
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
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

    _selectedAssetsNotifier.value =
        List.from(_selectedAssetsNotifier.value); // to trigger a rebuild
  }

  Widget _buildPickImage() {
    return GestureDetector(
      onTap: () async {
        List<XFile> pickedFiles = [];
        try {
          pickedFiles = await ImagePicker().pickMultipleMedia();
        } catch (e) {
          print(e);
        }

        final List<GoodieAsset> pickedAssets = [];

        if (pickedFiles.isNotEmpty) {
          for (var file in pickedFiles) {
            GoodieAsset? asset;

            asset = _recentImages.firstWhereOrNull((element) =>
                element.asset.title != null &&
                element.asset.title == file.name);

            bool isRecent = asset != null;

            if (asset == null) {
              asset = xFileToAssetEntity(file);
            } else {
              final isSelected = _selectedAssetsNotifier.value.firstWhereOrNull(
                    (element) => element.asset.title == file.name,
                  ) !=
                  null;

              if (isSelected) {
                continue;
              }
            }
            if (!isRecent) {
              _recentImages.insert(0, asset);
            }

            pickedAssets.add(asset);
          }
          if (pickedAssets.isNotEmpty) {
            _selectedAssetNotifier.value = pickedAssets.first;
            final oldList = _selectedAssetsNotifier.value;
            final newList = List<GoodieAsset>.from(oldList);

            for (final asset in pickedAssets) {
              if (newList.contains(asset)) {
                continue;
              }
              newList.add(asset);
              if (newList.length > 10) {
                newList.removeAt(0);
              }
            }

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
    String filePath = file.path;
    String fileExtension = filePath.split('.').last;

    AssetType assetType;

    // List of video extensions can be extended as needed
    if (['mov', 'mp4', 'avi', 'mpeg', 'webm', 'wmv', 'mkv', 'flv', '3gp']
        .contains(fileExtension.toLowerCase())) {
      assetType = AssetType.video;
    }
    // List of image extensions can be extended as needed
    else if (['jpg', 'jpeg', 'png', 'gif']
        .contains(fileExtension.toLowerCase())) {
      assetType = AssetType.image;
    } else {
      throw Exception('Invalid file extension');
      assetType = AssetType.other; // Hand other types as you see fit
    }

    AssetEntity asset = AssetEntity(
        id: file.name,
        title: file.name,
        typeInt: assetType == AssetType.video
            ? 2
            : 1, // Assuming 1 is for images, 2 is for videos in your enum
        width: 1,
        height: 1,
        relativePath: file.path);

    final originFile = File(file.path);

    VideoPlayerController? videoController;

    if (assetType == AssetType.video) {
      videoController = VideoPlayerController.file(originFile)..initialize();
    }

    return GoodieAsset(
      asset: asset,
      imageFile: originFile,
      videoPlayerController: videoController,
    );
  }

  void _onSelectedAssetChange() {
    final selectedAsset = _selectedAssetNotifier.value;

    if (selectedAsset!.type == AssetType.video) {
      selectedAsset.videoPlayerController!
        ..play()
        ..setLooping(true);
    } else {
      _pauseAllVideos();
    }
  }

  void _pauseAllVideos() {
    _recentImages
        .where((element) => element.type == AssetType.video)
        .forEach((element) => element.videoPlayerController?.pause());
  }
}
