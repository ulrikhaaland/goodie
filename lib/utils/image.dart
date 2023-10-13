import 'dart:io';
import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:goodie/bloc/create_review_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

import '../model/restaurant.dart';

class MediaItem {
  final int index;
  final String url;
  final MediaType type;
  VideoPlayerController? videoPlayerController;
  final Reference? ref;

  MediaItem({
    required this.index,
    required this.url,
    required this.type,
    this.ref,
  });
}

enum MediaType { Image, Video }

// ignore: must_be_immutable
class GoodieAsset extends AssetEntity {
  AssetEntity asset;
  double? scale;
  Offset? offset;
  File? imageFile;
  Restaurant? restaurant;
  VideoPlayerController? videoPlayerController;

  GoodieAsset({
    required this.asset,
    this.imageFile,
    this.videoPlayerController,
  }) : super(
          id: asset.id,
          typeInt: asset.typeInt,
          width: asset.width,
          height: asset.height,
          duration: asset.duration,
        );
}

Future<String> uploadAssetToFirebaseStorage(File assetFile, String path) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child(path);
  UploadTask uploadTask = ref.putFile(assetFile);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}

bool isValidUrl(String url) {
  final Uri? uri = Uri.tryParse(url);
  return uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty;
}

Future<List<GoodieAsset>> loadRecentImages() async {
  List<GoodieAsset> recentImages = [];
  try {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final value = await recentPath.getAssetListRange(start: 0, end: 100);
    recentImages = value
        .map((e) => GoodieAsset(
              asset: e,
            ))
        .toList();

    final videos =
        recentImages.where((media) => media.asset.type == AssetType.video);

    for (final vid in videos) {
      final videoFile = await vid.originFile;
      vid.videoPlayerController = VideoPlayerController.file(videoFile!);
      await vid.videoPlayerController!.initialize();
    }
  } catch (e) {
    print("Error loading recent images: $e");
  }
  return recentImages;
}

Future<List<GoodieAsset>> refreshRecentImages(
    List<GoodieAsset> existingImages) async {
  List<GoodieAsset> updatedImages = [];
  try {
    final List<AssetPathEntity> paths =
        await PhotoManager.getAssetPathList(onlyAll: true);
    final AssetPathEntity recentPath = paths.first;
    final List<GoodieAsset> newRecentImages = await recentPath
        .getAssetListRange(start: 0, end: 100)
        .then((value) => value.map((e) => GoodieAsset(asset: e)).toList());

    final Set<String> existingIds =
        existingImages.map((e) => e.asset.id).toSet();
    final List<GoodieAsset> trulyNewImages = newRecentImages
        .where((e) => !existingIds.contains(e.asset.id))
        .toList();

    final trulyNewVideos =
        trulyNewImages.where((media) => media.asset.type == AssetType.video);

    for (final vid in trulyNewVideos) {
      final videoFile = await vid.originFile;
      vid.videoPlayerController = VideoPlayerController.file(videoFile!);
      await vid.videoPlayerController!.initialize();
    }

    if (trulyNewImages.isNotEmpty) {
      updatedImages = [...trulyNewImages, ...existingImages];
    } else {
      updatedImages = existingImages;
    }
  } catch (e) {
    print("Error refreshing recent images: $e");
  }
  return updatedImages;
}
