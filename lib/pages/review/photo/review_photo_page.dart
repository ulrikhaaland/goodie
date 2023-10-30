import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:goodie/bloc/bottom_nav_provider.dart';
import 'package:goodie/main.dart';
import 'package:goodie/pages/review/photo/review_photo_asset_thumbnail.dart';
import 'package:goodie/pages/review/photo/review_photo_selection_indicator.dart';
import 'package:goodie/pages/review/photo/review_photo_sliver_head_delegate.dart';
import 'package:goodie/widgets/gradient_circular_progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../../bloc/create_review_provider.dart';
import '../../../utils/image.dart';

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
  bool _scrollable = true;

  ValueNotifier<bool> isLoadingPickAsset = ValueNotifier(false);

  late final BottomNavigationProvider _bottomNavigationProvider;

  ValueNotifier<GoodieAsset?> get _selectedAssetNotifier =>
      widget.reviewProvider.selectedAssetNotifier;

  ValueNotifier<List<GoodieAsset>> get _selectedAssetsNotifier =>
      widget.reviewProvider.selectedAssetsNotifier;

  Map<GoodieAsset, Uint8List> get _thumbnailCache =>
      widget.reviewProvider.thumbnailCache;

  List<GoodieAsset> get _recentImages =>
      widget.reviewProvider.recentImagesNotifier.value;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context, listen: false);

    _bottomNavigationProvider.currentIndexListener
        .addListener(_handleOnBottomNavIndexChange);

    _selectedAssetNotifier.addListener(_onSelectedAssetChange);

    super.initState();
  }

  @override
  void dispose() {
    _selectedAssetNotifier.removeListener(_onSelectedAssetChange);
    _bottomNavigationProvider.currentIndexListener
        .removeListener(_handleOnBottomNavIndexChange);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant RestaurantReviewPhotoPage oldWidget) {
    // pause all videos if widget.iscurrentpage == false
    if (!widget.isCurrentPage) {
      _pauseAllVideos(selectedAssetId: _selectedAssetNotifier.value?.id);
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

    return SizedBox(
      height: screenHeight,
      child: CustomScrollView(
        physics: _scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: const Text(
              'Ny anmeldelse',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            elevation: 8,
            centerTitle: true,
            floating: true,
            snap: true,
            backgroundColor: Colors.transparent, // Make it transparent
            flexibleSpace: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent2Color,
                    primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child:
                  Container(), // This can be empty, it's just to hold the gradient
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
            sliver: SliverPersistentHeader(
              pinned: true,
              delegate: SliverHeaderDelegate(
                minHeight: selectedAssetHeight.toDouble(),
                maxHeight: selectedAssetHeight.toDouble(),
                child: ValueListenableBuilder(
                  valueListenable: _selectedAssetNotifier,
                  builder: (context, selectedAsset, child) {
                    if (selectedAsset == null) {
                      return _buildSelectedAssetPlaceholder();
                    }

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
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 12,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: ValueListenableBuilder<List<GoodieAsset>>(
              valueListenable: widget.reviewProvider
                  .recentImagesNotifier, // Reference to the ValueNotifier in your provider
              builder: (context, List<GoodieAsset> value, child) {
                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.775,
                    mainAxisSpacing: 0,
                    crossAxisSpacing: 0,
                    mainAxisExtent: 101,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    childCount: value.length +
                        1, // Add 1 for the "Open Camera Roll" item
                    (BuildContext context, int index) {
                      // If the index is 0, return the "Open Camera Roll" item
                      if (index == 0) {
                        return _buildPickImage();
                      }

                      // Adjust the index to account for the additional item
                      index = index - 1;

                      return buildAssetThumbnailWithSelectionIndicator(
                          value[index], thumbnailSize, thumbnailSize);
                    },
                  ),
                );
              },
            ),
          )
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
          if (asset.type == AssetType.video)
            Positioned(
              right: 5,
              bottom: 5,
              child: Builder(
                builder: (context) {
                  final duration = asset.videoDuration;
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
      onTap: _onPickImageTap,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo,
            color: accent2Color,
          ), // Use any appropriate icon
          Text("Åpne kamera-rull", textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Future<GoodieAsset> xFileToAssetEntity(XFile file) async {
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

    File? videoFile = File(file.path);

    VideoPlayerController? videoController;

    // init videoController to get video length
    if (assetType == AssetType.video) {
      videoController = VideoPlayerController.file(videoFile);
      await videoController.initialize();
    }

    final videoDuration = videoController?.value.duration.inMilliseconds;

    // trim video if needed
    if (assetType == AssetType.video && videoDuration! > 60000) {
      // Assuming asset.duration is in milliseconds
      String inputPath =
          asset.relativePath!; // Replace this with actual input file path
      String outputPath =
          "$inputPath-trimmed.mp4"; // Replace this with actual output file path
      await videoController!.dispose();
      videoFile = await trimVideo(
        inputPath,
        outputPath,
        0,
        60000,
      ); // Trim to 60 seconds
      videoController = VideoPlayerController.file(videoFile!);
      await videoController.initialize();
    }

    return GoodieAsset(
      asset: asset,
      imageFile: videoFile,
      videoPlayerController: videoController,
    );
  }

  Future<void> _onSelectedAssetChange() async {
    final selectedAsset = _selectedAssetNotifier.value;
    if (selectedAsset == null) return;

    if (selectedAsset.asset.type == AssetType.video) {
      _pauseAllVideos(selectedAssetId: selectedAsset.id);

      selectedAsset.videoPlayerController =
          VideoPlayerController.file(selectedAsset.imageFile!);

      await selectedAsset.videoPlayerController!.initialize();

      setState(() {
        selectedAsset.videoPlayerController!
          ..play()
          ..setLooping(true);
      });
    } else {
      _pauseAllVideos();
    }
  }

  void _pauseAllVideos({String? selectedAssetId}) {
    _recentImages
        .where((element) =>
            element.type == AssetType.video && element.id != selectedAssetId)
        .forEach((element) => element.videoPlayerController
          ?..pause()
          ..dispose());
  }

  Future<void> _handleOnBottomNavIndexChange() async {
    final index = _bottomNavigationProvider.currentIndexListener.value;

    if (index == 2) {
      await widget.reviewProvider.refreshImages();
      setState(() {});
    } else if (_selectedAssetsNotifier.value.isNotEmpty) {
      _selectedAssetsNotifier.value = [];
      // pause video when switching to other pages
      _pauseAllVideos();
    }
  }

  Widget _buildSelectedAssetPlaceholder() {
    return ValueListenableBuilder(
      valueListenable: isLoadingPickAsset,
      builder: (context, bool value, child) {
        if (value) {
          return const Center(child: GradientCircularProgressIndicator());
        } else {
          return GestureDetector(
            onTap: _onPickImageTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: amberColor,
                ),
              ),
              child: Center(
                child: TextButton(
                  onPressed: _onPickImageTap,
                  child: const Text('Legg til bilde'),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _onPickImageTap() async {
    List<XFile> pickedFiles = [];
    try {
      pickedFiles = await ImagePicker().pickMultipleMedia();
    } catch (e) {
      print(e);
    }

    final List<GoodieAsset> pickedAssets = [];

    if (pickedFiles.isNotEmpty) {
      isLoadingPickAsset.value = true;

      _selectedAssetNotifier.value = null;

      for (var file in pickedFiles) {
        GoodieAsset? asset;

        asset = _recentImages.firstWhereOrNull((element) =>
            element.asset.title != null && element.asset.title == file.name);

        bool isRecent = asset != null;

        if (asset == null) {
          asset = await xFileToAssetEntity(file);
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
        isLoadingPickAsset.value = false;
      }
    }
  }
}
